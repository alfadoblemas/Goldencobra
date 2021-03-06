# encoding: utf-8

module Goldencobra
	class Author < ActiveRecord::Base
		has_many  :article_authors
    has_many  :articles, :through => :article_authors
    
		web_url :googleplus

		def title
			[self.try(:firstname), self.try(:lastname)].join(" ")
		end
	end
end