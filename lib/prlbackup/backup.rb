module PrlBackup
  class Backup
    class << self

      include PrlBackup

      def all(uuid)
        backup_list(uuid).split("\n").map { |b| create(b) }.compact.sort
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

      def to_s
        'Backup'
      end
    end

    include PrlBackup
    include Comparable

    attr_reader :properties

    def initialize(properties)
      @properties = properties
    end

    def uuid
      properties[:uuid]
    end

    def time
      DateTime.strptime(properties[:time], '%m/%d/%Y %H:%M:%S')
    end

    def full?
      properties[:type] == 'f'
    end

    def delete
      conditionally_run('prlctl', 'backup-delete', '--tag', uuid)
    end

    def <=>(other)
      time <=> other.time
    end

    # Display time of backup.
    def to_s
      "#{self.class.to_s}: #{time.strftime('%Y-%m-%d %H:%M:%S')}"
    rescue ArgumentError
      "#{self.class.to_s}: Unknown"
    end
  end
end
