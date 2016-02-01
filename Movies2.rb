#Brad Payne 

class MovieData 

	def intialize
	end 

	def load_data(file)
		@Users_to_movies = Hash.new(0) # Default = 0 # User_id will be the key, Movie_Id's will be stored in an array 
		@Movies_to_users = Hash.new(0) # Movie_id will be the key, every user that has seen the movie will be stored in an array 
		@UM_to_ratings = Hash.new(0)   # Arr[user_id,movie_id] will return the rating that a user gave to a movie #load_data(file)s

		current_file = open(file)
		current_file.each_line do |line| # read each line and seperate it into the four bytes of info
			numbers = line.split("\t") # splits the input file line into an array of four words. The first three are used 
			user_id = numbers[0].to_i
			movie_id = numbers[1].to_i
			temp_rating = numbers[2].to_i

			unless @Users_to_movies.has_key?(user_id) # if it is the first time a user is added, it makes a new array 
				@Users_to_movies[user_id] = Array.new 
				@Users_to_movies[user_id] << movie_id
			else 
				@Users_to_movies[user_id] << movie_id
			end

			unless @Movies_to_users.has_key?(movie_id) # if it is the first time a movie is added, it makes a new array 
				@Movies_to_users[movie_id] = Array.new 
				@Movies_to_users[movie_id] << user_id
			else 
				@Movies_to_users[movie_id] << user_id
			end

			@UM_to_ratings[ [user_id, movie_id] ] = temp_rating # stores in a unique array-key 
		end 
		puts "Finished Loading"
	end 

	def rating (user, movie)
		@UM_to_ratings[ [ user, movie ]]
		#returns the rating that user u gave movie m in the training set, and 0 if user u did not rate movie m
	end

	def movies (user)
		#returns the array of movies that user u has watched
		@Users_to_movies[user]
	end

	def views(movie)
		#returns the array of users that have seen movie m
		@Movies_to_users[movie]
	end

	def predict(user,movie)
		#returns a floating point number between 1.0 and 5.0 as an estimate of what user u would rate movie m
		# returns the average rating fora movie 
		number = 0 
		score = 0 
		others = views(movie)
		others.each do |u| 
			score = score + @UM_to_ratings[ [u, movie] ].to_i
			number = number + 1 
	 	end

		return score / number 
	end 

	def run_test(*args)
		# Ruby's version of method overloading 
		if (args.size == 1) # determines if there are 1 or 0 arguments to figure out which type of calculations to do
			k = args[0]
			i = 0 
			@number_of_ratings = 0 
			@total_score = 0 
			@arr_of_ratings = Array.new # for finding the stddev 
			while i < k do 
				user_id = i 
				arr = movies(user_id)
				if(arr.class == Array)
					arr.each do |m|
						@number_of_ratings = @number_of_ratings + 1 
						real_score = rating(user_id, m)
						predication = predict(user_id, m)
						@total_score = @total_score + (predication.to_i - real_score.to_i).abs
						@arr_of_ratings << (predication.to_i - real_score.to_i).abs 
					end 
				end
				i = i + 1 
			end 
			puts "Finished running tests"
		else 
			hash_size = @Users_to_movies.size
			run_test(hash_size)
		end 
	end 

	def mean
		#returns the average predication error (which should be close to zero)
		# Total score is the total number of values. Each value is the difference between the actual rating and the predicted rating 
		# Dividing it by the number of 
		if(@number_of_ratings == 0 )
			puts "Error, run run_test(k) first to read the data"
		else 
			@mean = (@total_score.to_i / @number_of_ratings.to_i).to_f
		end 
	end

	def stddev
		#returns the standard deviation of the error
		# Step 1: find the mean, Step 2: subtract the mean from every number in the set, find the mean of those squared differnces, Step 3: take the square root 
		sum = 0
		@arr_of_ratings.each do |r|
			dif = (r - @mean)*(r-mean)
			sum = sum + dif 
		end 
		new_mean = sum / @number_of_ratings
		@stddev = Math.sqrt(new_mean)
		return @stddev
	end

	def rms
		#returns the root mean square error of the prediction
		# Step 1: square all the values in a set, Step two: find the new mean 
		sum = 0
		@arr_of_ratings.each do |r|
			r_squared = (r * r) 
			sum = sum + r_squared
		end 
		new_mean = sum / @number_of_ratings
		@rms = Math.sqrt(new_mean)
		return @rms
	end 

	def to_a(user, movie)
		#returns an array of the predictions in the form [u,m,r,p]
		arr = [user, movie, @UM_to_ratings[ [user, movie] ], predict(user, movie) ]
		return arr
	end 
end 
#######

input_file = ARGV.first # using test1.txt for testing 
md = MovieData.new
md.load_data(input_file)

# testing Code  

=begin 
puts md.rating(1, 242)
puts md.movies(196)
puts md.views(298)
puts md.predict(196, 242)

puts md.run_test(10)
puts md.mean
puts md.stddev
puts md.rms
puts md.to_a(196, 242).inspect
 
=end 

=begin 
Comments:
I decided to use one class instead of two because I found I was using every method and variable I had created in the MovieData class 
in the MovieTest class. Combining them simplified my code extremely. 

=end 


