# Changelog

All notable changes to this project will be documented in this file.

This project adheres to [Semantic Versioning](https://semver.org/).

## [2.4.0] - 2026-02-14

### Fixed

- **MQTT bridge crash with mqtt-homie-homeassistant**: Split the multi-value
  `"command"` enum property (which contained `clear_notification`,
  `normal_operation`, and `soak`) into three individual single-value enum
  properties (`clear-notification`, `normal-operation`, `soak`). This resolves
  the `ArgumentError: Property must have one valid enum value` crash introduced
  by mqtt-homie-homeassistant's stricter validation.
- **Gemspec email typo**: Removed trailing apostrophe from author email address.
- **Gemspec homepage typo**: Corrected `balboa_wordlwide_app` →
  `balboa_worldwide_app` in the homepage URL.
- **RuboCop offenses** (23 total):
  - `exe/bwa_mqtt_bridge`: Removed unused `require "set"`, removed redundant
    `begin` block inside retry loop, simplified `rescue StandardError` →
    `rescue`.
  - `lib/bwa/client.rb`: Fixed `Style/SlicingWithRange` —
    `[bytes_read..-1]` → `[bytes_read..]`.
  - `lib/bwa/messages/status.rb`: Fixed `Style/RedundantFreeze` — removed
    `.freeze` from an immutable `Range`.
  - `lib/bwa/proxy.rb`: Fixed `Style/SlicingWithRange` —
    `[(data_length + 2)..-1]` → `[(data_length + 2)..]`.
  - `spec/`: Moved constants (`PropertyRecord`, `FakeProperty`, `FakeSpa`) out
    of `RSpec.describe` block to fix `Lint/ConstantDefinitionInBlock`, converted
    string arrays to `%w[]` word arrays, fixed array element indentation.

### Added

- **Reconnect with exponential backoff and jitter**: The MQTT bridge now
  automatically reconnects on failure using equal-jitter exponential backoff
  (industry-standard algorithm). Configurable via `DEFAULT_RETRY_BASE_DELAY`
  (1 s) and `DEFAULT_RETRY_MAX_DELAY` (60 s). Supports deterministic testing
  via injectable `rng:` parameter.
- **Structured JSON retry telemetry**: `MQTTBridge.retry_backoff` returns a
  metadata hash (`attempt`, `base_delay`, `max_delay`, `capped_delay`, `delay`,
  `jitter`) emitted as JSON to `$stderr` on each retry for Loki/ELK/Grafana
  ingestion.
- **RSpec test suite**:
  - `spec/mqtt_bridge_publish_basic_attributes_spec.rb` — verifies action button
    HA discovery properties, object_id/payload_press mapping, and YAML snapshot
    drift detection.
  - `spec/mqtt_bridge_retry_spec.rb` — covers exponential growth, max cap,
    custom base delay, equal-jitter bounds, backoff metadata consistency, and
    input validation.
  - `spec/fixtures/action_buttons_snapshot.yml` — reference snapshot for button
    discovery properties.
  - `spec/spec_helper.rb`, `.rspec` — RSpec harness configuration.
  - `spec/README.md` — documents how to run tests and update snapshots.
- **GitHub Actions CI** (`.github/workflows/ci.yml`): Matrix build on Ruby 3.2
  and 3.3; runs RuboCop lint then RSpec tests; includes line-ending
  normalization step.
- **`.gitattributes`**: Enforces LF line endings (`* text=auto eol=lf`).
- **Operational logging docs**: Added Loki/ELK/Grafana-friendly logging section
  to `README.md` with example JSON payload, recommended indexed fields,
  dashboard/alert suggestions, and ingestion pipeline guidance.

### Changed

- **Required Ruby version**: Raised from `>= 2.4` to `>= 3.2` to match
  upstream `mqtt-homie-homeassistant 1.2.0` and `mqtt-homeassistant 1.2.0`
  requirements.
- **Dependency floors**:
  - `mqtt-homeassistant` → `~> 1.2, >= 1.2.0` (was `~> 0.1`).
  - `mqtt-homie-homeassistant` → `~> 1.2, >= 1.2.0` (was `~> 0.1`).
- **RuboCop target**: `.rubocop.yml` `TargetRubyVersion` updated from `2.5` to
  `3.2`.
- **`rubocop.yml` workflow**: Updated Ruby version from `3.1` to `3.2`;
  upgraded `actions/checkout` from `v2` to `v4`; added line-ending
  normalization step.
- **MQTT bridge main guard**: Wrapped startup code in
  `if __FILE__ == $PROGRAM_NAME` so the file can be safely loaded by tests
  without executing the main loop.
- **Extracted `publish_action_buttons`**: Refactored inline action button
  creation into a dedicated private method for testability.
- Added `rspec ~> 3.0` as a development dependency.

## [2.3.2] and earlier

See git history for previous changes.
