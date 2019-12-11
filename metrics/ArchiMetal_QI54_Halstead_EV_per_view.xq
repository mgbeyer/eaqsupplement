(: QI54, Halstead EV ratings per view, remember to adapt path to the XML file! :)


declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $log2 := math:log(2)
let $stroud := 18

let $views := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view

for $vi in $views
let $vpid := $vi/@identifier
let $nodes := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vpid]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef
let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$nodes]
let $conns := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vpid]/ea:connection/@relationshipRef
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@identifier=$conns]

let $n1 := count(distinct-values($rels/@xsi:type))
let $N1 := count($rels)
let $n2 := count(distinct-values($elems/@xsi:type))
let $N2 := count($elems)
let $n := $n1+$n2
let $N := $N1+$N2
let $V := if($n=0) then 0 else $N * (math:log($n) div $log2)
let $DV_ := if($n2=0) then 0 else $n1 * ($N2 div $n2)
let $DV := if($DV_=0) then 0 else $DV_ * (math:log($DV_) div $log2)
let $EV := $V * $DV
order by $vi/ea:name/string()
(: order by $EV div $stroud descending :)
return <tmp view='{$vi/ea:name/string()}' id='{$vpid}' EVmin='{$EV div $stroud div 60}' />
