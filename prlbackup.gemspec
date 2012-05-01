# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prlbackup/version"

Gem::Specification.new do |s|
  s.name        = 'prlbackup'
  s.version     = PrlBackup::VERSION
  s.authors     = ['Björn Albers']
  s.email       = ['bjoernalbers@googlemail.com']
  s.homepage    = "https://github.com/bjoernalbers/#{s.name}"
  s.summary     = 'an awesome backup tool for Parallels Server Virtual Machines'
  s.description = %q{prlbackup simplifies the backup of one or multiple Virtual Machines
(VM) running on Parallels Server by stoping them during backup and
deleting old backups on demand.}
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'mixlib-cli', '>= 1.2.0'

  s.add_development_dependency 'cucumber', '>= 1.1.4'
  s.add_development_dependency 'aruba', '>= 0.4.11'
  s.add_development_dependency 'aruba-doubles', '~> 1.2.1'
  s.add_development_dependency 'guard-cucumber', '>= 0.7.5'
  s.add_development_dependency 'guard-rspec', '>= 0.5.1'
  s.add_development_dependency 'guard-ronn', '>= 0.1.2'
  s.add_development_dependency 'ronn', '>= 0.7.3'
  s.add_development_dependency 'rake'
  s.add_development_dependency 'rb-fsevent', '>= 0.9.0' if RUBY_PLATFORM =~ /darwin/i
end
