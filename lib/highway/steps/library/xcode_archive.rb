#
# xcode_archive.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"
require "xcodeproj"

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class XcodeArchiveStep < Step

        def self.name
          "xcode-archive"
        end

        def self.parameters
          [
            Parameters::Single.new(
              name: "clean",
              required: false,
              type: Types::Bool.new(),
              default: true,
            ),
            Parameters::Single.new(
              name: "configuration",
              required: false,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "flags",
              required: false,
              type: Types::Array.new(Types::String.new()),
              default: [],
            ),
            Parameters::Single.new(
              name: "method",
              required: true,
              type: Types::Enum.new("ad-hoc", "app-store", "development", "developer-id", "enterprise", "package"),
            ),
            Parameters::Single.new(
              name: "project",
              required: true,
              type: Types::AnyOf.new(
                project: Types::String.regex(/.+\.xcodeproj/),
                workspace: Types::String.regex(/.+\.xcworkspace/),
              ),
            ),
            Parameters::Single.new(
              name: "scheme",
              required: true,
              type: Types::String.new(),
            ),
            Parameters::Single.new(
              name: "settings",
              required: false,
              type: Types::Hash.new(Types::String.new(), validate: lambda { |dict| dict.keys.all? { |key| /[A-Z_][A-Z0-9_]*/ =~ key } }),
              default: {},
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          # Interpret the parameters. At this point they are parsed and
          # transformed to be recognizable by Fastlane.

          clean = parameters["clean"]
          scheme = parameters["scheme"]
          method = parameters["method"]

          configuration = parameters["configuration"]
          configuration ||= detect_configuration(parameters)

          flags = parameters["flags"].join(" ")
          settings = parameters["settings"].map { |setting, value| "#{setting}=\"#{value.shellescape}\"" }.join(" ")

          xcargs = flags + settings
          xcargs = nil if xcargs.empty?

          project_key = parameters["project"][:tag]
          project_value = parameters["project"][:value]

          # Prepare artifacts. Create temporary directories, get file names that
          # will be later passed to the build command.

          output_raw_temp_dir = Dir.mktmpdir()
          output_raw_path = report.prepare_artifact("raw.log")

          output_ipa_path = report.prepare_artifact("archive.ipa")
          output_ipa_dir = File.dirname(output_ipa_path)
          output_ipa_file = File.basename(output_ipa_path)

          # Prepare temporary variables.

          report_archive = {}
          report_artifacts = {}
          rescued_error = nil

          # Run the build and archival.

          context.run_action("build_ios_app", options: {

            project_key => project_value,

            clean: clean,
            configuration: configuration,
            scheme: scheme,
            export_method: method,

            xcargs: xcargs,
            export_xcargs: xcargs,

            buildlog_path: output_raw_temp_dir,
            output_directory: output_ipa_dir,
            output_name: output_ipa_file,

          })

          # Save the archive and artifacts subreports in the report.

          report[:archive] = {
            result: :success
          }

          report[:artifacts] = {
            ipa: context.fastlane_lane_context[:IPA_OUTPUT_PATH],
            dsym: context.fastlane_lane_context[:DSYM_OUTPUT_PATH],
          }

        end

        private

        def self.detect_configuration(parameters)
          if parameters["project"][:tag] == :project
            detect_configuration_from_project(parameters["project"][:value], parameters["scheme"])
          elsif parameters["project"][:tag] == :workspace
            detect_configuration_from_workspace(parameters["project"][:value], parameters["scheme"])
          end
        end

        def self.detect_configuration_from_project(project_path, scheme_name)
          return nil unless File.exist?(project_path)
          project_schemes = Xcodeproj::Project.schemes(project_path)
          return nil unless project_schemes.include?(scheme_name)
          scheme_path = File.join(project_path, "xcshareddata", "xcschemes", "#{scheme_name}.xcscheme")
          return nil unless File.exist?(scheme_path)
          Xcodeproj::XCScheme.new(scheme_path).archive_action.build_configuration
        end

        def self.detect_configuration_from_workspace(workspace_path, scheme_name)
          return nil unless File.exist?(workspace_path)
          workspace = Xcodeproj::Workspace.new_from_xcworkspace(workspace_path)
          workspace_schemes = workspace.schemes.reject { |k, v| v.include?("Pods/Pods.xcodeproj") }
          return nil unless workspace_schemes.keys.include?(scheme_name)
          detect_configuration_from_project(workspace_schemes[scheme_name], scheme_name)
        end

      end

    end
  end
end
