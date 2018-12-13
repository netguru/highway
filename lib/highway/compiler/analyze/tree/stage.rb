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
          # @param policy [Symbol] Execution policy of the stage.
          # @param index [Integer] Index of the stage.
          def initialize(name:, policy:, index:)
            @name = name
            @policy = policy
            @index = index
          end

          # Name of the stage.
          #
          # @return [String]
          attr_reader :name

          # Execution policy of the stage.
          #
          # @return [Symbol]
          attr_reader :policy

          # Index of the stage.
          #
          # @return [Integer]
          attr_reader :index

        end

      end
    end
  end
end
