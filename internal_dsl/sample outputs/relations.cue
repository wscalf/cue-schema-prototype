// This is what the unified CUE looks like for meta/hbi/rbac, with all extensions applied and data merged
// It includes everything we'd need (plus further processing) to generate a Zanzibar schema and do some introspection
// like mapping between data fields and relations.
// This can be compiled from CUE files with a go library and interrogated in-memory.
hbi: {
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
            data: {
                workspace_id: number
            }
        }
    }
    metadata: {}
}
rbac: {
    resources: {
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
                    parts: [{
                        kind: "ref"
                        name: "inventory_all_all"
                    }, {
                        kind: "ref"
                        name: "inventory_hosts_all"
                    }, {
                        kind: "ref"
                        name: "inventory_any_read"
                    }, {
                        kind: "ref"
                        name: "inventory_hosts_read"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
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
                    parts: [{
                        kind: "ref"
                        name: "inventory_all_all"
                    }, {
                        kind: "ref"
                        name: "inventory_hosts_all"
                    }, {
                        kind: "ref"
                        name: "inventory_any_write"
                    }, {
                        kind: "ref"
                        name: "inventory_hosts_write"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
                }
                remediations_all_all: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediations_all: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_any_read: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediations_read: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediation_view: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "remediations_all_all"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_all"
                    }, {
                        kind: "ref"
                        name: "remediations_any_read"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_read"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
                }
                remediations_any_write: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediations_write: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediation_update: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "remediations_all_all"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_all"
                    }, {
                        kind: "ref"
                        name: "remediations_any_write"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_write"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
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
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "inventory_host_view"
                    }]
                }
                inventory_host_update: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "inventory_host_update"
                    }]
                }
                remediations_remediation_view: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "remediations_remediation_view"
                    }]
                }
                remediations_remediation_update: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "remediations_remediation_update"
                    }]
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
                view_metadata: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "inventory_host_view"
                    }, {
                        kind: "ref"
                        name: "remediations_remediation_view"
                    }]
                }
                inventory_host_view: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "inventory_host_view"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "inventory_host_view"
                    }]
                }
                inventory_host_update: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "inventory_host_update"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "inventory_host_update"
                    }]
                }
                remediations_remediation_view: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "remediations_remediation_view"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "remediations_remediation_view"
                    }]
                }
                remediations_remediation_update: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "remediations_remediation_update"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "remediations_remediation_update"
                    }]
                }
            }
            data: {}
        }
    }
    metadata: {
        "inventory:hosts:write": {
            application: "inventory"
            resource:    "hosts"
            verb:        "write"
        }
        "remediations:remediations:read": {
            application: "remediations"
            resource:    "remediations"
            verb:        "read"
        }
        "remediations:remediations:write": {
            application: "remediations"
            resource:    "remediations"
            verb:        "write"
        }
        "inventory:hosts:read": {
            application: "inventory"
            resource:    "hosts"
            verb:        "read"
        }
    }
}