#
# root.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/tree/parameter"
require "highway/compiler/analyze/tree/segment"
require "highway/compiler/analyze/tree/stage"
require "highway/compiler/analyze/tree/step"
require "highway/compiler/analyze/tree/value"
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

          # @return [String] Name of the default preset.
          attr_accessor :default_preset

          # @return [Array<Highway::Compiler::Analyze::Tree::Variable>] Variables in the tree.
          attr_reader :variables

          # @return [Array<Highway::Compiler::Analyze::Tree::Step>] Steps in the tree.
          attr_reader :steps

          # @return [Array<Highway::Compiler::Analyze::Tree::Stage>] Stages in the tree.
          attr_reader :stages

          # Add a variable to the tree.
          #
          # @param name [String] Name of the variable.
          # @param value [Highway::Compiler::Analyze::Tree::Value] Value of the variable.
          # @param preset [String] Parent preset of the variable.
          def add_variable(name:, value:, preset:)
            @variables << Variable.new(name: name, value: value, preset: preset)
          end

          # Add a step to the tree.
          #
          # @param name [String] Name of the step.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          # @param index [Numeric] Index of step in its scope.
          def add_step(name:, step_class:, parameters:, preset:, stage:, index:, policy:)
            @steps << Step.new(name: name, step_class: step_class, parameters: parameters, preset: preset, stage: stage, index: index)
          end
          

          # Add a stage to the tree.
          #
          # @param name [String] Name of the stage.
          # @param policy [:normal, :always] Execution policy of the stage.
          # @param index [Numeric] Index of the stage.
          def add_stage(name:, policy:, index:)
            @stages << Stage.new(name: name, policy: policy, index: index)
          end

        end

      end
    end
  end
end
