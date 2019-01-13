#
# action.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"
require "highway"

module Fastlane
  module Actions

    # The `run_highway` action that can be used inside Fastline.
    class RunHighwayAction < Action

      # Available options of `run_highway` action.
      #
      # Use the same behavior of computing option values as in lane entry point.
      # First, get the actual values, then fall back to env variables, then fall
      # back to default values.
      #
      # @return [Array<FastlaneCore::ConfigItem>]
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :highwayfile,
            description: "Path to Highway configuration file",
            type: String,
            optional: false,
            env_name: "HIGHWAY_HIGHWAYFILE",
            default_value: "Highwayfile.yml",
          ),
          FastlaneCore::ConfigItem.new(
            key: :preset,
            description: "Highway preset to run",
            type: String,
            optional: false,
            env_name: "HIGHWAY_PRESET",
            default_value: "default",
          ),
        ]
      end

      # Execute the `run_highway` action.
      #
      # This is the main entry point of Highway.
      #
      # @param options [Hash<String, Object>]
      def self.run(options)

        # Run Highway from `:action` entry point.

        main = Highway::Main.new(
          entrypoint: :action,
          path: options[:highwayfile],
          preset: options[:preset],
          fastlane_runner: runner,
          fastlane_lane_context: lane_context,
        )

        main.run()

      end

    end

  end
end
