(: QI21d Coherence: Application service serves business process :)
(: remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $source_elem := 'ApplicationService'
let $target_elem := ('BusinessProcess', 'BusinessFunction', 'BusinessInteraction', 'BusinessService')
let $rt_serve := 'Serving'

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $nodes := $views/descendant-or-self::ea:node[@xsi:type='Element']
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes/@elementRef]

let $targetelem:= $elems[@xsi:type=$target_elem]
let $serves := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@xsi:type=$rt_serve and @target=$targetelem/@identifier]

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
  where $elem[@identifier=$serves/@source] 
  return $elem
)
let $faults := $check[not(. = $correct)]

return <tmp type='{$e}'>{
  for $f in $faults
  return <element name='{$f/ea:name/string()}' id='{$f/@identifier/string()}' />
}</tmp>

