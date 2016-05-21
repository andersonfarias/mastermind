# Tweet Microservice
# Ruby application that periodically fetches tweets on three topics, store them into a relational database and makes them avaible via a REST API.

## Description

This is a Ruby application in Sinatra that represents a microservice to periodically fetch the lastest 10 tweets of three different topics and store them into a relational database.
It make those tweets available via a REST API, where it's possible to give a topic as an argument and the microservice will return the lasted 10 tweets for that topic that were persisted into the database.
It uses the following stack:

* [Sinatra](http://www.sinatrarb.com/): it's a lightwight HTTP client for ruby. It's used to implement the REST API.
* [Sinatra Contrib](https://github.com/sinatra/sinatra-contrib): it's a collection of common Sinatra extensions. It's used to read configuration file and respond JSON.
* [Sinatra Active Record](http://gruntjs.com/): it extends Sinatra with ActiveRecord. It's used to communicate with the relational database (ORM Layer).
* [SQLite3](https://www.sqlite.org/): it's a lightweight SQL database engine. It's used as the datastore.
* [Ruby Twitter](https://github.com/sferik/twitter): it's a A Ruby interface to the Twitter API. It's used to easly communicate with the Twitter's API.
* [Rufus Scheduler](https://github.com/jmettraux/rufus-scheduler): it's a scheduler for Ruby. It's used to schedule the task of finding the lasted tweets and store them.
* [Sinatra Cross Origin](https://github.com/britg/sinatra-cross_origin): it's a Cross Origin Request Sharing extension for Sinatra. It's used to enable CORS.

## Pre-Requisites

Before building, you will need to have installed in your machine the following tools:

* Ruby - 2.2.3+
* Bundler - 1.12.4+

## Building

  To build and run the application, first clone this repo in your machine:
  
  ```
  git clone https://github.com/andersonfarias/top-twitter-topics.git
  ```
  
  Open the terminal and go to the microservice application folder
  
  ```
  cd path_to_donwloaded_repo/tweet_microservice
  ```
  
  Execute the following command to install required libraries:
  
  ```
  bundle install
  ```
  
  Now execute this rake tasks to create the database and generate the schema:
  
  ```
  bundle exec rake db:create
  bundle exec rake db:migrate
  ```
  
  Before you can run the application, you will need credentials to access the Twitter's API. You can read the [Twitter's documentation](https://dev.twitter.com/oauth/overview) for how to get them.

  Now, we need to create 4 environment variables to store the Twitter's credentials:
  
  ```
  export TWITTER_CONSUMER_KEY="YOUR_CONSUMER_KEY"
  export TWITTER_CONSUMER_SECRET="YOUR_CONSUMER_SECRET"
  export TWITTER_ACCESS_TOKEN="YOUR_ACCESS_TOKEN"
  export TWITTER_TOKEN_SECRET="YOUR_ACCESS_SECRET"
  ```

  Run `bundle exec rackup -p 4567` to run. This will start the application at http://localhost:4567/
  
  Go to the following URL [http://localhost:4567/tweets/topics](http://localhost:4567/tweets/topics). If you get the following response, then everything is working just fine:
  
  ```
  {"topics":["healthcare","nasa","open source"]}
  ```
  
  Note that the application will run on port 4567 and that the front-end application is expecting the host to be 127.0.0.1 and port 4567. If you change any of these, you will have to change at the front-end application the new host and port.

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0