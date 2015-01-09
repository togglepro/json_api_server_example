# JSON:API Server Example

This is an application that provides a simple example of a [JSON:API](http://jsonapi.org) compliant server written in [Ruby on Rails](http://rubyonrails.org). It's based on the [cerebris/peeps](https://github.com/cerebris/peeps) application that is the demo of [cerebris/jsonapi-resources](https://github.com/cerebris/jsonapi-resources).

## Instructions
Follow these instructions to create the application.


1. Create the rails app.

    ```bash
    rails new json_api_server_example --skip-javascript --skip-test-unit
    ```

2. Create the database.  

    ```bash
    bin/rake db:create
    ```

3. Edit the Gemfile (the application's dependencies).

    * Remove unnecessary gems.
    * Add the [`jsonapi-resources`](https://github.com/cerebris/jsonapi-resources) to easily define an interface for our resources that complies with JSON:API specification.
    * Add `rspec-rails`, `spring-commands-rspec`, and `shoulda-matchers` for the test infrastructure.
    * Add `factory_girl_rails` to generate factories to make testing easier.

    ```ruby
    # Gemfile
    source "https://rubygems.org"

    gem "rails", "4.2.0"
    gem "pg"
    gem "jsonapi-resources"

    group :development, :test do
      gem "byebug"
      gem "spring"
      gem "rspec-rails", "~> 3.1.0"
      gem "spring-commands-rspec"
      gem "factory_girl_rails", "~> 4.5.0"
    end

    group :test do
      gem "shoulda-matchers", require: false
    end
    ```
    ```bash
    bundle install
    bin/rails generate rspec:install
    bundle exec spring binstub rspec
    ```

4. Configure the environment.  

    ```ruby
    # config/environments/development.rb
    # avoids autoloading strangeness and thread safety issues
    config.eager_load = true
    # don't generate helpers because we're not going to use them
    config.generators.helper = false
    ```

5. Subclass `ApplicationController` from `JSONAPI::ResourceController`.  
    This will give controllers that inherit from `ApplicationController` the ability to respond to JSON:API formatted requests.

    ```ruby
    # app/controllers/application_controller.rb
    class ApplicationController < JSONAPI::ResourceController
    end
    ```

6. Create the resources directory where we'll add our resources classes.  

    ```bash
    mkdir app/resources
    ```

7. Create a model, test that it worked, and add a factory.  

    ```bash
    bin/rails g model Sport name:string
    bin/rake db:migrate Sports --skip-assets
    ```
    ```ruby
    # spec/models/sport_spec.rb
    RSpec.describe Sport, type: :model do
      it { is_expected.to have_attribute :name }
    end
    ```
    ```ruby
    # spec/factories/sports.rb
    FactoryGirl.define do
      factory :sport do
        name "Basketball"
      end
    end
    ```

8. Create a resource.  

    ```ruby
    # app/resources/sport_resource.rb
    class SportResource < JSONAPI::Resource
      attributes :name
    end
    ```

9. Setup the routes.  

    ```ruby
    # config/routes.rb
    Rails.application.routes.draw do
      jsonapi_resources :sports
    end
    ```

10. Test that the sports resource is accessible via the API. This is just a simple set of tests to show that everything works and will be updated later as we add additional functionality.

    ```ruby
    # spec/controllers/sports_controller_spec.rb
    require 'rails_helper'

    RSpec.describe SportsController, :type => :controller do
      describe "POST create" do
        it "responds with a 201 status" do
          post :create, sports: FactoryGirl.attributes_for(:sport)
          expect(response.status).to eq 201
        end
      end
      describe "GET show" do
        it "responds with a 200 status" do
          get :show, id: FactoryGirl.create(:sport)
          expect(response.status).to eq 200
        end
      end
      describe "PUT update" do
        let! :sport do
          FactoryGirl.create(:sport)
        end
        it "updates the resource and responds with a 200 status" do
          expect(sport.name).to eq "Basketball"
          put :update, id: sport, sports: { name: "basketball" }
          expect(sport.reload.name).to eq "basketball"
          expect(response.status).to eq 200
        end
      end
      describe "GET index" do
        it "responds with a 200 status" do
          get :index
          expect(response.status).to eq 200
        end
      end
      describe "DELETE destroy" do
        it "responds with a 200 status" do
          sport = FactoryGirl.create(:sport)
          delete :destroy, id: sport
          expect(Sport.find_by(id: sport)).to be_nil
          expect(response.status).to eq 204
        end
      end
    end
    ```

11. Test that the sports resource is serialized into JSON with the correct format.

    First, to DRY up the code, create an example group that will be added to all resource specs.
    ```ruby
    # spec/rails_helper.rb
    # This will require all files in the support directory.
    # ...
    Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }
    ```
    ```ruby
    # spec/support/example_groups/resource_example_group.rb
    module ResourceExampleGroup
      extend ActiveSupport::Concern

      included do
        require "jsonapi/resource_serializer"
        let :serializer do
          JSONAPI::ResourceSerializer.new(described_class)
        end
        let :model do
          FactoryGirl.build_stubbed(
            described_class._model_class.model_name.element,
            id: 1001
          )
        end
        let :resource do
          described_class.new(model)
        end
        let :serialized_hash do
          serializer.serialize_to_hash(resource)
        end
      end

      RSpec.configure do |config|
        config.include(self, type: :resource, file_path: %r(spec/resources))
      end
    end

    ```
    Then, test that the serialized sport resource matches our expectation.
    ```ruby
    # spec/resources/sport_resource_spec.rb
    require "rails_helper"

    describe SportResource do
      let :expected_serialized_hash do
        {
          "sports" => {
            "id" => 1001,
            "name" => "Basketball"
          }
        }
      end
      it "serializes the sport into the correct JSON format" do
        expect(serialized_hash).to eq(expected_serialized_hash)
      end
    end

    ```

12. Start a development server and try the API out via curl.

    ```bash
    bin/rails server
    ```
    ```bash
    curl -i -H "Accept: application/json" -H "Content-Type: application/json" -X POST -d '{"sports": {"name": "Basketball"}}' http://localhost:3000/sports
    ```
    ```bash
    HTTP/1.1 201 Created
    X-Frame-Options: SAMEORIGIN
    X-Xss-Protection: 1; mode=block
    X-Content-Type-Options: nosniff
    Content-Type: application/json; charset=utf-8
    Etag: W/"51eb95f4b3dc2f26a423d3072646f26e"
    Cache-Control: max-age=0, private, must-revalidate
    X-Request-Id: 4dd8b179-366e-408f-a692-c87479979894
    X-Runtime: 0.028043
    Server: WEBrick/1.3.1 (Ruby/2.2.0/2014-12-25)
    Date: Fri, 09 Jan 2015 14:46:21 GMT
    Content-Length: 39
    Connection: Keep-Alive

    {"sports":{"id":1,"name":"Basketball"}}
    ```
    ```bash
    curl http://localhost:3000/sports/1
    ```
    ```bash
    {"sports":{"id":1,"name":"Basketball"}}
    ```
    ```bash
    curl -H "Accept: application/json" -H "Content-Type: application/json" -X PUT -d '{"sports":{"name": "basketball"}}' http://localhost:3000/sports/1
    ```
    ```bash
    {"sports":{"id":1,"name":"basketball"}}
    ```
    ```bash
    curl http://localhost:3000/sports
    ```
    ```bash
    {"sports":[{"id":1,"name":"basketball"}]}
    ```
    ```bash
    curl -i -X DELETE http://localhost:3000/sports/1
    ```
    ```bash
    HTTP/1.1 204 No Content
    ```
