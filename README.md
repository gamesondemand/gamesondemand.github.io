# Welcome to Games on Demand's GameDay

This is a [Github Pages](https://pages.github.com/) powered site.
It leverages [Jekyll](http://jekyllrb.com/).

## Purpose

I want to provide as much information as is reasonable to various audiences for Games on Demand:

* Hosts - people coordinating matching players with GMs
* GMs - people facilitating games
* Players - people showing up and wanting to play the games

This is to be a tool for those at the convention.

## Installing Jekyll

This project has been upgraded to use Ruby 3.4 and Jekyll. A setup on MacOS with homebrew would include:

#### Install the version manager and compiler
```bash
   $ brew install chruby ruby-install
```

The output of that command will give you some chruby scripts to run in your `.bashrc` or `.zshrc` do so.

Mine look like
```
source /opt/homebrew/opt/chruby/share/chruby/chruby.sh
source /opt/homebrew/opt/chruby/share/chruby/auto.sh
```

#### Install the current ruby version

```bash
   $ ruby-install ruby 3.4
```

## Running the Site Offline

First create the local environment sandbox by running this at the top level of the repo:

```bash
   $ bundle install
```

From the command line run the following:

```console
$ bundle exec jekyll serve -p 4000 -H localhost --watch
```

Then point your browser to [http://localhost:4000](http://localhost:4000)

## Rake fetching from Google Drive??

It appears that an earlier developer had an automated system for importing
data directly from the Google Sheets. The old
`GoogleDrive.login(ENV['GOOGLE_USERNAME'], ENV['GOOGLE_PASSWORD'])`
login method is for sure both completely insecure and blocked
by Google for being insecure.

It may be possible to restore this functionality later. But no time tonight.

It would have been run via:

```console
$ bundle exec rake
```
