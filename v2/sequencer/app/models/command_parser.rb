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

    class Copy < Base
      def initialize(line)
        @operation = Application::Operation::Copy
        tokens = line.split
        from = tokens[1].to_i
        length = tokens[2].to_i
        to = tokens[3].to_i
        channel = tokens[4] ? tokens[4].to_i : nil
        channel_to = tokens[5] ? tokens[5].to_i : nil
        @args = [from, length, to, channel, channel_to]
      end

      def self.name
        'copy'
      end

      def self.definition
        'copy <from> <length> <to> [<channel>] [<channel_to>]'
      end

      def self.syntax_error(line)
        line !~ /^copy\s+[0-9]{1,3}\s+[0-9]{1,3}\s+[0-9]{1,3}(\s+[0-9]{1,2}){0,2}\s*$/
      end
    end

    class Move < Base
      def initialize(line)
        @operation = Application::Operation::Move
        tokens = line.split
        from = tokens[1].to_i
        length = tokens[2].to_i
        to = tokens[3].to_i
        channel = tokens[4] ? tokens[4].to_i : nil
        channel_to = tokens[5] ? tokens[5].to_i : nil
        @args = [from, length, to, channel, channel_to]
      end

      def self.name
        'move'
      end

      def self.definition
        'move <from> <length> <to> [<channel>] [<channel_to>]'
      end

      def self.syntax_error(line)
        line !~ /^move\s+[0-9]{1,3}\s+[0-9]{1,3}\s+[0-9]{1,3}(\s+[0-9]{1,2}){0,2}\s*$/
      end
    end

    class Erase < Base
      def initialize(line)
        @operation = Application::Operation::Erase
        tokens = line.split
        from = tokens[1].to_i
        length = tokens[2].to_i
        channel = tokens[3] ? tokens[3].to_i : nil
        @args = [from, length, channel]
      end

      def self.name
        'erase'
      end

      def self.definition
        'erase <from> <length> [<channel>]'
      end

      def self.syntax_error(line)
        line !~ /^erase\s+[0-9]{1,3}\s+[0-9]{1,3}(\s+[0-9]{1,2})?\s*$/
      end
    end

    class Delete < Base
      def initialize(line)
        @operation = Application::Operation::Delete
        tokens = line.split
        from = tokens[1].to_i
        length = tokens[2].to_i
        @args = [from, length]
      end

      def self.name
        'delete'
      end

      def self.definition
        'delete <from> <length>'
      end

      def self.syntax_error(line)
        line !~ /^delete\s+[0-9]{1,3}\s+[0-9]{1,3}\s*$/
      end
    end

    class Insert < Base
      def initialize(line)
        @operation = Application::Operation::Insert
        tokens = line.split
        from = tokens[1].to_i
        length = tokens[2].to_i
        @args = [from, length]
      end

      def self.name
        'insert'
      end

      def self.definition
        'insert <from> <length>'
      end

      def self.syntax_error(line)
        line !~ /^insert\s+[0-9]{1,3}\s+[0-9]{1,3}\s*$/
      end
    end

    class FileCommand < Base
      def self.file_list(filename)
        dirpath = File.expand_path(SMF.directory)
        Dir["#{dirpath}/**/*"].select do |f|
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

    class Quit < Base
      def initialize(line)
        @operation = Application::Operation::Quit
      end

      def self.name
        'quit'
      end

      def self.definition
        'quit'
      end

      def self.syntax_error(line)
        line !~ /^quit\s*$/
      end
    end

    COMMANDS = [
      Channel,
      Velocity,
      Tempo,
      Beat,
      Copy,
      Move,
      Erase,
      Delete,
      Insert,
      Read,
      Write,
      Quit,
    ]

  end
end
