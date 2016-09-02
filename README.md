# Reactive Record

[![Join the chat at https://gitter.im/catprintlabs/reactive-record](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/reactrb/chat?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Code Climate](https://codeclimate.com/github/reactrb/reactive-record/badges/gpa.svg)](https://codeclimate.com/github/reactrb/reactive-record)
[![Gem Version](https://badge.fury.io/rb/reactive-record.svg)](https://badge.fury.io/rb/reactive-record)


#### reactive-record gives you active-record models on the client integrated with reactrb.

*"So simple its almost magic" (Amazed developer)*

#### NOTE: reactive-record >= 0.8.x depends on the reactrb gem.  You must [upgrade to reactrb](https://github.com/reactrb/reactrb#upgrading-to-reactrb)

#### NOTE: therubyracer has been removed as a dependency to allow the possibility of using other JS runtimes. Please make sure if you're upgrading that you have it (or another runtime) required in your gemfile.

You do nothing to your current active-record models except move them to the models/public directory (so they are compiled on the client as well as the server.)

* Fully integrated with [Reactrb](https://github.com/reactrb/reactrb) (which is React with a beautiful ruby dsl.)
* Takes advantage of React prerendering, and afterwards additional data is *lazy loaded* as it is needed by the client.
* Supports full CRUD access using standard Active Record features, including associations, aggregations, and errors.
* Uses model based authorization mechanism for security similar to [Hobo](http://www.hobocentral.net/manual/permissions) or [Pundit](https://github.com/elabs/pundit).
* Models and even methods within models can be selectively implemented "server-side" only.

There are no docs yet, but you may consider the test cases as a starting point, or have a look at [reactrb todo](https://reactiverb-todo.herokuapp.com/) (live demo [here.](https://reactiverb-todo.herokuapp.com/))

For best results simply use the [reactrb-rails-generator](https://github.com/reactrb/reactrb-rails-generator) to install everything you need into a new or existing rails app.

Head on over to [gitter.im](https://gitter.im/reactrb/chat) to ask any questions you might have!

Note: We have dropped suppport for the ability to have rails load the same Class *automatically* from two different files, one with server side code, and one with client side code. If you need this functionality load the following code to your config/application.rb file.  However we found from experience that this was very confusing, and you are better off to explicitly include modules as needed.

```ruby
module ::ActiveRecord
  module Core
    module ClassMethods
      def inherited(child_class)
        begin
          file = Rails.root.join('app','models',"#{child_class.name.underscore}.rb").to_s rescue nil
          begin
            require file
          rescue LoadError
          end
          # from active record:
          child_class.initialize_find_by_cache
        rescue
        end # if File.exist?(Rails.root.join('app', 'view', 'models.rb'))
        super
      end
    end
  end
end
```

## Running tests
The test suite runs in opal on a rails server, so the test database is actually the test_app's dev database.

* ```cd spec/test_app```
* ```rake db:reset``` (to prepare the "test" database)
* ```rails s```
* visit localhost:3000/spec-opal to run the suite.
Note: If any tests fail when running the entire suite, there is a good possibility that you will need to run ```rake db:reset``` to fix the database before running the tests again.
