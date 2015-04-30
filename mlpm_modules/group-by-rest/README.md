### group-by-rest

##### REST extension: `http://marklogic.com/rest-api/resource/group-by`

MarkLogic REST API extension for zero-knowledge JSON `cts:group-by` queries

available through [mlpm](http://registry.demo.marklogic.com/package/group-by-rest):

    mlpm install group-by-rest

*depends on*

* [https://github.com/joemfb/cts-extensions](https://github.com/joemfb/cts-extensions)
* [https://github.com/joemfb/group-by](https://github.com/joemfb/group-by)
* [https://github.com/joemfb/ml-index-discovery](https://github.com/joemfb/ml-index-discovery)

#### Methods

##### GET `/v1/resources/group-by`

gets a dynamic list of configured range indices, grouped by document-root QNames, a list of available aggregate functions, and a list of numeric lexicon types

##### POST `/v1/resources/group-by`

evaluates a JSON-serialized `cts:group-by` query

### License Information

- Copyright (c) 2014 Joseph Bryan. All Rights Reserved.

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
