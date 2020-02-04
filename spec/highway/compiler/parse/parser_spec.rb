#
# parser_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"

describe Highway::Compiler::Parse::Parser do
    before {
        @interface = HighwaySpec::Helpers::InterfaceMock.new()
        @parser = Highway::Compiler::Parse::Parser.new(interface: @interface)
    }

    it "Parses configuration file with V1 version" do
        parse_tree = @parser.parse(path: "spec/Supporting Files/Highwayfile.yml")
        expect(parse_tree).to_not be_nil
    end
end