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

      def self.command(line)
        new(line)
      end
    end

    class Channel < Base
      def initialize(line)
        @operation = Application::Operation::SetChannel
        @args = line.split[1].to_i
      end

      def self.name
        'channel'
      end

      def self.definition
        'channel <channel>'
      end

      def self.syntax_error(line)
        line !~ /^channel\s+[0-9]{1,2}\s*/
      end
    end

    class Read < Base
      def initialize(line)
        @operation = Application::Operation::ReadSong
        @args = line.split[1]
      end

      def self.name
        'read'
      end

      def self.definition
        'read <filename>'
      end

      def self.syntax_error(line)
        line !~ /^read\s+.*\s*/
      end
    end

    COMMANDS = [
      Channel,
      Read,
    ]

  end
end
