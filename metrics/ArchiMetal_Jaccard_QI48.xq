(: Jaccard similarity per view, all views :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

declare function local:J($A, $B) { 
  let $count_intersect := count(distinct-values($A)[. = distinct-values($B)])
  return if( (count($A) + count($B) - $count_intersect) >0 ) then $count_intersect div (count($A) + count($B) - $count_intersect) else 0
};

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $allnodes := $views/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]
let $allconns := $views/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]

let $divisor := count($views) * (count($views)-1)

for $v1 in $views
order by $v1/ea:name/string()
let $nodes := $v1/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]/@elementRef
let $conns := $v1/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]/@relationshipRef
let $A := $nodes
for $v2 in $views
order by $v2/ea:name/string()
where not($v1/@identifier=$v2/@identifier)
let $nodes := $v2/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]/@elementRef
let $conns := $v2/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]/@relationshipRef
let $B := $nodes
let $JAB := local:J($A, $B)

return <vals v2='{concat( $v2/ea:name/string(), ', ', $v2/@identifier/string() )}' v1='{concat( $v1/ea:name/string(), ', ', $v1/@identifier/string() )}' val='{$JAB}' /> 



(: Avg. Jaccard similarity for each view :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

declare function local:J($A, $B) { 
  let $count_intersect := count(distinct-values($A)[. = distinct-values($B)])
  return if( (count($A) + count($B) - $count_intersect) >0 ) then $count_intersect div (count($A) + count($B) - $count_intersect) else 0
};

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $allnodes := $views/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]
let $allconns := $views/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]

let $divisor := count($views) * (count($views)-1)

for $v1 in $views
order by $v1/ea:name/string()
let $nodes := $v1/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]/@elementRef
let $conns := $v1/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]/@relationshipRef
let $A := $nodes
let $JAB := sum(
  for $v2 in $views
  where not($v1/@identifier=$v2/@identifier)
  let $nodes := $v2/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]/@elementRef
  let $conns := $v2/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]/@relationshipRef
  let $B := $nodes
  return local:J($A, $B)
)
let $avgJAB := $JAB div (count($views)-1)

return <vals view='{concat( $v1/ea:name/string(), ', ', $v1/@identifier/string() )}' val='{$avgJAB}' /> 



(: Note: Remember to adapt path to the XML file! :)
