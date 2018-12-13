#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/compiler/suite"
require "highway/interface"
require "highway/runtime/runner"
require "highway/steps/registry"

module Highway

  # This class is a main entry point to Highway.
  class Main

    public

    # Initialize an instance.
    #
    # @param option_path [String] Path to the configuration file.
    # @param option_preset [String] Preset to run.
    # @param fastlane_runner [Fastlane::Runner] The fastlane runner.
    # @param fastlane_lane_context [Hash] The fastlane lane context.
    # @param mode [Symbol] The mode in which Highway is running.
    def initialize(option_path:, option_preset:, fastlane_runner:, fastlane_lane_context:, mode:)
      @option_path = option_path
      @option_preset = option_preset
      @fastlane_runner = fastlane_runner
      @fastlane_lane_context = fastlane_lane_context
      @mode = mode
    end

    # Run Highway.
    #
    # @return [Void]
    def run()

      Dir.chdir(running_dir) do

        interface = Interface.new()

        registry = Steps::Registry.new_and_load_default_library()

        compiler = Compiler::Suite.new(
          registry: registry,
          interface: interface
        )

        manifest = compiler.compile(
          path: @option_path,
          preset: @option_preset
        )

        context = Runtime::Context.new(
          fastlane_runner: @fastlane_runner,
          fastlane_lane_context: @fastlane_lane_context,
          interface: interface
        )

        runner = Runtime::Runner.new(
          manifest: manifest,
          context: context,
          interface: interface,
        )

        runner.run()

      end

    end

    private

    def running_dir
      File.expand_path(FastlaneCore::FastlaneFolder.path, "..")
    end

  end

end
