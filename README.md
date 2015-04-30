## analytics query browser

A MarkLogic and Angular.js application for interactive lexicon aggregate queries.

With zero configuration, this app discovers the range-indexes in a database of your choosing, and presents them, grouped by document root-element names, for easy lexicon co-occurrence and aggregation.

*via [mlpm](https://github.com/joemfb/mlpm), depends on:*

- [https://github.com/joemfb/cts-extensions](https://github.com/joemfb/cts-extensions)
- [https://github.com/joemfb/group-by](https://github.com/joemfb/group-by)
- [https://github.com/joemfb/ml-index-discovery](https://github.com/joemfb/ml-index-discovery)

### Getting Started

This app uses the [Roxy](https://github.com/marklogic/roxy) deployer. To setup an instance, follow these steps:

Check the default configuration; if any settings (such as ports, credentials, etc.) aren't appropriate for your environment, create `deploy/local.properties`, and override them.

    ./ml local info

Once the settings are correct, bootstrap a REST API instance (connected to your `Documents` database):

    ./ml local bootstrap

This app uses [mlpm](https://github.com/joemfb/mlpm) for package management (see `mlpm.json`). While the dependencies are already checked in (see `./mlpm_modules/`), you'll still need the mlpm client for package deployment.

Install `mlpm` from `npm` ([and yes, I know ... ;)](https://twitter.com/ddprrt/status/529909875347030016)):

    npm install -g mlpm

Deploy dependency packages:

    ./ml local deploy_packages

Deploy application:

    ./ml local deploy modules

And you're done! Browse to [http://localhost:8064](http://localhost:8064) (or whatever you defined in `deploy/location.properties`), login with your admin credentials, and start exploring!

_Note: `deploy_packages` is a custom command defined in `deploy/app_specific.rb`; it wraps `mlpm deploy`._

### License Information

- Copyright (c) 2015 Joseph Bryan. All Rights Reserved.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

[http://www.apache.org/licenses/LICENSE-2.0]
(http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

The use of the Apache License does not indicate that this project is
affiliated with the Apache Software Foundation.
