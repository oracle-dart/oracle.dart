#!/bin/bash

rm -rf coverage > /dev/null
mkdir coverage

for f in test/*_test.dart; do
    echo "Covering $f"
    dart_coveralls report -T --dry-run -p $f | python tool/scrape_json.py > coverage/$(basename $f).json
done

echo "Covering cpp"
cpp-coveralls -b lib/src -t faketoken --dump coverage/cpp_coverage.json

merged_json=coverage/merged.json
echo "Merging coverage files"
python tool/coveralls_merge.py coverage/* $merged_json

echo 'Uploading to coveralls.io...'
curl -v -F json_file=@$merged_json https://coveralls.io/api/v1/jobs
