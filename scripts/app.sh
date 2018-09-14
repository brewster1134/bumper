#!/usr/bin/env bash

# clear tmp directory
rm -rf $bumper_root_dir/.tmp

# always run app from the same directory, no matter where app.sh is run from
bumper_root_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )
cd $bumper_root_dir

# convert coffee to js
yarn run coffee -o $bumper_root_dir/.tmp/app_start.js $bumper_root_dir/app/app_start.coffee

# start the app
nodemon $bumper_root_dir/.tmp/app_start.js
