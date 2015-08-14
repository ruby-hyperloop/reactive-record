module ReactiveRecord

  class Collection

    def initialize(target_klass, owner = nil, association = nil, *vector)
      if association and (association.macro != :has_many or association.klass != target_klass)
        message = "unimplemented association #{owner} :#{association.macro} #{association.attribute}"
        `console.error(#{message})`
      end
      @owner = owner  # can be nil if this is an outer most scope
      @association = association
      @target_klass = target_klass
      if owner and !owner.id and !owner.vector
        @synced_collection = @collection = []
      else
        @vector = vector.count == 0 ? [target_klass] : vector
      end
      @scopes = {}
    end

    def all
      unless @collection
        @collection = []
        if ids = ReactiveRecord::Base.fetch_from_db([*@vector, "*all"])
          ids.each do |id|
            @collection << @target_klass.find_by(@target_klass.primary_key => id)
          end
        else
          ReactiveRecord::Base.load_from_db(*@vector, "*all")
          @collection << ReactiveRecord::Base.new_from_vector(@target_klass, nil, *@vector, "*")
        end
      end
      @collection
    end


    def ==(other_collection)
      if @collection
        @collection == other_collection.all
      else
        !other_collection.instance_variable_get(:@collection)
      end
    end

    def apply_scope(scope, *args)
      # The value returned is another ReactiveRecordCollection with the scope added to the vector
      # no additional action is taken
      scope = [scope, *args] if args.count > 0
      @scopes[scope] ||= Collection.new(@target_klass, @owner, @association, *@vector, [scope])
    end

    def proxy_association
      @association
    end


    def <<(item)
      inverse_of = @association.inverse_of
      if @owner and inverse_of = @association.inverse_of
        item.attributes[inverse_of].attributes[@association.attribute].delete(item) if item.attributes[inverse_of] and item.attributes[inverse_of].attributes[@association.attribute]
        item.attributes[inverse_of] = @owner
        backing_record = item.instance_variable_get(:@backing_record)
        React::State.set_state(backing_record, inverse_of, @owner) unless backing_record.data_loading?
      end
      all << item unless all.include? item
      self
    end

    def replace(new_array)
      return new_array if @collection == new_array
      if @collection
        @collection.dup.each { |item| delete(item) }
      else
        @collection = []
      end
      new_array.each { |item| self << item }
      new_array
    end

    def delete(item)
      if @owner and inverse_of = @association.inverse_of
        item.attributes[inverse_of] = nil
        backing_record = item.instance_variable_get(:@backing_record)
        React::State.set_state(backing_record, inverse_of, nil) unless backing_record.data_loading?
      end
      all.delete(item)
    end

    def method_missing(method, *args, &block)
      if [].respond_to? method
        all.send(method, *args, &block)
      elsif @target_klass.respond_to? method
        apply_scope(method, *args)
      else
        super
      end
    end

  end

end
