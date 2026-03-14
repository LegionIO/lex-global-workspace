# frozen_string_literal: true

RSpec.describe Legion::Extensions::GlobalWorkspace::Helpers::Broadcast do
  subject(:broadcast) do
    described_class.new(content: 'threat_detected', source: :emotion, domain: :safety, salience: 0.9,
                        coalition: %i[fear attention])
  end

  let(:constants) { Legion::Extensions::GlobalWorkspace::Helpers::Constants }

  describe '#initialize' do
    it 'sets attributes' do
      expect(broadcast.content).to eq('threat_detected')
      expect(broadcast.source).to eq(:emotion)
      expect(broadcast.domain).to eq(:safety)
      expect(broadcast.salience).to eq(0.9)
      expect(broadcast.coalition).to eq(%i[fear attention])
    end

    it 'clamps salience' do
      high = described_class.new(content: :x, source: :s, domain: :d, salience: 1.5)
      expect(high.salience).to eq(1.0)
    end

    it 'records broadcast_at' do
      expect(broadcast.broadcast_at).to be_a(Time)
    end

    it 'starts with empty received_by' do
      expect(broadcast.received_by).to be_empty
    end

    it 'limits coalition size' do
      big = described_class.new(content: :x, source: :s, domain: :d, salience: 0.5,
                                coalition: (1..20).to_a)
      expect(big.coalition.size).to eq(constants::MAX_COALITION_SIZE)
    end
  end

  describe '#acknowledge' do
    it 'adds subscriber to received_by' do
      broadcast.acknowledge(:memory)
      expect(broadcast.received_by).to include(:memory)
    end

    it 'does not duplicate' do
      broadcast.acknowledge(:memory)
      broadcast.acknowledge(:memory)
      expect(broadcast.received_by.size).to eq(1)
    end
  end

  describe '#expired?' do
    it 'returns false when fresh' do
      expect(broadcast.expired?).to be false
    end
  end

  describe '#age' do
    it 'returns elapsed time' do
      expect(broadcast.age).to be >= 0.0
    end
  end

  describe '#label' do
    it 'returns :dominant for high salience' do
      expect(broadcast.label).to eq(:dominant)
    end

    it 'returns :subliminal for low salience' do
      low = described_class.new(content: :x, source: :s, domain: :d, salience: 0.1)
      expect(low.label).to eq(:subliminal)
    end
  end

  describe '#to_h' do
    it 'returns hash with all fields' do
      h = broadcast.to_h
      expect(h).to include(:content, :source, :domain, :salience, :label, :coalition, :broadcast_at, :age,
                           :received_by, :expired)
    end
  end
end
