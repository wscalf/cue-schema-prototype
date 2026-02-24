package kessel

/* 
    This package is part library and part meta-schema. It defines the types and overall structures that other packages
    'unify' with to create a schema
*/ 

#RelationBody:
    #And | #Or | #Unless | #Ref | #Assignable

#And: {
    kind: "and"
    left: #RelationBody
    right: #RelationBody
}

#Or: {
    kind: "or"
    left: #RelationBody
    right: #RelationBody
}

#Unless: {
    kind: "unless"
    left: #RelationBody
    right: #RelationBody
}

// Reference to something in your model (relationship/permission/etc.)
#Ref: {
    kind: "ref"
    type?:    string
    name:     string
    relation?: string
}

#AssignMap: {
    name: string
    data_field?: string
}

#Assignable: {
    kind: "assignable"
    types: [...#AssignMap]
    cardinality: "AtMostOne" | "ExactlyOne" | "AtLeastOne" | "Any" | "All"
}

// A type schema
#Resource: {
    relations: [string]: #RelationBody
    data: [string]: _
}

// Root schema document
#Schema: {
    resources: [string]: #Resource
}

// The entrypoint for this module, unified into schema.cue, equivalent to an empty schema fragment
base: #Schema & {

}