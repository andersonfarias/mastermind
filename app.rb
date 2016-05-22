require 'i18n'

require 'mongo'
require 'mongoid'

require 'json'

require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/config_file'
require 'sinatra/cross_origin'

require './models'
require './validators'

#   Mastermind implements a RESTful API for playing, in single play mode, the Mastermind game.
#   It supports multiple users hitting the API at the same time playing different games of Mastermind.
#   You can checkout the rules at <a href="https://en.wikipedia.org/wiki/Mastermind_(board_game)#Gameplay_and_rules">wikipedia</a>
#   The API only has two endpoints which are outlined below.
#   <ul>
#      <li>POST /new_game</li>
#      <li>POST /guess</li>
#   </ul>
#   You can checkout the <a href="./swagger.io">swagger.io<a> file for the API specification.
#   Basically, the API enables you to start a new game and guessing the correct pattern.
#   For every guessing, the API will give you the number of exact and near matches.
#   You can choose from 8 different colors (duplicate allowed) and you will have up to 8 tryies to guess the correct pattern.
#   If you correctly guess the pattern, you win! Otherwise, you lose after the 8 tryies.
#   The valid colors are:
#   <ul>
#      <li>'R' for red</li>
#      <li>'B' for blue</li>
#      <li>'G' for gray</li>
#      <li>'Y' for yellow</li>
#      <li>'O' for orange</li>
#      <li>'P' for purple</li>
#      <li>'C' for cyan</li>
#      <li>'M' for magenta</li>
#   </ul>
#   After you start a new game, it wil give you a unique game_key, which you will be using to guess.
#
#   There is a time limit of 5 minutes set for each game, after 5 minutes the game_key is no longer valid and you need to start a new game with the /new_game endpoint.
class Mastermind < Sinatra::Application
	register Sinatra::CrossOrigin

	#   Configure the application
	#   It enables CORS for all requests, load files for i18n and setup the database connection.
	#   Lastly it sets some options for error handling
	configure do
		enable :cross_origin
		I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config/locales', '*.yml').to_s]

		Mongoid.load!( './config/mongoid.yml' )

		# Don't capture any errors. Throw them up the stack
		# Disable internal middleware for presenting errors as useful HTML pages
	    set :raise_errors, false
	    set :show_exceptions, false
	    set :dump_errors, false
	end

	#   Executed before all requests
	#   Since this is a RESTFul API, all response content-type is set to JSON
	before do
    	content_type 'application/json'
  	end

  	#   Error handling method.
  	#   It gets the error and send it back as a JSON
  	error do
  		@error = env[ 'sinatra.error' ]

  		status 405
		json Hash[ "error", @error.message, "code", @error.code ]
	end

  	#   Helper methods to avoid logic duplication and favor's reusability and maintenance
  	helpers do

  		#   Validates the request parameters, checking for it's existence and matching against a pre-defined JSON schema.
		def validate_arguments arguments, schema
			ArgumentsValidator.new( './config/schemas', schema ).validate( arguments )
		end

	end

	#   API endpoint for starting a new game.
	#   It accepts only POSTs at '/new_game' route.
	#   
	#   The following JSON represents the expected params.
	#   { user: "Anderson Farias" }
	#
	#   The following JSON represents the output
	#   { 
    #      "colors": ["R","B","G","Y","O","P","C","M"], 
    #      "code_length": 8, 
    #      "game_key": "5740f16ff293446321000000", 
    #      "num_guesses": 0, 
    #      "past_results": [], 
    #      "solved": "false" 
    #   }
    #   
    #   For more details, like errors, and field types, please check the swagger.io file.
	post '/new_game' do
		args = request.body.read

		validate_arguments( args, 'user.json' )

		game = Game.create( :user => User.from_hash( JSON.parse args ) )
		json game.to_json_hash
	end

	#   API endpoint for guessing the pattern.
	#   It accepts only POSTs at '/guess' route.
	#   
	#   The following JSON represents the expected params.
	#   { 
    #      "code": "RPYGOGOP", 
    #      "game_key": "5740f16ff293446321000000" 
	#   }
	#
	#   The following JSON represents the output
	#   { 
	#      "code_length": 8, 
	#      "colors": ["R","B","G","Y","O","P","C","M"], 
	#       "game_key": "niBpjqhujvM9NR0CQrB6e_xJXXWNNRLgfwYu8YPI3wpn4JdXs3ufRzOAv3SEC_0BNSw", 
	#       "guess": "RRBPPCBC", 
	#       "num_guesses": 1, 
	#       "past_results": [{ 
	#         "exact": 1, 
	#         "guess": "RRBPPCBC", 
	#         "near": 5 
	#      }], 
	#      "result": { 
	#         "exact": 1, 
	#         "near": 5 
	#      }, 
	#      "solved": "false" 
	#   }
    #   
    #   For more details, like errors, and field types, please check the swagger.io file.
	post '/guess' do
		args = request.body.read

		# validate the given arguments
		validate_arguments( args, 'guess.json' )

		guess = JSON.parse( args )

		# searching for the game
		begin
			game = Game.find( guess[ "game_key" ] )
		rescue Mongoid::Errors::DocumentNotFound
			raise ValidationError.new Messages::INVALID_GAME_KEY
		end

		# validates the guessing
		GuessingValidator.new( game, guess ).validate

		pattern = game.pattern.map do |e| e.dup end

		exact = near = 0
		nears = []

		# calculates the exact and near
		guess[ "code" ].upcase.split( "" ).each_with_index do | color , index |
			if color == pattern[ index ]
				exact += 1
				pattern[ index ] = -1
			else
				nears << color
			end
		end
		
		nears.each_with_index do | color , index |
			if pattern.include? color
				near += 1
				pattern[ pattern.find_index color ] = -1
			end

		end

		# saving/update the guessing result
		attempt = Guess.new
		attempt.exact = exact
		attempt.near = near
		attempt.guess = guess

		game.solved = true if exact == game.code_length
		game.guesses << attempt
		game.save()

		response = game.to_json_hash
		response[ :result ] = Hash[ "exact", exact, "near", near ]

		json response
	end

	# start the server if ruby file executed directly
	run! if app_file == $0
end