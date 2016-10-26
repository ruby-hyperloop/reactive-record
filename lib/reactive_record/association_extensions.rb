module AssociationExtensions
  module ClassMethods
    [:has_many, :belongs_to, :composed_of].each do |macro|
      define_method macro.to_sym do |attr_name, *args, &block|
        define_method "#{attr_name}_changed?".to_sym do
          instance_variable_get "@reactive_record_#{attr_name}_changed".to_sym
        end
        (@reactive_record_association_keys ||= []) << attr_name
        super(attr_name, *args, &block)
      end
    end

    def belongs_to(attr_name, scope = nil, options = {})
      define_method "#{attr_name}_is?".to_sym do |model|
        send(options[:foreign_key] || "#{attr_name}_id") == model.id
      end
      super(attr_name, scope, options)
    end
  end

  def self.prepended(base)
    class << base
      prepend ClassMethods
    end
  end
end
