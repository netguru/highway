#
# report.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway
  module Runtime

    # This class represents a report of running a step during runtime. It
    # contains metrics (such as status and duration) as well as metadata set by
    # steps themselves.
    class Report

      # Initialize an instance.
      #
      # @param invocation [Highway::Compiler::Build::Output::Invocation] The invocation.
      # @param context [Highway::Runtime::Context] The runtime context.
      def initialize(invocation:, context:)
        @invocation = invocation
        @context = context
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

      # An error that the step failed with, if any.
      #
      # @return [FastlaneCore::Interface::FastlaneException, nil]
      attr_accessor :error

      # Duration of the step, in seconds.
      #
      # @return [Numeric]
      attr_accessor :duration

      # The custom data in the report.
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

      # Prepare an artifact file with a given name and return its path.
      #
      # @param name [String] An artifact file name.
      #
      # @return [String]
      def prepare_artifact_file(name)
        File.join(@context.artifacts_dir, "#{invocation.identifier}-#{name}")
      end

      # Prepare an artifact temporary directory and return its path.
      #
      # @return [String]
      def prepare_artifact_temp_dir()
        Dir.mktmpdir()
      end

    end

  end
end
