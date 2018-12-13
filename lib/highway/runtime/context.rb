#
# context.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/utilities"

module Highway
  module Runtime

    # This class is responsible for maintaining runtime context between step
    # invocations, allowing steps to access runtimes of both Fastlane and
    # Highway.
    class Context

      public

      # Initialize an instance.
      #
      # @param fastlane_runner [Fastlane::Runner] The Fastlane runner.
      # @param fastlane_lane_context [Hash] The Fastlane lane context.
      # @param reporter [Highway::Interface] The interface.
      def initialize(fastlane_runner:, fastlane_lane_context:, interface:)
        @fastlane_runner = fastlane_runner
        @fastlane_lane_context = fastlane_lane_context
        @interface = interface
      end

      # The interface.
      #
      # @return [Highway::Interface]
      attr_reader :interface

      # The Fastlane lane context.
      #
      # @return [Hash]
      attr_reader :fastlane_lane_context

      # Assert that a gem with specified name is available.
      #
      # @param name [String] Name of the gem.
      def assert_gem_available!(name)
        Fastlane::Actions.verify_gem!(name)
      end

      # Assert that an executable with specified name is available.
      #
      # @param name [String] Name of executable.
      def assert_executable_available!(name)
        unless FastlaneCore::CommandExecutor.which(name) != nil
          @interface.fatal!("Required executable '#{name}' could not be found. Make sure it's installed.")
        end
      end

      # Whether `bundle exec` is available and should be used if possible.
      #
      # @return [Boolean]
      def should_use_bundle_exec?()
        return File.exist?("Gemfile")
      end

      # Run a Fastlane lane.
      #
      # @param name [String, Symbol] Name of the lane.
      # @param options [Hash] Options passed to the lane.
      def run_lane(name, options:)

        unless contains_lane?(name)
          @interface.fatal!("Can't execute lane '#{name}' because it doesn't exist.")
        end

        unless !contains_action?(name)
          @interface.fatal!("Can't execute lane '#{name}' because an action with the same name exists.")
        end

        run_lane_or_action(name, options)

      end

      # Run a Fastlane action.
      #
      # @param name [String, Symbol] Name of the action.
      # @param options [Hash] Options passed to the action.
      def run_action(name, options:)

        unless contains_action?(name)
          @interface.fatal!("Can't execute action '#{name}' because it doesn't exist.'")
        end

        unless !contains_lane?(name)
          @interface.fatal!("Can't execute action '#{name}' because a lane with the same name exists.")
        end

        run_lane_or_action(name, options)

      end

      # Run a shell command.
      #
      # @param command [String] A shell command.
      # @param on_error [Proc] Called if command exits with a non-zero code.
      def run_sh(command, on_error: nil)
        Fastlane::FastFile.sh(command, error_callback: on_error)
      end

      # Execute the given block in the scope of overridden ENV variables. After
      # that, old values will be restored.
      #
      # @param new_env [Hash] ENV variables to override.
      # @param &block [Proc] A block to execute.
      def with_env(new_env, &block)

        old_env = Utilities::hash_map(new_env.keys) { |name|
          [name, ENV[name]]
        }

        new_env.each_pair { |name, value|
          ENV[name] = value
        }

        block.call()

        old_env.each_pair { |name, value|
          ENV[name] = value
        }

      end

      private

      def contains_lane?(lane_name)
        lane = @fastlane_runner.lanes.fetch(nil, {}).fetch(lane_name.to_sym, nil)
        lane != nil
      end

      def contains_action?(action_name)
        action = @fastlane_runner.class_reference_from_action_name(action_name.to_sym)
        action ||= @fastlane_runner.class_reference_from_action_alias(action_name.to_sym)
        action != nil
      end

      def run_lane_or_action(name, args)
        symbolicated_args = Utilities::hash_map(args || {}) { |key, value| [key.to_sym, value] }
        @fastlane_runner.trigger_action_by_name(name.to_sym, Dir.pwd, true, *[symbolicated_args])
      end

    end

  end
end
