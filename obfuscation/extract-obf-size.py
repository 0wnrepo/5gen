#!/usr/bin/env python2

from __future__ import division, print_function
import os, sys
import utils

def main(argv):
    if len(argv) != 2:
        print('Usage: %s <dir>' % argv[0])
        sys.exit(1)
    dir = argv[1]
    size = utils.obfsize('%s/obf-size.log' % dir)
    print('Size: %.2f MB' % round(size / 2 ** 20, 2))

if __name__ == '__main__':
    try:
        main(sys.argv)
    except KeyboardInterrupt:
        pass
