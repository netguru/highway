#
# hockeyapp.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class HockeyAppStep < Step

        def self.name
          "hockeyapp"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "api_token",
              required: true,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "app_id",
              required: true,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "notify",
              required: false,
              type: Types::Bool.new(),
              default: false,
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          api_token = parameters["api_token"]
          app_id = parameters["app_id"]
          notify = parameters["notify"] ? "1" : "0"

          context.run_action("hockey", options: {
            api_token: api_token,
            public_identifier: app_id,
            notify: notify,
            build_server_url: context.env.ci_build_url,
            commit_sha: context.env.git_commit_hash,
            repository_url: context.env.git_repo_url,
          })

          response = context.fastlane_lane_context[:HOCKEY_BUILD_INFORMATION]

          report[:deployment] = {

            service: "HockeyApp",

            package: {
              name: response["title"],
              version: response["shortversion"],
              build: response["version"],
            },

            urls: {
              install: File.join(response["public_url"], "app_versions", response["id"].to_s),
              view: response["config_url"],
            },

          }

        end

      end

    end
  end
end
