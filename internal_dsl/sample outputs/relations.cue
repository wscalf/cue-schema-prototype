// This is what the unified CUE looks like for meta/hbi/rbac, with all extensions applied and data merged
// It includes everything we'd need (plus further processing) to generate a Zanzibar schema and do some introspection
// like mapping between data fields and relations.
// This can be compiled from CUE files with a go library and interrogated in-memory.
resources: {
    host: {
        relations: {
            workspace: {
                kind: "assignable"
                types: [{
                    name:       "workspace"
                    data_field: "workspace_id"
                }]
                cardinality: "ExactlyOne"
            }
            view: {
                kind:     "ref"
                name:     "workspace"
                relation: "inventory_host_view"
            }
            update: {
                kind:     "ref"
                name:     "workspace"
                relation: "inventory_host_update"
            }
            delete: {
                kind:     "ref"
                name:     "workspace"
                relation: "inventory_host_update"
            }
        }
        data: {}
    }
    principal: {
        relations: {}
        data: {}
    }
    role: {
        relations: {
            all_all_all: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_all_all: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_hosts_all: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_any_read: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_hosts_read: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_host_view: {
                kind: "or"
                left: {
                    kind: "ref"
                    name: "inventory_all_all"
                }
                right: {
                    kind: "or"
                    left: {
                        kind: "ref"
                        name: "inventory_hosts_all"
                    }
                    right: {
                        kind: "or"
                        left: {
                            kind: "ref"
                            name: "inventory_any_read"
                        }
                        right: {
                            kind: "or"
                            left: {
                                kind: "ref"
                                name: "inventory_hosts_read"
                            }
                            right: {
                                kind: "ref"
                                name: "all_all_all"
                            }
                        }
                    }
                }
            }
            inventory_any_write: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_hosts_write: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "All"
            }
            inventory_host_update: {
                kind: "or"
                left: {
                    kind: "ref"
                    name: "inventory_all_all"
                }
                right: {
                    kind: "or"
                    left: {
                        kind: "ref"
                        name: "inventory_hosts_all"
                    }
                    right: {
                        kind: "or"
                        left: {
                            kind: "ref"
                            name: "inventory_any_write"
                        }
                        right: {
                            kind: "or"
                            left: {
                                kind: "ref"
                                name: "inventory_hosts_write"
                            }
                            right: {
                                kind: "ref"
                                name: "all_all_all"
                            }
                        }
                    }
                }
            }
        }
        data: {}
    }
    role_binding: {
        relations: {
            subject: {
                kind: "assignable"
                types: [{
                    name: "principal"
                }]
                cardinality: "Any"
            }
            granted: {
                kind: "assignable"
                types: [{
                    name: "role"
                }]
                cardinality: "Any"
            }
            inventory_host_view: {
                kind: "and"
                left: {
                    kind: "ref"
                    name: "subject"
                }
                right: {
                    kind:     "ref"
                    name:     "granted"
                    relation: "inventory_host_view"
                }
            }
            inventory_host_update: {
                kind: "and"
                left: {
                    kind: "ref"
                    name: "subject"
                }
                right: {
                    kind:     "ref"
                    name:     "granted"
                    relation: "inventory_host_update"
                }
            }
        }
        data: {}
    }
    workspace: {
        relations: {
            parent: {
                kind: "assignable"
                types: [{
                    name: "workspace"
                }]
                cardinality: "AtMostOne"
            }
            binding: {
                kind: "assignable"
                types: [{
                    name: "role_binding"
                }]
                cardinality: "Any"
            }
            inventory_host_view: {
                kind: "or"
                left: {
                    kind:     "ref"
                    name:     "binding"
                    relation: "inventory_host_view"
                }
                right: {
                    kind:     "ref"
                    name:     "parent"
                    relation: "inventory_host_view"
                }
            }
            inventory_host_update: {
                kind: "or"
                left: {
                    kind:     "ref"
                    name:     "binding"
                    relation: "inventory_host_update"
                }
                right: {
                    kind:     "ref"
                    name:     "parent"
                    relation: "inventory_host_update"
                }
            }
        }
        data: {}
    }
}