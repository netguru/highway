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
                name: "apple_id",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "app_specific_password",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "password",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "session",
                required: false,
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
              ),
              Parameters::Single.new(
                name: "team_name",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "username",
                required: true,
                type: Types::String.regex(/^\S+@\S+\.\S+$/)
              )
            ]
          end

          def self.run(parameters:, context:, report:)

            password = parameters["password"]
            app_specific_password = parameters["app_specific_password"]
            session = parameters["session"]

            if password.nil? && app_specific_password.nil?
              context.interface.fatal!("You need to provide an account password or application specific password! Additionally if you have enabled two-step verification, you will need to provide generated session.")
            end

            username = parameters["username"]
            apple_id = parameters["apple_id"]
            team_name = parameters["team_name"]
            skip_submission = parameters["skip_submission"]
            skip_waiting_for_build_processing = parameters["skip_waiting_for_build_processing"]

            env = {
              "FASTLANE_APPLE_APPLICATION_SPECIFIC_PASSWORD" => app_specific_password,
              "FASTLANE_PASSWORD" => password,
              "FASTLANE_SESSION" => session
            }

            context.with_modified_env(env) {
              context.run_action("upload_to_testflight", options: {
                username: username,
                skip_submission: skip_submission,
                skip_waiting_for_build_processing: skip_waiting_for_build_processing,
                apple_id: apple_id,
                team_name: team_name
              })
            }
  
          end

        end

      end
    end
end
