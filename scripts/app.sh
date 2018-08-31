#!/usr/bin/env bash

# always run app from the same directory, no matter where app.sh is run from
bumper_root_dir=$( cd "$( dirname "${BASH_SOURCE[0]}" )"/.. && pwd )
cd $bumper_root_dir

# convert coffee to js
yarn run coffee -o $bumper_root_dir/.tmp/app_start.js $bumper_root_dir/scripts/app_start.coffee

# start the app
node $bumper_root_dir/.tmp/app_start.js
