let $views_ne := /ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
  for $vi in $views_ne
  order by $vi/ea:name/string()
  let $VCCbas := eaqt:execXq(concat('AMMP_VCCbas:vid=', $vi/@identifier/string()))
  let $VI := eaqt:execXq(concat('AMMP_VI:vid=', $vi/@identifier/string()))
  let $VA := 1 - eaqt:execNormalizer( concat('NT_3PL:xzero=4.0,k=1.5,raw=', $VCCbas) )
  return <tmp view='{$vi/ea:name/string()}' VI='{$VI}' VA='{$VA}' VCCbas='{$VCCbas}' /> 
 
 (: Please note: This query makes use of extension functions and/or includes, and needs to be executed within the EAQTool API context against the repository layer :)
 
 
 (: This metric also makes intensive use of other helper metrics and functionalities, we strongly recommend to consult the thesis paper and the EAQTool sources (metrics.json) for detailed information! :) 
 
(: AMMP_VCCbas :)
declare variable $vid as xs:string external;
let $junction := ('AndJunction', 'OrJunction') 
let $gtype := 'Grouping' 
let $elems := /ea:model/ea:elements/ea:element[@xsi:type=$junction]/@identifier 
let $gelems := /ea:model/ea:elements/ea:element[@xsi:type=$gtype]/@identifier 
let $junctions := count(/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/descendant-or-self::ea:node[@xsi:type='Element' and @elementRef=$elems]) 
let $nodes := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/descendant-or-self::ea:node[@xsi:type='Element' and not(@elementRef=$elems)] 
let $elems := count($nodes) 
let $containers := count($nodes[not(@elementRef=$gelems)]/child::ea:node[@xsi:type='Element']) 
let $rels := count(/ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/ea:connection[@xsi:type='Relationship']) + $junctions + $containers 
let $JCP := eaqt:execXq(concat('AMMP_JCP:vid=', $vid)) 
let $DRCD := eaqt:execXq(concat('AMMP_DRCD:vid=', $vid)) 
return if($rels + $JCP - $DRCD >= $elems) then $rels - $elems + $JCP - $DRCD + 1 else 1

(: AMMP_VI :)
declare variable $vid as xs:string external;
let $views := /ea:model/ea:views/ea:diagrams/ea:view 
let $nodes := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef 
let $elems := /ea:model/ea:elements/ea:element[@identifier=$nodes] 
let $sosi := ( 
  for $v in $views 
  where $v/@identifier!=$vid 
  let $nodes_target := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$v/@identifier]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef 
  let $elems_target := /ea:model/ea:elements/ea:element[@identifier=$nodes_target] 
  let $num_shared_elem := count(distinct-values($elems)[. = distinct-values($elems_target)]) 
  let $so := if($num_shared_elem=0) then 0 else $num_shared_elem div count($elems) 
  let $si := if($num_shared_elem=0) then 0 else $num_shared_elem div count($elems_target) 
  let $so := if($num_shared_elem>0 and $so=$si) then 1-$so else $so 
  return <tmp so='{$so}' si='{$si}' /> 
) 
let $sigma_o := sum($sosi/@so) 
let $sigma_i := sum($sosi/@si) 
return if($sigma_i + $sigma_o > 0) then $sigma_o div ($sigma_i + $sigma_o) else 1

(: AMMP_JCP :)
declare variable $vid as xs:string external;
let $jtypes := ('AndJunction', 'OrJunction') 
let $nodes := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef 
let $conns := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/ea:connection[@xsi:type='Relationship']/@relationshipRef 
let $junctions := /ea:model/ea:elements/ea:element[@xsi:type=$jtypes and @identifier=$nodes] 
return sum( 
  for $j in $junctions 
  let $rels := /ea:model/ea:relationships/ea:relationship[@identifier=$conns and (@source=$j/@identifier or @target=$j/@identifier)]/(@source, @target) 
  let $elems := /ea:model/ea:elements/ea:element[@identifier!=$j/@identifier and @identifier=$rels] 
  return sum( 
    for $e in $elems 
    return if (not($e/@xsi:type=$jtypes)) then 0.1 else 
           if ($e/@xsi:type=$j/@xsi:type) then 0.2 else 0.4 
  ) 
)

(: AMMP_DRCD :)
declare variable $vid as xs:string external;
(:@=INC_FNCT_route:) 
let $dyntypes := ('Triggering', 'Flow') 
let $nodes := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/descendant-or-self::ea:node[@xsi:type='Element']/@elementRef 
let $conns := /ea:model/ea:views/ea:diagrams/ea:view[@identifier=$vid]/ea:connection[@xsi:type='Relationship']/@relationshipRef 
let $rels := /ea:model/ea:relationships/ea:relationship[@xsi:type=$dyntypes and @identifier=$conns] 
let $_rels := /ea:model/ea:relationships/ea:relationship[not(@xsi:type=$dyntypes) and @identifier=$conns] 
let $elems := /ea:model/ea:elements/ea:element[@identifier=$nodes] 
let $sources := ( 
  for $e in $elems 
  return if(count($rels[@source=$e/@identifier])=1 and count($rels[@target=$e/@identifier])=0) then $e/@identifier/string() else () 
) 
let $targets := ( 
  for $e in $elems 
  return if(count($rels[@source=$e/@identifier])=0 and count($rels[@target=$e/@identifier])=1) then $e/@identifier/string() else () 
) 
let $paths := ( 
  for $s in $sources, $t in $targets 
  return local:route($rels, $s, $t) 
) 
let $overall := sum(
  for $path in $paths 
  let $token := tokenize($path, ',') 
  let $p := subsequence($token, 2, count($token)-2) 
  let $faults := sum( 
    for $e in $p 
    return if( count($rels[@source=$e])=1 and count($rels[@target=$e])=1 and 
               count($_rels[@source=$e])=0 and count($_rels[@target=$e])=0 ) 
           then 0 else 1 
  ) 
  return if($faults=0) then count($p) else 0
) 
return $overall

(: INC_FNCT_route :)
(: Finds all paths between source and sink elements :)
declare function local:route($edges, $visited, $source, $sink) { 
  if ($source=$sink) then (string-join($visited, ',')) else ( 
  for $edge in $edges[@source=$source] 
return if (not($edge[@target=$visited])) then local:route($edges, ($visited, data($edge/@target)), data($edges[@target=$edge/@target]/@target), $sink) else ) 
) 
}; 
declare function local:route($edges, $source, $sink) { 
  local:route($edges, $source, $source, $sink) 
};
