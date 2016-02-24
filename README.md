
![__APPNAME__](http://dki887u7q00gv.cloudfront.net/images/home/logo-white-mmp.png?1416314762)
=====================

## Configuration

* Ruby 2.x / Rails 4.2.5

* In config/database.yml (please, use makemepulse database for development)
  ```YAML
    LOCAL_DB_USERNAME: "username"
    LOCAL_DB_PASSWORD: "password"
    LOCAL_DB_HOSTNAME: "hostname"
  ```

* In config/env.yml (or defined as ENV variables on the server)
  ```YAML
    AWS_REGION: "AWS region for all elements"
    AWS_SECRET_KEY: "aws secret key"
    AWS_ACCESS_KEY_ID: "aws access key"
    AWS_ASSET_HOST: "CDN asset host"
    S3_BUCKET_NAME: "S3 bucket name"
  ```

## Installation

* Install gems
  ```Shell
  bundle install
  ```

* Generate your secret (for staging and production)
  ```Ruby
  rake secret
  ```
  then add it in your ENV variable as ENV["SECRET_KEY_BASE"]

## Import the locales from GDRIVE

* Be sure to have a Google Drive file in config/translations.yml
* Run the command 
  ```
  bundle exec rake i18n:import_translations
  ```

## API documentation

The API documentation is generated with APIPIE.
Once your application is running, check the documentation [here](http://localhost:3000/apipie/1.0.html)


## Install Git Flow localy

> [Cheat Sheet](http://danielkummer.github.io/git-flow-cheatsheet/)

```Shell
  git flow init
```

* __master__ branch is used only for releases.
* __develop__ branch is used for the current state of the application.
* Development of new features starting from the __develop__ branch.


## Run application localy 

* Launch Rails
  ```Shell
  rails s
  ```




