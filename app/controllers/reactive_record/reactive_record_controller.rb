module ReactiveRecord
  
  class ReactiveRecordController < ActionController::Base #ApplicationController
  
    #todo make sure this is right... looks like model.id always returns the attribute value of the primary key regardless of what the key is. 

    def fetch
      @data = Hash.new {|hash, key| hash[key] = Hash.new}
      params[:pending_fetches].each do |fetch_item|
        if parent = Object.const_get(fetch_item[0]).send("find_by_#{fetch_item[1]}", fetch_item[2])
          @data[fetch_item[0]][parent.id] ||= ReactiveRecord::Cache.build_json_hash parent
          fetch_association(parent, fetch_item[3..-1])
        end
      end
      render :json => @data
    end
                  
    def fetch_association(item, associations)
      @data[item.class.name][item.id] ||= ReactiveRecord::Cache.build_json_hash(item)
      unless associations.empty?
        association_value = item.send(associations.first)
        if association_value.respond_to? :each
          association_value.each do |item|
            fetch_association(item, associations[1..-1])
          end
        else
          fetch_association(association_value, associations[1..-1])
        end
      end
    end
  
  end
  
end