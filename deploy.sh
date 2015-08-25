#!/bin/sh

rake build
cp -r build/* ../slate-pages/
cd ../slate-pages
git ci -am "update"
git push
