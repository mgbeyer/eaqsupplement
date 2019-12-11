(: QI51, degree per view, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[not(@xsi:type='Grouping')]
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship

let $res := ( 
  for $v in $views
  order by $v/ea:name/string()
  let $vnodes := $v/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems/@identifier] 
  let $all_direct_childs := $vnodes/child::ea:node[@xsi:type='Element']
  let $vconns := (
    for $n in $vnodes
    let $direct_childs := $n/child::ea:node[@xsi:type='Element']
    (: nesting (childs) is considered connectivity if real relationships in the model exist respectively :)
    let $Rnest := sum(
      for $dc in $direct_childs
      return if($rels[ (@source=$dc/@elementRef and @target=$dc/../@elementRef) or (@target=$dc/@elementRef and @source=$dc/../@elementRef) ] ) then 1 else 0 
    )
    (: is the current node $n a direct child (i.e. there is a parent node nesting it)? if so the conncection to its parent has to be counted, too (+1) :)
    let $Rnest := if($n/@identifier=$all_direct_childs/@identifier) then ($Rnest + 1) else $Rnest
    return count($n/ancestor::ea:view/ea:connection[@source=$n/@identifier or @target=$n/@identifier]) + $Rnest
  )
  let $degree := if(count($vnodes)>0) then sum($vconns) div count($vnodes) else 0
  return <tmp view='{$v/ea:name/string()}' degree='{$degree}' vconnsSum='{sum($vconns)}' vnodesSum='{count($vnodes)}' />
)

return $res
