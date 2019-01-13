#
# step.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class represents a step node in a parse tree. It contains
        # information about a single step and its parameters.
        class Step

          public

          # Initialize an instance.
          #
          # @param index [Integer] Index of step in its scope.
          # @param name [String] Name of the step.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Highway::Compiler::Analyze::Tree::Values::Hash] The hash value of step parameters.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          def initialize(index:, name:, step_class:, parameters:, preset:, stage:)
            @index = index
            @name = name
            @step_class = step_class
            @parameters = parameters
            @preset = preset
            @stage = stage
          end

          # Index of step in its scope.
          #
          # @return [Integer]
          attr_reader :index

          # Name of the step.
          #
          # @return [String]
          attr_reader :name

          # Definition class of the step.
          #
          # @return [Class]
          attr_reader :step_class

          # The hash value of step parameters.
          #
          # @return [Highway::Compiler::Analyze::Tree::Values::Hash]
          attr_reader :parameters

          # Parent preset of the step.
          #
          # @return [String]
          attr_reader :preset

          # Parent stage of the step.
          #
          # @return [String]
          attr_reader :stage

        end

      end
    end
  end
end
