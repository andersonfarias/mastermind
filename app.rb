require 'i18n'

require 'json'
require "json-schema"

require 'sinatra'
require 'sinatra/base'
require 'sinatra/json'
require 'sinatra/cross_origin'

class Mastermind < Sinatra::Base
	register Sinatra::CrossOrigin
	register Sinatra::ActiveRecordExtension

	configure do
		enable :cross_origin
		I18n.load_path += Dir[File.join(File.dirname(__FILE__), 'config/locales', '*.yml').to_s]
	end

	helpers do
		# Just a simple alias
		def t(*args)
			I18n.t(*args)
		end
	end

	post '/new_game' do
		args = request.body.read

		if args.nil? || args.strip.empty?
			status 405
			return json error: t( 'error.new_game.user_required', locale: :en )
		end

		valid_json = JSON::Validator.validate( './config/schemas/user.json', args, { :strict => true, :validate_schema => true } )
		if not valid_json
			status 405
			return json error: t( 'error.new_game.user_json_invalid', locale: :en )
		end

		user = JSON.parse args

		puts user
	end

	post '/guess' do
		puts 'chegou!'
	end

	# start the server if ruby file executed directly
	run! if app_file == $0
end