module ActiveRecord
  class Schema
    class << self
      def define(opts = {}, &block)
        new.define(opts, &block)
      end
    end

    def define(_opts = {}, &block)
      instance_eval(&block)
    end

    def create_table(table_name, _opts = {})
      table = Table.new(table_name)
      yield table
    end

    def add_index(table_name, attribute, opts = {})
    end

    def initialize
    end
  end

  class Table
    def initialize(table_name)
      @klass = table_name.gsub(/(s|es)$/, '').camelize.constantize
    end

    def boolean(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_s.casecmp('true') == 0
        end
      end
    end

    def string(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_s
        end
      end
    end

    def text(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_s
        end
      end
    end

    def integer(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_i
        end
      end
    end

    def float(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_f
        end
      end
    end

    def decimal(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          _read_attribute(attribute).to_d
        end
      end
    end

    def datetime(attribute, _opts = {})
      @klass.class_eval do
        define_method(attribute) do
          Time.parse(_read_attribute(attribute))
        end
      end
    end

    def index(opts = {}, *attributes)
    end
  end
end
