# frozen_string_literal: true

require_relative "../exe/bwa_mqtt_bridge"

RSpec.describe MQTTBridge do
  describe ".retry_backoff" do
    it "returns backoff metadata without jitter" do
      backoff = described_class.retry_backoff(3, jitter: false)

      expect(backoff).to include(
        attempt: 3,
        base_delay: 1,
        max_delay: 60,
        capped_delay: 4,
        delay: 4,
        jitter: false
      )
    end

    it "returns equal-jitter bounded metadata" do
      rng = instance_double(Random, rand: 0.5)
      backoff = described_class.retry_backoff(4, jitter: true, rng: rng)

      expect(backoff[:capped_delay]).to eq(8)
      expect(backoff[:delay]).to eq(6.0)
      expect(backoff[:jitter]).to eq(true)
    end
  end

  describe ".retry_delay" do
    it "grows exponentially without jitter" do
      expect(described_class.retry_delay(1, jitter: false)).to eq(1)
      expect(described_class.retry_delay(2, jitter: false)).to eq(2)
      expect(described_class.retry_delay(3, jitter: false)).to eq(4)
      expect(described_class.retry_delay(4, jitter: false)).to eq(8)
    end

    it "caps delay at max_delay without jitter" do
      expect(described_class.retry_delay(8, max_delay: 60, jitter: false)).to eq(60)
      expect(described_class.retry_delay(20, max_delay: 60, jitter: false)).to eq(60)
    end

    it "respects custom base_delay without jitter" do
      expect(described_class.retry_delay(1, base_delay: 3, jitter: false)).to eq(3)
      expect(described_class.retry_delay(2, base_delay: 3, jitter: false)).to eq(6)
    end

    it "returns equal-jitter bounded delay" do
      low_rng = instance_double(Random, rand: 0.0)
      high_rng = instance_double(Random, rand: 1.0)

      expect(described_class.retry_delay(4, jitter: true, rng: low_rng)).to eq(4.0)
      expect(described_class.retry_delay(4, jitter: true, rng: high_rng)).to eq(8.0)
    end

    it "matches delay from retry_backoff" do
      rng = instance_double(Random, rand: 0.25)

      delay = described_class.retry_delay(5, jitter: true, rng: rng)
      backoff = described_class.retry_backoff(5, jitter: true, rng: instance_double(Random, rand: 0.25))

      expect(delay).to eq(backoff[:delay])
    end

    it "validates input arguments" do
      expect { described_class.retry_delay(0) }.to raise_error(ArgumentError, /attempt/)
      expect { described_class.retry_delay(1, base_delay: 0) }.to raise_error(ArgumentError, /base_delay/)
      expect { described_class.retry_delay(1, base_delay: 2, max_delay: 1) }.to raise_error(ArgumentError, /max_delay/)
    end
  end
end
