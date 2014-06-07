# GitCloner

[![Build Status](https://travis-ci.org/tbpgr/git_cloner.png?branch=master)](https://travis-ci.org/tbpgr/git_cloner)

GitCloner clone git repositoris from Gitclonerfile settings.

## Installation

Add this line to your application's Gemfile:

    gem 'git_cloner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_cloner

## CLI-Usage

### generate Gitclonerfile

~~~bash
gitcloner init
~~~

~~~ruby
# encoding: utf-8

# default_output place
# default_output is required
# default_output allow only String
# default_output's default value => "./"
default_output "./"

# git repositries
# repos allow only Array(in Array, Hash[:place, :output, :copies])
# copies is option.
# copies must have Array[Hash{:from, :to}].
# you can copy files or directories.
# repos's default value => []
repos [
  {
    place: 'https://github.com/tbpgr/rspec_piccolo.git',
    output: './tmp',
    copies: [
      {from: "./tmp/rspec_piccolo/lib/rspec_piccolo", to: "./"},
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}
    ]
  }
]
~~~

### edit Gitclonerfile manually

~~~ruby
# encoding: utf-8
default_output "./"
repos [
  {
    place: "https://github.com/tbpgr/rspec_piccolo.git",
    output: "./tmp",
    copies: [
      {from: "./tmp/rspec_piccolo/lib/rspec_piccolo", to: "./"}, 
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}, 
      {from: "./tmp/rspec_piccolo/spec/spec_helper.rb", to: "./helper/helper.rb"}, 
    ]
  },
  {
    place: "https://github.com/tbpgr/tbpgr_utils.git",
  }
]
~~~

### execute clone

~~~bash
gitcloner clone
~~~

### confirm clone result

~~~bash
$ tree
├─helper
｜ └spec_helper.rb
├─rspec_piccolo
｜ └many files...
├─sample
｜ ├rspec_piccolo_spec.rb
｜ └spec_helper.rb
├─tmp
｜ └rspec_piccolo
└─tbpgr_utils
    └many files...
~~~

## Direct Usage
if you want to use GitCloner directry, you can use like this sample.

~~~ruby
require 'git_cloner_core'

default_output = "./",
repos = [
  {
    place: "https://github.com/tbpgr/rspec_piccolo.git",
    output: "./tmp",
    copies: [
      {from: "./tmp/rspec_piccolo/lib/rspec_piccolo", to: "./"}, 
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}, 
      {from: "./tmp/rspec_piccolo/spec/spec_helper.rb", to: "./helper/helper.rb"}, 
    ]
  },
  {
    place: "https://github.com/tbpgr/tbpgr_utils.git",
  }
]

GitCloner::Core.new.clone default_output, repos
~~~

## History
* version 0.0.3 : enable direct call clone.
* version 0.0.2 : add files,directories copy.
* version 0.0.1 : first release.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
