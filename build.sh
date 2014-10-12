#!/usr/bin/env bash

# This is my generic Ruby build script that will:
#
# * prepare gem set
# * update bundles
# * invoke rake

# prepare ruby version for this environment
[[ -s "${HOME}/.rvm/scripts/rvm" ]] && source "${HOME}/.rvm/scripts/rvm"
[[ -s /usr/local/rvm/scripts/rvm ]] && source /usr/local/rvm/scripts/rvm
[[ -f .ruby-version && -f .ruby-gemset ]] && RVM_GEMSET=$(cat .ruby-version .ruby-gemset | tr "\\n" "@" | sed 's/@$//')
[[ -z "${RVM_GEMSET}" ]] && echo "ERROR: no valid ruby gemset found" && exit
rvm --create --install use ${RVM_GEMSET}

# prepare bundler
which bundle | grep ${RVM_GEMSET} >/dev/null || gem install bundler --no-rdoc --no-ri
bundle check >/dev/null || bundle install

# run rake with parameters
bundle exec rake -f Rakefile $@
