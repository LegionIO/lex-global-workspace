# frozen_string_literal: true

RSpec.describe Legion::Extensions::GlobalWorkspace::Client do
  subject(:client) { described_class.new }

  it 'includes Runners::GlobalWorkspace' do
    expect(described_class.ancestors).to include(Legion::Extensions::GlobalWorkspace::Runners::GlobalWorkspace)
  end

  it 'supports full conscious access lifecycle' do
    # Register subscribers (cognitive subsystems)
    client.register_subscriber(id: :memory, name: 'lex-memory', domains: [:all])
    client.register_subscriber(id: :emotion, name: 'lex-emotion', domains: [:safety])
    client.register_subscriber(id: :planning, name: 'lex-planning', domains: [:cognition])

    # Multiple subsystems submit content for conscious access
    client.submit_for_broadcast(content: 'threat_nearby', source: :emotion, domain: :safety, salience: 0.85)
    client.submit_for_broadcast(content: 'plan_step_3', source: :planning, domain: :cognition, salience: 0.5)
    client.submit_for_broadcast(content: 'memory_trace', source: :memory, domain: :recall, salience: 0.3)

    # Competition: emotion wins (highest salience, clear margin)
    competition = client.run_competition
    expect(competition[:success]).to be true
    expect(competition[:broadcast][:content]).to eq('threat_nearby')

    # Verify consciousness
    conscious = client.query_consciousness(content: 'threat_nearby')
    expect(conscious[:conscious]).to be true

    # Subscribers acknowledge receipt
    client.acknowledge_broadcast(subscriber_id: :memory)
    client.acknowledge_broadcast(subscriber_id: :emotion)

    # Check current state
    current = client.current_broadcast
    expect(current[:broadcast][:received_by]).to include(:memory, :emotion)

    # Tick maintenance
    client.update_global_workspace

    # History preserved
    history = client.broadcast_history(limit: 10)
    expect(history[:total]).to eq(1)

    # Stats
    stats = client.workspace_stats
    expect(stats[:stats][:subscribers]).to eq(3)
  end
end
