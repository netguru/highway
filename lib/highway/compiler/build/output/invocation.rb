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
          # @param step_class [Class] Definition class of the step.
          # @param parameters [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step invocation.
          # @param policy [:normal, :always] Execution policy of the step invocation.
          def initialize(step_class:, parameters:, policy:)
            @step_class = step_class
            @parameters = parameters
            @policy = policy
          end

          # @return [Class] Definition class of the step.
          attr_reader :step_class

          # @return [Array<Highway::Compiler::Analyze::Tree::Parameter>] Parameters of the step invocation.
          attr_reader :parameters

          # @return [:normal, :always] Execution policy of the step invocation.
          attr_reader :policy

        end
        
      end
    end
  end
end
