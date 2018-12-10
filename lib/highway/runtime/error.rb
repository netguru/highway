#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Runtime

    # This class represents an error caprured during invocation in runtime.
    class CapturedError

      public 

      # Initialize an instance.
      #
      # @param invocation [Highway::Compiler::Build::Output::Invocation] Invocaton during which the error was captured.
      # @param error [StandardError] A captured error.
      def initialize(invocation:, error:)
        @invocation = invocation
        @error = error
      end

      # An invocation during which the error was caprutred.
      #
      # @return [Highway::Compiler::Build::Output::Invocation]
      attr_reader :invocation

      # A captured error.
      #
      # @return [StandardError]
      attr_reader :error

    end

  end
end
