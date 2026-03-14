# frozen_string_literal: true

module Legion
  module Extensions
    module GlobalWorkspace
      module Helpers
        class Broadcast
          include Constants

          attr_reader :content, :source, :domain, :salience, :coalition,
                      :broadcast_at, :received_by

          def initialize(content:, source:, domain:, salience:, coalition: [])
            @content      = content
            @source       = source
            @domain       = domain
            @salience     = salience.to_f.clamp(0.0, 1.0)
            @coalition    = Array(coalition).first(MAX_COALITION_SIZE)
            @broadcast_at = Time.now.utc
            @received_by  = []
          end

          def acknowledge(subscriber_id)
            @received_by << subscriber_id unless @received_by.include?(subscriber_id)
          end

          def expired?
            (Time.now.utc - @broadcast_at) > BROADCAST_TTL
          end

          def age
            Time.now.utc - @broadcast_at
          end

          def label
            SALIENCE_LABELS.each { |range, lbl| return lbl if range.cover?(@salience) }
            :subliminal
          end

          def to_h
            {
              content: @content,
              source: @source,
              domain: @domain,
              salience: @salience.round(4),
              label: label,
              coalition: @coalition,
              broadcast_at: @broadcast_at,
              age: age.round(2),
              received_by: @received_by.dup,
              expired: expired?
            }
          end
        end
      end
    end
  end
end
