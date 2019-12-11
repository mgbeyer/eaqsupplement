(: compute VCL ratings :)


(: ...by basic view :) 
let $threshold := 0.625
let $views := /ea:model/ea:views/ea:diagrams/ea:view
let $basicview := eaqt:execEaMeta('getBasicViews')
let $ret := (
  for $bas in $basicview
  order by $bas
  let $allowed := eaqt:execEaMeta(concat('getElementTypesByBasicView:id=', $bas))
  return <tmp basicview='{$bas}'>{
    for $vid in $views
    let $unique := eaqt:execXq(concat('AMMP_getUniqueElementTypesInView:vid=', $vid/@identifier/string()))
    (:@=INC_VICLbas:)
    order by $INC_VICLbas descending
    return <vals view='{$vid/ea:name/string()}' val='{$INC_VICLbas}' />
  }</tmp>\n
)
return $ret


(: ...by view :)
let $threshold := 0.625
let $views := /ea:model/ea:views/ea:diagrams/ea:view
let $basicview := eaqt:execEaMeta('getBasicViews')
let $ret := (
  for $vid in $views
  order by $vid
  let $unique := eaqt:execXq(concat('AMMP_getUniqueElementTypesInView:vid=', $vid/@identifier/string()))
  return <tmp view='{$vid/ea:name/string()}'>{
    for $bas in $basicview
    let $allowed := eaqt:execEaMeta(concat('getElementTypesByBasicView:id=', $bas))
    (:@=INC_VICLbas:)
    order by $INC_VICLbas descending
    return <vals basicview='{$bas}' val='{$INC_VICLbas}' />
  }</tmp>\n
)
return $ret


(: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 

(: INC_VICLbas :)
let $allowed := distinct-values($allowed) 
let $unique := distinct-values($unique) 
let $na := $unique[not(. = $allowed)] 
let $an := $allowed[not(. = ($allowed[. = $unique]) )] 
let $conformity := if (empty($unique)) then 0 else 1 - (count($na) div count($unique)) 
let $rateofuse := if (empty($unique)) then 0 else 1 - (count($an) div count($allowed)) 
let $INC_VICLbas := ($conformity + $rateofuse) div 2 

