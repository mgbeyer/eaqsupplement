let $views := /ea:model/ea:views/ea:diagrams/ea:view 
let $ret := ( 
  for $vi in $views 
  let $VCCbas := eaqt:execXq(concat('AMMP_VCCbas:vid=', $vi/@identifier/string())) 
  let $VI := eaqt:execXq(concat('AMMP_VI:vid=', $vi/@identifier/string())) 
  let $VA := 1 - eaqt:execNormalizer( concat('NT_3PL:xzero=4.0,k=1.5,raw=', $VCCbas) )
  let $d := $VI + $VA - 1 
  let $zop := if($d < 0) then 1 else 0 
  order by $d 
  return <tmp view='{$vi/ea:name/string()}' ZOP='{$zop}' D='{$d}' VI='{$VI}' VA='{$VA}' /> 
) 
return $ret


(: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
(: This metric also makes intensive use of other helper metrics and functionalities, we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 
 
(: For helper functions see: ArchiMetal_RobertMartin_VI_VA_Ratings_By_View_QI35_QI53.xq :)
