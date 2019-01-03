#
# xcode_test.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/infrastructure"

module Highway
  module Steps
    module Library

      class XcodeTestStep < Step

        def self.name
          "xcode-test"
        end

        def self.parameters
          [
            Parameter.new(
              name: "clean",
              required: false,
              type: Types::Bool.new(),
              default_value: false,
            ),
            Parameter.new(
              name: "project",
              required: true,
              type: Types::AnyOf.new(
                project: Types::String.regex(/.+\.xcodeproj/),
                workspace: Types::String.regex(/.+\.xcworkspace/),
              )
            ),
            Parameter.new(
              name: "scheme",
              required: true,
              type: Types::String.new(),
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          clean = parameters["clean"]
          scheme = parameters["scheme"]

          project_key = parameters["project"][:tag]
          project_value = parameters["project"][:value]

          output_raw_temp_dir = report.prepare_artifact_temp_dir()
          output_raw_path = report.prepare_artifact_file("raw.log")

          output_html_path = report.prepare_artifact_file("report.html")
          output_junit_path = report.prepare_artifact_file("report.junit")

          output_html_file = File.basename(output_html_path)
          output_junit_file = File.basename(output_junit_path)

          output_dir = context.artifacts_dir
          output_types = ["html", "junit"].join(",")
          output_files = [output_html_file, output_junit_file].join(",")

          rescued_error = nil

          begin

            context.run_action("run_tests", options: {

              project_key => project_value,

              clean: clean,
              scheme: scheme,

              buildlog_path: output_raw_temp_dir,
              output_directory: output_dir,
              output_types: output_types,
              output_files: output_files,

            })

          rescue FastlaneCore::Interface::FastlaneBuildFailure => error

            report[:test_result] = :compile_error
            report[:test_error] = error

            rescued_error = error

          rescue FastlaneCore::Interface::FastlaneTestFailure => error

            report[:test_result] = :test_failure
            report[:test_error] = error

            rescued_error = error

          end

          output_raw_temp_path = Dir.glob(File.join(output_raw_temp_dir, "*.log")).first
          FileUtils.mv(output_raw_temp_path, output_raw_path) if output_raw_temp_path != nil

          report[:artifact_raw_log] = output_raw_path if File.exist?(output_raw_path)
          report[:artifact_html_report] = output_html_path if File.exist?(output_html_path)
          report[:artifact_junit_report] = output_junit_file if File.exist?(output_junit_path)

          # Re-raise the build/test failure error after report is prepared.

          raise rescued_error if rescued_error != nil

        end

      end

    end
  end
end
