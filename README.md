# GitCloner

GitCloner clone git repositoris from Gitclonerfile settings.

## Installation

Add this line to your application's Gemfile:

    gem 'git_cloner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install git_cloner

## Usage

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
# repo allow only Array(in Array, Hash[:place, :output])
# repo's default value => []
repos [
  {
    place: 'https://github.com/tbpgr/rspec_piccolo.git',
    output: './tmp'
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
      {from: "./tmp/rspec_piccolo/spec", to: "./sample"}
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
├─rspec_piccolo
├─sample
｜ ├rspec_piccolo_spec.rb
｜ └spec_helper.rb
├─tmp
｜ └rspec_piccolo
└─tbpgr_utils
~~~

## History
* version 0.0.2 : add directories copy.
* version 0.0.1 : first release.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
