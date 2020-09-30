#
# appcenter.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/steps/infrastructure"

module Highway
    module Steps
      module Library

        class AppCenterStep < Step

          def self.name
            "appcenter"
          end

          def self.plugin_name
            "fastlane-plugin-appcenter"
          end

          def self.parameters
            [
              Parameters::Single.new(
                name: "app_name",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "api_token",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "distribution_group",
                required: false,
                type: Types::String.new(),
                default: "*"
              ),
              Parameters::Single.new(
                name: "dsym",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "notify",
                required: false,
                type: Types::Bool.new(),
                default: false
              ),
              Parameters::Single.new(
                name: "owner_name",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "upload_dsym_only",
                required: false,
                type: Types::Bool.new(),
                default: false
              ),
              Parameters::Single.new(
                name: "release_notes",
                required: false,
                type: Types::String.new(),
                default: ""
              )
            ]
          end

          def self.run(parameters:, context:, report:)

            app_name = parameters["app_name"]
            api_token = parameters["api_token"]
            destinations = parameters["distribution_group"]
            dsym = parameters["dsym"]
            notify = parameters["notify"]
            owner_name = parameters["owner_name"]
            upload_dsym_only = parameters["upload_dsym_only"]
            release_notes = parameters["release_notes"]

            context.assert_gem_available!(plugin_name)

            context.run_action("appcenter_upload", options: {
              api_token: api_token,
              owner_name: owner_name,
              app_name: app_name,
              destinations: destinations,
              notify_testers: notify,
              dsym: dsym,
              upload_dsym_only: upload_dsym_only,
              release_notes: release_notes
            })

            response = context.fastlane_lane_context[:APPCENTER_BUILD_INFORMATION]

            unless response.nil?
              report[:deployment] = {

                service: "AppCenter",

                package: {
                  name: response["app_display_name"],
                  version: response["short_version"],
                  build: response["version"],
                },

                urls: {
                  install: response["install_url"],
                  view: response["download_url"],
                },

              }
            end

          end

        end

      end
    end
  end
