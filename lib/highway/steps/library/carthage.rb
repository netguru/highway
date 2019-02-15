#
# carthage.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class CarthageStep < Step

        def self.name
          "carthage"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "command",
              required: false,
              type: Types::Enum.new("bootstrap", "update"),
              default: "bootstrap",
            ),
            Parameters::Single.new(
              name: "github_token",
              required: false,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "platforms",
              required: true,
              type: Types::Set.new(Types::Enum.new("macos", "ios", "tvos", "watchos")),
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          context.assert_executable_available!("carthage")

          command = parameters["command"]
          token = parameters["github_token"]

          platform_map = {macos: "Mac", ios: "iOS", tvos: "tvOS", watchos: "watchOS"}
          platform = parameters["platforms"].to_a.map { |p| platform_map[p.to_sym] }.join(",")

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
