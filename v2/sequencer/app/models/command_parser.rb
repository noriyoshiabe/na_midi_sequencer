class CommandParser

  def candidates(line)
    Command::COMMANDS.select do |c|
      0 < line.split.size && c.name.index(/^#{line.split[0]}/)
    end
  end

  module Command
    class Base
      attr_reader :operation
      attr_reader :args

      def self.name
      end
      def self.definition
      end
      def self.syntax_error(line)
      end
      def self.file_list(*args)
      end

      def self.command(line)
        new(line)
      end
    end

    class Channel < Base
      def initialize(line)
        @operation = Application::Operation::Channel
        @args = line.split[1].to_i
      end

      def self.name
        'channel'
      end

      def self.definition
        'channel <channel>'
      end

      def self.syntax_error(line)
        line !~ /^channel\s+[0-9]{1,2}\s*$/
      end
    end

    class Velocity < Base
      def initialize(line)
        @operation = Application::Operation::Velocity
        @args = line.split[1].to_i
      end

      def self.name
        'velocity'
      end

      def self.definition
        'velocity <velocity>'
      end

      def self.syntax_error(line)
        line !~ /^velocity\s+[0-9]{1,3}\s*$/
      end
    end

    class Tempo < Base
      def initialize(line)
        @operation = Application::Operation::Tempo
        @args = [line.split[1].to_i, line.split[2].to_f]
      end

      def self.name
        'tempo'
      end

      def self.definition
        'tempo <measure> <tempo>'
      end

      def self.syntax_error(line)
        line !~ /^tempo\s+[0-9]{1,3}\s+[0-9]{1,3}(\.[0-9]{0,2})?\s*$/
      end
    end

    class Beat < Base
      def initialize(line)
        @operation = Application::Operation::Beat
        tokens = line.split
        index = tokens[1].to_i
        beat = tokens[2].split('/')
        @args = [index, beat[0].to_i, beat[1].to_i]
      end

      def self.name
        'beat'
      end

      def self.definition
        'beat <measure> <N/N>'
      end

      def self.syntax_error(line)
        line !~ /^beat\s+[0-9]{1,3}\s+[0-9]{1,2}\/[0-9]{1,2}\s*$/
      end
    end

    class FileCommand < Base
      def self.file_list(filename)
        dirpath = File.expand_path(SMF.directory)
        Dir["#{dirpath}/*"].select do |f|
          File.file? f
        end.map do |name|
          name.sub("#{dirpath}/", "")
        end.select do |name|
          name.index(/^#{filename}/)
        end
      end
    end

    class Read < FileCommand
      def initialize(line)
        @operation = Application::Operation::Read
        @args = line.split[1]
      end

      def self.name
        'read'
      end

      def self.definition
        'read <filename>'
      end

      def self.syntax_error(line)
        line !~ /^read\s+.*\s*$/
      end
    end

    class Write < FileCommand
      def initialize(line)
        @operation = Application::Operation::Write
        @args = line.split[1]
      end

      def self.name
        'write'
      end

      def self.definition
        'write <filename>'
      end

      def self.syntax_error(line)
        line !~ /^write\s+.*\s*$/
      end
    end

    COMMANDS = [
      Channel,
      Velocity,
      Tempo,
      Beat,
      Read,
      Write,
    ]

  end
end
