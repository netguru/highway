#
# step.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Parse
      module Tree

        # This class represents a step node in a parse tree. It contains
        # information about a single step and its parameters.
        class Step

          public

          # Initialize an instance.
          #
          # @param index [Integer] Index of step in its scope.
          # @param name [String] Name of the step.
          # @param parameters [Hash] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          def initialize(index:, name:, parameters:, preset:, stage:)
            @name = name
            @parameters = parameters
            @preset = preset
            @stage = stage
            @index = index
          end

          # Name of the step.
          #
          # @return [String]
          attr_reader :name

          # Parameters of the step.
          #
          # @return [Hash]
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
