#
# array_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Array do
    it "Validates array with String type" do 
        array = Highway::Steps::Types::Array.new(Highway::Steps::Types::String.new())
        expect(array.typecheck("Test")).to be_nil
        expect(array.typecheck(["Test", "Test2"])).to_not be_nil
        expect(array.typecheck({:test => 123})).to be_nil
    end
end