#
# bool_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Bool do
    it "Typechecks and coerces a bool value." do 
        bool = Highway::Steps::Types::Bool.new()
        expect(bool.typecheck("true")).to eq(true)
        expect(bool.typecheck("yes")).to eq(true)
        expect(bool.typecheck(true)).to eq(true)
        expect(bool.typecheck(1)).to eq(true)

        expect(bool.typecheck("false")).to eq(false)
        expect(bool.typecheck("no")).to eq(false)
        expect(bool.typecheck(false)).to eq(false)
        expect(bool.typecheck(0)).to eq(false)

        expect(bool.typecheck("fals")).to be_nil
        expect(bool.typecheck("tru")).to be_nil
    end
end