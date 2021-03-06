#
# cocoapods.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class CocoaPodsStep < Step

        def self.name
          "cocoapods"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "command",
              required: false,
              type: Types::Enum.new("install", "update"),
              default: "install",
            ),
            Parameters::Single.new(
              name: "update_specs_repo",
              required: false,
              type: Types::Enum.new("always", "never", "on-error"),
              default: "never",
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          context.assert_gem_available!("cocoapods")

          command = parameters["command"]
          update_specs_repo = parameters["update_specs_repo"]

          repo_update_always = update_specs_repo == "always"
          repo_update_on_error = update_specs_repo == "on-error"

          if command == "install"

            context.run_action("cocoapods", options: {
              repo_update: repo_update_always,
              try_repo_update_on_error: repo_update_on_error,
              use_bundle_exec: context.should_use_bundle_exec?,
            })

          elsif command == "update"

            invocation = []
            invocation << "bundle exec" if context.should_use_bundle_exec?
            invocation << "pod update"
            invocation << "--repo-update" if repo_update_always

            context.run_sh(invocation.join(" "), on_error: lambda { |error|
              if repo_update_on_error
                context.run_sh((invocation + ["--repo-update"]).join(" "))
              else
                context.reporter.fatal!(error)
              end
            })

          end

        end

      end

    end
  end
end
