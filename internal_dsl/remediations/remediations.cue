package remediations

import ("example.com/schema/kessel"
"example.com/schema/rbac")

// Remediations doesn't onboard any resources, so its schema is empty + RBAC templates
remediations: kessel.#Schema & {

} & (rbac.#AddV1BasedPermission & {
    application: "remediations"
    resource: "remediations"
    verb: "read"
    v2_perm: "remediations_remediation_view"
}).patch & (rbac.#AddV1BasedPermission & {
    application: "remediations"
    resource: "remediations"
    verb: "write"
    v2_perm: "remediations_remediation_update"
}).patch & (rbac.#AddV1BasedPermission & {
    application: "remediations"
    resource: "remediations"
    verb: "delete"
    v2_perm: "remediations_remediation_delete"
}).patch