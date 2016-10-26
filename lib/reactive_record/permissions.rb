module ReactiveRecord
  class AccessViolation < StandardError
    def message
      "ReactiveRecord::AccessViolation: #{super}"
    end
  end
end

class ActiveRecord::Base
  prepend AssociationExtensions

  attr_accessor :acting_user

  class << self
    attr_reader :reactive_record_association_keys
  end

  def create_permitted?
    true
  end

  def update_permitted?
    true
  end

  def destroy_permitted?
    true
  end

  def view_permitted?(attribute)
    true
  end

  def only_changed?(*attributes)
    (self.attributes.keys + self.class.reactive_record_association_keys).each do |key|
      return false if self.send("#{key}_changed?") and !attributes.include? key
    end
    true
  end

  def none_changed?(*attributes)
    attributes.each do |key|
      return false if self.send("#{key}_changed?")
    end
    true
  end

  def any_changed?(*attributes)
    attributes.each do |key|
      return true if self.send("#{key}_changed?")
    end
    false
  end

  def all_changed?(*attributes)
    attributes.each do |key|
      return false unless self.send("#{key}_changed?")
    end
    true
  end

  def check_permission_with_acting_user(user, permission, *args)
    old = acting_user
    self.acting_user = user
    if self.send(permission, *args)
      self.acting_user = old
      self
    else
      raise ReactiveRecord::AccessViolation, "for #{permission}(#{args})"
    end
  end

end

class ActionController::Base

  def acting_user
  end

end
