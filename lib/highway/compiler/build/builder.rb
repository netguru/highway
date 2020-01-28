#
# builder.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/root"
require "highway/compiler/build/output/manifest"
require "highway/utilities"

module Highway
  module Compiler
    module Build

      # This class is responsible for manifest generation based on the semantic
      # tree. This is the third and final phase of the compiler.
      class Builder

        public

        # Initialize an instance.
        #
        # @param interface [Highway::Interface] The interface.
        def initialize(interface:)
          @interface = interface
        end

        # Build the manifst.
        #
        # The builder resolves variables and steps in the semantic tree for
        # given preset and builds concrete invocations.
        #
        # The builder produces a manifest that is later executed by runner.
        #
        # @param sema_tree [Highway::Compiler::Analyze::Tree::Root] The semantic tree.
        #
        # return [Highway::Compiler::Build::Output::Manifest]
        def build(sema_tree:, preset:)

          manifest = Build::Output::Manifest.new()

          manifest.preset = preset

          variables = resolve_variables(sema_tree: sema_tree, preset: preset)
          steps = resolve_steps(sema_tree: sema_tree, preset: preset)

          build_invocations(stages: sema_tree.stages, variables: variables, steps: steps, manifest: manifest)

          manifest

        end

        private

        def resolve_variables(sema_tree:, preset:)

          exact_variables = sema_tree.variables.select { |variable|
            variable.preset == preset
          }

          default_variables = sema_tree.variables.select { |variable|
            variable.preset == sema_tree.default_preset && !exact_variables.any? { |exact_variable| exact_variable.name == variable.name }
          }

          default_variables + exact_variables

        end

        def resolve_steps(sema_tree:, preset:)

          stages = sema_tree.stages.sort_by { |stage| stage.index }

          stages.flat_map { |stage|

            exact_steps = sema_tree.steps.select { |step|
              step.preset == preset && step.stage == stage.name
            }

            default_steps = sema_tree.steps.select { |step|
              step.preset == sema_tree.default_preset && step.stage == stage.name
            }

            exact_steps = exact_steps.sort_by { |step| step.index }
            default_steps = default_steps.sort_by { |step| step.index }

            exact_steps = nil if exact_steps.empty?
            default_steps = nil if default_steps.empty?

            exact_steps || default_steps || Array.new()

          }

        end

        def build_invocations(stages:, variables:, steps:, manifest:)
          steps.each_with_index do |step, index|
            stage = stages.find { |stage| stage.name == step.stage }
            parameters = build_value(value: step.parameters, variables: variables)
            keypath = [step.stage, step.preset, step.name]
            manifest.add_invocation(index: index + 1, step_class: step.step_class, parameters: parameters, policy: stage.policy, keypath: keypath)
          end
        end

        def build_value(value:, variables:)
          if value.is_a?(Analyze::Tree::Values::Primitive)
            Analyze::Tree::Values::Primitive.new(
              build_value_segments(segments: value.segments, variables: variables)
            )
          elsif value.is_a?(Analyze::Tree::Values::Array)
            Analyze::Tree::Values::Array.new(
              value.children.map { |value|
                build_value(value: value, variables: variables)
              }
            )
          elsif value.is_a?(Analyze::Tree::Values::Hash)
            Analyze::Tree::Values::Hash.new(
              Utilities::hash_map(value.children) { |key, value|
                [key, build_value(value: value, variables: variables)]
              }
            )
          end
        end

        def build_value_segments(segments:, variables:)

          resolved = segments.flat_map { |segment|
            if segment.is_a?(Analyze::Tree::Segments::Variable) && segment.scope == :static
              variable = variables.find { |variable| variable.name == segment.name }
              build_value_segments(segments: variable.value.segments, variables: variables)
            else
              [segment]
            end
          }

          reduced = resolved.reduce([]) { |memo, segment|
            if last = memo.pop()
              if last.is_a?(Analyze::Tree::Segments::Text) && segment.is_a?(Analyze::Tree::Segments::Text)
                memo + [Analyze::Tree::Segments::Text.new(last.value + segment.value)]
              else
                memo + [last, segment]
              end
            else
              [segment]
            end
          }

          reduced

        end

      end

    end
  end
end
