#   Module with all messages used in the API
#   Each message has a unique code and a string key.
#   The unique code is suposed to be used by API consumers
#   The string key is a short representation of the message and is used internally to get a i18n of that message
module Messages

	#   Some required param is nil or empty
	NULL_OR_EMPTY = [ 501 , 'error.required_params' ]

	#   The received JSON do not match the pre-defined schema
	INVALID_JSON = [ 502 , 'error.invalid_json' ]

	#   There's no game with the provided game_key
	INVALID_GAME_KEY = [ 503 , 'error.guess.invalid_game_key' ]

	#   Trying to guess a already finished game
	GAME_SOLVED = [ 504 , 'error.guess.game_solved' ]

	#   Trying to guess when there's no more attempts
	MAX_ATTEMPTS = [ 505 , 'error.guess.max_attempts' ]

	#   The given code for the guessing is not valid.
	#   It can only contains 8 characters. The allowed characters are:
	#   "R","B","G","Y","O","P","C","M"
	INVALID_GUESS = [ 506 , 'error.guess.invalid' ]

end