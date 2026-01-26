package hbi

import ("example.com/schema/rbac" 
    "example.com/schema/kessel")

let uuid = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"
hbi: kessel.#Schema & {
    resources: {
        host: {
            relations: {
                workspace: kessel.#Assignable & {types: [{name: "workspace", data_field: "workspace_id"}], cardinality: "ExactlyOne"}
                view: kessel.#Ref & {name: "workspace", relation: "inventory_host_view"}
                update: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
                delete: kessel.#Ref & {name: "workspace", relation: "inventory_host_update"}
            }
            data: {
                workspace_id: number
                subscription_manager_id?: =~ uuid | null
                satellite_id?: =~ uuid | =~"^\\d{10}$" | null
                insights_id?: =~ uuid | null
                ansible_host?: =~ "^.{1,255}$" | null
            }
        }
    }
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