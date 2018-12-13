#
# step.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
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
          # @param name [String] Name of the step.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          # @param index [Integer] Index of step in its scope.
          def initialize(name:, step_class:, parameters:, preset:, stage:, index:)
            @name = name
            @step_class = step_class
            @parameters = parameters
            @preset = preset
            @stage = stage
            @index = index
          end

          # Name of the step.
          #
          # @return [String]
          attr_reader :name

          # Definition class of the step.
          #
          # @return [Class]
          attr_reader :step_class

          # Parameters of the step.
          #
          # @return [Array<Highway::Compiler::Analyze::Tree::Value>]
          attr_reader :parameters

          # Parent preset of the step.
          #
          # @return [String]
          attr_reader :preset

          # Parent stage of the step.
          #
          # @return [String]
          attr_reader :stage

          # Index of step in its scope.
          #
          # @return [Integer]
          attr_reader :index

        end

      end
    end
  end
end
