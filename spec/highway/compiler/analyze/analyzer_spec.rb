#
# analyzer_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"

describe Highway::Compiler::Analyze::Analyzer do
    before {
        @interface = HighwaySpec::Helpers::InterfaceMock.new()
        @parser = Highway::Compiler::Parse::Parser.new(interface: @interface)
        @registry = Highway::Steps::Registry.new_and_load_default_library()
        @analyzer = Highway::Compiler::Analyze::Analyzer.new(registry: @registry, interface: @interface)
    }

    it "Analyzes configuration file with V1 version" do
        parse_tree = @parser.parse(path: "spec/Supporting Files/Highwayfile.yml")
        expect(parse_tree).to_not be_nil

        sema_tree = @analyzer.analyze(parse_tree: parse_tree)
        expect(sema_tree).to_not be_nil
    end
end