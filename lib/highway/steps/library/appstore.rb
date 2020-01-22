#
# appstore.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/steps/infrastructure"

module Highway
    module Steps
      module Library

        class AppStoreStep < Step

          def self.name
            "appstore"
          end

          def self.parameters
            [
              Parameters::Single.new(
                name: "app_identifier",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "build_number",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "force",
                required: false,
                default: true,
                type: Types::Bool.new()
              ),
              Parameters::Single.new(
                name: "metadata_path",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "password",
                required: true,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "session",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "screenshots_path",
                required: false,
                type: Types::String.new()
              ),
              Parameters::Single.new(
                name: "skip_app_version_update",
                required: false,
                default: false,
                type: Types::Bool.new()
              ),
              Parameters::Single.new(
                name: "skip_binary_upload",
                required: false,
                default: false,
                type: Types::Bool.new()
              ),
              Parameters::Single.new(
                name: "submit_for_review",
                required: false,
                default: false,
                type: Types::Bool.new()
              ),
              Parameters::Single.new(
                name: "team_id",
                required: false,
                type: Types::String.new()
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

            username = parameters["username"]
            password = parameters["password"]
            session = parameters["session"]
            app_identifier = parameters["app_identifier"]
            metadata_path = parameters["metadata_path"]
            screenshots_path = parameters["screenshots_path"]
            skip_app_version_update = parameters["skip_app_version_update"]
            submit_for_review = parameters["submit_for_review"]
            team_id = parameters["team_id"]
            team_name = parameters["team_name"]
            skip_binary_upload = parameters["skip_binary_upload"]
            force = parameters["force"]
            build_number = parameters["build_number"]

            env = {
              "FASTLANE_PASSWORD" => password,
              "FASTLANE_SESSION" => session
            }

            context.with_modified_env(env) {
              context.run_action("upload_to_app_store", options: {
                username: username,
                app_identifier: app_identifier,
                metadata_path: metadata_path,
                screenshots_path: screenshots_path,
                skip_app_version_update: skip_app_version_update,
                submit_for_review: submit_for_review,
                team_id: team_id,
                skip_binary_upload: skip_binary_upload,
                build_number: build_number,
                team_name: team_name,
                force: force
              })
            }
  
          end

        end

      end
    end
end
