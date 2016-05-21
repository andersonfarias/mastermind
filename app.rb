require "sinatra"
require "sinatra/base"
require "sinatra/json"
require "sinatra/cross_origin"

class Mastermind < Sinatra::Base
	register Sinatra::CrossOrigin

	configure do
		enable :cross_origin
	end

	post '/new_game' do
		
	end

	post '/guess' do
		
	end

	# start the server if ruby file executed directly
	run! if app_file == $0
end