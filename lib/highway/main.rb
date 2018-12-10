#
# runner.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "fastlane"

require "highway/compiler/frontend"
require "highway/runtime/runner"
require "highway/steps/registry"
require "highway/reporter"

module Highway

  # A class responsible for running Highway.
  class Main

    # Initialize a runner with a bunch of Fastlane dependencies.
    #
    # @param fastlane_options [Hash<String, Object>] The Fastlane action options.
    # @param fastlane_runner [Fastlane::Runner] The Fastlane runner.
    # @param fastlane_lane_context [Hash<String, Object>] The Fastlane lane context.
    # @param fastlane_ui [Fastlane::UI] The Fastlane UI.
    def initialize(fastlane_options:, fastlane_runner:, fastlane_lane_context:, fastlane_ui:)
      @fastlane_options = fastlane_options
      @fastlane_runner = fastlane_runner
      @fastlane_lane_context = fastlane_lane_context
      @fastlane_ui = fastlane_ui
    end

    # Run Highway. Called directly from `run_highway` Fastlane action.
    def run()

      reporter = Highway::Reporter.new(fastlane_ui: @fastlane_ui)

      registry = Highway::Steps::Registry.new_load_library()

      compiler = Compiler::Frontend.new(
        reporter: reporter,
        registry: registry
      )

      manifest = compiler.compile(
        path: @fastlane_options[:highwayfile],
        preset: @fastlane_options[:preset]
      )

      context = Runtime::Context.new(
        fastlane_options: @fastlane_options,
        fastlane_runner: @fastlane_runner,
        fastlane_lane_context: @fastlane_lane_context,
        reporter: reporter
      )

      runner = Runtime::Runner.new(
        context: context,
        manifest: manifest,
        reporter: reporter
      )

      runner.run()

    end

  end

end
