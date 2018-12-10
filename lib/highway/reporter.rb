#
# reporter.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

module Highway

  # This class is responsible for interfacing with the user (e.g. displaying
  # error messages), using Fastlane UI mechanism underneath.
  class Reporter

    public

    # Initialize an instance.
    #
    # @param fastlane_ui [Fastlane::UI] The Fastlane UI instance.
    def initialize(fastlane_ui:, transform: nil)
      @fastlane_ui = fastlane_ui
      @transform = transform || proc { |message| message }
    end

    # Display an error message and abort.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def fatal!(message)
      @fastlane_ui.user_error!(decorate(message))
    end

    # Display an error message.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def error(message)
      @fastlane_ui.error(decorate(message))
    end

    # Display a warning message.
    #
    # @param message [String] The warning message.
    #
    # @return [Void]
    def warning(message)
      @fastlane_ui.important(decorate(message))
    end

    # Display a note message.
    #
    # @param message [String] The note message.
    #
    # @return [Void]
    def note(message)
      @fastlane_ui.message(decorate(message))
    end

    # Display a success message.
    #
    # @param message [String] The success message.
    #
    # @return [Void]
    def success(message)
      @fastlane_ui.success(decorate(message))
    end

    # Pullback the UI with a block that transforms messages.
    #
    # @param transform [Proc] The transforming block.
    def map(&other_transform)
      self.class.new(fastlane_ui: @fastlane_ui, transform: proc { |message| other_transform.call(@transform.call(message)) })
    end

    private

    def decorate(message)
      "[Highway] #{@transform.call(message)}"
    end

  end
  
end
