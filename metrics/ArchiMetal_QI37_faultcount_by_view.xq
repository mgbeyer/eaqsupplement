(: QI37, faultcount per view, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element/@identifier


let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship/@identifier 
let $conns := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view/ea:connection[@xsi:type='Relationship']/@relationshipRef 
let $hits := ( 
  for $rel in $rels 
  where $rel=$conns 
  return $rel 
) 
let $checkrels := $rels[not(. = $hits)]
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@identifier=$checkrels]


for $v in $views
order by $v/ea:name/text()
let $nodes := $v/ea:node[@xsi:type='Element']
let $conns := $v/ea:connection[@xsi:type='Relationship']

let $ret := sum(
for $n1 in $nodes, $n2 in $nodes
where $n1/@identifier!=$n2/@identifier
let $relationships := $rels[ (@source=$n1/@elementRef and @target=$n2/@elementRef) or (@source=$n2/@elementRef and @target=$n1/@elementRef) ]
let $connections := $conns[ @relationshipRef=$relationships/@identifier and ( (@source=$n1/@identifier and @target=$n2/@identifier) or (@source=$n2/@identifier and @target=$n1/@identifier) ) ]
return if( count($connections)>0 or (count($connections)=0 and count($relationships)=0) ) then 0 else 1
)

return (concat($v/ea:name/text(), ', ', $v/@identifier), $ret)
