#!/bin/sh
# ideas used from https://gist.github.com/motemen/8595451

# Based on https://github.com/eldarlabs/ghpages-deploy-script/blob/master/scripts/deploy-ghpages.sh
# Used with their MIT license https://github.com/eldarlabs/ghpages-deploy-script/blob/master/LICENSE

# abort the script if there is a non-zero error
set -e

# show where we are on the machine
pwd
remote=git@github.com:marduke182/marduke182.github.io.git

# make a directory to put the gp-pages branch
mkdir gh-pages-branch
cd gh-pages-branch
# now lets setup a new repo so we can update the gh-pages branch
git config --global user.email "jrqb182@gmail.com" > /dev/null 2>&1
git config --global user.name "marduke182" > /dev/null 2>&1
git init
git remote add --fetch origin "$remote"

git checkout master
# delete any old site as we are going to replace it
# Note: this explodes if there aren't any, so moving it here for now
git rm -rf .

# copy over or recompile the new site
cp -a ../_site/. .
echo "blog.jquintanab.com" > CNAME

# stage any changes and new files
git add -A
# now commit, ignoring branch gh-pages doesn't seem to work, so trying skip
git commit --allow-empty -m "Deploy to GitHub pages [ci skip]"
# and push, but send any output to /dev/null to hide anything sensitive
git push --force --quiet origin master
# go back to where we started and remove the gh-pages git repo we made and used
# for deployment
cd ..
rm -rf gh-pages-branch

echo "Finished Deployment!"
