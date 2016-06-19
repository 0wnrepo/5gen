#!/usr/bin/env python2

from __future__ import division, print_function
import os, sys
import utils

def extract(line):
    return float(line.rstrip().rsplit(' ', 1)[1])

def main(argv):
    if len(argv) != 2:
        print('Usage: %s <dir>' % argv[0])
        sys.exit(1)
    dir = argv[1]
    utils.obftime('%s/obf-time.log' % dir)
    size = utils.obfsize('%s/obf-size.log' % dir)
    print('Obf Size:  %.2f MB' % round(size / 2 ** 20, 2))
    time, ram = utils.evaltime('%s/eval-time.log' % dir)
    print('Eval Time: %.2f s' % round(time, 2))
    print('Eval RAM:  %.2f MB' % round(ram / 1024, 2))

if __name__ == '__main__':
    try:
        main(sys.argv)
    except KeyboardInterrupt:
        pass
