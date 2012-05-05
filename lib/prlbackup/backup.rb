module PrlBackup
  class Backup
    class << self

      include PrlBackup

      def all(uuid)
        backup_list(uuid).split("\n").map { |b| create(b) }.compact
      end

      def backup_list(uuid)
        run('prlctl', 'backup-list', uuid)
      end

      def create(line)
        re = /^
          (\{[0-9a-f-]+\})        # VM UUID
          \s+
          (\{[0-9a-f-]+\}[\.\d]*) # Backup UUID
          \s+
          (\S+)                   # Node
          \s+
          ([\d\/]+\s[\d:]+)       # Time
          \s+
          ([fi])                  # Type
          \s+
          (\d+)                   # Size
        $/x
        new(:uuid => $2, :time => $4, :type => $5) if re.match(line)
      end
    end

    include PrlBackup

    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end

    def uuid
      properties[:uuid]
    end

    def time
      DateTime.parse(properties[:time])
    end

    def full?
      properties[:type] == 'f'
    end

    def delete
      conditionally_run('prlctl', 'backup-delete', '--tag', uuid)
    end
  end
end
