module Api
  module V1
    class BaseController < ApplicationController
      before_action :authenticate_user_from_token!
      before_action :ensure_admin!

      private

      def authenticate_user_from_token!
        header = request.headers["Authorization"]
        token = header.split(" ").last if header
        
        if token
          decoded = JwtService.decode(token)
          @current_user = User.find(decoded["user_id"]) if decoded
        end
        
        unless @current_user
          render json: {
            status: "error",
            message: "Authentication required"
          }, status: :unauthorized
        end
      rescue JWT::DecodeError
        render json: {
          status: "error",
          message: "Invalid token"
        }, status: :unauthorized
      end

      def ensure_admin!
        unless @current_user&.admin?
          render json: {
            status: "error",
            message: "Admin access required"
          }, status: :forbidden
        end
      end
    end
  end
end
