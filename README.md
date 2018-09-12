## Concourse API gem
This gem will assist you in interfacing with concourse's api

Currently only supports:
  * concourse's basic auth mechanism
  * the endpoints used by web ui

PRs are welcome for these, and other features


## Installation
Add the following to your Gemfile

upstream:
```bash
source "https://rubygems.org"
gem "concourserb"
```

git:
```bash
source 'https://rubygems.org'
gem 'concourserb', :git => 'https://github.com/arwineap/concourserb'
```

local:
```bash
source 'https://rubygems.org'
gem 'concourserb', :path => "~/git/concourserb"
```


## Examples
```ruby
require 'concourserb'
ci = Concourserb.new('https://ci.concourse.ci', 'main', 'basic_auth_user', 'basic_auth_pass')

puts ci.jobs('pipeline')
```
