#
# anyof.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/types/any"

module Highway
  module Steps
    module Types

      # This class represents a parameter type that's any of given types.
      class AnyOf < Types::Any

        public

        # Initialize an instance.
        #
        # The first variadic argument accepts hashes containing `tag` and
        # `type`. Tags are used to later denote which type the value falls to.
        #
        # Consider a step which defines the following parameter:
        #
        # ```
        # Types::AnyOf(
        #   {
        #     tag: :channel,
        #     type: Types::String.regex(/#\w+/)
        #   },
        #   {
        #     tag: :user,
        #     type: Types::String.regex(/@\w+/)
        #   },
        # )
        # ```
        #
        # Later, when a step which defined such a parameter receives a value,
        # it doesn't receive just a plain `String`, it receives:
        #
        # ```
        # { tag: :channel, value: "#general" }
        # ```
        #
        # Thus retaining the information about which type definition matched
        # the value.
        #
        # @param type_defs [Array] Type definitions. First match wins.
        # @param validate [Proc] A custom value validation block.
        def initialize(*type_defs, validate: nil)
          super(validate: validate)
          @type_defs = type_defs
        end

        # Typecheck and coerce a value if possible.
        #
        # This method returns a typechecked and coerced value or `nil` if value
        # has invalid type and can't be coerced.
        #
        # @param value [Object] A value.
        #
        # @return [Object, nil]
        def typecheck(value)
          typechecked_defs = @type_defs.map { |type_def| {tag: typedef[:tag], value: typedef[:type].typecheck_and_validate(value) } }
          typechecked_defs.find { |typechecked_def| typechecked_def[:value] != nil }
        end

      end

    end
  end
end
