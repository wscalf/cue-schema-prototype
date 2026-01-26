package kessel

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

#Assignable: {
    kind: "assignable"
    types: [...string]
    cardinality: "AtMostOne" | "ExactlyOne" | "AtLeastOne" | "Any" | "All"
}

// A type schema
#Resource: {
    relations: [string]: #RelationBody
}

// Root schema document
#Schema: {
    resources: [string]: #Resource
}

base: #Schema & {

}

schema: base & rbac & hbi
