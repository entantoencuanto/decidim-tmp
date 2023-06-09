# frozen_string_literal: true

module Decidim
  # A command with all the business logic to reject a join request to a user
  # group.
  class RejectUserGroupJoinRequest < Decidim::Command
    # Public: Initializes the command.
    #
    # membership - the UserGroupMembership to be accepted.
    def initialize(membership)
      @membership = membership
    end

    # Executes the command. Broadcasts these events:
    #
    # - :ok when everything is valid.
    # - :invalid if we could not proceed.
    #
    # Returns nothing.
    def call
      return broadcast(:invalid) unless membership
      return broadcast(:invalid) if membership.role.to_s != "requested"

      transaction do
        send_notification
        reject_membership
      end

      broadcast(:ok, @user_group)
    end

    private

    attr_reader :membership

    def reject_membership
      membership.destroy!
    end

    def send_notification
      Decidim::EventsManager.publish(
        event: "decidim.events.groups.join_request_rejected",
        event_class: JoinRequestRejectedEvent,
        resource: membership.user_group,
        affected_users: [membership.user],
        extra: {
          user_group_name: membership.user_group.name,
          user_group_nickname: membership.user_group.nickname
        }
      )
    end
  end
end
