# Peartrix

A rails app for managing team pairing rotations, inspired by [jgeiger/pairtrix](https://github.com/jgeiger/pairtrix).

## Getting Started

These instructions will get you a copy of the project up and running on your local machine for development and testing purposes. See deployment for notes on how to deploy the project on a live system.

### Prerequisites

* Ruby 2.3.1
* postgresql

### Installing

Fork the repo, and clone your fork to your machine

```
git clone https://github.com/[YOUR GITHUB USERNAME]/peartrix.git
```

Install the gems

```
bundle install
```
(**Troubleshooting note:** you may run into the following snag with postgres: )

```
No pg_config... trying anyway. If building fails, please try again with
 --with-pg-config=/path/to/pg_config
checking for libpq-fe.h... no
Can't find the 'libpq-fe.h header
*** extconf.rb failed ***
Could not create Makefile due to some reason, probably lack of necessary
libraries and/or headers.  Check the mkmf.log file for more details.  You may
need configuration options.
```
If you are on a Mac using Homebrew, try the following:

```
brew install postgresql
brew services start postgresql
```

Set up the database
```
rake db:create
rake db:migrate
```

Seed the database (optional)
```
rake db:seed
```


## Running the tests

To run all tests:
```
rake
```
