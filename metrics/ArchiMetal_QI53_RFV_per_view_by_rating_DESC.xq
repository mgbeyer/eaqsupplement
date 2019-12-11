(: QI53, RVF ratings per view, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0] 
let $allnodes := $views/descendant-or-self::ea:node[@xsi:type='Element'] 
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[not(@xsi:type='Grouping') and @identifier=$allnodes/@elementRef] 
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship 
let $res := ( 
  for $v in $views 
  let $nodes := $v/descendant-or-self::ea:node[@xsi:type='Element'] 
  let $O_set := distinct-values( 
    for $e in $elems 
    return if(not($e[@identifier=$nodes/@elementRef]) and $rels[ (@source=$nodes/@elementRef and @target=$e/@identifier) or (@source=$e/@identifier and @target=$nodes/@elementRef) ]) then $e/@identifier else () 
  ) 
  let $E_set := $elems[@identifier=$nodes/@elementRef]/@identifier
  let $RFV_raw :=  count(distinct-values( ($elems[@identifier=$nodes/@elementRef]/@identifier, $span) ))
  order by $RFV_raw descending
  return <tmp view='{$v/ea:name/string()}' id='{$v/@identifier/string()}' Eset='{count(distinct-values($E_set))}' Oset='{count($O_set)}' RFVraw='{$RFV_raw}' />
) 
return $res
