#
# main.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/compiler/suite"
require "highway/environment"
require "highway/interface"
require "highway/runtime/context"
require "highway/runtime/runner"
require "highway/steps/registry"

module Highway

  # This class is a main entry point to Highway.
  class Main

    public

    # Initialize an instance.
    #
    # @param entrypoint [Symbol] The entry point.
    # @param path [String] Path to the configuration file.
    # @param preset [String] Preset to run.
    # @param fastlane_runner [Fastlane::Runner] The fastlane runner.
    # @param fastlane_lane_context [Hash] The fastlane lane context.
    def initialize(entrypoint:, path:, preset:, fastlane_runner:, fastlane_lane_context:)
      @entrypoint = entrypoint
      @path = path
      @preset = preset
      @fastlane_runner = fastlane_runner
      @fastlane_lane_context = fastlane_lane_context
    end

    # Run Highway.
    #
    # @return [Void]
    def run()

      # Always run Highway in the root directory of the project. This should
      # standardize the legacy directory behavior described here:
      # https://docs.fastlane.tools/advanced/fastlane/#directory-behavior.

      Dir.chdir(running_dir) do

        # Print the header, similar to Fastlane's "driving the lane".

        interface.success("Driving the Highway preset '#{@preset}' 🏎")

        # Construct a steps registry and load steps from the default library
        # by requiring files in `highway/steps/library` and registering all
        # classes that inherit from `Highway::Steps::Step`.

        registry = Steps::Registry.new_and_load_default_library()

        # Set up the compiler and compile Highway configuration file into the
        # build manifest. See `highway/compiler/parse`, `highway/compiler/analyze`
        # and `highway/compiler/build` for more information.

        compiler = Compiler::Suite.new(
          registry: registry,
          interface: interface,
        )

        manifest = compiler.compile(
          path: File.expand_path(@path, running_dir),
          preset: @preset,
        )

        # At this point the compilation is done. Now, construct the runtime
        # context, set up the runner and run the compiled build manifest.

        context = Runtime::Context.new(
          fastlane_runner: @fastlane_runner,
          fastlane_lane_context: @fastlane_lane_context,
          env: env,
          interface: interface,
        )

        runner = Runtime::Runner.new(
          manifest: manifest,
          context: context,
          interface: interface,
        )

        runner.run()

        # We can safely print the success summary message because fatal errors
        # will be catched by the rescue block below.

        @interface.whitespace()
        @interface.success("Wubba lubba dub dub, Highway preset '#{@preset}' has succeeded!")

      end

    rescue StandardError => error

      # Unless the error contains any message we should print it right now but
      # as an error so that we can still control the output.

      interface.error(error) unless error.message.empty?

      # We should take care of the unnecessary printing of Fastlane lane
      # context but only if we're running from lane entry point (otherwise we
      # could affect other actions and fallback lanes user has set up).
      #
      # So, if we're running from lane entry point, we should clear the lane
      # context before raising a fatal error. If we're in verbose mode, we
      # should additionally print it before cleaning.

      if @entrypoint == :lane
        report_fastlane_lane_context() if env.verbose?
        clear_fastlane_lane_context()
      end

      # Now we throw a fatal error that tells Fastlane to abort.

      interface.whitespace()
      interface.fatal!("Highway preset '#{@preset}' has failed with one or more errors. Please examine the above log.")

    end

    private

    # The environment instance.
    #
    # @return [Highway::Environment]
    def env
      @env ||= Environment.new()
    end

    # The interface instance.
    #
    # @return [Highway::Interface]
    def interface
      @interface ||= Interface.new()
    end

    # The running directory to be used.
    #
    # @return [Path]
    def running_dir
      File.expand_path(File.join(FastlaneCore::FastlaneFolder.path, ".."))
    end

    # Report Fastlane lane context as a table.
    #
    # @return [Void]
    def report_fastlane_lane_context()

      lane_context_rows = @fastlane_lane_context.collect do |key, content|
        [key, content.to_s]
      end

      interface.table(
        title: "Fastlane Context".yellow,
        rows: lane_context_rows
      )

    end

    # Clear all values in Fastlane lane context.
    #
    # @return [Void]
    def clear_fastlane_lane_context()
      @fastlane_lane_context.clear()
    end

  end

end
