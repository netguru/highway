#
# url_spec.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway"

describe Highway::Steps::Types::Url do
    it("Typechecks url") do 
        url = Highway::Steps::Types::Url.new()
        expect(url.typecheck("http://lorem.com")).to_not be_nil
        expect(url.typecheck("http://lorem.com/ipsum.html")).to_not be_nil
        expect(url.typecheck("lorem.com")).to be_nil
        expect(url.typecheck("lorem.com/ipsum.html")).to be_nil
        expect(url.typecheck("lorem://ipsum?testing=true")).to be_nil
    end
end