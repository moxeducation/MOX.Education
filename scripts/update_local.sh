#!/bin/sh
rake db:drop db:create
ssh -l deployer madeofx mysqldump -u madeofx -p madeofx | rails db
rm -rf public/system/*
rsync -h --progress -r madeofx:/srv/madeofx.net/shared/public/system/ ./public/system/
