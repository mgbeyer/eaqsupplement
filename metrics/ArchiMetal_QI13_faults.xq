(: QI13, faults :)

let $serving_BA := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type_Between_Layers-By-Type:reltype=Serving,layertype1=Business,layertype2=Application') "+
let $serving_AT := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type_Between_Layers-By-Type:reltype=Serving,layertype1=Application,layertype2=Technology') "+
let $serving_BT := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type_Between_Layers-By-Type:reltype=Serving,layertype1=Business,layertype2=Technology') "+
let $realization_AB := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type-And-Dir_Between_Layers-By-Type:reltype=Realization,layertype_source=Application,layertype_target=Business') "+
let $realization_TA := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type-And-Dir_Between_Layers-By-Type:reltype=Realization,layertype_source=Technology,layertype_target=Application') "+
let $realization_TB := eaqt:execXq('AMMP_CountIsZero_Rel-By-Type-And-Dir_Between_Layers-By-Type:reltype=Realization,layertype_source=Technology,layertype_target=Business') "+
return (concat('serving_BA: ', $serving_BA), concat('serving_AT: ', $serving_AT), concat('serving_BT: ', $serving_BT), concat('realization_AB: ', $realization_AB), concat('realization_TA: ', $realization_TA), concat('realization_TB: ', $realization_TB))";


(: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
(: This metric also makes use of other helper metrics and functionalities, we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 


(: AMMP_CountIsZero_Rel-By-Type_Between_Layers-By-Type :)
declare variable $reltype as xs:string external;
declare variable $layertype1 as xs:string external;
declare variable $layertype2 as xs:string external;
let $ret := count(
   let $elemtypes1 := eaqt:execEaMeta(concat('getElementTypesByLayerCategory:id=', $layertype1)) 
   let $elemtypes2 := eaqt:execEaMeta(concat('getElementTypesByLayerCategory:id=', $layertype2)) 
   let $elemids1 := /ea:model/ea:elements/ea:element[@xsi:type=$elemtypes1]/@identifier 
   let $elemids2 := /ea:model/ea:elements/ea:element[@xsi:type=$elemtypes2]/@identifier 
   for $relations in /ea:model/ea:relationships/ea:relationship[@xsi:type=$reltype] 
   where ( ($relations[@source=$elemids1] and $relations[@target=$elemids2]) or ($relations[@source=$elemids2] and $relations[@target=$elemids1]) ) 
   return $relations
)
return if ($ret=0) then 1 else 0
