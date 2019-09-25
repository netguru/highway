#
# any_of_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::AnyOf do
    it "Validates given types" do
        any_types = Highway::Steps::Types::AnyOf.new(
            string: Highway::Steps::Types::String.new(),
            bool: Highway::Steps::Types::Bool.new()
        )
        expect(any_types.typecheck("Test")).to_not be_nil
        expect(any_types.typecheck({:test => "Hash"})).to be_nil
        expect(any_types.typecheck(true)).to_not be_nil
    end
end