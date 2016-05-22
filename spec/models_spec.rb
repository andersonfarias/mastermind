require File.expand_path('../../models', __FILE__)

#   Testing class responsible for testing the behavior of the game model
RSpec.describe Game do

  	describe "#validation" do

	    it "should generate repeated patterns" do

	    	max_attempts = 1000

	    	repeated_colors_in_pattern = false
	    	(1 .. max_attempts ).each do | attemp |

				pattern = Game::shuffle

				pattern.each do | color |
					if pattern.count( color ) > 1
						repeated_colors_in_pattern = true
						break
					end
				end

				break if repeated_colors_in_pattern
	    	end

			expect( repeated_colors_in_pattern ).to eq( true )
	    end

	end

end