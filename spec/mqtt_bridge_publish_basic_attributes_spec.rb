# frozen_string_literal: true

require "yaml"

require_relative "../exe/bwa_mqtt_bridge"

PropertyRecord = Struct.new(:name, :description, :type, :options, :callback, :button, keyword_init: true)

class FakeProperty
  attr_reader :record

  def initialize(record)
    @record = record
  end

  def hass_button(**kwargs)
    record.button = kwargs
  end
end

class FakeSpa
  attr_reader :properties

  def initialize
    @properties = []
  end

  def property(name, description, type, **kwargs, &block)
    record = PropertyRecord.new(name: name,
                                description: description,
                                type: type,
                                options: kwargs,
                                callback: block)
    properties << record
    FakeProperty.new(record)
  end
end

RSpec.describe MQTTBridge do
  describe "#publish_action_buttons" do
    it "publishes three Home Assistant button properties with single enum values" do
      bridge = described_class.allocate
      spa = FakeSpa.new
      bwa = instance_double(BWA::Client)
      allow(bwa).to receive(:toggle_item)
      bridge.instance_variable_set(:@bwa, bwa)

      allow_toggles = lambda do |value|
        value
      end

      bridge.send(:publish_action_buttons, spa, allow_toggles)

      expect(spa.properties.map(&:name)).to eq(%w[clear-notification normal-operation soak])
      expect(spa.properties.map { |prop| prop.options[:format] }).to eq(
        [
          ["clear_notification"],
          ["normal_operation"],
          ["soak"]
        ]
      )
      expect(spa.properties.map { |prop| prop.button[:payload_press] }).to eq(
        %w[clear_notification normal_operation soak]
      )

      spa.properties[0].callback.call("clear_notification")
      spa.properties[1].callback.call("normal_operation")
      spa.properties[2].callback.call("soak")

      expect(bwa).to have_received(:toggle_item).with(:clear_notification)
      expect(bwa).to have_received(:toggle_item).with(:normal_operation)
      expect(bwa).to have_received(:toggle_item).with(:soak)
    end

    it "maps object_id and payload_press consistently for each button" do
      bridge = described_class.allocate
      spa = FakeSpa.new
      bridge.instance_variable_set(:@bwa, instance_double(BWA::Client, toggle_item: nil))

      bridge.send(:publish_action_buttons, spa, ->(value) { value })

      expect(spa.properties.map { |prop| [prop.name, prop.button[:object_id], prop.button[:payload_press]] }).to eq(
        [
          %w[clear-notification clear_notification clear_notification],
          %w[normal-operation normal_operation normal_operation],
          %w[soak soak soak]
        ]
      )
    end

    it "matches the action button discovery snapshot" do
      bridge = described_class.allocate
      spa = FakeSpa.new
      bridge.instance_variable_set(:@bwa, instance_double(BWA::Client, toggle_item: nil))

      bridge.send(:publish_action_buttons, spa, ->(value) { value })

      actual = spa.properties.map do |prop|
        {
          "name" => prop.name,
          "format" => prop.options[:format],
          "object_id" => prop.button[:object_id],
          "payload_press" => prop.button[:payload_press]
        }
      end
      expected = YAML.load_file(File.expand_path("fixtures/action_buttons_snapshot.yml", __dir__))

      expect(actual).to eq(expected)
    end
  end
end
