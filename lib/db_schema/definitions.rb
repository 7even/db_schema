require 'dry/equalizer'

module DbSchema
  module Definitions
    class Field
      include Dry::Equalizer(:name, :type, :primary_key?, :null?, :default)
      attr_reader :name, :type, :default

      def initialize(name:, type:, primary_key: false, null: true, default: nil)
        @name         = name.to_sym
        @type         = type.to_sym
        @primary_key  = primary_key
        @null         = null
        @default      = default
      end

      def primary_key?
        @primary_key
      end

      def null?
        !primary_key? && @null
      end

      def options
        {}.tap do |options|
          options[:null] = false unless null?
          options[:default] = default unless default.nil?
        end
      end
    end

    class Index
      include Dry::Equalizer(:name, :fields, :unique?, :condition)
      attr_reader :name, :fields, :condition

      def initialize(name:, fields:, unique: false, condition: nil)
        @name      = name.to_sym
        @fields    = fields.map(&:to_sym)
        @unique    = unique
        @condition = condition
      end

      def unique?
        @unique
      end
    end

    class ForeignKey
      include Dry::Equalizer(:name, :fields, :table, :keys, :on_update, :on_delete, :deferrable?)
      attr_reader :name, :fields, :table, :keys, :on_update, :on_delete

      def initialize(name:, fields:, table:, keys: [], on_update: :no_action, on_delete: :no_action, deferrable: false)
        @name       = name
        @fields     = fields
        @table      = table
        @keys       = keys
        @on_update  = on_update
        @on_delete  = on_delete
        @deferrable = deferrable
      end

      def references_primary_key?
        keys.empty?
      end

      def deferrable?
        @deferrable
      end

      def options
        {
          deferrable:                  deferrable?,
          foreign_key_constraint_name: name,
          on_delete:                   on_delete,
          on_update:                   on_update
        }.tap do |options|
          options[:key] = keys unless references_primary_key?
        end
      end
    end

    class Table
      include Dry::Equalizer(:name, :fields, :indices, :foreign_keys)
      attr_reader :name, :fields, :indices, :foreign_keys

      def initialize(name:, fields: [], indices: [], foreign_keys: [])
        @name         = name.to_sym
        @fields       = fields
        @indices      = indices
        @foreign_keys = foreign_keys
      end
    end
  end
end
