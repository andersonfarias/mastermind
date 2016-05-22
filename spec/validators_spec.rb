require File.expand_path('../../validators', __FILE__)

#   Testing class responsible for testing the behavior of the Arguments Validator
RSpec.describe ArgumentsValidator do

  	describe "#validation" do

  		before( :all ) do
  			@user_json_schema = 'user.json'
  			@guess_json_schema = 'guess.json'
  			@schema_path = File.expand_path('../../config/schemas', __FILE__)

			I18n.load_path += Dir[ File.join( File.expand_path('../../', __FILE__) , 'config/locales', '*.yml').to_s ]
  		end

	    it "throws an error for nil values" do
			validator = ArgumentsValidator.new nil, nil

			begin
				validator.validate nil
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::NULL_OR_EMPTY[ 0 ] )	
			end
	      
	    end

	    it "throws an error for empty values" do
			validator = ArgumentsValidator.new nil, nil

			begin
	      		validator.validate ''
	      	rescue ValidationError => error
	      		expect( error.code ).to eq( Messages::NULL_OR_EMPTY[ 0 ] )	
	      	end
	      
	    end

	    it "throws an error for white-space only values" do
	      	validator = ArgumentsValidator.new nil, nil

	      	begin
	      		validator.validate '     '
	      	rescue ValidationError => error
	      		expect( error.code ).to eq( Messages::NULL_OR_EMPTY[ 0 ] )	
	      	end
	      
	    end

	    it "throws an error for invalid json" do
	    	invalid_json = "{ a,b }"

	    	validator = ArgumentsValidator.new @schema_path, @user_json_schema

			begin
	      		validator.validate invalid_json
	      	rescue ValidationError => error
	      		expect( error.code ).to eq( Messages::INVALID_JSON[ 0 ] )	
	      	end
	      
	    end

	    it "throws an error for valid json with extra properties" do
	    	valid_json = "{ user: 'user name', extra: 'x' }"

	    	validator = ArgumentsValidator.new @schema_path, @user_json_schema

			begin
	      		validator.validate valid_json
	      	rescue ValidationError => error
	      		expect( error.code ).to eq( Messages::INVALID_JSON[ 0 ] )	
	      	end
	      
	    end

	    it "is shouldn't throw error for a valid user json" do
	    	valid_json = "{ \"user\": \"user name\" }"

	    	validator = ArgumentsValidator.new @schema_path, @user_json_schema

	    	error = nil
			begin
	      		validator.validate valid_json
	      	rescue ValidationError => e
	      		error = e
	      	end
	      
	      	expect( error ).to eq( nil )	
	    end

	    it "is shouldn't throw error for a valid guess json" do
	    	valid_json = "{ \"code\": \"RBSD\", \"game_key\": \"123456\" }"

	    	validator = ArgumentsValidator.new @schema_path, @guess_json_schema

	    	error = nil
			begin
	      		validator.validate valid_json
	      	rescue ValidationError => e
	      		error = e
	      	end
	      
	      	expect( error ).to eq( nil )	
	    end

	end

end

#   Testing class responsible for testing the behavior of the Guessing Validator
RSpec.describe GuessingValidator do

  	describe "#validation" do

	    it "throws an error for already solved game" do
	    	game = Game.new
	    	game.solved = true

	    	guess = nil

			validator = GuessingValidator.new game, guess

			begin
				validator.validate
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::GAME_SOLVED[ 0 ] )	
			end
	      
	    end

	    it "throws an error for trying to guess after the max allowed # of attempts" do
	    	game = Game.new
	    	game.solved = false
	    	game.code_length = 8
	    	game.guesses = []

	    	( 1 .. game.code_length ).each do | i |
	    		game.guesses.push Guess.new
	    	end

			validator = GuessingValidator.new game, nil

			begin
				validator.validate
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::MAX_ATTEMPTS[ 0 ] )	
			end
	      
	    end

	    it "throws an error for guess with length greather than the expected" do
	    	game = Game.new
	    	game.solved = false
	    	game.code_length = 8
	    	game.guesses = []

	    	guess = Hash[ "code", "RGBMCRGBMCRGBMC", "game_key", "123123" ]

			validator = GuessingValidator.new game, guess

			begin
				validator.validate
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::INVALID_GUESS[ 0 ] )	
			end
	      
	    end

	    it "throws an error for guess with length smaller than the expected" do
	    	game = Game.new
	    	game.solved = false
	    	game.code_length = 8
	    	game.guesses = []

	    	guess = Hash[ "code", "RGB", "game_key", "123123" ]

			validator = GuessingValidator.new game, guess

			begin
				validator.validate
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::INVALID_GUESS[ 0 ] )	
			end
	      
	    end

	    it "throws an error for guess with invalid colors" do
	    	game = Game.new
	    	game.solved = false
	    	game.code_length = 8
	    	game.guesses = []

	    	guess = Hash[ "code", "RGBYYCMA", "game_key", "123123" ]

			validator = GuessingValidator.new game, guess

			begin
				validator.validate
			rescue ValidationError => error
				expect( error.code ).to eq( Messages::INVALID_GUESS[ 0 ] )	
			end
	      
	    end

	    it "shouldn't thrown any error for a valid guess" do
	    	game = Game.new
	    	game.solved = false
	    	game.code_length = 8
	    	game.guesses = []

	    	guess = Hash[ "code", "RGBYYCMM", "game_key", "123123" ]

			validator = GuessingValidator.new game, guess

			error = nil
			begin
				validator.validate
			rescue ValidationError => e
				error = e
			end

	      	expect( error ).to eq( nil )
	    end

	end

end