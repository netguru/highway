#
# number_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Number do
    it "Validates whether value is Number type" do
        number = Highway::Steps::Types::Number.new()
        expect(number.typecheck(1.0)).to_not be_nil
        expect(number.typecheck(51234123)).to_not be_nil
        expect(number.typecheck("1")).to be_nil
    end
end