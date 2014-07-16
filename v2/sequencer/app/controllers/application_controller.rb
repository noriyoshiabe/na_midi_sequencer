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
    build_keymap
  end

  def build_keymap
    @keymap = {}
    config = YAML.load_file("#{$root_dir}/config/key_mapping.yml")
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

  def execute_command(line)
    return unless line

    tokens = line.split
    return if tokens.empty?
    case tokens[0]
    when 'tempo'
      index = tokens[1].to_i
      tempo = tokens[2].to_f
      @app.editor.set_tempo(index, tempo)
    when 'beat'
      index = tokens[1].to_i
      beat = tokens[2].split('/')
      @app.editor.set_beat(index, beat[0].to_i, beat[1].to_i)
    when 'cp'
      from = tokens[1].to_i
      to = tokens[2].to_i
      length = tokens[3].to_i
      channel = tokens[4] ? tokens[4].to_i : nil
      channel_to = tokens[5] ? tokens[5].to_i : nil
      @app.editor.copy(from, to, length, channel, channel_to)
    when 'mv'
      from = tokens[1].to_i
      to = tokens[2].to_i
      length = tokens[3].to_i
      channel = tokens[4] ? tokens[4].to_i : nil
      channel_to = tokens[5] ? tokens[5].to_i : nil
      @app.editor.move(from, to, length, channel, channel_to)
    when 'erase'
      from = tokens[1].to_i
      length = tokens[2].to_i
      channel = tokens[3] ? tokens[3].to_i : nil
      @app.editor.erase(from, length, channel)
    when 'delete'
      from = tokens[1].to_i
      length = tokens[2].to_i
      @app.editor.delete(from, length)
    when 'insert'
      from = tokens[1].to_i
      length = tokens[2].to_i
      @app.editor.insert(from, length)
    when 'read'
      @app.read_song(tokens[1])
    when 'write'
      @app.write_song(tokens[1])
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
