#! /bin/sh

# install the right ruby

  yes no | rbenv install `cat .ruby-version`

# prolly want bundler, tho some newer rubies come w/it

  gem install bundler

# annnnd install ruby deps

  bundle
