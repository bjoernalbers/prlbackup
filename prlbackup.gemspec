# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prlbackup/version"

Gem::Specification.new do |s|
  s.name        = "prlbackup"
  s.version     = PrlBackup::VERSION
  s.authors     = ["Björn Albers"]
  s.email       = ["bjoernalbers@googlemail.com"]
  s.homepage    = "https://github.com/bjoernalbers/#{s.name}"
  s.summary     = "An awesome command-line app to backup Virtual Machines from Parallels Server."
  s.description = %q{prlbackup simplifies the backup of one or multiple Virtual Machines running
on Parallels Server by stoping VMs during backup and deleting old backups on demand.
A working installation of Parallels Server is required.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'mixlib-cli', '>= 1.2.0'

  s.add_development_dependency 'cucumber', '>= 1.1.4'
  s.add_development_dependency 'aruba', '>= 0.4.11'
  s.add_development_dependency 'aruba-doubles', '>= 0.3.0a'
  s.add_development_dependency 'guard-cucumber', '>= 0.7.5'
  s.add_development_dependency 'guard-rspec', '>= 0.5.1'
  s.add_development_dependency 'rb-fsevent', '>= 0.9.0' if RUBY_PLATFORM =~ /darwin/i
end
