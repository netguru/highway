#
# parser.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "yaml"

require "highway/compiler/parse/versions/v1"

module Highway
  module Compiler
    module Parse

      # This class is responsible for syntactic analysis of a configuration
      # file. This is the first phase of the compiler.
      class Parser

        public

        # Initialize an instance.
        #
        # @param interface [Highway::Interface] The interface.
        def initialize(interface:)
          @interface = interface
        end

        # Parse the configuration file.
        #
        # The parser is backwards compatible with previous versions of
        # configuration files.
        #
        # This method only loads the file, searches for the version declaration
        # and then delegates the wotk to parser of a particular version.
        #
        # The parser produces a parse tree which is then used by semantic
        # analysis phase to produce semantic tree.
        #
        # @param path [String] Path to configuration file.
        #
        # @return [Highway::Compiler::Parse::Tree::Root]
        def parse(path:)

          # Load the file.

          begin
            raw = YAML.load_file(path)
          rescue StandardError => error
            @interface.fatal!("The configuration file is not a valid YAML file.")
          end

          # Make sure it contains a hash.

          unless raw.is_a?(Hash)
            @interface.fatal!("The configuration file does not contain a top-level dictionary.")
          end

          # Specify the known versions and their corresponding subparsers.

          known = {
            1 => Parse::Versions::V1,
          }

          # Find and validate the version.

          unless version = (Integer(raw.fetch("version", nil)) rescue nil)
            @interface.fatal!("Missing or invalid value of: 'version'.")
          end

          unless known.keys.include?(version)
            expected_versions = known.keys.map { |v| "'#{v}'" }.join(", ")
            @interface.fatal!("Invalid value of: 'version'. Expected one of: [#{expected_versions}], got: '#{version}'.")
          end

          # Delegate the work to parser of a specific version.

          subparser = known[version].new(interface: @interface)

          # Parse and return the tree.

          subparser.parse(raw: raw)

        end

      end

    end
  end
end
