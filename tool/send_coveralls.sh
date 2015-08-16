#!/bin/bash

mkdir coverage

for f in test/*_test.dart; do
    dart_coveralls report --dry-run -p $f | python tool/scrape_json.py > coverage/$(basename $f).json
done

cpp-coverage -b lib/src -t faketoken --dump coverage/cpp_coverage.json
