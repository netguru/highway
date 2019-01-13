#
# interface.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"
require "terminal-table"

module Highway

  # This class is responsible for interfacing with the user (e.g. displaying
  # error messages), using Fastlane UI mechanism underneath.
  class Interface

    public

    # Initialize an instance.
    def initialize()
      @history = []
    end

    # Display a raw unformatted message.
    #
    # @param message [String] The raw message.
    #
    # @return [Void]
    def raw(message)
      puts(message.to_s)
      @history << message.to_s
    end

    # Display a whitespace, unless it's already displayed.
    #
    # @return [Void]
    def whitespace()
      unless (@history.last || "").end_with?("\n")
        raw("\n")
      end
    end

    # Display a success message.
    #
    # @param message [String] The success message.
    #
    # @return [Void]
    def success(message)
      FastlaneCore::UI.success(message.to_s)
      @history << message.to_s
    end

    # Display an error message and abort.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def fatal!(message)
      FastlaneCore::UI.user_error!(message.to_s)
    end

    # Display an error message.
    #
    # @param message [String] The error message.
    #
    # @return [Void]
    def error(message)
      FastlaneCore::UI.error(message.to_s)
      @history << message.to_s
    end

    # Display a warning message.
    #
    # @param message [String] The warning message.
    #
    # @return [Void]
    def warning(message)
      FastlaneCore::UI.important(message.to_s)
      @history << message.to_s
    end

    # Display a note message.
    #
    # @param message [String] The note message.
    #
    # @return [Void]
    def note(message)
      FastlaneCore::UI.message(message.to_s)
      @history << message.to_s
    end

    # Display a success header message.
    #
    # @param message [String] The header message.
    #
    # @return [Void]
    def header_success(message)
      whitespace()
      success("--- #{message}".bold)
    end

    # Display a warning header message.
    #
    # @param message [String] The header message.
    #
    # @return [Void]
    def header_warning(message)
      whitespace()
      warning("--- #{message}".bold)
    end

    # Display a table padded with whitespace.
    #
    # @param title [String] Table title.
    # @param headings [Array<String>] Heading titles.
    # @param rows [Array<String>] Row values.
    #
    # @return [Void]
    def table(title: nil, headings: [], rows:)

      whitespace()

      table = Terminal::Table.new(
        title: title,
        headings: headings,
        rows: FastlaneCore::PrintTable.transform_output(rows)
      )

      raw(table)

      whitespace()

    end

  end

end
