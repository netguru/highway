#
# suite.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/analyzer"
require "highway/compiler/build/builder"
require "highway/compiler/parse/parser"

module Highway
  module Compiler

    # This class is responsible for executing all compiler stages, including
    # syntactic analysis, semantic analysis and manifest generation.
    class Suite

      public

      # Initialize an instance.
      #
      # @param registry [Highway::Steps::Registry] The registry of steps.
      # @param interface [Highway::Inteface] The interface.
      def initialize(registry:, interface:)
        @registry = registry
        @interface = interface
      end

      # Run the compiler suite.
      #
      # @param path [String] Path to the configuration file.
      # @param preset [String] Preset to compile.
      #
      # @return [Highway::Compiler::Build::Output::Manifest]
      def compile(path:, preset:)

        parser_interface = @interface.map { |message| "Failed to parse the configuration file. #{message}" }
        parser = Parse::Parser.new(interface: parser_interface)
        parse_tree = parser.parse(path: path)

        analyzer_interface = @interface.map { |message| "Failed to validate the configuration file. #{message}" }
        analyzer = Analyze::Analyzer.new(registry: @registry, interface: analyzer_interface)
        sema_tree = analyzer.analyze(parse_tree: parse_tree)

        builder_interface = @interface.map { |message| "Failed to compile the configuration file. #{message}" }
        builder = Build::Builder.new(interface: builder_interface)
        manifest = builder.build(sema_tree: sema_tree, preset: preset)

        manifest

      end

    end

  end
end
