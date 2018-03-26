INPUT=../test/test.c-
if [ $# -gt 0 ]
then
	INPUT=$1
fi

mkdir -p bin 
lex -o "bin/lex.yy.c" src/lex/lex.l && g++ -Isrc/lex/ -std=c++14 "bin/lex.yy.c" -o bin/gcc-
pushd bin > /dev/null
./gcc- $INPUT
popd > /dev/null
