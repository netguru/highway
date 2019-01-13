#
# step.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/parameters/compound"

module Highway
  module Steps

    # This class serves as a base class for all step definition classes. It
    # contains a common API and some useful utilities.
    class Step

      public

      # Name of the step as it appears in configuration file.
      #
      # @return [String]
      def self.name
        raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
      end

      # Parameters that this step recognizes.
      #
      # @return [Array<Highway::Steps::Parameters::*>]
      def self.parameters
        raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
      end

      # The root parameter that nests all parameters of the step.
      #
      # @return [Highway::Steps::Parameters::Compound]
      def self.root_parameter
        return Parameters::Compound.new(name: "root", required: true, defaults: true, children: parameters)
      end

      # Run the step in given context containing inputs and Fastlane runner.
      #
      # @param parameters [Hash] Parameters of the step.
      # @param context [Highway::Runtime::Context] The runtime context.
      # @param report [Highway::Runtime::Report] The current runtime report.
      #
      # @return [Void]
      def self.run(parameters:, context:, report:)
        raise NotImplementedError.new("You must override `#{__method__.to_s}` in `#{self.class.to_s}`.")
      end

    end

  end
end
