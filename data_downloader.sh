#!/bin/bash

wget --quiet -O ./cat https://api.thecatapi.com/v1/images/search?size=full
wget --quiet -O ./quote http://api.icndb.com/jokes/random
chmod a+rwx ./cat

catimgURL=$(cat ./cat | jq -r '.[]' | jq -r '.url')
wget --quiet -O ./cat.jpg ${catimgURL}
catimg ./cat.jpg
cat ./quote | jq '.value' | jq '.joke'