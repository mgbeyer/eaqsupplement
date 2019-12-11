(:@=INC_maxElemImportance:)
let $elems := /ea:model/ea:elements/ea:element 
let $rels := /ea:model/ea:relationships/ea:relationship 
let $ret := ( 
  for $el in $elems 
  let $elemtype := $el/@xsi:type/string() 
  (: let $elem_weight := eaqt:execXq(concat('HLP_getElementWeightByType:elemtype=', $elemtype)) :) 
  (:@=INC_getElementWeightByType:)
  let $elem_weight := $INC_getElementWeightByType 
  let $outbound := $rels[@source=$el/@identifier]/@xsi:type/string() 
  let $degree := count($outbound) 
  let $omega := math:exp($degree div 3.5) - 1 
  let $i_of_e := if(empty($outbound)) then 0 else $elem_weight * (sum( 
    for $reltype in $outbound 
    (: return eaqt:execXq(concat('HLP_getRelationshipWeightByType:reltype=', $reltype)) :) 
    (:@=INC_getRelationshipWeightByType:) 
    return $INC_getRelationshipWeightByType 
  ) div count($outbound)) 
  let $rating := $omega * $i_of_e 
  order by $rating descending 
  return <tmp elem='{$el/ea:name/string()}' type='{$el/@xsi:type/string()}' rating='{$rating}' outdeg='{$degree}' IE='{$i_of_e}' omega='{$omega}' maxIE='{$INC_maxElemImportance}' /> 
) 
return $ret


(: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
(: This metric also makes use of other helper metrics and functionalities, we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 


(: INC_maxElemImportance :)
let $lcats := eaqt:execEaMeta('getLayerCategories') 
let $acats := eaqt:execEaMeta('getAspectCategories') 
let $rtypes := eaqt:execEaMeta('getRelationshipTypes') 
let $lmax := max(
  for $lcat in $lcats 
  return xs:integer( eaqt:execEaMeta(concat('getLayerWeightById:@attrib=value,id=', $lcat)) ) 
)
let $amax := max(
  for $acat in $acats 
  return xs:integer( eaqt:execEaMeta(concat('getAspectWeightById:@attrib=value,id=', $acat)) ) 
)
let $rmax := max(
  for $rtype in $rtypes 
  return xs:integer( eaqt:execEaMeta(concat('getRelationshipWeightById:@attrib=value,id=', $rtype)) ) 
)
let $INC_maxElemImportance := ( xs:integer($lmax) + xs:integer($amax) ) * xs:integer($rmax)


(: HLP_getElementWeightByType :)
declare variable $elemtype as xs:string external;
let $layer_id := eaqt:execEaMeta(concat('getLayerCategoryByElementType:id=', $elemtype)) 
let $aspect_id := eaqt:execEaMeta(concat('getAspectCategoryByElementType:id=', $elemtype)) 
let $layer_weight := max( 
  for $id in $layer_id 
  let $layer_weight := eaqt:execEaMeta(concat('getLayerWeightById:@attrib=value,id=', $id)) 
  return $layer_weight 
) 
let $aspect_weight := eaqt:execEaMeta(concat('getAspectWeightById:@attrib=value,id=', $aspect_id)) 
return xs:integer($layer_weight) + xs:integer($aspect_weight) "


(: HLP_getRelationshipWeightByType :)
declare variable $reltype as xs:string external;
let $rel_id := eaqt:execEaMeta(concat('getRelationshipTypeById:id=', $reltype)) 
return xs:integer( eaqt:execEaMeta(concat('getRelationshipWeightById:@attrib=value,id=', $rel_id)) ) 
