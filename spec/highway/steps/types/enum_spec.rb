#
# enum_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Enum do
    it "Typechecks enum value." do 
        enum = Highway::Steps::Types::Enum.new("Development", "Production")
        expect(enum.typecheck("Development")).to_not be_nil
        expect(enum.typecheck("Production")).to_not be_nil
        expect(enum.typecheck("Staging")).to be_nil
    end
end