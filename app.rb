require 'i18n'

require 'mongo'
require 'mongoid'

require 'json'
require "json-schema"

require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cross_origin'

require './models'

class Mastermind < Sinatra::Base
	register Sinatra::CrossOrigin

	configure do
		enable :cross_origin
		I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config/locales', '*.yml').to_s]

		Mongoid.load!( './config/mongoid.yml' )
	end

	helpers do

		def validate_json( json, schema, missing_msg )
			if json.nil? || json.strip.empty?
				status 405
				return json( :error => I18n.t( missing_msg, locale: :en ) )
			end

			valid_json = JSON::Validator.validate( "./config/schemas/#{schema}", json, { :strict => true, :validate_schema => true } )
			if not valid_json
				status 405
				return json( :error => I18n.t( 'error.invalid_json', locale: :en ) )
			end

			true
		end
	end

	post '/new_game' do
		content_type :json

		args = request.body.read

		valid_args = validate_json args, 'user.json', 'error.new_game.user_required'

		if valid_args != true
			return valid_args
		end

		user = User.from_hash JSON.parse( args )
		game = Game.create( :user => user )

		json game.to_json_hash
	end

	post '/guess' do
		content_type :json
		
		args = request.body.read

		valid_args = validate_json args, 'guess.json', 'error.guess.required_params'
		if valid_args != true
			return valid_args
		end

		args = JSON.parse( args )

		begin
			game = Game.find( args[ "game_key" ] )
		rescue Mongoid::Errors::DocumentNotFound
			status 405
			return json( :error => I18n.t( 'error.guess.invalid_game_key', locale: :en ) )
		end

		if game.solved
			status 405
			return json( :error => I18n.t( 'error.guess.game_solved', locale: :en ) )
		end

		if game.guesses.count == game.code_length
			status 405
			return json( :error => I18n.t( 'error.guess.max_attempts', locale: :en ) )
		end

		guess = args[ "code" ].upcase.split( "" )
		if guess.count != game.code_length
			status 405
			return json( :error => I18n.t( 'error.guess.invalid', locale: :en ) )
		end
		correct_code = game.pattern

		exact = 0
		near = 0
		guess.each_with_index do |code, index|
			if !Game::COLORS.include? code
				status 405
				return json( :error => I18n.t( 'error.guess.invalid', locale: :en ) )
			end

			if code == correct_code[ index ]
				exact += 1
			elsif correct_code.include? code
				near += 1
			end
		end

		attempt = Guess.new
		attempt.exact = exact
		attempt.near = near
		attempt.guess = guess

		game.solved = true if exact == game.code_length
		game.guesses << attempt
		game.save()

		json game
	end

	# start the server if ruby file executed directly
	run! if app_file == $0
end