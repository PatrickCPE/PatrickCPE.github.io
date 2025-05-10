#!/bin/sh
pushd `pwd`
cd ../patrickcpe_publish
cp  -r ../patrickcpe_build/* .
git add *
git commit
git push origin

