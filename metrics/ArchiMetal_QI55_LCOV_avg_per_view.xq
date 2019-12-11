(: QI55, LCOV avg. ratings per view, remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $ignore := ('Grouping', 'AndJunction', 'OrJunction')

let $allviews := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $elements := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[not(@xsi:type/string()=$ignore)]

for $v1 in $allviews
order by $v1/ea:name/string()
let $av := avg(
for $v2 in $allviews
where $v1/@identifier/string()!=$v2/@identifier/string()
let $views := ($v1, $v2)
let $allnodes := $views/descendant-or-self::ea:node[@xsi:type='Element']
let $elems := $elements[@identifier=$allnodes/@elementRef]
let $ecount := count($elems)
let $big_sigma_e := sum(
  for $e in $elems
  let $sigma_e := sum(
    for $v in $views
    let $nodes := $v/descendant-or-self::ea:node[@xsi:type='Element']
    return if($e[@identifier=$nodes/@elementRef]) then 1 else 0
  )
  return $sigma_e
)
let $lcov := 1 - ( ( (1 div $ecount) * $big_sigma_e ) - 2 ) div -1
return $lcov
)
return <tmp view='{$v1/ea:name/string()}' id='{$v1/@identifier/string()}' avg_lcov='{$av}' />


