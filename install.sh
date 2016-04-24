cd gghlite-flint
git submodule update
autoreconf -i
./configure
sed '/all:/i install:' mife/jsmn/Makefile > mife/jsmn/Makefile
make
sudo make install
cd ..
cd obfuscation
autoreconf -i
./configure
make
sudo make install
python2 setup.py test
cd ..
