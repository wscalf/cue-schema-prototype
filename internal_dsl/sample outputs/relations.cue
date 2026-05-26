schema: {
    hbi: {
        resources: {
            host: {
                workspace: {
                    kind: "assignable"
                    types: [{
                        name: "workspace"
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
        }
        metadata: {}
    }
    rbac: {
        resources: {
            principal: {}
            role: {
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
                remediations_any_delete: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediations_delete: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                remediations_remediation_delete: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "remediations_all_all"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_all"
                    }, {
                        kind: "ref"
                        name: "remediations_any_delete"
                    }, {
                        kind: "ref"
                        name: "remediations_remediations_delete"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
                }
                tasks_all_all: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_tasks_all: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_any_read: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_tasks_read: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_task_view: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "tasks_all_all"
                    }, {
                        kind: "ref"
                        name: "tasks_tasks_all"
                    }, {
                        kind: "ref"
                        name: "tasks_any_read"
                    }, {
                        kind: "ref"
                        name: "tasks_tasks_read"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
                }
                tasks_any_write: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_tasks_write: {
                    kind: "assignable"
                    types: [{
                        name: "principal"
                    }]
                    cardinality: "All"
                }
                tasks_task_update: {
                    kind: "or"
                    parts: [{
                        kind: "ref"
                        name: "tasks_all_all"
                    }, {
                        kind: "ref"
                        name: "tasks_tasks_all"
                    }, {
                        kind: "ref"
                        name: "tasks_any_write"
                    }, {
                        kind: "ref"
                        name: "tasks_tasks_write"
                    }, {
                        kind: "ref"
                        name: "all_all_all"
                    }]
                }
            }
            role_binding: {
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
                remediations_remediation_delete: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "remediations_remediation_delete"
                    }]
                }
                tasks_task_view: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "tasks_task_view"
                    }]
                }
                tasks_task_update: {
                    kind: "and"
                    parts: [{
                        kind: "ref"
                        name: "subject"
                    }, {
                        kind:     "ref"
                        name:     "granted"
                        relation: "tasks_task_update"
                    }]
                }
            }
            workspace: {
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
                    }, {
                        kind: "ref"
                        name: "tasks_task_view"
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
                remediations_remediation_delete: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "remediations_remediation_delete"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "remediations_remediation_delete"
                    }]
                }
                tasks_task_view: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "tasks_task_view"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "tasks_task_view"
                    }]
                }
                tasks_task_update: {
                    kind: "or"
                    parts: [{
                        kind:     "ref"
                        name:     "binding"
                        relation: "tasks_task_update"
                    }, {
                        kind:     "ref"
                        name:     "parent"
                        relation: "tasks_task_update"
                    }]
                }
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
            "remediations:remediations:delete": {
                application: "remediations"
                resource:    "remediations"
                verb:        "delete"
            }
            "tasks:tasks:read": {
                application: "tasks"
                resource:    "tasks"
                verb:        "read"
            }
            "tasks:tasks:write": {
                application: "tasks"
                resource:    "tasks"
                verb:        "write"
            }
            "inventory:hosts:read": {
                application: "inventory"
                resource:    "hosts"
                verb:        "read"
            }
        }
    }
}
