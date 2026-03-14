# frozen_string_literal: true

RSpec.describe Legion::Extensions::GlobalWorkspace::Helpers::Workspace do
  subject(:ws) { described_class.new }

  let(:constants) { Legion::Extensions::GlobalWorkspace::Helpers::Constants }

  describe '#register_subscriber / #unregister_subscriber' do
    it 'registers a subscriber' do
      expect(ws.register_subscriber(id: :memory, name: 'lex-memory', domains: [:all])).to be true
      expect(ws.subscriber_count).to eq(1)
    end

    it 'unregisters a subscriber' do
      ws.register_subscriber(id: :memory, name: 'lex-memory')
      expect(ws.unregister_subscriber(id: :memory)).to be true
      expect(ws.subscriber_count).to eq(0)
    end

    it 'returns false for unknown unregister' do
      expect(ws.unregister_subscriber(id: :unknown)).to be false
    end

    it 'limits subscribers' do
      constants::MAX_SUBSCRIBERS.times { |i| ws.register_subscriber(id: "sub_#{i}", name: "s#{i}") }
      expect(ws.register_subscriber(id: :overflow, name: 'over')).to be false
    end
  end

  describe '#submit' do
    it 'adds a competitor' do
      comp = ws.submit(content: 'idea', source: :cortex, domain: :cognition, salience: 0.6)
      expect(comp).to be_a(Legion::Extensions::GlobalWorkspace::Helpers::Competitor)
      expect(ws.competitor_count).to eq(1)
    end

    it 'rejects below-threshold submissions' do
      result = ws.submit(content: 'weak', source: :s, domain: :d, salience: 0.1)
      expect(result).to be_nil
      expect(ws.competitor_count).to eq(0)
    end

    it 'limits competitor queue' do
      constants::MAX_COMPETITORS.times { |i| ws.submit(content: "c_#{i}", source: :s, domain: :d, salience: 0.5) }
      ws.submit(content: :overflow, source: :s, domain: :d, salience: 0.5)
      expect(ws.competitor_count).to eq(constants::MAX_COMPETITORS)
    end
  end

  describe '#compete' do
    it 'returns nil with no competitors' do
      expect(ws.compete).to be_nil
    end

    it 'broadcasts the dominant competitor' do
      ws.submit(content: 'strong', source: :emotion, domain: :safety, salience: 0.9)
      ws.submit(content: 'weak', source: :cortex, domain: :cognition, salience: 0.3)
      broadcast = ws.compete
      expect(broadcast).to be_a(Legion::Extensions::GlobalWorkspace::Helpers::Broadcast)
      expect(broadcast.content).to eq('strong')
    end

    it 'returns nil when no clear winner (within margin)' do
      ws.submit(content: 'a', source: :s, domain: :d, salience: 0.5)
      ws.submit(content: 'b', source: :s, domain: :d, salience: 0.5)
      result = ws.compete
      expect(result).to be_nil
    end

    it 'boosts urgency of losers' do
      ws.submit(content: 'a', source: :s, domain: :d, salience: 0.5)
      ws.submit(content: 'b', source: :s, domain: :d, salience: 0.5)
      ws.compete
      expect(ws.competitors.first.urgency).to be > 0
    end

    it 'removes winner from competitors' do
      ws.submit(content: 'winner', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.competitor_count).to eq(0)
    end

    it 'adds to broadcast history' do
      ws.submit(content: 'winner', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.broadcast_history.size).to eq(1)
    end
  end

  describe '#conscious?' do
    it 'returns true for current broadcast content' do
      ws.submit(content: 'idea', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.conscious?('idea')).to be true
    end

    it 'returns false when no broadcast' do
      expect(ws.conscious?('anything')).to be false
    end

    it 'returns false for non-matching content' do
      ws.submit(content: 'idea', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.conscious?('other')).to be false
    end
  end

  describe '#current_content' do
    it 'returns broadcast hash when active' do
      ws.submit(content: 'idea', source: :cortex, domain: :cognition, salience: 0.9)
      ws.compete
      content = ws.current_content
      expect(content[:content]).to eq('idea')
      expect(content[:source]).to eq(:cortex)
    end

    it 'returns nil when no active broadcast' do
      expect(ws.current_content).to be_nil
    end
  end

  describe '#acknowledge' do
    it 'acknowledges current broadcast' do
      ws.submit(content: 'idea', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.acknowledge(subscriber_id: :memory)).to be true
    end

    it 'returns false when no broadcast' do
      expect(ws.acknowledge(subscriber_id: :memory)).to be false
    end
  end

  describe '#state' do
    it 'returns :idle when empty' do
      expect(ws.state).to eq(:idle)
    end

    it 'returns :broadcasting when broadcast active' do
      ws.submit(content: 'idea', source: :s, domain: :d, salience: 0.9)
      ws.compete
      expect(ws.state).to eq(:broadcasting)
    end

    it 'returns :contention when multiple competitors' do
      ws.submit(content: 'a', source: :s, domain: :d, salience: 0.5)
      ws.submit(content: 'b', source: :s, domain: :d, salience: 0.5)
      expect(ws.state).to eq(:contention)
    end
  end

  describe '#tick' do
    it 'decays competitors' do
      ws.submit(content: 'idea', source: :s, domain: :d, salience: 0.5)
      before = ws.competitors.first.salience
      ws.tick
      expect(ws.competitors.first&.salience || 0).to be <= before
    end

    it 'prunes weak competitors after decay' do
      ws.submit(content: 'weak', source: :s, domain: :d, salience: constants::COMPETITION_THRESHOLD + 0.01)
      ws.tick
      expect(ws.competitor_count).to eq(0)
    end
  end

  describe '#to_h' do
    it 'returns stats hash' do
      h = ws.to_h
      expect(h).to include(:state, :state_label, :subscribers, :competitors, :broadcast_history, :utilization,
                           :competitions)
    end
  end
end
