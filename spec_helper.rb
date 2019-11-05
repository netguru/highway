#
# spec_helper.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require 'simplecov'

SimpleCov.start do
    add_group "Steps", "lib/highway/steps"
    add_group "Steps library", "lib/highway/steps/library"
    add_group "Parameters", "lib/highway/steps/parameters"
    add_group "Types", "lib/highway/steps/types"
    add_group "Runtime", "lib/highway/runtime"
    add_group "Compiler", "lib/highway/compiler"
    add_group "Long files" do |src_file|
      src_file.lines.count > 250
    end
    add_filter "spec"
  end