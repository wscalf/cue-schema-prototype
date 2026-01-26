role: {
    inventory_hosts_read: bool
    inventory_hosts_write: bool
    inventory_hosts_all: bool

    inventory_host_view: role["inventory_hosts_read"] || role["inventory_hosts_all"]
    inventory_host_update: role["inventory_hosts_write"] || role["inventory_hosts_all"]
}


//_#add_v1_based_permission: {
//    application: string
//    resourceType: string
//    verb: string
//    v2_perm: string
//
//    role : {
//        inventory_hosts_read: bool
//        inventory_hosts_all: bool
//
//        inventory_host_view: role["inventory_hosts_read"] || role["inventory_hosts_all"]
//    }
//}
//
//_inventory_hosts_view: _#add_v1_based_permission & {
//    application: "inventory"
//    resourceType: "hosts"
//    verb: "read"
//    v2_perm: "inventory_host_view"
//}
//
//_inventory_hosts_update: _#add_v1_based_permission & {
//    application: "inventory"
//    resourceType: "hosts"
//    verb: "write"
//    v2_perm: "inventory_host_update"
//}
