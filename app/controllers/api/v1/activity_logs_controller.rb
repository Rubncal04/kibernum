module Api
  module V1
    class ActivityLogsController < BaseController
      include CacheInvalidation

      def index
        page = params[:page] || 1
        per_page = params[:per_page] || 20

                cache_key = "activity_logs_index:#{page}:#{per_page}:#{params[:user_id] || 'all'}:#{params[:scope_type] || 'all'}:#{params[:scope_id] || 'all'}:#{params[:action_type] || 'all'}:#{ActivityLog.maximum(:created_at)&.to_i}"
        
        result = Rails.cache.fetch(cache_key, expires_in: 10.minutes) do
          @activity_logs = apply_filters(ActivityLog.includes(:user, :scope))
                                .recent
                                .page(page)
                                .per(per_page)

          {
            activity_logs: @activity_logs.map { |log| activity_log_response(log) },
            pagination: {
              current_page: @activity_logs.current_page,
              total_pages: @activity_logs.total_pages,
              total_count: @activity_logs.total_count
            }
          }
        end

        render json: {
          status: 'success',
          data: result,
          cached: true
        }
      end

      def show
        @activity_log = ActivityLog.includes(:user, :scope).find(params[:id])

        render json: {
          status: 'success',
          data: {
            activity_log: activity_log_response(@activity_log)
          }
        }
      rescue ActiveRecord::RecordNotFound
        render json: {
          status: 'error',
          message: 'Activity log not found'
        }, status: :not_found
      end



      private

      def apply_filters(activity_logs)
        activity_logs = activity_logs.by_user(params[:user_id]) if params[:user_id].present?
        activity_logs = activity_logs.by_scope_type(params[:scope_type]) if params[:scope_type].present?
        activity_logs = activity_logs.by_scope_id(params[:scope_id]) if params[:scope_id].present?
        activity_logs = activity_logs.by_action(params[:action_type]) if params[:action_type].present?
        activity_logs
      end

      def activity_log_response(activity_log)
        {
          id: activity_log.id,
          action: activity_log.action,
          scope_type: activity_log.scope_type,
          scope_id: activity_log.scope_id,
          scope_name: activity_log.scope_name,
          user: {
            id: activity_log.user.id,
            name: activity_log.user.name,
            email: activity_log.user.email
          },
          changes: activity_log.changes_summary,
          formatted_changes: activity_log.formatted_changes,
          created_at: activity_log.created_at,
          updated_at: activity_log.updated_at
        }
      end
    end
  end
end
