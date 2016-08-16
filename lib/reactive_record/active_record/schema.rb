module ActiveRecord
  class Schema
    class << self
      def define(opts = {}, &block)
        new.define(opts, &block)
      end
    end

    def initialize
    end

    def define(_opts = {}, &block)
      instance_eval(&block)
    end

    def create_table(table_name, _opts = {})
      table = Table.new(table_name)
      yield(table) if table.klass
    end

    def add_index(table_name, attribute, opts = {})
    end
  end

  class Table
    TYPES = [:boolean, :string, :text, :integer, :float, :decimal, :date, :datetime]

    attr_accessor :klass

    class << self
      def return_or_convert(value, type)
        if value.is_a? ReactiveRecord::Base::DummyValue
          value
        elsif value.nil?
          nil
        else
          converted_value(value, type)
        end
      end

      def converted_value(value, type) # rubocop:disable Metrics/CyclomaticComplexity
        case type
        when :boolean         then value.to_s.casecmp('true').zero?
        when :string, :text   then value.to_s
        when :integer         then value.to_i
        when :float, :decimal then value.to_f
        when :date            then Date.parse(value)
        when :datetime        then Time.parse(value)
        else value
        end
      end
    end

    def initialize(table_name)
      # This is VERY ugly, TODO: make this better somehow
      @klass =
        table_name.singularize.camelize.constantize rescue table_name.camelize.constantize rescue nil
    end

    TYPES.each do |type|
      define_method(type) do |attribute, _opts = {}|
        @klass.class_eval do
          return if method_defined?(attribute)
          define_method(attribute) do
            ActiveRecord::Table.return_or_convert(@backing_record.reactive_get!(attribute), type)
          end

          define_method("#{attribute}?") do
            !!ActiveRecord::Table.return_or_convert(@backing_record.reactive_get!(attribute), type)
          end
        end
      end
    end

    def index(opts = {}, *attributes)
    end
  end
end
