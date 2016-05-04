import os

def extract(line):
    return float(line.rstrip().rsplit(' ', 1)[1])

def obftime(fname):
    mmap = False
    with open(fname, 'r') as f:
        while True:
            try:
                line = f.next().strip()
            except StopIteration:
                break
            if line.startswith('Initializing mmap'):
                mmap = True
            elif line.startswith('Generating p_i'):
                r = extract(line)
                print('p_i/g_i: %.2f s' % round(r, 2))
            elif line.startswith('Generating CRT'):
                r = extract(line)
                print('CRT: %.2f s' % round(r, 2))
            elif line.startswith('Generating z_i'):
                r = extract(line)
                print('z_i: %.2f s' % round(r, 2))
            elif line.startswith('Generating pzt'):
                r = extract(line)
                print('pzt: %.2f s' % round(r, 2))
            elif line.startswith('Took') and mmap:
                r = extract(line)
                print('Mmap Time: %.2f s' % round(r, 2))
                mmap = False
            elif line.startswith('Obfuscation took'):
                r = extract(line)
                print('Obf Time:  %.2f s' % round(r, 2))
            elif line.startswith('Max memory'):
                print('RAM:       %.2f MB' % round(extract(line) / 1024, 2))
                break

def obfsize(fname):
    with open(fname, 'r') as f:
        total = 0
        for line in f:
            size, _ = line.strip().split('\t', 1)
            total += int(size)
        return int(total)

def evaltime(fname):
    with open(fname, 'r') as f:
        while True:
            try:
                line = f.next()
            except StopIteration:
                raise Exception('Could not find time info')
            if line.startswith('Took:'):
                a, b = line.rstrip().rsplit(' ', 1)
                return float(b)
