#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/compiler/analyze/tree/root"
require "highway/runtime/artifact"
require "highway/runtime/context"
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
        validate_invocations()
        run_invocations()
      end

      private

      def validate_invocations()
        @manifest.invocations.each do |invocation|
          invocation.parameters.each do |parameter|
            unless parameter.value.contains_env_variable_segments?
              definition = invocation.step_class.parameters.find { |definition| definition.name == parameter.name }
              value = evaluate_parameter(value: parameter.value)
              coerce_and_validate_parameter(definition: definition, value: value, invocation: invocation)
            end
          end
        end
      end

      def run_invocations()

        @interface.success("Running Highway preset '#{@manifest.preset}' 🏎")

        errors = []

        @manifest.invocations.each do |invocation|
          run_invocation(invocation: invocation, errors: errors)
        end

        report_metrics()

        if errors.empty?
          @interface.success("Wubba lubba dub dub, Highway preset '#{@manifest.preset}' has succeeded!")
        else
          clear_and_report_fastlane_lane_context()
          @interface.fatal!("Highway preset '#{@manifest.preset}' has failed with one or more errors. Please examine the above log.")
        end

      end

      def run_invocation(invocation:, errors:)

        artifact = Artifact.new(invocation: invocation)

        step_name = invocation.step_class.name
        time_started = Time.now

        if errors.empty? || invocation.policy == :always

          @interface.header_success("Running step: #{step_name}...")

          begin

            evaluated_parameters = Utilities::hash_map(invocation.parameters) { |parameter|
              [parameter.name, evaluate_parameter(value: parameter.value)]
            }

            coerced_parameters = Utilities::hash_map(evaluated_parameters) { |name, value|
              definition = invocation.step_class.parameters.find { |definition| definition.name == name }
              [name, coerce_and_validate_parameter(definition: definition, value: value, invocation: invocation)]
            }

            invocation.step_class.run(
              parameters: coerced_parameters,
              context: @context,
              artifact: artifact,
            )

            artifact.result = :success

          rescue FastlaneCore::Interface::FastlaneException => error

            @interface.error(error.message)
            errors << {invocation: invocation, error: error}

            artifact.result = :failure

          end

        else

          @interface.header_warning("Skipping step: #{step_name}...")
          @interface.warning("Skipping step '#{step_name}' because a previous step has failed.")

          artifact.result = :skip

        end

        artifact.duration = (Time.now - time_started).round

        @context.add_artifact(artifact)

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

      def coerce_and_validate_parameter(definition:, value:, invocation:)
        if value != nil
          if (coerced = definition.type.coerce_and_validate(value: value))
            coerced
          else
            @interface.fatal!("Invalid value: '#{value}' for parameter: '#{definition.name}' of step: '#{invocation.step_class.name}'.")
          end
        else
          definition.default_value
        end
      end

      def report_metrics()

        rows = @context.artifacts.each_with_index.map { |artifact, index|

          status = case artifact.result
            when :success then (index + 1).to_s
            when :failure then "x"
            when :skip then "-"
          end

          name = artifact.invocation.step_class.name

          minutes = (artifact.duration / 60).floor
          seconds = artifact.duration % 60

          duration = "#{minutes}m #{seconds}s" if minutes > 0
          duration ||= "#{seconds}s"

          row = [status, name, duration].map { |text|
            case artifact.result
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
