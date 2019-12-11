(: VES per view, QI41, remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view

let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $conns := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view/ea:connection[@xsi:type='Relationship']
let $R := ( 
  for $rel in $rels 
  where $rel/@identifier=$conns/@relationshipRef  
  return $rel 
) 
let $res := (
  for $v in $views
  order by $v/ea:name/text()
  let $nodes := $v/descendant-or-self::ea:node[@xsi:type='Element']
  let $conns := $v/ea:connection[@xsi:type='Relationship']
  let $RVspan := (
    for $rel in $R
    return if($rel[ (@source=$nodes/@elementRef and not(@target=$nodes/@elementRef)) or (not(@source=$nodes/@elementRef) and @target=$nodes/@elementRef) ]) then $rel else ()
  )
  let $RVdom := (
    for $rel in $R
    return if($rel[@identifier=$conns/@relationshipRef and @source=$nodes/@elementRef and @target=$nodes/@elementRef]) then $rel else ()
  )
  let $RVspan_count := count($RVspan/@identifier)
  let $RVdom_count := count($RVdom/@identifier)
  let $val := if($RVspan_count + $RVdom_count>0) then $RVspan_count div ($RVspan_count + $RVdom_count) else 0
  return <tmp view='{$v/ea:name/text()}' id='{$v/@identifier}' val='{$val}' RVspan_count='{$RVspan_count}' RVdom_count='{$RVdom_count}' RVspan='{string-join($RVspan/@identifier, ', ')}' RVdom='{string-join($RVdom/@identifier, ', ')}' />
)

return $res

