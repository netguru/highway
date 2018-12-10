#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/compiler/analyze/tree/root"
require "highway/runtime/context"
require "highway/runtime/error"
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
      # @parameter manifest [Highway::Reporter] The reporter.
      def initialize(context:, manifest:, reporter:)
        @context = context
        @manifest = manifest
        @reporter = reporter
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

        errors = []

        @manifest.invocations.each do |invocation|
          if errors.empty? || invocation.policy == :always
            run_invocation(invocation: invocation, errors: errors)
          else
            @reporter.warning("Skipping step '#{invocation.step_class.name}' because a previous step has failed.")
          end
        end

        if errors.empty?
          @reporter.success("Wubba lubba dub dub, Highway preset '#{@manifest.preset}' has succeeded!")
        else
          @reporter.fatal!("Highway preset '#{@manifest.preset}' has failed with one or more errors. Please examine the above log for more information.")
        end

      end

      def run_invocation(invocation:, errors:)
        begin

          evaluated_parameters = Utilities::hash_map(invocation.parameters) { |parameter|
            [parameter.name, evaluate_parameter(value: parameter.value)]
          }

          coerced_parameters = Utilities::hash_map(evaluated_parameters) { |name, value|
            definition = invocation.step_class.parameters.find { |definition| definition.name == name }
            [name, coerce_and_validate_parameter(definition: definition, value: value, invocation: invocation)]
          }

          invocation.step_class.run(parameters: coerced_parameters, context: @context)

        rescue FastlaneCore::Interface::FastlaneException => error
          errors << Runtime::CapturedError.new(invocation: invocation, error: error)
          @reporter.error(error.message)
        end
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
            @reporter.fatal!("Invalid value: '#{value}' for parameter: '#{definition.name}' of step: '#{invocation.step_class.name}'.")
          end
        else
          definition.default_value
        end
      end

    end

  end
end
