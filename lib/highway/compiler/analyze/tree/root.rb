#
# root.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/segments/text"
require "highway/compiler/analyze/tree/segments/variable"
require "highway/compiler/analyze/tree/stage"
require "highway/compiler/analyze/tree/step"
require "highway/compiler/analyze/tree/values/array"
require "highway/compiler/analyze/tree/values/hash"
require "highway/compiler/analyze/tree/values/primitive"
require "highway/compiler/analyze/tree/variable"

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class represents a root node of a semantic tree. It contains
        # other nodes, such as variables and steps.
        class Root

          public

          # Initialize an instance.
          def initialize()
            @variables = Array.new()
            @steps = Array.new()
            @stages = Array.new()
          end

          # Name of the default preset.
          #
          # @return [String]
          attr_accessor :default_preset

          # Variables in the tree.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::Variable>]
          attr_reader :variables

          # Steps in the tree.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::Step>]
          attr_reader :steps

          # Stages in the tree.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::Stage>]
          attr_reader :stages

          # Add a variable to the tree.
          #
          # @param name [String] Name of the variable.
          # @param value [Highway::Compiler::Analyze::Tree::Values::*] Value of the variable.
          # @param preset [String] Parent preset of the variable.
          #
          # @return [Void]
          def add_variable(name:, value:, preset:)
            @variables << Variable.new(name: name, value: value, preset: preset)
          end

          # Add a step to the tree.
          #
          # @param index [Integer] Index of step in its scope.
          # @param name [String] Name of the step.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Highway::Compiler::Analyze::Tree::Values::Hash] The hash value of step parameters.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          #
          # @return [Void]
          def add_step(index:, name:, step_class:, parameters:, preset:, stage:)
            @steps << Step.new(index: index, name: name, step_class: step_class, parameters: parameters, preset: preset, stage: stage)
          end


          # Add a stage to the tree.
          #
          # @param index [Integer] Index of the stage.
          # @param name [String] Name of the stage.
          # @param policy [Symbol] Execution policy of the stage.
          #
          # @return [Void]
          def add_stage(index:, name:, policy:)
            @stages << Stage.new(index: index, name: name, policy: policy)
          end

        end

      end
    end
  end
end
