require 'spec_helper'
require 'user'
require 'todo_item'
require 'address'
require 'components/test'

describe "prerendering" do

  it "passes" do
    expect(true).to be_truthy
  end

  it "will not return an id before preloading" do
    expect(User.find_by_email("mitch@catprint.com").id).not_to eq(1)
  end

  async "preloaded the records" do
    `window.ClientSidePrerenderDataInterface.ReactiveRecordInitialData = undefined` rescue nil
    container = Element[Document.body].append('<div></div>').children.last
    complete = lambda do
      React::IsomorphicHelpers.load_context
      run_async do
        mitch = User.find_by_email("mitch@catprint.com")
        expect(mitch.id).to eq(1)
        expect(mitch.first_name).to eq("Mitch")
        expect(mitch.todo_items.first.title).to eq("a todo for mitch")
        expect(mitch.address.zip).to eq("14617")
        expect(mitch.todo_items.find_string("mitch").first.title).to eq("a todo for mitch")
      end
    end
    `container.load('/test', complete)`
  end

  async "does not preload everything" do
    `window.ClientSidePrerenderDataInterface.ReactiveRecordInitialData = undefined` rescue nil
    container = Element[Document.body].append('<div></div>').children.last
    complete = lambda do
      React::IsomorphicHelpers.load_context
      run_async do
        expect(User.find_by_email("mitch@catprint.com").last_name).to eq("")
      end
    end
    `container.load('/test', complete)`
  end

end
