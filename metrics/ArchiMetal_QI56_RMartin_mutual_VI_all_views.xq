declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view

let $vi := (
for $vi in $views
order by $vi/ea:name/string()
let $vpid := $vi/@identifier
let $nodes := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vpid]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes]

let $sosi := (
for $v in $views
where $v/@identifier!=$vpid
let $nodes_target := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$v/@identifier]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef
let $elems_target := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes_target]
let $num_shared_elem := count($elems[. = $elems_target])
let $so := if($num_shared_elem=0) then 1 else $num_shared_elem div count($elems)
let $si := if($num_shared_elem=0) then 0 else $num_shared_elem div count($elems_target)
let $so := if($so=$si) then 1-$so else $so
let $vi_raw := $so div ($si+$so)
order by $vi_raw
return <tmp view='{$vi/ea:name/string()}' v='{$v/ea:name/string()}' so='{$so}' si='{$si}' shared='{$num_shared_elem}' VI='{$vi_raw}' />
)
let $sigma_o := sum($sosi/@so)
let $sigma_i := sum($sosi/@si)
(: return $sigma_o div ($sigma_i + $sigma_o) :)
   return $sosi
)
return $vi


(: QI56, detailed mutual VI ratings for all view, ordered by view name, VI, remember to adapt path to the XML file!:)

