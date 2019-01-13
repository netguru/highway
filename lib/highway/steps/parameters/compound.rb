#
# compound.rb
# Copyright © 2019 Netguru S.A. All rights reserved.
#

require "highway/steps/parameters/base"

module Highway
  module Steps
    module Parameters

      # This class is used in step definition classes to represent a compound
      # parameter of a step that consists of other parameters.
      class Compound < Parameters::Base

        # Initialize an instance.
        #
        # @param name [String] Name of the parameter.
        # @param required [Boolean] Whether parametr is required.
        # @param defaults [Boolean] Whether to construct default value from child parameters.
        # @param children [Array<Highway::Steps::Parameters::*>] Child parameters.
        def initialize(name:, required:, defaults: false, children:)
          @name = name
          @required = required
          @defaults = defaults
          @children = children
        end

        # Child parameters.
        #
        # @return [Array<Highway::Steps::Parameters::*>]
        attr_reader :children

        # Find a child parameter definition by name.
        #
        # @param name [String] Name of the parameter
        #
        # @return [Highway::Steps::Parameters::*]
        def find_child_for_name(name)
          @children.find { |child| child.name == name }
        end

        # Default value of the parameter.
        #
        # @return [Hash, nil]
        def default
          if @defaults
            Utilities::hash_map(@children) { |child| [child.name, child.default] }
          end
        end

        # Typecheck and validate a value of the parameter.
        #
        # This method returns typechecked, coerced and validated value or raises
        # a fatal error if value has invalid type, can't be coerced or is
        # othweriwse invalid.
        #
        # @param value [Object] A value.
        # @param interface [Highway::Interface] An interface instance.
        # @param keypath [Array<String>] A keypath to be used for debugging purposes.
        #
        # @return [Object]
        def typecheck_and_validate(values, interface:, keypath: [])

          unless values.is_a?(Hash)
            interface.fatal!("Invalid type of value for parameter: '#{Utilities::keypath_to_s(keypath)}'.")
          end

          @children.each { |child|
            if child.is_required? && !values.keys.include?(child.name) && child.default == nil
              interface.fatal!("Missing value for required parameter: '#{Utilities::keypath_to_s(keypath + [child.name])}'.")
            end
          }

          values.keys.each { |name|
            unless find_child_for_name(name)
              expected = @children.map { |child| "'#{child.name}'" }.join(", ")
              interface.fatal!("Unknown parameter: '#{Utilities::keypath_to_s(keypath + [name])}'. Expected one of: [#{expected}].")
            end
          }

          typechecked = Utilities::hash_map(values) { |name, value|
            child = find_child_for_name(name)
            [name, child.typecheck_and_validate(value, interface: interface, keypath: keypath + [name])]
          }

          (default || {}).merge(typechecked)

        end

        # Typecheck and prevalidate a value of the parameter. This method is
        # used during the initial prevalidation of step parameter values before
        # evaluating all the values.
        #
        # This method works in a similar way to `typecheck_and_validate` with
        # one difference: if it encounters a single parameter whose value
        # is (or contains) `:ignore` symbol, it doesn't perform any typechecking
        # and validation on it. That way, the caller can specify which values
        # should be fully validated and which should be ignored.
        #
        # @param value [Object] A value.
        # @param interface [Highway::Interface] An interface instance.
        # @param keypath [Array<String>] A keypath to be used for debugging purposes.
        #
        # @return [Void]
        def typecheck_and_prevalidate(values, interface:, keypath: [])

          unless values.is_a?(Hash)
            interface.fatal!("Invalid type of value for parameter: '#{Utilities::keypath_to_s(keypath)}'.")
          end

          @children.each { |child|
            if child.is_required? && !values.keys.include?(child.name) && child.default == nil
              interface.fatal!("Missing value for required parameter: '#{Utilities::keypath_to_s(keypath + [child.name])}'.")
            end
          }

          values.keys.each { |name|
            unless find_child_for_name(name)
              expected = @children.map { |child| "'#{child.name}'" }.join(", ")
              interface.fatal!("Unknown parameter: '#{Utilities::keypath_to_s(keypath + [name])}'. Expected one of: [#{expected}].")
            end
          }

          values.each_pair { |name, value|
            if (child = find_child_for_name(name))
              if child.is_a?(Parameters::Compound)
                child.typecheck_and_prevalidate(value, interface: interface, keypath: keypath + [name])
              elsif !Utilities::recursive_include?(value, :ignore)
                child.typecheck_and_validate(value, interface: interface, keypath: keypath + [name])
              end
            end
          }

        end

      end

    end
  end
end
