#
# v1.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/parse/tree/root"

module Highway
  module Compiler
    module Parse
      module Versions

        # This class is responsible for parsing a configuration file v1.
        class V1

          public

          # Initialize an instance.
          #
          # @param reporter [Highway::Interface] The interface.
          def initialize(interface:)
            @interface = interface
          end

          # Parse the configuration file v1.
          #
          # @param raw [Hash] Raw content of configuration file.
          #
          # @return [Highway::Compiler::Parse::Tree::Root]
          def parse(raw:)

            parse_tree = Parse::Tree::Root.new(version: 1)

            validate_toplevel_keys(raw: raw)

            parse_variables(raw: raw, parse_tree: parse_tree)
            parse_steps(raw: raw, parse_tree: parse_tree)

            parse_tree

          end

          private

          def validate_toplevel_keys(raw:)
            expected = %w(version variables bootstrap test deploy report)
            raw.each_key do |key|
              assert_toplevel_key_valid(key, expected: expected)
            end
          end

          def parse_variables(raw:, parse_tree:)
            variables = raw.fetch("variables", {})
            assert_value_type(variables, expected: Hash, keypath: ["variables"])
            variables.each_pair do |preset, names_and_values|
              assert_value_type(names_and_values, expected: Hash, keypath: ["variables", preset])
              names_and_values.each_pair do |name, value|
                parse_tree.add_variable(name: name, value: value, preset: preset)
              end
            end
          end

          def parse_steps(raw:, parse_tree:)
            %w(bootstrap test deploy report).each do |stage|
              presets = raw.fetch(stage, {})
              assert_value_type(presets, expected: Hash, keypath: [stage])
              presets.each_pair do |preset, steps|
                assert_value_type(steps, expected: Array, keypath: [stage, preset])
                steps.each_with_index do |step, step_index|
                  assert_value_type(step, expected: Hash, keypath: [stage, preset, step_index])
                  assert_value_length(step, expected: 1, keypath: [stage, preset, step_index])
                  assert_value_type(step.values.first, expected: Hash, keypath: [stage, preset, step.keys.first])
                  parse_tree.add_step(name: step.keys.first, parameters: step.values.first, preset: preset, stage: stage, index: step_index)
                end
              end
            end
          end

          def assert_toplevel_key_valid(actual, expected:)
            unless expected.include?(actual)
              expected_keys = expected.map { |key| "'#{key}'" }.join(", ")
              @interface.fatal!("Invalid top-level key: '#{actual}'. Expected one of: [#{expected_keys}].")
            end
          end

          def assert_value_type(actual, expected:, keypath:)
            if expected.is_a?(Class)
              unless actual.is_a?(expected)
                @interface.fatal!("Invalid type of value: '#{actual}' at: '#{keypath}'. Expected: '#{expected}', got: '#{actual.class}'.")
              end
            elsif expected.is_a?(Array)
              unless (expected.any? { |klass| actual.is_a?(klass) })
                expected_types = expected.map { |klass| "'#{klass}'"}.join(", ")
                @interface.fatal!("Invalid type of value: '#{actual}' at: '#{keypath}'. Expected one of: [#{expected_types}], got: '#{actual.class}'.")
              end
            end
          end

          def assert_value_length(actual, expected:, keypath:)
            unless actual.length == expected
              @interface.fatal!("Invalid length of value at: '#{keypath}'. Expected: #{expected}, got: #{actual}.")
            end
          end

        end

      end
    end
  end
end
