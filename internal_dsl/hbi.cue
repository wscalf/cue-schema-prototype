package kessel

hbi: #Schema & {
    resources: {
        host: {
            relations: {
                workspace: #Assignable & {types: ["workspace"], cardinality: "ExactlyOne"}
                view: #Ref & {name: "workspace", relation: "inventory_host_view"}
                update: #Ref & {name: "workspace", relation: "inventory_host_update"}
                delete: #Ref & {name: "workspace", relation: "inventory_host_update"}
            }
        }
    }
} & (#AddV1BasedPermission & {
    application: "inventory"
    resource: "hosts"
    verb: "read"
    v2_perm: "inventory_host_view"
}).patch & (#AddV1BasedPermission & {
    application: "inventory"
    resource: "hosts"
    verb: "write"
    v2_perm: "inventory_host_update"
}).patch