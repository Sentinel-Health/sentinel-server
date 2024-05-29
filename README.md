# Sentinel Rails Server

This repository is the main repository for the Sentinel Ruby on Rails server. The server serves as the backend API for the iOS app.

Sentinel is an app that connects to your Apple HealthKit data and provides you with a personalized AI health assistant. You can find the iOS app [here](https://github.com/Sentinel-Health/sentinel-ios).

## Background

Sentinel was started to address the problem that the traditional healthcare system is not designed for the patient. There are many factors contributing to this, in particular misaligned incentives and asymmetric information, the latter of which is what we built Sentinel to solve. Unfortunately, due to a number of different challenges we decided to shut down the business.

However, we also decided to open source all of the code used to build Sentinel. We hope that by doing so, others may be able to continue to use it on their own, improve upon it, or just learn something from it. This is one of the repositories. The other can be found [here](https://github.com/Sentinel-Health/sentinel-ios).

## Local Development Setup

To get your development environment up and running, follow the steps below. These instructions will guide you through the setup process, from cloning the repository to starting the server.

### Requirements

Ensure you have the following installed before proceeding:

- Ruby (Version specified in `.ruby-version` file)
- Rails (Version specified in `Gemfile`)
- PostgreSQL >14 (ideally, latest stable version)

For Ruby and Rails, it's recommended to use [rbenv](https://github.com/rbenv/rbenv) or [RVM](https://rvm.io) to manage Ruby versions and gemsets.

### Environment Configuration

There are two main ways we deal with Environment variables in the app:

1. Using .env files
2. Using Rails credentials

In order to run the app, you will need to have both of these for the development environment. Please reach out on Slack or email to get these credentials.

For the `.env` file, you can copy the example file and fill in the values provided:

```shell
cp .env.example .env
```

For the Rails credentials, you'll want to run:

```shell
rails credentials:edit
```

and then fill in the values for the example keys that can be found in the `config/credentials.example.yml` file.

### Installation

Clone the repo first, then the basic setup commands are:

```shell
cd sentinel-rails-server
bin/setup
```

This should get your local server up and running.

You'll also want to seed some data to start, you can do this by running:

```shell
rails biomarkers_data:create_or_update_biomarkers
```

To run the server, run:

```shell
bin/dev
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.
