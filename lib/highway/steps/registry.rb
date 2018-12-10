#
# registry.rb
# Copyright © 2018 Netguru S.A. All rights reserved.
#

require "highway/steps/step"

module Highway
  module Steps
  
    # This class is responsible for keeping track of available steps.
    class Registry

      public

      # Initialize an instance.
      def initialize()
        @classes = Set.new()
      end

      # Initialize an instance and automatically load all steps in the library.
      #
      # @return [Highway::Steps::Registry] The registry.
      def self.new_load_library()

        registry = self.new()

        Dir[File.expand_path('library/*.rb', File.dirname(__FILE__))].each do |file|
          require(file)
        end

        unless Highway::Steps.const_defined?("Library")
          return
        end

        Highway::Steps::Library.constants.each do |step_symbol|
          step_class = Highway::Steps::Library.const_get(step_symbol)
          if step_class_valid?(step_class)
            registry.register(step_class)
          end
        end

        registry

      end

      # Add a new step definition class to the registry. Is it is already
      # registered, this does nothing.
      #
      # @param step_class [Class] The step definition class.
      #
      # @raise [ArgumentError] If trying to register an invalid step class.
      #
      # @return [Void]
      def register(step_class)
        if self.class.step_class_valid?(step_class)
          @classes.add(step_class)
        else
          raise ArgumentError.new("Step class `#{step_class}` is invalid.")
        end
      end

      # Remove a step definition class from the registry. If it is not
      # registered, this does nothing.
      #
      # @param step_class [Class] The step definition class.
      #
      # @return [Void]
      def unregister(step_class)
        @classes.remove(step_class)
      end

      # Get a step definition class by its name.
      #
      # @param step_name [String] The step name.
      #
      # @return [Class, NilClass] The step definition class or `nil`.
      def get_by_name(step_name)
        @classes.find { |step_class| step_class.name == step_name }
      end

      private

      def self.step_class_valid?(step_class)
        step_class.is_a?(Class) && step_class < Highway::Steps::Step
      end

    end

  end
end
