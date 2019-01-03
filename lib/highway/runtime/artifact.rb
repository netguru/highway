#
# artifact.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Runtime

    # This class represents an artifact of running a step during runtime. It
    # contains metrics (such as status and duration) as well as metadata set by
    # steps themselves.
    class Artifact

      # Initialize an instance.
      #
      # @param invocation [Highway::Compiler::Build::Output::Invocation] The invocation.
      def initialize(invocation:)
        @invocation = invocation
        @data = Hash.new()
      end

      # The invocation.
      #
      # @return [Highway::Compiler::Build::Output::Invocation]
      attr_accessor :invocation

      # Result of the step, one of: `:success`, `:failure`, `:skip`.
      #
      # @return [Symbol]
      attr_accessor :result

      # Duration of the step, in seconds.
      #
      # @return [Numeric]
      attr_accessor :duration

      # The custom data in the artifact.
      #
      # @return [Hash]
      attr_reader :data

      # Get custom data value for given key.
      #
      # @param key [String] A key.
      #
      # @return [Object, nil]
      def [](key)
        @data[key]
      end

      # Set custom data value for given key.
      #
      # @param key [String] A key.
      # @param value [Object, nil] A value.
      #
      # @return [Void]
      def []=(key, value)
        @data[key] = value
      end

    end

  end
end
