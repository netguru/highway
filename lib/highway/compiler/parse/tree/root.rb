#
# root.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/parse/tree/step"
require "highway/compiler/parse/tree/variable"

module Highway
  module Compiler
    module Parse
      module Tree

        # This class represents a root node of a parse tree. It contains other
        # nodes, such as variables and steps.
        class Root

          public

          # Initialize an instance.
          #
          # @param version [Numeric] Version of the parse tree.
          def initialize(version:)
            @version = version
            @variables = Array.new()
            @steps = Array.new()
          end

          # @return [Numeric] Version of the parse tree.
          attr_reader :version
          
          # @return [Array<Highway::Compiler::Parse::Tree::Variable>] Variables in the tree.
          attr_reader :variables

          # @return [Array<Highway::Compiler::Parse::Tree::Step>] Steps in the tree.
          attr_reader :steps

          # Add a variable to the tree.
          #
          # @param name [String] Name of the variable.
          # @param value [String] Raw value of the variable.
          # @param preset [String] Parent preset of the variable.
          def add_variable(name:, value:, preset:)
            @variables << Variable.new(name: name, value: value, preset: preset)
          end

          # Add a step to the tree.
          #
          # @param name [String] Name of the step.
          # @param parameters [Hash<String, Object>] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          # @param index [Numeric] Index of step in its scope.
          def add_step(name:, parameters:, preset:, stage:, index:)
            @steps << Step.new(name: name, parameters: parameters, preset: preset, stage: stage, index: index)
          end

        end

      end
    end
  end
end
