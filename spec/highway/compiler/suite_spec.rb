#
# suite_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"
require "spec/helpers/interface_mock"

describe Highway::Compiler::Suite do
    before {
        @interface = HighwaySpec::Helpers::InterfaceMock.new()
        @registry = Highway::Steps::Registry.new_and_load_default_library()
        @suite = Highway::Compiler::Suite.new(registry: @registry, interface: @interface)
    }

    it "Runs the compiler suite and builds manifest" do
        manifest = @suite.compile(path: "spec/Supporting Files/Highwayfile.yml", preset: "staging")
        expect(manifest).to_not be_nil
    end
end