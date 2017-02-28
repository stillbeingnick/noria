#!/bin/bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
URL="http://jmob.ow2.org/tpcw/generate.tar.gz"

# default scale factor is 10000
SF_ITEMS=10000
SF_BROWSERS=10000

if [[ $# > 1 ]]; then
  SF_ITEMS=$1
  SF_BROWSERS=$2
fi

mkdir -p generate
mkdir -p data

# download
wget ${URL} -O generate/generate.tar.gz
tar -xzf generate/generate.tar.gz

# patch & build generator
cd generate
echo "char *getRandString(char *str, int l, int h);" >> tpcw-spec.h
make clean && make all

CUST=$(expr ${SF_BROWSERS} \* 288)
# generate tables
echo "Generating countries..."
./tpcw -t country > ../data/countries.tsv
echo "Generating authors..."
# authors = 0.25 * ITEM, and for weird reasons must be at least 12
SF_ITEMS_ROUNDED=$(python -c "from math import ceil; print max(12, int(ceil(${SF_ITEMS}*0.25)))")
./tpcw -t author -i ${SF_ITEMS_ROUNDED} > ../data/authors.tsv
echo "Generating customers..."
./tpcw -t customer -c ${CUST} > ../data/customers.tsv
echo "Generating addresses..."
./tpcw -t address -c ${CUST} > ../data/addresses.tsv
echo "Generating orders..."
./tpcw -t orders -c ${CUST} -p ../data > ../data/orders.tsv