package tasks

import ("example.com/schema/kessel"
"example.com/schema/rbac")

// Tasks doesn't onboard any resources, so its schema is empty + RBAC templates
tasks: kessel.#Schema & {

} & (rbac.#AddV1BasedPermission & {
    application: "tasks"
    resource: "tasks"
    verb: "read"
    v2_perm: "tasks_task_view"
}).patch & (rbac.#AddV1BasedPermission & {
    application: "tasks"
    resource: "tasks"
    verb: "write"
    v2_perm: "tasks_task_update"
}).patch
