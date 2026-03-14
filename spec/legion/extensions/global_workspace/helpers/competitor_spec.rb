# frozen_string_literal: true

RSpec.describe Legion::Extensions::GlobalWorkspace::Helpers::Competitor do
  subject(:competitor) do
    described_class.new(content: 'idea', source: :cortex, domain: :cognition, salience: 0.6, coalition: [:attention])
  end

  let(:constants) { Legion::Extensions::GlobalWorkspace::Helpers::Constants }

  describe '#initialize' do
    it 'sets attributes' do
      expect(competitor.content).to eq('idea')
      expect(competitor.source).to eq(:cortex)
      expect(competitor.salience).to eq(0.6)
      expect(competitor.urgency).to eq(0.0)
    end

    it 'clamps salience' do
      high = described_class.new(content: :x, source: :s, domain: :d, salience: 2.0)
      expect(high.salience).to eq(1.0)
    end
  end

  describe '#effective_salience' do
    it 'equals salience when no urgency' do
      expect(competitor.effective_salience).to eq(0.6)
    end

    it 'includes urgency' do
      competitor.urgency = 0.2
      expect(competitor.effective_salience).to eq(0.8)
    end

    it 'clamps to 1.0' do
      competitor.salience = 0.9
      competitor.urgency = 0.3
      expect(competitor.effective_salience).to eq(1.0)
    end
  end

  describe '#decay' do
    it 'reduces salience' do
      before = competitor.salience
      competitor.decay
      expect(competitor.salience).to eq(before - constants::SALIENCE_DECAY)
    end

    it 'does not go below 0' do
      competitor.salience = 0.01
      competitor.decay
      expect(competitor.salience).to eq(0.0)
    end
  end

  describe '#boost_urgency' do
    it 'increases urgency' do
      competitor.boost_urgency
      expect(competitor.urgency).to eq(constants::URGENCY_BOOST)
    end

    it 'caps at MAX_URGENCY' do
      50.times { competitor.boost_urgency }
      expect(competitor.urgency).to eq(constants::MAX_URGENCY)
    end
  end

  describe '#below_threshold?' do
    it 'returns false when above threshold' do
      expect(competitor.below_threshold?).to be false
    end

    it 'returns true when below threshold' do
      competitor.salience = 0.1
      expect(competitor.below_threshold?).to be true
    end
  end

  describe '#to_h' do
    it 'returns hash with all fields' do
      h = competitor.to_h
      expect(h).to include(:content, :source, :domain, :salience, :urgency, :effective_salience, :coalition)
    end
  end
end
