(: QI21b Coherence: Business service realized by business process :)
(: remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $source_elem := "BusinessService"
let $target_elem := ("BusinessProcess", "BusinessFunction", "BusinessInteraction")
let $rt_realize := "Realization"

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $nodes := $views/descendant-or-self::ea:node[@xsi:type='Element']
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes/@elementRef]

let $targetelem:= doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@xsi:type=$target_elem]
let $realizations := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@xsi:type=$rt_realize and @source=$targetelem/@identifier]

let $source := (
  for $ex in $source_elem
  let $ecount := count($elems[@xsi:type=$ex])
  return if ($ecount>0) then $ex else ()
)

let $totalelem := count($elems[@xsi:type=$source])

for $e in $source
let $check := $elems[@xsi:type=$e]
let $correct := (
  for $elem in $check
  where $elem[@identifier=$realizations/@target] 
  return $elem
)
let $faults := $check[not(. = $correct)]

return <tmp type='{$e}'>{
  for $f in $faults
  return <element name='{$f/ea:name/string()}' id='{$f/@identifier/string()}' />
}</tmp>

