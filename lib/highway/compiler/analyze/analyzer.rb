#
# analyzer.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/root"
require "highway/utilities"

module Highway
  module Compiler
    module Analyze

      # This class is responsible for semantic analysis of a parse tree. This is
      # the second phase of the compiler.
      class Analyzer

        public

        # Initialize an instance.
        #
        # @param registry [Highway::Steps::Registry] The steps registry.
        # @param reporter [Highway::Interface] The interface.
        def initialize(registry:, interface:)
          @registry = registry
          @interface = interface
        end

        # Analyze the parse tree.
        #
        # The semantic analyzer validates the parse tree in terms of content,
        # performs segmentation of values and resolves steps against the
        # registry.
        #
        # The semantic analyzer produces a semantic tree which is then used by
        # build phase to generate a manifest.
        #
        # @param parse_tree [Highway::Compiler::Parse::Tree::Root] The parse tree.
        #
        # @return [Highway::Compiler::Analyze::Tree::Root]
        def analyze(parse_tree:)

          sema_tree = Analyze::Tree::Root.new()

          sema_tree.add_stage(index: 0, name: "bootstrap", policy: :normal, )
          sema_tree.add_stage(index: 1, name: "test", policy: :normal)
          sema_tree.add_stage(index: 2, name: "deploy", policy: :normal)
          sema_tree.add_stage(index: 3, name: "report", policy: :always)

          sema_tree.default_preset = "default"

          validate_preset_names(parse_tree: parse_tree)
          validate_variable_names(parse_tree: parse_tree)
          validate_variable_values(parse_tree: parse_tree)
          validate_step_names(parse_tree: parse_tree)
          validate_step_parameter_values(parse_tree: parse_tree)

          resolve_variables(parse_tree: parse_tree, sema_tree: sema_tree)
          resolve_steps(parse_tree: parse_tree, sema_tree: sema_tree)

          validate_variable_references(sema_tree: sema_tree)

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
            variable.value.select_variable_segments_with_scope(:static).each do |segment|
              unless (ref_variable = find_referenced_variable(sema_tree: sema_tree, name: segment.name, preset: variable.preset))
                @interface.fatal!("Unknown variable: '#{segment.name}' referenced from: '#{Utilities::keypath_to_s(["variables", variable.preset, variable.name])}'.")
              end
              if ref_variable.value.select_variable_segments_with_scope(:static).any? { |other| other.name == variable.name }
                @interface.fatal!("Detected a reference cycle between: '#{Utilities::keypath_to_s(["variables", variable.preset, variable.name])}' and '#{Utilities::keypath_to_s(["variables", ref_variable.preset, ref_variable.name])}'.")
              end
            end
          end
          sema_tree.steps.each do |step|
            step.parameters.children.each_pair do |name, value|
              value.select_variable_segments_with_scope(:static).each do |segment|
                unless find_referenced_variable(sema_tree: sema_tree, name: segment.name, preset: step.preset)
                  @interface.fatal!("Unknown variable: '#{segment.name}' referenced from: '#{Utilities::keypath_to_s([step.stage, step.preset, step.name, name])}'.")
                end
              end
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
            parameters = segmentize_value(step.parameters)
            sema_tree.add_step(index: step.index, name: step.name, step_class: klass, parameters: parameters, stage: step.stage, preset: step.preset)
          end
        end

        def segmentize_value(value)
          if value.is_a?(String)
            Analyze::Tree::Values::Primitive.new(
              value.to_enum(:scan, %r((?<!\\)\$\(([A-Z0-9:_]+)\)|((?:[^\\\$]|\\\$)+))).map { Regexp.last_match }.map { |match|
                if match[1]
                  if match[1][0, 4] == "ENV:"
                    Analyze::Tree::Segments::Variable.new(match[1][4..-1], scope: :env)
                  else
                    Analyze::Tree::Segments::Variable.new(match[1], scope: :static)
                  end
                elsif match[2]
                  Analyze::Tree::Segments::Text.new(match[2])
                end
              }
            )
          elsif value.is_a?(Array)
            Analyze::Tree::Values::Array.new(
              value.map { |element|
                segmentize_value(element)
              }
            )
          elsif value.is_a?(Hash)
            Analyze::Tree::Values::Hash.new(
              Utilities::hash_map(value) { |name, element|
                [name, segmentize_value(element)]
              }
            )
          elsif value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(NilClass)
            Analyze::Tree::Values::Primitive.new(
              [Analyze::Tree::Segments::Text.new(value.to_s)]
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
            @interface.fatal!("Invalid preset name: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
          end
        end

        def assert_variable_name_valid(value, keypath:)
          unless %r(^[A-Z_][A-Z0-9_]*$) =~ value
            @interface.fatal!("Invalid variable name: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
          end
        end

        def assert_variable_value_valid(value, keypath:)
          if value.is_a?(String)
            unless %r(^((?:[^\$]*(?:(?:\\\$)|(?<!\\)\$\((?:ENV:)?[A-Z_][A-Z0-9_]*\))*)*)$) =~ value
              @interface.fatal!("Invalid variable value: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
            end
          elsif value.is_a?(Array) || value.is_a?(Hash)
            @interface.fatal!("Invalid variable value: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
          else
            unless value.is_a?(TrueClass) || value.is_a?(FalseClass) || value.is_a?(Numeric) || value.is_a?(NilClass)
              @interface.fatal!("Invalid variable value: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
            end
          end
        end

        def assert_step_exists(value, keypath:)
          unless @registry.get_by_name(value)
            @interface.fatal!("Unknown step: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
          end
        end

        def assert_step_parameter_name_valid(value, expected:, keypath:)
          unless expected.include?(value)
            expected_names = expected.map { |name| "'#{name}'" }.join(", ")
            @interface.fatal!("Unknown step parameter: '#{value}' at '#{Utilities::keypath_to_s(keypath)}'. Expected one of: [#{expected_names}].")
          end
        end

        def assert_step_parameter_value_valid(value, keypath:)
          if value.is_a?(String)
            unless %r(^((?:[^\$]*(?:(?:\\\$)|(?<!\\)\$\((?:ENV:)?[A-Z_]+\))*)*)$) =~ value
              @interface.fatal!("Invalid step parameter value: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
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
              @interface.fatal!("Invalid step parameter value: '#{value}' at: '#{Utilities::keypath_to_s(keypath)}'.")
            end
          end
        end

        def assert_step_parameter_exists(value, expected:, keypath:)
          unless value.include?(expected)
            @interface.fatal!("Missing value for required step parameter: '#{expected}' at: '#{Utilities::keypath_to_s(keypath)}'.")
          end
        end

      end

    end
  end
end
