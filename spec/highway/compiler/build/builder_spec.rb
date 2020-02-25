#
# builder_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"

describe Highway::Compiler::Build::Builder do
    before {
        @interface = HighwaySpec::Helpers::InterfaceMock.new()
        @parser = Highway::Compiler::Parse::Parser.new(interface: @interface)
        @registry = Highway::Steps::Registry.new_and_load_default_library()
        @analyzer = Highway::Compiler::Analyze::Analyzer.new(registry: @registry, interface: @interface)
        @builder = Highway::Compiler::Build::Builder.new(interface: @interface)
    }

    it "Builds the manifest" do
        parse_tree = @parser.parse(path: "spec/Supporting Files/Highwayfile.yml")
        expect(parse_tree).to_not be_nil

        sema_tree = @analyzer.analyze(parse_tree: parse_tree)
        expect(sema_tree).to_not be_nil

        manifest = @builder.build(sema_tree: sema_tree, preset: "staging")
        expect(manifest).to_not be_nil
    end
end