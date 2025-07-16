module Auditable
  extend ActiveSupport::Concern

  included do
    after_create :log_creation
    after_update :log_update
    after_destroy :log_destruction
  end

  private

  def log_creation
    return unless Current.user

    ActivityLog.log_activity(
      self,
      Current.user,
      'create',
      { 'after' => attributes.except('id', 'created_at', 'updated_at') }
    )

    Rails.cache.delete_matched("activity_logs_index*")
  end

  def log_update
    return unless Current.user && saved_changes.any?

    ActivityLog.log_activity(
      self,
      Current.user,
      'update',
      {
        'before' => saved_changes.transform_values(&:first),
        'after' => saved_changes.transform_values(&:last)
      }
    )

    Rails.cache.delete_matched("activity_logs_index*")
  end

  def log_destruction
    return unless Current.user

    ActivityLog.log_activity(
      self,
      Current.user,
      'destroy',
      { 'before' => attributes.except('id', 'created_at', 'updated_at') }
    )

    Rails.cache.delete_matched("activity_logs_index*")
  end
end
