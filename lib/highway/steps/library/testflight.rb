#
# testflight.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/steps/infrastructure"

module Highway
    module Steps
      module Library

        class TestFlightStep < Step

          def self.name
            "testflight"
          end

          def self.parameters
            [
              Parameters::Single.new(
                name: "username",
                required: true,
                type: Types::String.regex(/^\S+@\S+\.\S+$/)
              ),
              Parameters::Single.new(
                name: "app_specific_password",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "apple_id",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "skip_submission",
                required: false,
                default: true,
                type: Types::Bool.new()
              ),
              Parameters::Single.new(
                name: "skip_waiting_for_build_processing",
                required: false,
                default: true,
                type: Types::Bool.new()
              )
            ]
          end

          def self.run(parameters:, context:, report:)

            username = parameters["username"]
            app_specific_password = parameters["app_specific_password"]
            apple_id = parameters["apple_id"]
            skip_submission = parameters["skip_submission"]
            skip_waiting_for_build_processing = parameters["skip_waiting_for_build_processing"]

            env = {
              "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password
            }

            context.with_modified_env(env) {
              context.run_action("upload_to_testflight", options: {
                username: username,
                skip_submission: skip_submission,
                skip_waiting_for_build_processing: skip_waiting_for_build_processing,
                apple_id: apple_id
              })
            }
  
          end

        end

      end
    end
end
