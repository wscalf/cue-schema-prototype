package hbi

import ("example.com/schema/rbac" 
    "example.com/schema/kessel")

//Note on uuid - while CUE supports JSONSchema as an output format, it has limited support for JSONSchema types. It can do regexes tho..
let uuid = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

// This is the entrypoint to the package, an empty schema unified with HBI's details to create the HBI fragment.
// Will be unified with other fragments in schema.cue
// Note that this results in a flat schema (no namespace/reporter distinction) - this was due to an oversite in this prototype and not a CUE limitation
hbi: kessel.#Schema & {
    "hbi": {
        resources: {
            host: { //Host type definition
                workspace: kessel.#Assignable & {types: [{name: "workspace"}], cardinality: "ExactlyOne"}
                view: kessel.#Ref & {name: "workspace", relation: "inventory_host_view"}
                update: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
                delete: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
                subscription_manager_id?: =~ uuid
                satellite_id?: =~ uuid | =~"^\\d{10}$"
                insights_id?: =~ uuid
                ansible_host?: =~ "^.{1,255}$"
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