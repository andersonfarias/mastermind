require 'i18n'
require 'json-schema'

require File.expand_path('../models', __FILE__)
require File.expand_path('../config/messages', __FILE__)

#   Error that the API gives in response as JSON when some validation error
#   related to the game rules or some invalid parameters are given
#   It has a unique code and a i18n message
class ValidationError < RuntimeError

	#   Unique code
	attr :code

	#   i18n message
	attr :message

	def initialize code_and_message
		@code = code_and_message[ 0 ]
		@message = I18n.t( code_and_message[ 1 ] , locale: :en )
	end

end

#   Class that validates the arguments in any given request
#   It validades the existence of arguments and if the arguments match a pre-defined JSON schema
class ArgumentsValidator

	def initialize schemas_path, schema
		@schema = "#{schemas_path}/#{schema}"
	end

	#   Validates the arguments for existence and compliance with a JSON schema
	def validate arguments

		raise ValidationError.new Messages::NULL_OR_EMPTY if arguments.nil? || arguments.strip.empty?

		if !JSON::Validator.validate( @schema, arguments, { :strict => true, :validate_schema => true } )
			raise ValidationError.new Messages::INVALID_JSON
		end

	end
end

#   Class that validates the given game and guess according to the Mastermind rules
#   It perform the following validations:
#   1 - It validades if is guessing in a already solved game
#   2 - It validades if the number of attemps were already reached
#   3 - It validades the lenght and characters in a guess
class GuessingValidator

	def initialize game, guess
		@game = game
		@guess = guess
	end

	def validate

		raise ValidationError.new Messages::GAME_SOLVED if @game.solved
		raise ValidationError.new Messages::MAX_ATTEMPTS if @game.guesses.length == @game.code_length		
		raise ValidationError.new Messages::INVALID_GUESS if @guess.count == @game.code_length

		code = @guess[ "code" ].upcase.split( "" )
		code.each_with_index do | color , index |
			raise ValidationError.new Messages::INVALID_GUESS if !Game::COLORS.include? color
		end
	end

end