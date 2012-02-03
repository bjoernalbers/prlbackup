# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "prlbackup/version"

Gem::Specification.new do |s|
  s.name        = "prlbackup"
  s.version     = Prlbackup::VERSION
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
end
