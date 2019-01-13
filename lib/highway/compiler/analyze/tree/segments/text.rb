#
# text.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

module Highway
  module Compiler
    module Analyze
      module Tree
        module Segments

          # This class represents a text value segment in the semantic tree. It
          # consists of a raw text value.
          class Text

            public

            # Initialize an instance.
            #
            # @param value [String] The raw text value.
            def initialize(value)
              @value = value
            end

            # The raw text value.
            #
            # @return [String]
            attr_reader :value

          end

        end
      end
    end
  end
end
