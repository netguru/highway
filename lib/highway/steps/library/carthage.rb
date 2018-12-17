#
# carthage.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      # A step for executing Carthage.
      class Carthage < Step

        def self.name
          "carthage"
        end

        def self.parameters
          [
            Parameter.new(
              name: "command",
              required: false,
              type: Types::Enum.new("bootstrap", "update"),
              default_value: "bootstrap"
            ),
            Parameter.new(
              name: "github_token",
              required: false,
              type: Types::String.new(),
            ),
            Parameter.new(
              name: "platforms",
              required: true,
              type: Types::Array.new(Types::Enum.new("iOS", "macOS", "tvOS", "watchOS")),
            ),
          ]
        end

        def self.run(parameters:, context:, artifact:)

          context.assert_executable_available!("carthage")

          command = parameters["command"]
          platform = parameters["platforms"].join(",").gsub(%r(macOS), "Mac")
          token = parameters["github_token"]

          env = {
            "GITHUB_ACCESS_TOKEN" => token
          }

          context.with_modified_env(env) {

            context.run_action("carthage", options: {
              cache_builds: true,
              command: command,
              platform: platform,
            })

          }

        end

      end

    end
  end
end
