(: Basic Statistics of the ArchiMetal Model :)

declare namespace ea = "http://www.opengroup.org/xsd/archimate/3.0/";

let $all_views := doc("./ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view
let $non_empty_views := doc("./ArchiMetal.xml")/ea:model/ea:views/ea:diagrams/ea:view[count(descendant::ea:node[@xsi:type='Element'])>0]
let $elems := doc("./ArchiMetal.xml")/ea:model/ea:elements/ea:element
let $rels := doc("./ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship
let $all_nodes := $all_views/descendant-or-self::ea:node[@xsi:type='Element']
let $all_conns := $all_views/ea:connection[@xsi:type='Relationship']
let $elems_in_views := doc("./ArchiMetal.xml")/ea:model/ea:elements/ea:element[@identifier=$all_nodes/@elementRef]
let $rels_in_views := doc("./ArchiMetal.xml")/ea:model/ea:relationships/ea:relationship[@identifier=$all_conns/@relationshipRef]

return <tmp all_views='{count($all_views)}' non_empty_views='{count($non_empty_views)}' elements='{count($elems)}' relationships='{count($rels)}' all_nodes='{count($all_nodes)}' all_connections='{count($all_conns)}' elements_in_views='{count($elems_in_views)}' relationships_in_views='{count($rels_in_views)}' />

