# JSON:API Server Example

This is an application that provides a simple example of a [JSON:API](http://jsonapi.org) compliant server written in [Ruby on Rails](http://rubyonrails.org). It's based on the [cerebris/peeps](https://github.com/cerebris/peeps) application that is the demo of [cerebris/jsonapi-resources](https://github.com/cerebris/jsonapi-resources).

## Instructions
Follow these instructions to create the application.


1. Create the rails app.
    ```bash
    rails new json_api_server_example --skip-javascript --skip-test-unit --database=postgresql
    ```
2. Add [`rspec-rails`](https://github.com/rspec/rspec-rails) and [`spring-commands-rspec`](https://github.com/jonleighton/spring-commands-rspec) to the Gemfile and run the rspec generator. The `spring-commands-rspec` is added to make the test suite run within spring (and therefore a bit faster).

    ```ruby
    # Gemfile
    group :development, :test do
      # ...
      gem "rspec-rails", "~> 3.1.0"
      gem "spring-commands-rspec"
    end
    ```
    ```bash
    bundle install
    bin/rails generate rspec:install
    bundle exec spring binstub rspec
    ```
3. Create the database.  
    ```bash
    bin/rake db:create
    ```
4. Add the [`jsonapi-resources`](https://github.com/cerebris/jsonapi-resources) gem to the Gemfile and remove unnecessary gems. `jsonapi-resource` enables us to easily define an interface for our resources that complies with JSON:API specification.  

    ```ruby
    # Gemfile
    source "https://rubygems.org"

    gem "rails", "4.2.0"
    gem "pg"
    gem "jsonapi-resources"

    group :development, :test do
      gem "byebug"
      gem "spring"
    end
    ```
5. Configure the environment.  

    ```ruby
    # config/environments/development.rb
    # avoids autoloading strangeness and thread safety issues
    config.eager_load = true
    # don't generate helpers because we're not going to use them
    config.generators.helper = false
    ```
6. Subclass `ApplicationController` from `JSONAPI::ResourceController`.  
    This will give controllers that inherit from `ApplicationController` the ability to respond to JSON:API formatted requests.

    ```ruby
    # app/controllers/application_controller.rb
    class ApplicationController < JSONAPI::ResourceController
      # ...
    end
    ```
7. Create the resources directory where we'll add our resources classes.
    ```bash
    mkdir app/resources
    ```
8. Create a model.
    ```bash
    bin/rails g model Sport name:string
    bin/rake db:migrate Sports --skip-assets
    ```
9. Create a resource.
    ```ruby
    # app/resources/sport_resource.rb
    class SportResource < JSONAPI::Resource
      attributes :name
    end
    ```
10. Setup the routes.
    ```ruby
    # config/routes.rb
    Rails.application.routes.draw do
      jsonapi_resources :sports
    end
    ```
11. Create a test.
