#!/usr/bin/env bash

# Use .rvmrc as per
#   https://rvm.io/workflow/rvmrc
#
# To debug this script use
#   set -v

# run rake with parameters
# bundle exec rake -f Rakefile $@
rake -f Rakefile $@
