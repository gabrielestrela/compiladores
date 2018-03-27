INPUT=./test/test.c-
SRCDIR=./src
BINDIR=./bin
BINOBJ=gcc-

if (( $# < 1 )); then
    echo 'Input não especificado, usando padrão "'"$INPUT"'".'
else
    INPUT=$1
fi

if [[ ! -d "$BINDIR" ]]; then
    echo 'Diretório de binários inexistente, criando.'
    mkdir -p bin
fi

if [[ ! -e "$BINDIR/$BINOBJ" ]]; then
    echo 'Binário do lexer inexistente, gerando.'
    lex -o "$BINDIR/lex.yy.c" "$SRCDIR/lex/lex.l" \
        && g++ -I"$SRCDIR/lex/" -std=c++14 "$BINDIR/lex.yy.c" -o "$BINDIR/$BINOBJ"
fi

echo 'Rodando lexer para arquivo de input "'"$INPUT"'".'
"$BINDIR/$BINOBJ" "$INPUT"
echo 'Finalizado. Todos os resultados em "'relatorio.txt'".'
