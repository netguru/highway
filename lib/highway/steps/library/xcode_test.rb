#
# xcode_test.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
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
            Parameters::Single.new(
              name: "clean",
              type: Types::Bool.new(),
              required: false,
              default: true,
            ),
            Parameters::Single.new(
              name: "configuration",
              type: Types::String.new(),
              required: false,
            ),
            Parameters::Single.new(
              name: "device",
              type: Types::String.new(),
              required: false,
            ),
            Parameters::Single.new(
              name: "flags",
              type: Types::Array.new(Types::String.new()),
              required: false,
              default: [],
            ),
            Parameters::Single.new(
              name: "project",
              type: Types::AnyOf.new(
                project: Types::String.regex(/.+\.xcodeproj/),
                workspace: Types::String.regex(/.+\.xcworkspace/),
              ),
              required: true,
            ),
            Parameters::Single.new(
              name: "scheme",
              type: Types::String.new(),
              required: true,
            ),
            Parameters::Single.new(
              name: "settings",
              type: Types::Hash.new(Types::String.new(), validate: lambda { |dict| dict.keys.all? { |key| /[A-Z_][A-Z0-9_]*/ =~ key } }),
              required: false,
              default: {},
            ),
          ]
        end

        def self.run(parameters:, context:, report:)

          # Interpret the parameters. At this point they are parsed and
          # transformed to be recognizable by Fastlane.

          clean = parameters["clean"]
          configuration = parameters["configuration"]
          device = parameters["device"]
          scheme = parameters["scheme"]

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

          output_html_path = report.prepare_artifact("report.html")
          output_junit_path = report.prepare_artifact("report.junit")

          output_html_file = File.basename(output_html_path)
          output_junit_file = File.basename(output_junit_path)

          # Configure xcpretty. Set custom locations of report artifacts so that
          # we can track them accurately.

          output_dir = context.artifacts_dir
          output_types = ["html", "junit"].join(",")
          output_files = [output_html_file, output_junit_file].join(",")

          # Prepare temporary variables.

          report_test = {}
          report_artifacts = {}

          rescued_error = nil

          # Run the build and test.

          begin

            context.run_action("run_tests", options: {

              project_key => project_value,

              clean: clean,
              configuration: configuration,
              device: device,
              scheme: scheme,

              xcargs: xcargs,

              buildlog_path: output_raw_temp_dir,
              output_directory: output_dir,
              output_types: output_types,
              output_files: output_files,

            })

          rescue FastlaneCore::Interface::FastlaneBuildFailure => error

            # A compile error occured. Save it to be re-raised later.

            report_test[:result] = :error
            rescued_error = error

          rescue FastlaneCore::Interface::FastlaneTestFailure => error

            # A test failure occured. Save it to be re-raised later.

            report_test[:result] = :failure
            rescued_error = error

          else

            # Build succeeded!

            report_test[:result] = :success

          end

          # Now the real fun begins. Move the raw xcodebuild log from temporary
          # directory to artifacts directory.

          output_raw_temp_path = Dir.glob(File.join(output_raw_temp_dir, "*.log")).first
          FileUtils.mv(output_raw_temp_path, output_raw_path)

          # Save the artifact paths in the subreport.

          report_artifacts[:raw] = output_raw_path
          report_artifacts[:html] = output_html_path
          report_artifacts[:junit] = output_junit_path

          # Load the raw log and pipe it through xcpretty with a JSON formatter.
          # That will output a machine-readable information about everything
          # that happened in the build.

          xcpretty_json_formatter_path = context.run_sh("xcpretty-json-formatter", bundle_exec: true, silent: true)
          temp_json_report_path = File.join(Dir.mktmpdir(), "report.json")

          context.with_modified_env({"XCPRETTY_JSON_FILE_OUTPUT" => temp_json_report_path}) do
            context.run_sh(["cat", output_raw_path, "| xcpretty --formatter", xcpretty_json_formatter_path], bundle_exec: true, silent: true)
          end

          # Load the build report and a JUnit report into memory.

          junit_report = Scan::TestResultParser.new.parse_result(File.read(output_junit_path))
          xcode_report = JSON.parse(File.read(temp_json_report_path))

          # Extract test numbers from JUnit report.

          report_test_count = {}

          report_test_count[:all] = junit_report[:tests]
          report_test_count[:failed] = junit_report[:failures]
          report_test_count[:succeeded] = report_test_count[:all] - report_test_count[:failed]

          report_test[:count] = report_test_count

          # Extract compile errors from the build report.

          report_test_errors = []

          report_test_errors += xcode_report.fetch("file_missing_errors", []).map { |entry|
            {location: File.basename(entry["file_path"]), reason: entry["reason"]}
          }

          report_test_errors += xcode_report.fetch("compile_errors", []).map { |entry|
            {location: File.basename(entry["file_path"]), reason: entry["reason"]}
          }

          report_test_errors += xcode_report.fetch("undefined_symbols_errors", []).map { |entry|
            {location: entry["symbol"], reason: entry["message"]}
          }

          report_test_errors += xcode_report.fetch("format_duplicate_symbols", []).map {
            {location: nil, reason: entry["message"]}
          }

          report_test_errors += xcode_report.fetch("errors", []).map { |entry|
            {location: nil, reason: entry}
          }

          report_test[:errors] = report_test_errors

          # Extract test failures from the build report.

          report_test_failures = xcode_report.fetch("tests_failures", []).values.flatten.map { |entry|
            {location: entry["test_case"], reason: entry["reason"]}
          }

          report_test[:failures] = report_test_failures

          # Save the test and artifacts subreports in the report.

          report[:test] = report_test
          report[:artifacts] = report_artifacts

          # Re-raise the error after the report is finally prepared.

          raise rescued_error if rescued_error != nil

        end

      end

    end
  end
end
