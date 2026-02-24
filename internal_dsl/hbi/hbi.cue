package hbi

import ("example.com/schema/rbac" 
    "example.com/schema/kessel")

//Note on uuid - while CUE supports JSONSchema as an output format, it has limited support for JSONSchema types. It can do regexes tho..
let uuid = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

// This is the entrypoint to the package, an empty schema unified with HBI's details to create the HBI fragment.
// Will be unified with other fragments in schema.cue
// Note that this results in a flat schema (no namespace/reporter distinction) - this was due to an oversite in this prototype and not a CUE limitation
hbi: kessel.#Schema & {
    resources: {
        host: { //Host type definition
            relations: { // Relations are defined in a block (essentially an array) referencing things by name. Extensions are handled separately.
                // For this assignable relation, it's mapped to a data field to get the value from. This is shown as an alternative to assignable relations being special fields
                // and is not due to a limitation or particular advantage of CUE.
                workspace: kessel.#Assignable & {types: [{name: "workspace", data_field: "workspace_id"}], cardinality: "ExactlyOne"}
                view: kessel.#Ref & {name: "workspace", relation: "inventory_host_view"}
                update: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
                delete: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
            }
            data: { // Data fields are also defined in a block as properties with data types in the native type system.
                //These are essentially unsatisfied fields in the model which will be used later for generating JSONSchema (for what data would complete the model)
                workspace_id: number
                subscription_manager_id?: =~ uuid | null
                satellite_id?: =~ uuid | =~"^\\d{10}$" | null
                insights_id?: =~ uuid | null
                ansible_host?: =~ "^.{1,255}$" | null
            }
        }
    }
    // This is how extensions work - unifying a template from another package with concrete data, 
    // and unifying the resulting 'patch' field, which is itself a schema fragment, with our schema fragment
    // Doing so includes the schema generated from the other service's template in _this_ service's schema fragment
    // ..and then the resulting schema
} & (rbac.#AddV1BasedPermission & {
    application: "inventory"
    resource: "hosts"
    verb: "read"
    v2_perm: "inventory_host_view"
}).patch & (rbac.#AddV1BasedPermission & {
    application: "inventory"
    resource: "hosts"
    verb: "write"
    v2_perm: "inventory_host_update"
}).patch