#
# invocation.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Build
      module Output

        # This class represents a step invocation in the build manifest. It
        # contains information about step definition class, parameters and
        # execution policy.
        class Invocation

          public

          # Initialize an instance.
          #
          # @param index [Integer] Index of invocation, 1-based.
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step invocation.
          # @param policy [Symbol] Execution policy of the step invocation.
          def initialize(index:, step_class:, parameters:, policy:)
            @index = index
            @step_class = step_class
            @parameters = parameters
            @policy = policy
          end

          # Index of invocation, 1-based.
          #
          # @return [Integer]
          attr_reader :index

          # Definition class of the step.
          #
          # @return [Class]
          attr_reader :step_class

          # Parameters of the step invocation.
          # @return [Array<Highway::Compiler::Analyze::Tree::Parameter>]
          attr_reader :parameters

          # Execution policy of the step invocation.
          #
          # @return [Symbol]
          attr_reader :policy

          # An identifier of the invocation, joined by index and step name.
          #
          # @return [String]
          def identifier
            return "#{index}-#{step_class.name}"
          end

        end

      end
    end
  end
end
