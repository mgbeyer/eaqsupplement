(: empty views, QI22 :)

let $isolation_ratio_threshold := 0.66 
let $views := /ea:model/ea:views/ea:diagrams/ea:view 
let $ret := ( 
  for $vi in $views 
  order by $vi/ea:name/string() 
  let $vielem := $vi/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef 
  let $num_isolated_nodes := eaqt:execXq(concat('AMMP_countIsolatedElementsInView:vid=', $vi/@identifier/string())) 
  let $isolation_ratio := if(count($vielem)=0) then 0 else $num_isolated_nodes div count($vielem) 
  return if(count($vielem)<3 or $isolation_ratio>=$isolation_ratio_threshold) then $vi/ea:name/string() else () 
) 
return $ret


(: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
(: This metric also makes use of other helper metrics and functionalities, we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 
 
 
(: AMMP_countIsolatedElementsInView :)
declare variable $vid as xs:string external;
let $nodes_in_view := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/ea:node[@xsi:type='Element'] 
let $count_isolated_nodes := sum( 
  for $node in $nodes_in_view 
  let $conn := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/ea:connection[@source=$node/@identifier or @target=$node/@identifier] 
  return if(count($conn)=0) then 1 else 0 
) 
return $count_isolated_nodes

 