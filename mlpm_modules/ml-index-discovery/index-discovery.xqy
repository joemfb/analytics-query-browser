xquery version "1.0-ml";

(:~
 : functions for discovering range indexes and grouping them by document-root QNames.
 :
 : &lt;em&gt;
 :   &lt;strong&gt;Warning: this is experimental software!&lt;/strong&gt;
 :   This module uses un-supported features of MarkLogic Server, which are subject to modification or removal without notice.
 : &lt;/em&gt;
 :
 : @author Joe Bryan
 : @version 1.0.0
 :)
module namespace idx = "http://marklogic.com/index-discovery";

import module namespace admin = "http://marklogic.com/xdmp/admin" at "/MarkLogic/admin.xqy";
import module namespace ctx = "http://marklogic.com/cts-extensions"
  at "/mlpm_modules/cts-extensions/cts-extensions.xqy";

declare option xdmp:mapping "false";

(: creates a new map from a sequence of maps, merging values by key :)
declare %private function idx:intersect-maps($maps as map:map*) as map:map
{
  fn:fold-left(
    function($a, $b) { $a + $b },
    map:map(),
    $maps)
};

(: returns a map of `cts:reference` objects, grouped by document-root QNames :)
declare %private function idx:evaluate-indexes($indexes as element()*) as map:map
{
  idx:intersect-maps(
    for $index in $indexes
    for $ref in ctx:resolve-reference-from-index($index)
    for $root in ctx:root-QNames( ctx:reference-query($ref) )
    return map:entry(xdmp:key-from-QName($root), $ref))
};

(:~
 : returns a map of `cts:element-reference` objects (one for each configured element-range index),
 : grouped by document-root QNames
 :)
declare function idx:element-indexes() as map:map
{
  idx:element-indexes( xdmp:database() )
};

(:~
 : returns a map of `cts:element-reference` objects (one for each configured element-range index),
 : grouped by document-root QNames
 :)
declare function idx:element-indexes($database as xs:unsignedLong) as map:map
{
  idx:evaluate-indexes(
    admin:database-get-range-element-indexes(admin:get-configuration(), $database))
};

(:~
 : returns a map of `cts:element-attribute-reference` objects (one for each configured element-attribute-range index),
 : grouped by document-root QNames
 :)
declare function idx:element-attribute-indexes() as map:map
{
  idx:element-attribute-indexes( xdmp:database() )
};

(:~
 : returns a map of `cts:element-attribute-reference` objects (one for each configured element-attribute-range index),
 : grouped by document-root QNames
 :)
declare function idx:element-attribute-indexes($database as xs:unsignedLong) as map:map
{
  idx:evaluate-indexes(
    admin:database-get-range-element-attribute-indexes(admin:get-configuration(), $database))
};

(:~
 : returns a map of `cts:path-reference` objects (one for each configured path-range index),
 : grouped by document-root QNames
 :)
declare function idx:path-indexes() as map:map
{
  idx:path-indexes( xdmp:database() )
};

(:~
 : returns a map of `cts:path-reference` objects (one for each configured path-range index),
 : grouped by document-root QNames
 :)
declare function idx:path-indexes($database as xs:unsignedLong) as map:map
{
  idx:evaluate-indexes(
    admin:database-get-range-path-indexes(admin:get-configuration(), $database))
};

(:~
 : returns a map of `cts:reference` objects, grouped by document-root QNames
 :)
declare function idx:range-indexes() as map:map
{
  idx:range-indexes( xdmp:database() )
};

(:~
 : returns a map of `cts:reference` objects, grouped by document-root QNames
 :)
declare function idx:range-indexes($database as xs:unsignedLong) as map:map
{
  idx:intersect-maps((
    idx:element-indexes($database),
    idx:element-attribute-indexes($database),
    idx:path-indexes($database)
    (: TODO: implement field, geospatial, etc. :)
  ))
};

(:~
 : returns a map of map-serialized `cts:reference` objects, grouped by document-root QNames
 :)
declare function idx:all() as map:map
{
  idx:expand-references( idx:range-indexes() )
};

(:~
 : replaces `cts:reference` objects with their map:map serialization, returns a new map
 :)
declare function idx:expand-references($indexes as map:map) as map:map
{
  map:new(
    for $key in map:keys($indexes)
    return
      map:entry($key,
        for $val in map:get($indexes, $key)
        return ctx:reference-to-map($val)))
};