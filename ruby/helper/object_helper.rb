class Object
	def self_or_default(default) 
		return default if self.nil?

		self.empty? ? default : self if self.respond_to? :empty?
	end
end