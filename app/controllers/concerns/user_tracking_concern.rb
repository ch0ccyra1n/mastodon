# frozen_string_literal: true

module UserTrackingConcern
  extend ActiveSupport::Concern

  REGENERATE_FEED_DAYS = 14
  UPDATE_SIGN_IN_HOURS = 24

  included do
    before_action :set_user_activity, if: %i(user_signed_in? user_needs_sign_in_update?)
  end

  private

  def set_user_activity
    # Mark as signed-in today
    current_user.update_tracked_fields!(request)

    # Regenerate feed if needed
    RegenerationWorker.perform_async(current_user.account_id) if user_needs_feed_update?
  end

  def user_needs_sign_in_update?
    current_user.current_sign_in_at.nil? || current_user.current_sign_in_at < UPDATE_SIGN_IN_HOURS.hours.ago
  end

  def user_needs_feed_update?
    current_user.last_sign_in_at < REGENERATE_FEED_DAYS.days.ago
  end
end