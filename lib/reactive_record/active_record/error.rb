module ActiveModel
  class Error
    attr_reader :messages

    def initialize(msgs = {})
      @messages = msgs || {}
      @messages.each { |attribute, messages| @messages[attribute] = messages.uniq }
    end

    def [](attribute)
      messages[attribute]
    end

    def add(attr, attr_messages)
      messages[attr.to_sym] = attr_messages
    end

    def delete(attribute)
      messages.delete(attribute)
    end

    def empty?
      messages.empty?
    end
  end
end
