#
# interface.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

module Highway

  # This class is responsible for interfacing with the user (e.g. displaying
  # error messages), using Fastlane UI mechanism underneath.
  class Interface

    public

    # Initialize an instance.
    #
    # @param transform [Proc] A transforming block.
    def initialize(transform: nil)
      @transform = transform || :itself.to_proc
    end

    # Display a success message.
    #
    # @param message [String] The success message.
    #
    # @return [Void]
    def success(message)
      FastlaneCore::UI.success(message)
    end

    # Display an error message and abort.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def fatal!(message)
      FastlaneCore::UI.user_error!(message)
    end

    # Display an error message.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def error(message)
      FastlaneCore::UI.error(message)
    end

    # Display a warning message.
    #
    # @param message [String] The warning message.
    #
    # @return [Void]
    def warning(message)
      FastlaneCore::UI.important(message)
    end

    # Display a note message.
    #
    # @param message [String] The note message.
    #
    # @return [Void]
    def note(message)
      FastlaneCore::UI.message(message)
    end

    # Display a header message.
    #
    # @param message [String] The header message.
    #
    # @return [Void]
    def header(message)
      FastlaneCore::UI.header(message)
    end

    # Map the interface by transforming messages with a block.
    #
    # @param other [Proc] A transforming block.
    #
    # @return [Highway::Interface]
    def map(&other)
      self.class.new(transform: lambda { |message| other.call(@transform.call(message)) })
    end

  end

end
