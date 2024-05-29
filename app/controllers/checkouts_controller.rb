class CheckoutsController < ApplicationController
  def success
    token = params[:token]
    head :not_found unless token
  end
end
