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
                name: "api_token",
                required: true,
                type: Types::String.new(),
              ),
              Parameters::Single.new(
                name: "owner_name",
                required: true,
                type: Types::String.new(),
              ),
              Parameters::Single.new(
                name: "app_name",
                required: true,
                type: Types::String.new(),
              ),
              Parameters::Single.new(
                name: "notify",
                required: false,
                type: Types::Bool.new(),
                default: false,
              )
            ]
          end
  
          def self.run(parameters:, context:, report:)
  
            api_token = parameters["api_token"]
            owner_name = parameters["owner_name"]
            app_name = parameters["app_name"]
            notify = parameters["notify"]

            context.assert_gem_available!(plugin_name)
  
            context.run_action("appcenter_upload", options: {
              api_token: api_token,
              owner_name: owner_name,
              app_name: app_name,
              notify_testers: notify
            })
  
            response = context.fastlane_lane_context[:APPCENTER_BUILD_INFORMATION]
  
            report[:deployment] = {
  
              service: "AppCenter",
  
              package: {
                name: response["app_display_name"],
                version: response["short_version"],
                build: response["version"],
              },
  
              urls: {
                install: respone["install_url"],
                view: response["download_url"],
              },
  
            }
  
          end
  
        end
  
      end
    end
  end