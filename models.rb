class Game
	include Mongoid::Document
	include Mongoid::Timestamps

	CODE_LENGTH = 8
	COLORS = [ "R", "B" , "G" , "Y" , "O" , "P" , "C" , "M" ]

	embeds_one :user

	field :colors, type: Array, default: Game::COLORS
  	field :code_length, type: Integer, default: 8
  	field :solved, type: Boolean, default: false
  	field :pattern, type: Array, default: Game::COLORS.shuffle
  	
  	embeds_many :guesses, class_name: "Guess"

  	attr_readonly :user, :colors, :code_length, :pattern

	def to_json_hash
		Hash[ "colors", colors, "code_length", code_length, "game_key", _id.to_s, "num_guesses", guesses.count, "past_results", guesses, "solved", solved]
	end

end

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

class Guess
	include Mongoid::Document

	field :exact, type: Integer
	field :guess, type: String
	field :near, type: Integer

	embedded_in :game

end