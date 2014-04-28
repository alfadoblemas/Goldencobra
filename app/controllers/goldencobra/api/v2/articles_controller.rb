# encoding: utf-8

module Goldencobra
  module Api
    module V2
      class ArticlesController < ActionController::Base

        respond_to :json

        # /api/v2/articles/search[.json]
        # ---------------------------------------------------------------------------------------
        def search

          # Check if we have an argument.
          unless params[:q]
            render status: 200, json: {}
            return
          end

          # Check if the query string contains something.
          if params[:q].length == 0
            render status: 200, json: {}
          else
            # 1. Do the search and return the search result array.
            render status: 200, json: Goldencobra::Article.simple_search( ActionController::Base.helpers.sanitize(params[:q]) ).to_json
          end
        end

      end
    end
  end
end
