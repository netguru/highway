#
# context_mock.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"
require "spec/helpers/environment_mock"

module HighwaySpec
    module Helpers
        class ContextMock < Highway::Runtime::Context

            attr_accessor :run_action_name
            attr_accessor :run_action_options
            attr_accessor :run_sh_command

            attr_accessor :fastlane_lane_context

            def initialize()
                @env = HighwaySpec::Helpers::EnvironmentMock.new({})
            end

            def run_action(name, options:)
                @run_action_name = name
                @run_action_options = options
            end

            def assert_gem_available!(name)
            end

            def run_sh(command, bundle_exec: false, silent: false, on_error: nil)
                command = ["bundle exec", command].flatten if bundle_exec && should_use_bundle_exec?
                @run_sh_command = command
            end
        end
    end
end