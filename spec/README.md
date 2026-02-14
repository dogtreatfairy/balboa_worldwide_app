# Test Notes

## Running tests

```sh
bundle exec rspec
```

## Snapshot spec: action button discovery

The file `fixtures/action_buttons_snapshot.yml` is used by
`mqtt_bridge_publish_basic_attributes_spec.rb` to detect accidental drift in
Home Assistant action-button discovery fields.

If you intentionally change action button discovery output, update the snapshot
in tandem:

1. Modify the bridge code and/or expectations.
2. Update `fixtures/action_buttons_snapshot.yml` to match the new intended
   values.
3. Run `bundle exec rspec` and ensure tests pass.

Keep snapshot updates tightly scoped to intended behavior changes.

## Retry/backoff behavior

`mqtt_bridge_retry_spec.rb` validates retry backoff calculations, jitter bounds,
and backoff metadata shape used by structured retry logs.
