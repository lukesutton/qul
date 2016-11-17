# Qul

An experiment with building declarative transforms of JSON data. The essential
idea is to be able to compose a pipeline of transformations, which can then
be applied to a JSON object, reformatting it in some way.

It should also accumulate any failures as it processes. It does not exit on the
first failure, but rather attempts what it can. This way it can show _all_ the
issues with the JSON and transforms.

## Planned transforms:

- Rename field
- Remove field
- Flatten array value
- Convert value type e.g. String to Integer

## Further Ideas

- Allow transform configuration to be stored in a database; trivial actually
- Add validation; works in the same way, but only generates failures
- Failures could be better classified using types rather than just strings
