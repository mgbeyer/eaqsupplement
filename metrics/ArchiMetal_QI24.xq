(: ambiguous or redundant relationships between elements (no count, just all there are to check if everything works fine), QI24, remember to adapt path to the XML file! :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $rels := doc("../ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship 
let $elements := doc("../ArchiMetal.xml")/ea:model/ea:elements/ea:element 
return ( 
  for $rel in $rels, $relx in $rels 
  order by $rel/@identifier/string()
  return ( 
    let $ret := if( $rel/@identifier!=$relx/@identifier and ( 
                    ( $rel/@source=$relx/@source and $rel/@target=$relx/@target and ($rel/not(exists(ea:name)) or $rel/ea:name/string()=$relx/ea:name/string()) ) or 
                    ( $rel/@source=$relx/@target and $rel/@target=$relx/@source and ($rel/not(exists(ea:name)) or $rel/ea:name/string()=$relx/ea:name/string()) and $rel/@xsi:type/string()=$relx/@xsi:type/string() ) 
                  ) ) then  <tmp source='{concat($elements[@identifier/string()=$rel/@source/string()]/ea:name/string(), ' (', $rel/@source/string(), ')')}' target='{concat($elements[@identifier/string()=$rel/@target/string()]/ea:name/string(), ' (', $rel/@target/string(), ')')}' reltype='{$rel/@xsi:type/string()}' relID='{$rel/@identifier/string()}' /> else () 
    return $ret 
  ) 
)

