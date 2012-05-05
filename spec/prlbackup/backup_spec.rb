require 'spec_helper'

module PrlBackup
  describe Backup do
    before do
      @uuid = '{deadbeef}'
      Backup.stub(:run).and_return('')
      Backup.stub(:conditionally_run).and_return('')
    end

    describe '.all' do
      it 'should query the backup list by UUID' do
        Backup.should_receive(:backup_list).with(@uuid).and_return('')
        Backup.all(@uuid)
      end

      it 'should initialize backups by line' do
        Backup.stub(:backup_list).and_return("line 1\nline 2")
        Backup.should_receive(:create).with('line 1')
        Backup.should_receive(:create).with('line 2')
        Backup.all(@uuid)
      end

      it 'should only return successfully initialized backups' do
        Backup.stub(:backup_list).and_return("line 1\nline 2\nline 3")
        Backup.stub(:create).and_return(nil, 'backup', nil)
        Backup.all(@uuid).should eql(['backup'])
      end
    end

    describe '.backup_list' do
      it 'should query and return the backup list by UUID' do
        Backup.should_receive(:run).with('prlctl', 'backup-list', @uuid).and_return('backup list')
        Backup.backup_list(@uuid).should eql('backup list')
      end
    end

    describe '.create' do
      it 'should initialize a backup with properties' do
        line = '{deadbeef} {ae6565dd-7f8f-42cb-a088-8b1d98f5160b} psfm.example.com 02/27/2012 13:11:32     f 10537597943'
        backup = Backup.create(line)
        backup.properties[:uuid].should eql('{ae6565dd-7f8f-42cb-a088-8b1d98f5160b}')
        backup.properties[:time].should eql('02/27/2012 13:11:32')
        backup.properties[:type].should eql('f')
      end

      it 'should return nil when the backup line is not parsable' do
        Backup.create('hello, world.').should be_nil
      end
    end

    describe '#uuid' do
      it 'should return the backup uuid' do
        backup = Backup.new(:uuid => '{ae6565dd-7f8f-42cb-a088-8b1d98f5160b}')
        backup.uuid.should eql('{ae6565dd-7f8f-42cb-a088-8b1d98f5160b}')
      end
    end

    describe '#time' do
      it 'should return the time object' do
        backup = Backup.new(:time => '02/27/2012 13:11:32')
        backup.time.year.should eql(2012)
        backup.time.month.should eql(2)
        backup.time.day.should eql(27)
        backup.time.hour.should eql(13)
        backup.time.min.should eql(11)
        backup.time.sec.should eql(32)
      end
    end

    describe '#full?' do
      it 'should be true when full' do
        backup = Backup.new(:type => 'f')
        backup.should be_full
      end

      it 'should be false when incremental' do
        backup = Backup.new(:type => 'i')
        backup.should_not be_full
      end
    end

    describe '#delete' do
      it 'should delete itself' do
        backup = Backup.new(:uuid => '{some-backup-uuid}')
        backup.should_receive(:conditionally_run).with('prlctl', 'backup-delete', '--tag', '{some-backup-uuid}')
        backup.delete
      end
    end
  end
end
