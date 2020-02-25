#
# compound_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"

describe Highway::Steps::Parameters::Compound do

    before {
        @parameters = [
            Highway::Steps::Parameters::Single.new(
                name: "app_identifier",
                required: true,
                type: Highway::Steps::Types::String.new()
              ),
              Highway::Steps::Parameters::Single.new(
                name: "build_number",
                required: false,
                type: Highway::Steps::Types::String.new()
              )
        ]

        @interface = HighwaySpec::Helpers::InterfaceMock.new()
    }

    it "Type checks and validates compound parameter" do
        compound = Highway::Steps::Parameters::Compound.new(name: "root", required: true, defaults: true, children: @parameters)
        values = { "app_identifier" => "12345", "build_number" => "123" }
        expect(compound.typecheck_and_validate(values, interface: @interface, keypath: [])).to_not be_nil
    end

    it "Type checks and pre-validates compound parameter" do
        compound = Highway::Steps::Parameters::Compound.new(name: "root", required: true, defaults: true, children: @parameters)
        values = { "app_identifier" => "12345", "build_number" => "123" }
        expect(compound.typecheck_and_prevalidate(values, interface: @interface, keypath: [])).to_not be_nil
    end
end