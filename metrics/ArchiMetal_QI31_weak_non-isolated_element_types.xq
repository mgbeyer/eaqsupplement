declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $elems := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element
let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
return (
for $el in $elems
let $out_degree := count($rels[@source=$el/@identifier])
let $degree := count($rels[@source=$el/@identifier or @target=$el/@identifier])
return if($degree>0 and $out_degree=0) then ($el/@identifier, $el/@xsi:type) else ()
) 

(: Get type of non-isolated weak elements (no out-degree), remember to adapt path to the XML file! :)
