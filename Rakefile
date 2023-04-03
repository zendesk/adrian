#!/usr/bin/env rake
require 'bundler/gem_tasks'

require 'rake/testtask'

Rake::TestTask.new(:test) do |test|
  test.libs   << 'lib'
  test.libs   << 'test'
  test.pattern = 'test/**/*_test.rb'
  test.verbose = true
  test.warning = false
end

task :default => [:test]
