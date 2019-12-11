(: QI21c Coherence: Application component uses technology :)
(: remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $target_elem := ('ApplicationComponent', 'ApplicationCollaboration')
let $source_elem := ('TechnologyService', 'TechnologyFunction', 'Node', 'Device', 'SystemSoftware')
let $rt_serve := 'Serving'
let $rt_assign := 'Assignment'
let $rt_aggregate := 'Aggregation'

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $nodes := $views/descendant-or-self::ea:node[@xsi:type='Element']
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes/@elementRef]

let $sourceelem:= $elems[@xsi:type=$source_elem]
let $serves := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@xsi:type=$rt_serve and @source=$sourceelem/@identifier]

let $assignments := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@xsi:type=$rt_assign and @source=$elems[@xsi:type=$target_elem]/@identifier and @target=$elems[@xsi:type=('ApplicationInteraction', 'ApplicationFunction')]/@identifier and @target=$serves/@target]

let $aggregates := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@xsi:type=$rt_aggregate and @target=$elems[@xsi:type='ApplicationComponent']/@identifier and @source=$elems[@xsi:type='ApplicationCollaboration']/@identifier and @source=$serves/@target]

let $target := (
  for $ex in $target_elem
  let $ecount := count($elems[@xsi:type=$ex])
  return if ($ecount>0) then $ex else ()
)

let $totalelem := count($elems[@xsi:type=$target])

for $e in $target
let $check := $elems[@xsi:type=$e]
let $correct := (
  for $elem in $check
  where ( $elem[@identifier=$serves/@target] or
          $elem[@identifier=$aggregates/@target] or
          $elem[@identifier=$assignments/@source] 
        )
  return $elem
)
let $faults := $check[not(. = $correct)]

return <tmp type='{$e}'>{
  for $f in $faults
  return <element name='{$f/ea:name/string()}' id='{$f/@identifier/string()}' />
}</tmp>

