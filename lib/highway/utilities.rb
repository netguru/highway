#
# utilities.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

module Highway

  # This class contains a collection of utility functions used throughout the
  # codebase.
  class Utilities

    public

    # Map pais of keys and values and combine them again into a Hash.
    #
    # @param subject [Hash] An input hash.
    # @param transform [Proc] A transformation block.
    #
    # @return [Hash]
    def self.hash_map(subject, &transform)
      Hash[subject.map(&transform)]
    end

  end

end
