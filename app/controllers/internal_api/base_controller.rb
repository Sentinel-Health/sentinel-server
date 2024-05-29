class InternalApi::BaseController < ApplicationController
  include ErrorHandling
  layout false

  skip_before_action :verify_authenticity_token
end
