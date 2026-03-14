# frozen_string_literal: true

module Legion
  module Extensions
    module GlobalWorkspace
      module Helpers
        module Constants
          # Maximum items that can compete for the workspace in one cycle
          MAX_COMPETITORS = 50

          # Maximum broadcasts retained in history
          MAX_BROADCAST_HISTORY = 200

          # Maximum number of coalition members per broadcast
          MAX_COALITION_SIZE = 10

          # Minimum salience to enter competition
          COMPETITION_THRESHOLD = 0.2

          # Winner takes all — top competitor must exceed runner-up by this margin
          DOMINANCE_MARGIN = 0.05

          # How long a broadcast remains "conscious" (seconds)
          BROADCAST_TTL = 10

          # Salience decay per tick for waiting competitors
          SALIENCE_DECAY = 0.02

          # Urgency boost per tick for items that keep losing competition
          URGENCY_BOOST = 0.01

          # Maximum urgency accumulation
          MAX_URGENCY = 0.5

          # EMA alpha for workspace utilization tracking
          UTILIZATION_ALPHA = 0.1

          # Maximum registered subscribers
          MAX_SUBSCRIBERS = 50

          # Labels for workspace state
          WORKSPACE_STATE_LABELS = {
            broadcasting: 'actively broadcasting content',
            idle: 'workspace empty, awaiting input',
            contention: 'multiple items competing for access',
            saturated: 'high utilization, processing backlog'
          }.freeze

          # Labels for broadcast salience
          SALIENCE_LABELS = {
            (0.8..) => :dominant,
            (0.6...0.8) => :salient,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :marginal,
            (..0.2) => :subliminal
          }.freeze
        end
      end
    end
  end
end
