# frozen_string_literal: true

module Decidim
  module Consultations
    module Admin
      # A command that sets a consultation as unpublished.
      class UnpublishConsultation < Decidim::Command
        # Public: Initializes the command.
        #
        # consultation - A Consultation that will be unpublished
        def initialize(consultation)
          @consultation = consultation
        end

        # Executes the command. Broadcasts these events:
        #
        # - :ok when everything is valid.
        # - :invalid if the data was not valid and we could not proceed.
        #
        # Returns nothing.
        def call
          return broadcast(:invalid) if consultation.nil? || !consultation.published?

          consultation.unpublish!
          broadcast(:ok)
        end

        private

        attr_reader :consultation
      end
    end
  end
end
