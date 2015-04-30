xquery version "1.0-ml";

(:~
 : MarkLogic REST API extension for zero-knowledge JSON `cts:group-by` queries
 :
 : @author Joe Bryan
 : @version 1.0.0
 :)
module namespace ext = "http://marklogic.com/rest-api/resource/group-by";

import module namespace cts = "http://marklogic.com/cts"
  at "/mlpm_modules/group-by/group-by.xqy";
import module namespace ctx = "http://marklogic.com/cts-extensions"
  at "/mlpm_modules/cts-extensions/cts-extensions.xqy";
import module namespace grpj = "http://marklogic.com/cts/group-by/json"
  at "/mlpm_modules/group-by/group-by-json.xqy";
import module namespace idx = "http://marklogic.com/index-discovery"
  at "/mlpm_modules/ml-index-discovery/index-discovery.xqy";

(:~
 : gets a dynamic list of configured range indices - grouped by document-root QNames,
 : a list of available aggregate functions,
 : and a list of numeric lexicon types
 :)
declare function ext:get(
  $context as map:map,
  $params as map:map
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  document {
    map:new((
      map:entry("docs", idx:all()),
      map:entry("numeric-types",
        for $type in $ctx:numeric-scalar-types
        order by $type
        return $type),
      map:entry("aggregates",
        for $agg in map:keys($cts:AGGREGATES)
        order by $agg
        return $agg))) ! xdmp:to-json(.)
  }
};

(:~
 : evaluates a JSON-serialized `cts:group-by` query
 :)
declare function ext:post(
  $context as map:map,
  $params as map:map,
  $input as document-node()*
) as document-node()*
{
  map:put($context, "output-types", "application/json"),
  (: TODO: catch errors, set status codes :)
  document {
    grpj:query( xdmp:from-json($input) ) ! xdmp:to-json(.)
  }
};
