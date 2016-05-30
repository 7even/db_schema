module DbSchema
  module Definitions
    module Field
      class Base
        include Dry::Equalizer(:name, :class, :primary_key?, :options)
        attr_reader :name, :default

        def initialize(name, primary_key: false, null: true, default: nil, **attributes)
          @name        = name
          @primary_key = primary_key
          @null        = null
          @default     = default
          @attributes  = attributes
        end

        def primary_key?
          @primary_key
        end

        def null?
          !primary_key? && @null
        end

        def options
          attributes.tap do |options|
            options[:null] = false unless null?
            options[:default] = default unless default.nil?
          end
        end

        def attributes
          self.class.valid_attributes.reduce({}) do |hash, attr_name|
            if attr_value = @attributes[attr_name]
              hash.merge(attr_name => attr_value)
            else
              hash
            end
          end
        end

        class << self
          def register(*types)
            types.each do |type|
              Field.registry[type] = self
            end
          end

          def attributes(*attr_names)
            valid_attributes.push(*attr_names)
          end

          def valid_attributes
            @valid_attributes ||= []
          end

          def type
            Field.registry.key(self)
          end
        end
      end
    end
  end
end
