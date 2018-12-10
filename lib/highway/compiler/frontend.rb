#
# frontend.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/compiler/analyze/analyzer"
require "highway/compiler/build/builder"
require "highway/compiler/parse/parser"

module Highway
  module Compiler

    # This class is responsible for executing all compiler stages, including
    # syntactic analysis, semantic analysis and manifest generation.
    class Frontend

      public

      # Initialize an instance.
      def initialize(reporter:, registry:)
        @reporter = reporter
        @registry = registry
      end

      def compile(path:, preset:)

        parser_reporter = @reporter.map { |message| "Failed to parse the configuration file. #{message}" }
        parser = Parse::Parser.new(reporter: parser_reporter)
        parse_tree = parser.parse(path: path)

        analyzer_reporter = @reporter.map { |message| "Failed to validate the configuration file. #{message}" }
        analyzer = Analyze::Analyzer.new(reporter: analyzer_reporter, registry: @registry)
        sema_tree = analyzer.analyze(parse_tree: parse_tree)

        builder_reporter = @reporter.map { |message| "Failed to compile the configuration file. #{message}" }
        builder = Build::Builder.new(reporter: builder_reporter)
        manifest = builder.build(sema_tree: sema_tree, preset: preset)

        manifest

      end

    end

  end
end
