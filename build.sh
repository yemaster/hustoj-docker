#!/bin/sh

rm -rf ./web/src/
rm -rf ./judger/src/

git clone ${GITHUB_PROXY}https://github.com/zhblue/hustoj

mkdir ./web/src/
mkdir ./judger/src/
mkdir ./judger/etc/

cp -r ./hustoj/trunk/web/* ./web/src/
cp -r ./hustoj/trunk/core/* ./judger/src/
cp -r ./hustoj/trunk/install/java0.policy ./judger/etc/
cp -r ./hustoj/trunk/install/judge.conf ./judger/etc/

cd ./web && docker build -t yemaster/hustoj-web . && cd ..
cd ./judger && docker build -t yemaster/hustoj-judger . && cd ..

echo "Done."