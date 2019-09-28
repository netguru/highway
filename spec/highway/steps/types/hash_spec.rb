#
# hash_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Hash do
    it "Validates Hash with String type" do
        hash = Highway::Steps::Types::Hash.new(Highway::Steps::Types::String.new())
        expect(hash.typecheck({:scheme => "staging"})).to_not be_nil
        expect(hash.typecheck({:scheme => nil})).to be_nil
        expect(hash.typecheck({:scheme => ["staging", "release"]})).to be_nil
    end
end