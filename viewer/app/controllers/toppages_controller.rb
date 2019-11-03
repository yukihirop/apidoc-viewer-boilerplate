class ToppagesController < ApplicationController
  def index
    @apidoc_title = ApiDoc.title
    @apidoc_url = ApiDoc.url
  end
end
