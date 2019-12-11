(: base value for VCC (unnormalized) per view :)

let $views := /ea:model/ea:views/ea:diagrams/ea:view 
for $vi in $views 
order by $vi/ea:name/string() 
let $VCCbas := eaqt:execXq(concat('AMMP_VCCbas:vid=', $vi/@identifier/string())) 
return <tmp view='{$vi/ea:name/string()}' val='{$VCCbas}' /> 

 (: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
 (: This metric also makes intensive use of other helper metrics and functionalities (for the script "AMMP_VCCbas" see also "ArchiMetal_RobertMartin_VI_VA_Ratings_By_View"), we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 

