class User < ActiveRecord::Base

	validates :username, presence: true, uniqueness: true
	belongs_to :created_in_spreadsheet, class_name: "Spreadsheet", foreign_key: "created_in_spreadsheet"

	def self.authenticate(username)
		return false if username.nil? || username.blank?
		return true if valid_usernames.include? username
		return false
	end

	def self.valid_usernames
		return User.all.map { |user| user.username }
	end

	def self.current_username=(user)
		Thread.current[:current_username] = user
	end

	def self.current_username
		user_string = Thread.current[:current_username].to_s
		user_string.blank? ? "UNAVAILABLE" : user_string
	end

	def self.current_username_object
		Thread.current[:current_username]
	end

	def name
		first_name + ' ' + last_name
	end

end
