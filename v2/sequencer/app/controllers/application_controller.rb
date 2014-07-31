require 'fileutils'
require 'yaml'

class ApplicationController

  Operation = enum [
    :Command,
    :ZoomIn,
    :ZoomOut,
    :ZoomReset,
    :SwitchTrack,
  ]

  class KeyOperation
    Type = enum [
      :Application,
      :Controller,
    ]

    attr_accessor :type
    attr_accessor :code
    attr_accessor :args
    def initialize(type, code, *args)
      @type = type
      @code = code
      @args = args
    end
  end

  def initialize(*args)
    @app = Application.new
    @app.add_observer(self)

    @screen = Screen.new
    @piano_roll_view = PianoRollView.new(@app, @screen, y: 0, height: @screen.height - 2)
    @status_view = StatusView.new(@app, @screen, y: @screen.height - 2, height: 1)
    @command_view = CommandView.new(@app, @screen, y: @screen.height - 1, height: 1)

    @exit = false

    init_config
    build_keymap
  end

  def init_config
    FileUtils.mkdir_p($work_dir, mode: 0755) unless Dir.exists? $work_dir

    ["key_mapping.yml", "directory.yml"].each do |file|
      FileUtils.copy("#{$root_dir}/config/#{file}", "#{$work_dir}/#{file}") unless File.exists? "#{$work_dir}/#{file}"
    end
  end

  def build_keymap
    @keymap = {}
    config = YAML.load_file("#{$work_dir}/key_mapping.yml")
    config.each do |k,v|
      key = k =~ /^KEY_/ ? Key.const_get(k) : k
      case KeyOperation::Type.const_get(v[0])
      when KeyOperation::Type::Application
        @keymap[key] = KeyOperation.new(KeyOperation::Type::Application, Application::Operation.const_get(v[1]), v[2])
      when KeyOperation::Type::Controller
        @keymap[key] = KeyOperation.new(KeyOperation::Type::Controller, ApplicationController::Operation.const_get(v[1]), v[2])
      end
    end
  end

  def running
    !@exit
  end

  def run
    while running do
      @screen.render
      handle_key_input(@screen.getch)
    end

    self
  end

  def handle_key_input(key)
    Log.debug(Key.name(key))

    operation = @keymap[key]
    return unless operation

    case operation.type
    when KeyOperation::Type::Application
      @app.execute(operation.code, operation.args[0])
    when KeyOperation::Type::Controller
      case operation.code
      when Operation::ZoomIn
        @piano_roll_view.zoom_in
      when Operation::ZoomOut
        @piano_roll_view.zoom_out
      when Operation::ZoomReset
        @piano_roll_view.zoom_reset
      when Operation::SwitchTrack
        channel = @piano_roll_view.switch_track
        @app.execute(Application::Operation::SetChannel, channel)
      when Operation::Command
        command = @command_view.input_command
        if command
          @app.execute(command.operation, command.args)
        end
      end
    end
  end

  def update(app, type, event, *args)
    case type
    when Application::Event::Type::App
      case event
      when Application::Event::Quit
        @exit = true
      end
    end
  end

  def destroy
    @screen.destroy
  end
end
