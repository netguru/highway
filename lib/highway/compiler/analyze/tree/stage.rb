#
# stage.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree

        # This class represents a stage note in the semantic tree. It contains
        # information about stage order and execution policy.
        class Stage

          public

          # Initialize an instance.
          #
          # @param name [String] Name of the stage.
          # @param policy [:normal, :always] Execution policy of the stage.
          # @param index [Numeric] Index of the stage.
          def initialize(name:, policy:, index:)
            @name = name
            @policy = policy
            @index = index
          end

          # @return [String] Name of the stage.
          attr_reader :name

          # @return [:normal, :always] Execution policy of the stage.
          attr_reader :policy

          # @return [Numeric] Index of the stage.
          attr_reader :index

        end

      end
    end
  end
end
