# frozen_string_literal: true

module Decidim
  module Proposals
    # A command with all the business logic to accept a user request to
    # contribute to a collaborative draft.
    class AcceptAccessToCollaborativeDraft < Decidim::Command
      # Public: Initializes the command.
      #
      # form         - A form object with the params.
      # collaborative_draft     - A Decidim::Proposals::CollaborativeDraft object.
      # current_user - The current user.
      # requester_user - The user that requested to collaborate.
      def initialize(form, current_user)
        @form = form
        @collaborative_draft = form.collaborative_draft
        @current_user = current_user
        @requester_user = form.requester_user
      end

      # Executes the command. Broadcasts these events:
      #
      # - :ok when everything is valid.
      # - :invalid if it was not valid and we could not proceed.
      #
      # Returns nothing.
      def call
        return broadcast(:invalid) if @form.invalid?
        return broadcast(:invalid) if @current_user.nil?

        transaction do
          @collaborative_draft.requesters.delete @requester_user

          Decidim::Coauthorship.create(
            coauthorable: @collaborative_draft,
            author: @requester_user
          )
        end

        notify_collaborative_draft_requester
        notify_collaborative_draft_authors
        broadcast(:ok, @requester_user)
      end

      private

      def notify_collaborative_draft_authors
        affected_users = @collaborative_draft.notifiable_identities - [@requester_user]
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_access_accepted",
          event_class: Decidim::Proposals::CollaborativeDraftAccessAcceptedEvent,
          resource: @collaborative_draft,
          affected_users: affected_users.uniq,
          extra: {
            requester_id: @requester_user.id
          }
        )
      end

      def notify_collaborative_draft_requester
        Decidim::EventsManager.publish(
          event: "decidim.events.proposals.collaborative_draft_access_requester_accepted",
          event_class: Decidim::Proposals::CollaborativeDraftAccessRequesterAcceptedEvent,
          resource: @collaborative_draft,
          affected_users: [@requester_user]
        )
      end
    end
  end
end
