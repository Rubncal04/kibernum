class ActivityLog < ApplicationRecord
  belongs_to :scope, polymorphic: true
  belongs_to :user

  validates :action, presence: true, inclusion: { in: %w[create update destroy] }
  validates :changes_data, presence: true
  validates :scope_type, presence: true
  validates :scope_id, presence: true

  scope :by_user, ->(user_id) { where(user_id: user_id) }
  scope :by_scope_type, ->(scope_type) { where(scope_type: scope_type) }
  scope :by_scope_id, ->(scope_id) { where(scope_id: scope_id) }
  scope :by_action, ->(action) { where(action: action) }
  scope :recent, -> { order(created_at: :desc) }
  scope :for_product, -> { where(scope_type: 'Product') }
  scope :for_category, -> { where(scope_type: 'Category') }

  def self.log_activity(scope, user, action, changes = {})
    create!(
      scope: scope,
      user: user,
      action: action,
      changes_data: changes
    )
  end

  def scope_name
    scope&.name || "Unknown #{scope_type}"
  end

  def user_name
    user&.name || 'Unknown User'
  end

  def formatted_changes
    case action
    when 'create'
      "Created #{scope_type.downcase} '#{scope_name}'"
    when 'update'
      changes_text = changes_data['after']&.keys&.map { |key| key.humanize }&.join(', ')
      "Updated #{scope_type.downcase} '#{scope_name}' (#{changes_text})"
    when 'destroy'
      "Deleted #{scope_type.downcase} '#{scope_name}'"
    else
      "#{action.humanize} #{scope_type.downcase}"
    end
  end

  def changes_summary
    return {} unless changes_data.present?

    case action
    when 'create'
      { 'created' => changes_data['after'] }
    when 'update'
      changes_data
    when 'destroy'
      { 'destroyed' => changes_data['before'] }
    else
      changes_data
    end
  end
end
