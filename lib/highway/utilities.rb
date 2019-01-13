#
# utilities.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
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

    # Join keypath into a string.
    #
    # @param keypath [Array<String>] A keypath.
    #
    # @return [String]
    def self.keypath_to_s(keypath)
      keypath.join(".")
    end

    # Recursively check whether the subject includes an element.
    #
    # @param subject [Object] A haystack.
    # @param element [Object] A needle.
    #
    # @return [Boolean]
    def self.recursive_include?(subject, element)
      if subject.is_a?(Hash)
        recursive_include?(subject.values, element)
      elsif subject.respond_to?(:any?)
        subject.any? { |value| recursive_include?(value, element) }
      else
        subject == element
      end
    end

  end

end
