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
          # @param version [Integer] Version of the parse tree.
          def initialize(version:)
            @version = version
            @variables = Array.new()
            @steps = Array.new()
          end

          # Version of the parse tree.
          #
          # @return [Integer]
          attr_reader :version

          # Variables in the tree.
          #
          # @return [Array<Highway::Compiler::Parse::Tree::Variable>]
          attr_reader :variables

          # Steps in the tree.
          #
          # @return [Array<Highway::Compiler::Parse::Tree::Step>]
          attr_reader :steps

          # Add a variable to the tree.
          #
          # @param name [String] Name of the variable.
          # @param value [String] Raw value of the variable.
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
          # @param parameters [Hash] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          #
          # @return [Void]
          def add_step(name:, parameters:, preset:, stage:, index:)
            @steps << Step.new(index: index, name: name, parameters: parameters, preset: preset, stage: stage)
          end

        end

      end
    end
  end
end
