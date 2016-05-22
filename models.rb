#   Model class that represents one Mastermind game
#   By default, all games are allowed 8 guessing attempts, each guessing must contain a 8 characters.
#   The game is started by a user and some logic is applied in it's inicialization
#   When initializing, it's randonly assigned a pattern to the game. Repeated characters are allowed.
class Game
	include Mongoid::Document
	include Mongoid::Timestamps

	#   Length of the guessing
	CODE_LENGTH = 8
	#   Allowed colors
	COLORS = [ "R", "B" , "G" , "Y" , "O" , "P" , "C" , "M" ]

	#   Randomly generates a pattern of the allowed colors.
	#   Repeated colors are allowed.
	def self.shuffle
  		pattern = []

  		( 1 .. Game::CODE_LENGTH ).to_a.each do | item | 
  			pattern << Game::COLORS[ rand( Game::CODE_LENGTH ) ]
  		end

  		pattern
  	end

	embeds_one :user

	field :colors, type: Array, default: Game::COLORS
  	field :code_length, type: Integer, default: 8
  	field :solved, type: Boolean, default: false
  	field :pattern, type: Array, default: Game::shuffle
  	
  	embeds_many :guesses, class_name: "Guess"

  	attr_readonly :user, :colors, :code_length, :pattern

  	#   Creates a Hash that will be used to respond the API request in JSON format
  	#   The fields inclued in the return are: "colors", "code_length", "game_key",
  	#   "num_guesses", "past_results" and "solved".
	def to_json_hash
		guesses_hash = guesses.map do |g| g.to_json_hash end

		Hash[ 
			"colors", colors, "code_length", code_length, "game_key", _id.to_s, 
			"num_guesses", guesses.count, "past_results", guesses_hash, "solved", solved
		]
	end

end

#   Model class that represents one User of the game.
#   This model is embedded in a Mastermind game when persisting into the database.
class User
	include Mongoid::Document

	field :name, type: String

	embedded_in :game

	def self.from_hash( params = {} )
		user = User.new
		user.name = params[ "user" ] if !params[ "user" ].nil?
		user
	end

end

#   Model class that represents one Guess of a game.
#   This model is embedded in a Mastermind game when persisting into the database.
class Guess
	include Mongoid::Document

	field :exact, type: Integer
	field :guess, type: String
	field :near, type: Integer

	embedded_in :game

	def to_json_hash
		Hash[ "exact", exact, "guess", guess[ "code" ], "near", near ]
	end
end