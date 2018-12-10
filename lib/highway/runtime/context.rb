#
# context.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

module Highway
  module Runtime

    # This class is responsible for maintaining runtime context between step
    # invocations, allowing steps to access runtimes of both Fastlane and
    # Highway.
    class Context

      public

      # Initialize an instance.
      #
      # @param fastlane_options [Hash] The Fastlane action options.
      # @param fastlane_runner [Fastlane::Runner] The Fastlane runner.
      # @param fastlane_lane_context [Hash] The Fastlane lane context.
      # @param reporter [Highway::Reporter] The reporter.
      def initialize(fastlane_options:, fastlane_runner:, fastlane_lane_context:, reporter:)
        @fastlane_options = fastlane_options
        @fastlane_runner = fastlane_runner
        @fastlane_lane_context = fastlane_lane_context
        @reporter = reporter
      end

      # The reporter instance.
      #
      # @return [Highway::Reporter]
      attr_reader :reporter

      # Run a Fastlane lane.
      #
      # @param name [String, Symbol] Name of the lane.
      # @param args [Hash] Options passed to the lane.
      def run_lane(name, args)

        unless contains_lane?(name)
          @reporter.fatal!("Can't execute lane '#{name}' because it doesn't exist.")
        end

        unless !contains_action?(name)
          @reporter.fatal!("Can't execute lane '#{name}' because an action with the same name exists.")
        end

        run_lane_or_action(name, args)

      end

      # Run a Fastlane action.
      #
      # @param name [String, Symbol] Name of the action.
      # @param args [Hash] Options passed to the action.
      def run_action(name, args)

        unless contains_action?(name)
          @reporter.fatal!("Can't execute action '#{name}' because it doesn't exist.'")
        end

        unless !contains_lane?(name)
          @reporter.fatal!("Can't execute action '#{name}' because a lane with the same name exists.")
        end

        run_lane_or_action(name, args)

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
        @fastlane_runner.trigger_action_by_name(name.to_sym, Dir.pwd, false, *[symbolicated_args])
      end

    end

  end
end
