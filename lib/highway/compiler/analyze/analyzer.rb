#
# analyzer.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/root"

module Highway
  module Compiler
    module Analyze

      # This class is responsible for semantic analysis of a parse tree. This is
      # the second phase of the compiler.
      class Analyzer

        public

        # Initialize an instance.
        #
        # @param reporter [Highway::Reporter] The reporter.
        # @param registry [Highway::Steps::Registry] The steps registry.
        def initialize(reporter:, registry:)
          @reporter = reporter
          @registry = registry
        end

        # Analyze the parse tree.
        #
        # The semantic analyzer validates the parse tree in terms of content,
        # performs segmentation of values and resolves steps against the
        # registry.
        #
        # @param parse_tree [Highway::Compiler::Parse::Tree::Root] The parse tree.
        #
        # @return [Highway::Compiler::Analyze::Tree::Root] The semantic tree.
        def analyze(parse_tree:)

          sema_tree = Analyze::Tree::Root.new()

          sema_tree.add_stage(name: "bootstrap", policy: :normal, index: 0)
          sema_tree.add_stage(name: "test", policy: :normal, index: 1)
          sema_tree.add_stage(name: "deploy", policy: :normal, index: 2)
          sema_tree.add_stage(name: "report", policy: :always, index: 3)

          sema_tree.default_preset = "default"

          validate_preset_names(parse_tree: parse_tree)
          validate_variable_names(parse_tree: parse_tree)
          validate_variable_values(parse_tree: parse_tree)
          validate_step_names(parse_tree: parse_tree)
          validate_step_parameter_values(parse_tree: parse_tree)

          resolve_variables(parse_tree: parse_tree, sema_tree: sema_tree)
          resolve_steps(parse_tree: parse_tree, sema_tree: sema_tree)
          
          validate_variable_references(sema_tree: sema_tree)
          validate_step_parameter_names(sema_tree: sema_tree)
          validate_step_parameter_optionality(sema_tree: sema_tree)

          sema_tree

        end

        private

        def validate_preset_names(parse_tree:)
          parse_tree.variables.each do |variable|
            assert_preset_name_valid(variable.preset, keypath: ["variables"])
          end
          parse_tree.steps.each do |step|
            assert_preset_name_valid(step.preset, keypath: [step.stage])
          end
        end

        def validate_variable_names(parse_tree:)
          parse_tree.variables.each do |variable|
            assert_variable_name_valid(variable.name, keypath: ["variables", variable.preset])
          end
        end

        def validate_variable_values(parse_tree:)
          parse_tree.variables.each do |variable|
            assert_variable_value_valid(variable.value, keypath: ["variables", variable.preset, variable.name])
          end
        end

        def validate_step_names(parse_tree:)
          parse_tree.steps.each do |step|
            assert_step_exists(step.name, keypath: [step.stage, step.preset])
          end
        end

        def validate_step_parameter_values(parse_tree:)
          parse_tree.steps.each do |step|
            step.parameters.each_pair do |param_name, param_value|
              assert_step_parameter_value_valid(param_value, keypath: [step.stage, step.preset, step.name, param_name])
            end
          end
        end

        def validate_variable_references(sema_tree:)
          sema_tree.variables.each do |variable|
            variable.value.variable_segments.each do |segment|
              unless (ref_variable = find_referenced_variable(sema_tree: sema_tree, name: segment.variable_name, preset: variable.preset))
                @reporter.fatal!("Unknown variable: '#{segment.variable_name}' referenced from: '#{keypath_to_s(["variables", variable.preset, variable.name])}'.")
              end
              if ref_variable.value.variable_segments.any? { |other| other.variable_name == variable.name }
                @reporter.fatal!("Detected a reference cycle between: '#{keypath_to_s(["variables", variable.preset, variable.name])}' and '#{keypath_to_s(["variables", ref_variable.preset, ref_variable.name])}'.")
              end
            end
          end
          sema_tree.steps.each do |step|
            step.parameters.each do |parameter|
              parameter.value.variable_segments.each do |segment|
                unless find_referenced_variable(sema_tree: sema_tree, name: segment.variable_name, preset: step.preset)
                  @reporter.fatal!("Unknown variable: '#{segment.variable_name}' referenced from: '#{keypath_to_s([step.stage, step.preset, step.name, parameter.name])}'.")
                end
              end
            end
          end
        end

        def validate_step_parameter_names(sema_tree:)
          sema_tree.steps.each do |step|
            step.parameters.each do |parameter|
              expected = step.step_class.parameters.map { |expected_parameter| expected_parameter.name }
              assert_step_parameter_name_valid(parameter.name, expected: expected, keypath: [step.stage, step.preset, step.name])
            end
          end
        end

        def validate_step_parameter_optionality(sema_tree:)
          sema_tree.steps.each do |step|
            step.step_class.parameters.select { |param| param.is_required? }.map { |param| param.name }.each do |expected|
              parameters = step.parameters.map { |param| param.name }
              assert_step_parameter_exists(parameters, expected: expected, keypath: [step.stage, step.preset, step.name])
            end
          end
        end

        def resolve_variables(parse_tree:, sema_tree:)
          parse_tree.variables.each do |variable|
            value = segmentize_value(variable.value)
            sema_tree.add_variable(name: variable.name, value: value, preset: variable.preset)
          end
        end

        def resolve_steps(parse_tree:, sema_tree:)
          parse_tree.steps.each do |step|
            klass = @registry.get_by_name(step.name)
            parameters = step.parameters.map { |name, value| Tree::Parameter.new(name: name, value: segmentize_value(value)) }
            policy = step.stage == "report" ? :always : :normal
            sema_tree.add_step(name: step.name, step_class: klass, parameters: parameters, stage: step.stage, preset: step.preset, index: step.index, policy: policy)
          end
        end

        def segmentize_value(value)
          if value.is_a?(String)
            Analyze::Tree::PrimitiveValue.new(
              segments: value.to_enum(:scan, %r((?<!\\)\$\(([A-Z0-9:_]+)\)|((?:[^\\\$]|\\\$)+))).map { Regexp.last_match }.map { |match|
                if match[1]
                  if match[1][0, 4] == "ENV:"
                    Analyze::Tree::EnvVariableValueSegment.new(variable_name: match[1][4..-1])
                  else
                    Analyze::Tree::VariableValueSegment.new(variable_name: match[1])
                  end
                elsif match[2]
                  Analyze::Tree::TextValueSegment.new(value: match[2])
                end
              }
            )
          elsif value.is_a?(Array)
            Analyze::Tree::ArrayValue.new(
              children: value.map { |element|
                segmentize_value(element)
              }
            )
          elsif value.is_a?(Hash)
            Analyze::Tree::DictionaryValue.new(
              children: hash_map(value) { |name, element|
                [name, segmentize_value(element)]
              }
            )
          elsif value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(NilClass)
            Analyze::Tree::PrimitiveValue.new(
              segments: [Analyze::Tree::TextValueSegment.new(value: value.to_s)]
            )
          end
        end

        def find_referenced_variable(sema_tree:, name:, preset:)
          sema_tree.variables.find do |variable|
            variable.name == name && [preset, sema_tree.default_preset].include?(variable.preset)
          end
        end

        def assert_preset_name_valid(value, keypath:)
          unless %r(^[a-z_]*$) =~ value
            @reporter.fatal!("Invalid preset name: '#{value}' at: '#{keypath_to_s(keypath)}'.")
          end
        end

        def assert_variable_name_valid(value, keypath:)
          unless %r(^[A-Z_][A-Z0-9_]*$) =~ value
            @reporter.fatal!("Invalid variable name: '#{value}' at: '#{keypath_to_s(keypath)}'.")
          end
        end

        def assert_variable_value_valid(value, keypath:)
          if value.is_a?(String)
            unless %r(^((?:[^\$]*(?:(?:\\\$)|(?<!\\)\$\((?:ENV:)?[A-Z_][A-Z0-9_]*\))*)*)$) =~ value
              @reporter.fatal!("Invalid variable value: '#{value}' at: '#{keypath_to_s(keypath)}'.")
            end
          elsif value.is_a?(Array) || value.is_a?(Hash)
            @reporter.fatal!("Invalid variable value: '#{value}' at: '#{keypath_to_s(keypath)}'.")
          else
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(NilClass)
              @reporter.fatal!("Invalid variable value: '#{value}' at: '#{keypath_to_s(keypath)}'.")
            end
          end
        end

        def assert_step_exists(value, keypath:)
          unless @registry.get_by_name(value)
            @reporter.fatal!("Unknown step: '#{value}' at: '#{keypath_to_s(keypath)}'.")
          end
        end

        def assert_step_parameter_name_valid(value, expected:, keypath:)
          unless expected.include?(value)
            expected_names = expected.map { |name| "'#{name}'" }.join(", ")
            @reporter.fatal!("Unknown step parameter: '#{value}' at '#{keypath_to_s(keypath)}'. Expected one of: [#{expected_names}].")
          end
        end

        def assert_step_parameter_value_valid(value, keypath:)
          if value.is_a?(String)
            unless %r(^((?:[^\$]*(?:(?:\\\$)|(?<!\\)\$\((?:ENV:)?[A-Z_]+\))*)*)$) =~ value
              @reporter.fatal!("Invalid step parameter value: '#{value}' at: '#{keypath_to_s(keypath)}'.")
            end
          elsif value.is_a?(Array)
            value.each_with_index do |single_value, index|
              assert_step_parameter_value_valid(single_value, keypath: keypath + [index])
            end
          elsif value.is_a?(Hash)
            value.each_pair do |key, single_value|
              assert_step_parameter_value_valid(single_value, keypath: keypath + [key])
            end
          else
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(NilClass)
              @reporter.fatal!("Invalid step parameter value: '#{value}' at: '#{keypath_to_s(keypath)}'.")
            end
          end
        end

        def assert_step_parameter_exists(value, expected:, keypath:)
          unless value.include?(expected)
            @reporter.fatal!("Missing value for required step parameter: '#{expected}' at: '#{keypath_to_s(keypath)}'.")
          end
        end

        def keypath_to_s(keypath)
          keypath.join(".")
        end

        def hash_map(subject, &transform)
          Hash[subject.map(&transform)]
        end

      end

    end
  end
end
