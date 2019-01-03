#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"
require "fileutils"

require "highway/compiler/analyze/tree/root"
require "highway/runtime/context"
require "highway/runtime/environment"
require "highway/runtime/report"
require "highway/utilities"

module Highway
  module Runtime

    # This class is responsible for evaluating invocation parameters, then
    # validating and running step invocations.
    class Runner

      public

      # Initialize an instance.
      #
      # @parameter context [Highway::Runtime::Context] The runtime context.
      # @parameter manifest [Highway::Compiler::Build::Output::Manifest] The build manifest.
      # @parameter manifest [Highway::Interface] The interface.
      def initialize(manifest:, context:, interface:)
        @manifest = manifest
        @context = context
        @interface = interface
      end

      # Run the build manifest.
      #
      # The runner prevalidates the step invocations if they don't contain any
      # environments variables, then runs step invocations.
      #
      # This method catches exceptions thrown inside steps in order to maintain
      # control over the execution policy.
      def run()

        # Validate invocations before running them. At this point we're able
        # to evaluate non-environment variables, typecheck and validate the
        # parameters.

        validate_invocations()

        # Print the header, similar to Fastlane's "driving the lane".

        @interface.success("Running Highway preset '#{@manifest.preset}' 🏎")

        # Prepare the artifacts directory. If it doesn't exist, it's created at
        # this point. If it exist, it's removed and re-created.

        prepare_artifacts_dir()

        # Run invocations one-by-one.

        run_invocations()

        # Print the metrics table containing the status of invocation, its step
        # name and a duration it took.

        report_metrics()

        # Print a summary depending on the invocation reports.

        if !@context.reports_any_failed?
          @interface.success("Wubba lubba dub dub, Highway preset '#{@manifest.preset}' has succeeded!")
        else
          clear_and_report_fastlane_lane_context()
          @interface.fatal!("Highway preset '#{@manifest.preset}' has failed with one or more errors. Please examine the above log.")
        end

      end

      private

      def validate_invocations()
        @manifest.invocations.each do |invocation|
          invocation.parameters.each do |parameter|
            unless parameter.value.contains_env_variable_segments?
              definition = invocation.step_class.parameters.find { |definition| definition.name == parameter.name }
              value = evaluate_parameter(value: parameter.value)
              typecheck_and_validate_parameter(definition: definition, value: value, invocation: invocation)
            end
          end
        end
      end

      def prepare_artifacts_dir()
        FileUtils.remove_entry(@context.artifacts_dir) if File.exist?(@context.artifacts_dir)
        FileUtils.mkdir(@context.artifacts_dir)
      end

      def run_invocations()
        @manifest.invocations.each do |invocation|
          report = run_invocation(invocation: invocation)
          @context.add_report(report)
        end
      end

      def run_invocation(invocation:)

        report = Report.new(invocation: invocation, context: @context)

        step_name = invocation.step_class.name
        time_started = Time.now

        if !@context.reports_any_failed? || invocation.policy == :always

          @interface.header_success("Running step: #{step_name}...")

          begin

            default_parameters = Utilities::hash_map(invocation.step_class.parameters) { |parameter|
              [parameter.name, parameter.default_value]
            }

            evaluated_parameters = Utilities::hash_map(invocation.parameters) { |parameter|
              [parameter.name, evaluate_parameter(value: parameter.value)]
            }

            coerced_parameters = Utilities::hash_map(evaluated_parameters) { |name, value|
              definition = invocation.step_class.parameters.find { |definition| definition.name == name }
              [name, typecheck_and_validate_parameter(definition: definition, value: value, invocation: invocation)]
            }

            parameters = default_parameters.merge(coerced_parameters)

            invocation.step_class.run(
              parameters: parameters,
              context: @context,
              report: report,
            )

            report.result = :success

          rescue FastlaneCore::Interface::FastlaneException => error

            @interface.error(error.message)

            report.result = :failure
            report.error = error

          end

        else

          @interface.header_warning("Skipping step: #{step_name}...")
          @interface.warning("Skipping because a previous step has failed.")

          report.result = :skip

        end

        report.duration = (Time.now - time_started).round

        report

      end

      def evaluate_parameter(value:)
        if value.is_a?(Compiler::Analyze::Tree::PrimitiveValue)
          value.segments.reduce("") { |memo, segment|
            if segment.is_a?(Compiler::Analyze::Tree::TextValueSegment)
              memo + segment.value
            elsif segment.is_a?(Compiler::Analyze::Tree::EnvVariableValueSegment)
              memo + ENV.fetch(segment.variable_name, "")
            end
          }
        elsif value.is_a?(Compiler::Analyze::Tree::ArrayValue)
          value.children.map { |value|
            evaluate_parameter(value: value)
          }
        elsif value.is_a?(Compiler::Analyze::Tree::DictionaryValue)
          Utilities::hash_map(value.children) { |key, value|
            [key, evaluate_parameter(value: value)]
          }
        end
      end

      def typecheck_and_validate_parameter(definition:, value:, invocation:)
        if value != nil
          if (typechecked = definition.type.typecheck_and_validate(value)) && definition.validate(typechecked)
            typechecked
          else
            @interface.fatal!("Invalid value: '#{value}' for parameter: '#{definition.name}' of step: '#{invocation.step_class.name}'.")
          end
        else
          definition.default_value
        end
      end

      def report_metrics()

        rows = @context.reports.each.map { |report|

          status = case report.result
            when :success then report.invocation.index.to_s
            when :failure then "x"
            when :skip then "-"
          end

          name = report.invocation.step_class.name

          minutes = (report.duration / 60).floor
          seconds = report.duration % 60

          duration = "#{minutes}m #{seconds}s" if minutes > 0
          duration ||= "#{seconds}s"

          row = [status, name, duration].map { |text|
            case report.result
              when :success then text.green
              when :failure then text.red.bold
              when :skip then text.yellow
            end
          }

          row

        }

        puts("\n")

        @interface.table(
          title: "Highway Summary".yellow,
          headings: ["", "Step", "Duration"],
          rows: rows
        )

        puts("\n")

      end

      def clear_and_report_fastlane_lane_context()

        lane_context_rows = @context.fastlane_lane_context.collect do |key, content|
          [key, content.to_s]
        end

        @interface.table(
          title: "Lane Context".yellow,
          rows: lane_context_rows
        )

        puts("\n")

        @context.fastlane_lane_context.clear()

      end

    end

  end
end
