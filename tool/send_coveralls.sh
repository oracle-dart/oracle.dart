#!/bin/bash

rm -rf coverage > /dev/null
mkdir coverage

for f in test/*_test.dart; do
    echo "Covering $f"
    dart_coveralls report -T --dry-run -p $f | python tool/scrape_json.py > coverage/$(basename $f).json
done

echo "Covering cpp"
cpp-coveralls -b lib/src -t faketoken --dump coverage/cpp_coverage.json

python tool/coveralls_merge.py coverage/*
