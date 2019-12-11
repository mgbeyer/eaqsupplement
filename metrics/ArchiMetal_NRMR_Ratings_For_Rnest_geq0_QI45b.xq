declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $jtypes := ('AndJunction', 'OrJunction')
let $gtype := 'Grouping'
let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view
let $jelems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@xsi:type=$jtypes]/@identifier
let $gelems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@xsi:type=$gtype]/@identifier
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element

let $res := ( 
for $v in $views
order by $v/ea:name/string()
let $nodes := $v/descendant-or-self::ea:node[@xsi:type='Element' and not(@elementRef=$jelems) and not(@elementRef=$gelems)]
let $conns := $v/ea:connection[@xsi:type='Relationship' and @relationshipRef=$rels/@identifier]
let $direct_childs := $nodes/child::ea:node[@xsi:type='Element']
let $Rnest := (
  for $dc in $direct_childs
  return if(not( $rels[ (@source=$dc/@elementRef and @target=$dc/../@elementRef) or (@target=$dc/@elementRef and @source=$dc/../@elementRef) ] ) and
            $elems[@identifier=$dc/@elementRef]/@xsi:type = $elems[@identifier=$dc/../@elementRef]/@xsi:type) then 0 else 1
)
let $Rexist := count($conns)
return if(sum($Rnest)>0) then ($v/ea:name/string(), sum($Rnest) div (sum($Rnest) + $Rexist)) else ()
)
return $res

(: return NRMR ratings for views where Rnest >= 0, remember to adapt path to the XML file! :)
