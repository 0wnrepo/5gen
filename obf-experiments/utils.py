import os

def extract(line):
    return float(line.rstrip().rsplit(' ', 1)[1])
def extract_bracket(line):
    try:
        str = line.rstrip().rsplit('\t', 1)[1]
    except IndexError:
        str = line.rstrip().rsplit(' ', 1)[1]
    return float(str[1:-2])

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
                line = f.next().strip()
                r = extract_bracket(line)
                print('    p_i/g_i: %.2f s' % round(r, 2))
            elif line.startswith('Generating CRT'):
                line = f.next().strip()
                r = extract_bracket(line)
                print('    CRT:     %.2f s' % round(r, 2))
            elif line.startswith('Generating z_i'):
                line = f.next().strip()
                r = extract_bracket(line)
                print('    z_i:     %.2f s' % round(r, 2))
            elif line.startswith('Generating pzt'):
                line = f.next().strip()
                r = extract_bracket(line)
                print('    pzt:     %.2f s' % round(r, 2))
            elif line.startswith('Took') and mmap:
                r = extract(line)
                print('Mmap Time: %.2f s' % round(r, 2))
                mmap = False
            elif line.startswith('Obfuscation took'):
                r = extract(line)
                print('Obf Time:  %.2f s' % round(r, 2))
            elif line.startswith('Max memory'):
                print('Obf RAM:   %.2f MB' % round(extract(line) / 1024, 2))
                break

def obfsize(fname):
    with open(fname, 'r') as f:
        total = 0
        for line in f:
            size, _ = line.strip().split('\t', 1)
            total += int(size)
        return int(total)

def evaltime(fname):
    time = None
    ram = None
    with open(fname, 'r') as f:
        while True:
            try:
                line = f.next()
            except StopIteration:
                break
            if line.startswith('Took:'):
                _, b = line.rstrip().rsplit(' ', 1)
                time = float(b)
            if line.startswith('Max memory usage:'):
                _, b = line.rstrip().rsplit(' ', 1)
                ram = int(b)
    return time, ram
                
