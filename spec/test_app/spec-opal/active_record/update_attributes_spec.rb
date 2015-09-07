require 'spec_helper'
#require 'user'
#require 'todo_item'
#require 'address'

use_case "creating and updating a record" do
  
  first_it "make sure user does not exist" do
    set_acting_user "super-user"
    React::IsomorphicHelpers.load_context
    ReactiveRecord.load do 
      user = User.find_by_first_name("Jon") 
      user and user.id
    end.then_test do |id|
      expect(id).to be_empty
      React::IsomorphicHelpers.load_context
    end
  end
  
  now_it "can create a new record" do
    jon = User.new({first_name: "Jon", last_name: "Weaver"})
    test do
      expect(jon.attributes).to eq({first_name: "Jon", last_name: "Weaver"})
    end
  end
  
  now_it "has no id" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.id).to be_nil }
  end
  
  and_it "is new" do  
    jon = User.find_by_first_name("Jon")
    test { expect(jon).to be_new }
  end
    
  and_it "has been changed" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.changed?).to be_truthy }
  end
  
  and_it "can be saved" do
    jon = User.find_by_first_name("Jon")
    jon.save.while_waiting { expect(jon.saving?).to be_truthy }
  end

  now_it "has an id" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.id).not_to be_nil }
  end

  and_it "is not saving" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.saving?).to be_falsy }
  end
  
  and_it "is not changed" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.changed?).to be_falsy }
  end
  
  and_it "can be reloaded" do
    React::IsomorphicHelpers.load_context
    ReactiveRecord.load do
      User.find_by_first_name("Jon").last_name
    end.then_test do |last_name|
      expect(last_name).to be("Weaver")
    end
  end

  now_it "has an id" do
    jon = User.find_by_first_name("Jon")
    test { expect(jon.id).not_to be_nil }
  end
  
  and_it "can be updated and saved" do
    jon = User.find_by_last_name("Weaver")
    jon.email = "jon@catprint.com"
    jon.save.then do
      React::IsomorphicHelpers.load_context
      ReactiveRecord.load do
        User.find_by_last_name("Weaver").email
      end.then_test do |email|
        expect(email).to be("jon@catprint.com")
      end
    end
  end
  
  and_it "can be deleted" do
    jon = User.find_by_last_name("Weaver")
    jon.destroy.then_test { expect(jon.id).to be_nil }
  end

  now_it "does not exist in the database" do
    React::IsomorphicHelpers.load_context
    ReactiveRecord.load do 
      User.find_by_first_name("Jon").id
    end.then_test do |id|
      expect(id).to be_empty
    end
  end 
  
  now_it "is time to test a one way writable attribute (might be used for a password - see the user model)" do
    jon = User.new({name: "Jon Weaver"})
    jon.save.then do
      React::IsomorphicHelpers.load_context
      ReactiveRecord.load do
        User.find_by_last_name("Weaver").first_name
      end.then_test do |first_name|
        expect(first_name).to be("Jon")
      end
    end
  end
  
  and_it "is time to delete it" do
    jon = User.find_by_last_name("Weaver")
    jon.destroy.then_test { expect(jon.id).to be_nil }
  end
  
end
      
    