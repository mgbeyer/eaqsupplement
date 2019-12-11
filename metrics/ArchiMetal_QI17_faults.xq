(: QI17, faults, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $vpelem := doc("../ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view/descendant-or-self::ea:node[@xsi:type="Element"]
let $elem := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element
let $invp := (
  for $e in $elem
  where $e/@identifier=$vpelem/@elementRef
  return $e
)
let $notinvp := $elem/@identifier[not(. = $invp/@identifier)]
let $ret := (
  for $e in $elem
  order by $e/@xsi:type/string()
  where $e[@identifier=$notinvp]
  return <tmp elem='{$e/ea:name/string()}' type='{$e/@xsi:type/string()}' id='{$e/@identifier/string()}' />
)
return $ret


