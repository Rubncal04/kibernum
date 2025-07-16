module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_user_from_token!, only: [:login, :register]
      skip_before_action :ensure_admin!, only: [:login, :register]

      def login
        user = User.find_by(email: params[:email])
        
        if user&.valid_password?(params[:password])
          token = JwtService.encode({ user_id: user.id, email: user.email })
          render json: {
            status: "success",
            message: "Login successful",
            data: {
              user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role.name
              },
              token: token
            }
          }, status: :ok
        else
          render json: {
            status: "error",
            message: "Invalid email or password"
          }, status: :unauthorized
        end
      end

      def register
        user = User.new(user_params)
        
        if user.save
          token = JwtService.encode({ user_id: user.id, email: user.email })
          render json: {
            status: "success",
            message: "Registration successful",
            data: {
              user: {
                id: user.id,
                email: user.email,
                name: user.name,
                role: user.role.name
              },
              token: token
            }
          }, status: :created
        else
          render json: {
            status: "error",
            message: "Registration failed",
            errors: user.errors.full_messages
          }, status: :unprocessable_entity
        end
      end

      def me
        render json: {
          status: "success",
          data: {
            user: {
              id: @current_user.id,
              email: @current_user.email,
              name: @current_user.name,
              role: @current_user.role.name
            }
          }
        }, status: :ok
      end

      private

      def user_params
        params.require(:user).permit(:email, :password, :password_confirmation, :name, :role_id)
      end
    end
  end
end
