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
      # @return [Array<FastlaneCore::ConfigItem>]
      def self.available_options
        [
          FastlaneCore::ConfigItem.new(
            key: :highwayfile,
            env_name: "HIGHWAY_HIGHWAYFILE",
            description: "Path to Highway configuration file",
            optional: false,
            type: String
          ),
          FastlaneCore::ConfigItem.new(
            key: :preset,
            env_name: "HIGHWAY_PRESET",
            description: "Highway preset to run",
            optional: false,
            type: String,
          ),
        ]
      end

      # Execute the `run_highway` action.
      #
      # This is the main entry point of Highway.
      #
      # @param options [Hash<String, Object>]
      def self.run(options)

        main = Highway::Main.new(
          fastlane_options: options,
          fastlane_runner: runner,
          fastlane_lane_context: lane_context,
          fastlane_ui: UI
        )

        main.run()

      end

    end

  end
end
