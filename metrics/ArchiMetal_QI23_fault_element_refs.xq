(: isolated nodes in views, faulty node refs., multiple refs. mean node appears isolated in more than one view, QI23, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[not(@xsi:type='Grouping')]
let $allviews := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view
let $nodes_in_views := $allviews/ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier]
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $conns_in_views := $allviews/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]

let $iso := ( 
  for $node in $nodes_in_views 
  order by $elems[@identifier=$node/@elementRef]/@xsi:type/string(), $elems[@identifier=$node/@elementRef]/ea:name/string()
  let $conn := $conns_in_views[@source=$node/@identifier or @target=$node/@identifier] 
  return if(count($conn)=0) then <tmp elem='{$elems[@identifier=$node/@elementRef]/ea:name/string()}' type='{$elems[@identifier=$node/@elementRef]/@xsi:type/string()}' id='{$elems[@identifier=$node/@elementRef]/@identifier/string()}' /> else ()
) 
return $iso
