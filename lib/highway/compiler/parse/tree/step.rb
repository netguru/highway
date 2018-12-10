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
          # @param name [String] Name of the step.
          # @param parameters [Hash<String, Object>] Parameters of the step.
          # @param preset [String] Parent preset of the step.
          # @param stage [String] Parent stage of the step.
          # @param index [Numeric] Index of step in its scope.
          def initialize(name:, parameters:, preset:, stage:, index:)
            @name = name
            @parameters = parameters
            @preset = preset
            @stage = stage
            @index = index
          end

          # @return [String] Name of the step.
          attr_reader :name

          # @return [Hash<String, Object>] Parameters of the step.
          attr_reader :parameters

          # @return [String] Parent preset of the step.
          attr_reader :preset

          # @return [String] Parent stage of the step.
          attr_reader :stage

          # @return [Numeric] Index of step in its scope.
          attr_reader :index

        end

      end
    end
  end
end
