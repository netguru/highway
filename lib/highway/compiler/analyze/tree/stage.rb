#
# stage.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
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
          # @param index [Integer] Index of the stage.
          # @param name [String] Name of the stage.
          # @param policy [Symbol] Execution policy of the stage.
          def initialize(index:, name:, policy:)
            @index = index
            @name = name
            @policy = policy
          end

          # Index of the stage.
          #
          # @return [Integer]
          attr_reader :index

          # Name of the stage.
          #
          # @return [String]
          attr_reader :name

          # Execution policy of the stage.
          #
          # @return [Symbol]
          attr_reader :policy

        end

      end
    end
  end
end
