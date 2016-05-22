# Mastermind RESTful API
# Ruby RESTful JSON API to play the Mastermind game application.

## Description

This is a Ruby application, in Sinatra, that implements a RESTful JSON API for playing, in single play mode, the Mastermind game.
It supports multiple users hitting the API at the same time playing different games of Mastermind.
You can checkout the rules at [Wikipedia](https://en.wikipedia.org/wiki/Mastermind_(board_game)#Gameplay_and_rules)

The API only has two endpoints which are outlined below.

* POST /new_game
* POST /guess

You can checkout the [swagger.io](./swagger.io) file for the complete API specification.

Basically, the API enables you to start a new game and guessing the correct pattern. For every guessing, the API will give you the number of exact and near matches.

You can choose from 8 different colors, duplicate allowed, and you will have up to 8 attempts to guess the correct pattern.
If you correctly guess the pattern, you win! Otherwise, you lose after 8 attempts.

The valid colors are:

* 'R' for red
* 'B' for blue
* 'G' for gray
* 'Y' for yellow
* 'O' for orange
* 'P' for purple
* 'C' for cyan
* 'M' for magenta

After you start a new game, it wil give you a unique game_key, which you will be using to guess.

The application uses the following stack:

* [Sinatra](http://www.sinatrarb.com/): it's a lightwight HTTP client for ruby. It's used to implement the REST API.
* [Sinatra Contrib](https://github.com/sinatra/sinatra-contrib): it's a collection of common Sinatra extensions.
* [Sinatra Cross Origin](https://github.com/britg/sinatra-cross_origin): it's a Cross Origin Request Sharing extension for Sinatra. It's used to enable CORS.
* [Mongoid](https://docs.mongodb.com/ecosystem/tutorial/ruby-mongoid-tutorial/): it's an ODM (Object-Document-Mapper) framework for MongoDB in Ruby.
* [MongoDB](https://www.mongodb.com/): it's a NoSQL database.

## Pre-Requisites

Before building, you will need to have installed in your machine the following tools:

* Ruby - 2.2.3+
* Bundler - 1.12.4+
* MongoDB - 3.2.x

## Building

  To build and run the application, first clone this repo in your machine:
  
  ```
  git clone https://github.com/andersonfarias/mastermind.git
  ```
  
  Open the terminal and go to application folder
  
  ```
  cd mastermind
  ```
  
  Execute the following command to install required libraries:
  
  ```
  bundle install
  ```
  
  Before you can run the application, you will need a running MongoDB instance. You can easily follow a [tutorial](https://docs.mongodb.com/manual/installation/) to get MongoDB running into your own machine or use a [cloud instance](https://mlab.com/).
  
  If you decided to locally install and run MongoDB, then you just need to run it on default port. The application will start, connect to MongoDB and create everything it needs.

  If you're using a remote instance, or cloud, you will have to change the mongoid.yml file and setup a URL for the database. You can find this file at the config folder.

  Run `bundle exec rackup -p 4567` to run. This will start the API at http://localhost:4567/
  
  Openup a terminal and execute the following command to start a new game
  
  ```
  curl --data "{ \"user\": \"Anderson Farias\" }" http://localhost:4567/new_game
  ```
  
  You should see a response like this
  
  ```javascript
  {"colors":["R","B","G","Y","O","P","C","M"],"code_length":8,"game_key":"574142d7f293448b42000000","num_guesses":0,"past_results":[],"solved":false}
  ```
  
  Have fun!

## License

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0
