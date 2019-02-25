#
# runner.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"
require "fileutils"

require "highway/compiler/analyze/tree/root"
require "highway/environment"
require "highway/runtime/context"
require "highway/runtime/report"
require "highway/steps/infrastructure"
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

        prevalidate_invocations()

        # Prepare the artifacts directory. If it doesn't exist, it's created at
        # this point. If it exist, it's removed and re-created.

        prepare_artifacts_dir()

        # Run invocations one-by-one.

        run_invocations()

        # Print the metrics table containing the status of invocation, its step
        # name and a duration it took.

        report_metrics()

        # Now it's time to raise an error if any of the steps failed.

        if @context.reports_any_failed?
          @interface.fatal!(nil)
        end

      end

      private

      def prevalidate_invocations()

        @interface.header_success("Validating step parameters...")

        @manifest.invocations.each { |invocation|
          invocation.step_class.root_parameter.typecheck_and_prevalidate(
            evaluate_parameter_for_prevalidation(invocation.parameters),
            interface: @interface,
            keypath: invocation.keypath,
          )
        }

        @interface.success("All step parameters passed initial validation.")

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

        # Prepare a report instance and some temporary variables to be used in
        # metrics.

        report = Report.new(
          invocation: invocation,
          artifacts_dir: @context.artifacts_dir,
        )

        step_name = invocation.step_class.name
        time_started = Time.now

        if !@context.reports_any_failed? || invocation.policy == :always

          # Only run the step if no previous step has failed or if the step
          # should always be executed.

          @interface.header_success("Running step: #{step_name}...")

          begin

            # Evaluate, typecheck and map the invocation parameters. At this
            # point we're able to evaluate environment variables.

            evaluated_parameters = Utilities::hash_map(invocation.parameters.children) { |name, value|
              [name, evaluate_parameter(value)]
            }

            parameters = invocation.step_class.root_parameter.typecheck_and_validate(
              evaluated_parameters,
              interface: @interface,
              keypath: invocation.keypath,
            )

            # Run the step invocation. This is where steps are executed.

            invocation.step_class.run(
              parameters: parameters,
              context: @context,
              report: report,
            )

            report.result = :success

          rescue FastlaneCore::Interface::FastlaneError, FastlaneCore::Interface::FastlaneCommonException => error

            # These two errors should not count as crashes and should not print
            # backtrace unless running in verbose mode. This follows the
            # behavior of `Fastlane::Runner`.

            @interface.error(error.message)
            @interface.error(error.backtrace.join("\n")) if @context.env.verbose?

            report.result = :failure
            report.error = error

          rescue FastlaneCore::Interface::FastlaneShellError => error

            # This error should be treated in a special way as its message
            # contains the whole command output. It should only be printed in
            # verbose mode.

            @interface.error(error.message.split("\n").first)
            @interface.error(error.message.split("\n").drop(1).join("\n")) if @context.env.verbose?
            @interface.error(error.backtrace.join("\n")) if @context.env.verbose?

            report.result = :failure
            report.error = error

          rescue => error

            # Chances are that this is `FastlaneCore::Interface::FastlaneCrash`
            # but it could be another error as well. For these error a backtrace
            # should always be printed. This follows the behavior of
            # `Fastlane::Runner`.

            @interface.error("#{error.class}: #{error.message}")
            @interface.error(error.backtrace.join("\n"))

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

      def evaluate_parameter(value)
        if value.is_a?(Compiler::Analyze::Tree::Values::Primitive)
          value.segments.reduce("") { |memo, segment|
            if segment.is_a?(Compiler::Analyze::Tree::Segments::Text)
              memo + segment.value
            elsif segment.is_a?(Compiler::Analyze::Tree::Segments::Variable) && segment.scope == :env
              memo + @context.env.find(segment.name) || ""
            end
          }
        elsif value.is_a?(Compiler::Analyze::Tree::Values::Array)
          value.children.map { |value|
            evaluate_parameter(value)
          }
        elsif value.is_a?(Compiler::Analyze::Tree::Values::Hash)
          Utilities::hash_map(value.children) { |key, value|
            [key, evaluate_parameter(value)]
          }
        end
      end

      def evaluate_parameter_for_prevalidation(value)
        if value.is_a?(Compiler::Analyze::Tree::Values::Primitive)
          if value.select_variable_segments_with_scope(:env).empty?
            evaluate_parameter(value)
          else
            :ignore
          end
        elsif value.is_a?(Compiler::Analyze::Tree::Values::Array)
          value.children.map { |value|
            evaluate_parameter_for_prevalidation(value)
          }
        elsif value.is_a?(Compiler::Analyze::Tree::Values::Hash)
          Utilities::hash_map(value.children) { |key, value|
            [key, evaluate_parameter_for_prevalidation(value)]
          }
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

        @interface.table(
          title: "Highway Summary".yellow,
          headings: ["", "Step", "Duration"],
          rows: rows
        )

      end

    end

  end
end
