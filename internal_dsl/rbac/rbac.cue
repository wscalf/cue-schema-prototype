package rbac

import ("example.com/schema/kessel")

// The entrypoint for RBAC's schema fragment, contains only the concrete, non-extended parts of RBAC's schema
rbac: kessel.#Schema & {
    "rbac": {
        resources: {
            principal: kessel.#Resource & {}

            role: kessel.#Resource & {
                relations: {
                    all_all_all: kessel.#Assignable & {types: [{name: "principal"}], cardinality: "All"}
                }
            }

            role_binding: kessel.#Resource & {
                relations: {
                    subject: kessel.#Assignable & {types: [{name: "principal"}], cardinality: "Any"}
                    granted: kessel.#Assignable & {types: [{name: "role"}], cardinality: "Any"}
                }
            }

            workspace: kessel.#Resource & {
                relations: {
                    parent: kessel.#Assignable & {types: [{name: "workspace"}], cardinality: "AtMostOne"}
                    binding: kessel.#Assignable & {types: [{name: "role_binding"}], cardinality: "Any"}
                }
            }
        }
    }
}

#Permission: {
    application: string
    resource: string
    verb: string
}

// Sample extension, is a parameterized template that results in a 'patch' - a schema fragment containing only the results
#AddV1BasedPermission: {
    application: string
    resource: string
    verb: string
    v2_perm: string

    patch: kessel.#Schema & {
        "rbac": {
            resources: {
                role: {
                    let boolean = kessel.#Assignable & {types: [{name: "principal"}], cardinality: "All"} //Alias for principal:*

                    // V1 perm and wildcard names
                    let app_admin = "\(application)_all_all"
                    let any_verb = "\(application)_\(resource)_all"
                    let any_resource = "\(application)_any_\(verb)"
                    let v1_perm = "\(application)_\(resource)_\(verb)"

                    //Include them + v2_perm that ors them together
                    relations: {
                        "\(app_admin)": boolean
                        "\(any_verb)": boolean
                        "\(any_resource)": boolean
                        "\(v1_perm)": boolean
                        //This line is a lot, but it's doing essentially the same thing as all the other v2_perm expressions, the syntax to create an inline object is just verbose
                        "\(v2_perm)": kessel.#Or & {parts: [kessel.#Ref & {name: app_admin}, kessel.#Ref & {name: any_verb}, kessel.#Ref & {name: any_resource}, kessel.#Ref & {name: v1_perm}, kessel.#Ref & {name: "all_all_all"}]}
                    }
                }

                role_binding: {
                    relations: {
                        "\(v2_perm)": kessel.#And & {parts: [kessel.#Ref & {name: "subject"}, kessel.#Ref & {name: "granted", relation: "\(v2_perm)"}]}
                    }
                }

                workspace: {
                    relations: {
                        "\(v2_perm)": kessel.#Or & {parts: [kessel.#Ref & {name: "binding", relation: "\(v2_perm)"}, kessel.#Ref & {name: "parent", relation: "\(v2_perm)"}]}
                    }
                    // read_perms only exists when verb == "read"; absent fields are not null, so gate on the same condition (and keep read_perms beside the relations that use it).
                    if verb == "read" {
                        _read_perms: {
                            "\(v2_perm)": {}
                        }
                        relations: {
                            "view_metadata": kessel.#Or & {parts: [for perm, _ in _read_perms { kessel.#Ref & {name: perm} }]}
                        }
                    }
                }
            }
            metadata: {
                let app = application //Need to assign to a variable to avoid shadowing the struct member
                let res = resource
                let act = verb

                "\(app):\(res):\(act)": #Permission & {application: "\(app)", resource: "\(res)", verb: "\(act)"}
            }
        }
    }
}