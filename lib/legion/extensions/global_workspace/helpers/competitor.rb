# frozen_string_literal: true

module Legion
  module Extensions
    module GlobalWorkspace
      module Helpers
        class Competitor
          include Constants

          attr_reader :content, :source, :domain, :coalition, :submitted_at
          attr_accessor :salience, :urgency

          def initialize(content:, source:, domain:, salience:, coalition: [])
            @content      = content
            @source       = source
            @domain       = domain
            @salience     = salience.to_f.clamp(0.0, 1.0)
            @coalition    = Array(coalition).first(MAX_COALITION_SIZE)
            @urgency      = 0.0
            @submitted_at = Time.now.utc
          end

          def effective_salience
            (@salience + @urgency).clamp(0.0, 1.0)
          end

          def decay
            @salience = [@salience - SALIENCE_DECAY, 0.0].max
          end

          def boost_urgency
            @urgency = [@urgency + URGENCY_BOOST, MAX_URGENCY].min
          end

          def below_threshold?
            effective_salience < COMPETITION_THRESHOLD
          end

          def to_h
            {
              content: @content,
              source: @source,
              domain: @domain,
              salience: @salience.round(4),
              urgency: @urgency.round(4),
              effective_salience: effective_salience.round(4),
              coalition: @coalition,
              submitted_at: @submitted_at
            }
          end
        end
      end
    end
  end
end
