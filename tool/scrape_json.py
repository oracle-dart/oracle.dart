#!/usr/bin/env python

#
# Scrape json from dart_coveralls because it's terrible and only dumps json to stdout
#

import sys

def main():
    lines = sys.stdin.readlines()

    for i, l in enumerate(lines):
        if l.startswith('{'):
            break

    for l in lines[i:]:
        print(l.strip("\r\n"))


if __name__ == '__main__':
    main()
