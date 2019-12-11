declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $jtypes := ('AndJunction', 'OrJunction')
let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $nodes := $views/descendant-or-self::ea:node[@xsi:type='Element'] 
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[not(@xsi:type=$jtypes) and @identifier=$nodes/@elementRef]
let $UEall := count(distinct-values($elems/@xsi:type))
  for $v in $views
  let $vnodes := $v/descendant-or-self::ea:node[@xsi:type='Element'] 
  let $velems := $elems[not(@xsi:type=$jtypes) and @identifier=$vnodes/@elementRef]
  order by count(distinct-values($velems/@xsi:type))
  return <tmp view='{$v/ea:name/string()}' val='{count(distinct-values($velems/@xsi:type))}' />

(: computes view VED (QI47), remember to adapt path to the XML file! :)
