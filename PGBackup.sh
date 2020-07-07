#!/bin/bash
# Autor: Wagner Cipriano Gn�OB <wagner@intip.com.br> #
# * DataBases PostgreSql #
# Para incluir novos bancos de dados no backup editar o arquivo #
# './DBs.backup' colocando espaco entre os nomes. #
# #
# Copie a vontade, mantenha o autoria original #
################################################

# CRIAR UM ARQUIVO DBs.backup com o nome da base de dados

PATH=/usr/sbin:/usr/local/bin:/usr/bin:/bin
export PATH
inicio="`date +%Y-%m-%d_%H:%M:%S`"
C:\Users\Cezar\Downloads\PGBackup.shCD
#@ Variaveis
EMAIL="cezar.alves.dev@gmail.com"
DIR=/backup/data
ERRORLOG="$DIR/error.log"
ERROR=0;
PGUser="postgres"
PGPort="5432"

#@ Pega a lista de databases a "bk_piar" no arq de configuracao
DATABASES=(`cat ./DBs.backup`)
if [ "$?" -ne 0 ]; then
echo "ERRO: arquivo de configuracao dos DataBases nao encontrado: 'DBs.backup'";
ERROR=1;
fi


#@ Para cada database da lista, executa o dump e compacta
DIR=/backup/data/pgsql
cd $DIR
for((i=0; i < ${#DATABASES[@]}; i++))
do
echo ">>> dump DB ${DATABASES[$i]}"
pg_dump -p $PGPort -U $PGUser -C -f ./db${DATABASES[$i]}.bkp ${DATABASES[$i]} 2> $ERRORLOG
if [ "$?" -ne 0 ]; then
echo "ERRO ao gerar dump DB $i: '${DATABASES[$i]}'";
ERROR=1;
fi
echo ">>> compactando dump do DB ${DATABASES[$i]}"
tar -cvzf db${DATABASES[$i]}-`date +"%y%m%d"`.tgz ./db${DATABASES[$i]}.bkp 2>> $ERRORLOG
if [ "$?" -ne 0 ]; then
echo "ERRO ao compactar DUMP do DB $i: '${DATABASES[$i]}'";
ERROR=1;
fi
done
cd $DIR
#@ Apaga os arquivos de backup e mantem apenas os arquivos compactador
rm ./*.bkp
#@ limpa os arquivos antigos, mantendo os ultimos 5 dias
find $DIR/ -name "*.tgz" -mtime +5 -type f -exec rm -f {} \;


#@ Envia email de confirmacao
echo ">>> envio de email de comfirmacao para $EMAIL"
if [ "$ERROR" -eq 1 ]; then
cat $ERRORLOG | mail $EMAIL -s "web-master Intip: Erro no backup `date`";
else
echo "Backup local web-master Intip gerado com sucesso em `date`" | mail $EMAIL -s "web-master Intip: backup ok em `date`"
fi

echo "Rotina inciou em: $inicio"
echo "Rotina terminou em: `date +%Y-%m-%d_%H:%M:%S`"
