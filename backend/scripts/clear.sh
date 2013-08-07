#!/bin/bash
echo "FLUSHALL" | redis-cli       
echo "db.dropDatabase()" | mongo parliament
mongoimport --db parliament --collection mp_votes --file data/votematrix-2010.dat --drop --type tsv --headerline
mongoimport --db parliament --collection lords_votes --file data/votematrix-lords.dat --drop --type tsv --headerline
mongoimport --db parliament --collection mp_votes_meta --file data/votematrix-2010.txt --drop --type tsv --headerline
mongoimport --db parliament --collection lords_votes_meta --file data/votematrix-lords.txt --drop --type tsv --headerline
