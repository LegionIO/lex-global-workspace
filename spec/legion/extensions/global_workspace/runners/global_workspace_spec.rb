# frozen_string_literal: true

RSpec.describe Legion::Extensions::GlobalWorkspace::Runners::GlobalWorkspace do
  let(:client) { Legion::Extensions::GlobalWorkspace::Client.new }

  describe '#submit_for_broadcast' do
    it 'submits content for competition' do
      result = client.submit_for_broadcast(content: 'idea', source: :cortex, domain: :cognition, salience: 0.7)
      expect(result[:success]).to be true
      expect(result[:effective_salience]).to be > 0
    end

    it 'rejects below-threshold content' do
      result = client.submit_for_broadcast(content: 'weak', source: :s, domain: :d, salience: 0.1)
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:below_threshold)
    end
  end

  describe '#run_competition' do
    it 'broadcasts winning content' do
      client.submit_for_broadcast(content: 'strong', source: :emotion, domain: :safety, salience: 0.9)
      result = client.run_competition
      expect(result[:success]).to be true
      expect(result[:broadcast][:content]).to eq('strong')
    end

    it 'returns no_winner when no competitors' do
      result = client.run_competition
      expect(result[:success]).to be false
      expect(result[:reason]).to eq(:no_winner)
    end
  end

  describe '#register_subscriber / #unregister_subscriber' do
    it 'registers a subscriber' do
      result = client.register_subscriber(id: :memory, name: 'lex-memory', domains: [:all])
      expect(result[:success]).to be true
      expect(result[:subscriber_count]).to eq(1)
    end

    it 'unregisters a subscriber' do
      client.register_subscriber(id: :memory, name: 'lex-memory')
      result = client.unregister_subscriber(id: :memory)
      expect(result[:success]).to be true
    end
  end

  describe '#acknowledge_broadcast' do
    it 'acknowledges active broadcast' do
      client.submit_for_broadcast(content: 'idea', source: :s, domain: :d, salience: 0.9)
      client.run_competition
      result = client.acknowledge_broadcast(subscriber_id: :memory)
      expect(result[:success]).to be true
    end

    it 'returns false when no broadcast' do
      result = client.acknowledge_broadcast(subscriber_id: :memory)
      expect(result[:success]).to be false
    end
  end

  describe '#query_consciousness' do
    it 'returns conscious: true for broadcasted content' do
      client.submit_for_broadcast(content: 'idea', source: :s, domain: :d, salience: 0.9)
      client.run_competition
      result = client.query_consciousness(content: 'idea')
      expect(result[:conscious]).to be true
    end

    it 'returns conscious: false for non-broadcasted content' do
      result = client.query_consciousness(content: 'nothing')
      expect(result[:conscious]).to be false
    end
  end

  describe '#current_broadcast' do
    it 'returns broadcast when active' do
      client.submit_for_broadcast(content: 'idea', source: :s, domain: :d, salience: 0.9)
      client.run_competition
      result = client.current_broadcast
      expect(result[:broadcast]).not_to be_nil
      expect(result[:broadcast][:content]).to eq('idea')
    end

    it 'returns nil when no active broadcast' do
      result = client.current_broadcast
      expect(result[:broadcast]).to be_nil
    end
  end

  describe '#broadcast_history' do
    it 'returns history' do
      client.submit_for_broadcast(content: 'idea', source: :s, domain: :d, salience: 0.9)
      client.run_competition
      result = client.broadcast_history(limit: 5)
      expect(result[:success]).to be true
      expect(result[:history].size).to eq(1)
    end
  end

  describe '#update_global_workspace' do
    it 'runs tick maintenance' do
      result = client.update_global_workspace
      expect(result[:success]).to be true
      expect(result).to have_key(:state)
      expect(result).to have_key(:utilization)
    end
  end

  describe '#workspace_stats' do
    it 'returns stats' do
      result = client.workspace_stats
      expect(result[:success]).to be true
      expect(result[:stats]).to include(:state, :subscribers, :competitors, :utilization)
    end
  end
end
