module ErrorHandling
  extend ActiveSupport::Concern

  included do
    # Custom Error classes for raising 4XX responses
    class InternalApi::Forbidden < StandardError
    end

    class InternalApi::NotFound < StandardError
    end

    class InternalApi::Invalid < StandardError
    end

    class InternalApi::BadRequest < StandardError
    end

    class InternalApi::Unauthorized < StandardError
    end

    rescue_from ActionController::RoutingError, with: :not_found
    rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
    rescue_from ActiveRecord::RecordInvalid, with: :record_invalid
    rescue_from InternalApi::Forbidden, with: :forbidden
    rescue_from InternalApi::NotFound, with: :record_not_found
    rescue_from InternalApi::Invalid, with: :record_invalid
    rescue_from InternalApi::BadRequest, with: :bad_request
    rescue_from InternalApi::Unauthorized, with: :unauthorized
    rescue_from JWT::DecodeError, with: :unauthorized
    rescue_from JWT::ExpiredSignature, with: :unauthorized
    rescue_from JWT::VerificationError, with: :unauthorized
    rescue_from JWT::ImmatureSignature, with: :unauthorized
    rescue_from JWT::InvalidIatError, with: :unauthorized
    rescue_from JWT::InvalidAudError, with: :unauthorized
    rescue_from JWT::InvalidIssuerError, with: :unauthorized
    # rescue_from StandardError, with: :render_error_message

    protected

    def record_not_found(e)
      Rails.logger.error(e.message)
      render json: {error: "Not Found", message: t("auth.errors.not_found", default: "Not Found.")}, status: 404
    end

    def record_invalid(e)
      Rails.logger.error(e.message)
      render json: {error: "Invalid Request", message: e.message, validation_errors: e.dig('record', 'errors')}, status: 422
    end

    def bad_request(e)
      Rails.logger.error(e.message)
      render json: {error: "Bad Request", message: e.message}, status: 400
    end

    def forbidden(e)
      Rails.logger.error(e.message)
      render json: {error: "Forbidden", message: t("auth.errors.forbidden", default: "Forbidden.")}, status: 403
    end

    def unauthorized(e)
      Rails.logger.error(e.message)
      render json: {error: "Unauthorized", message: t("auth.errors.unauthorized", default: "Unauthorized.")}, status: 401
    end

    def render_error_message(e)
      Rails.logger.error(e.message)
      render json: {error: "Unprocessable Entity", message: e.message}, status: 422
    end
  end
end
