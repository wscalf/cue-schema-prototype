package rbac

import ("example.com/schema/kessel")

rbac: kessel.#Schema & {
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
                parent: kessel.#Assignable & {types: [{name: "workspace"}], cardinality: "AtMostOne"} //Simplified since no tenant type
                binding: kessel.#Assignable & {types: [{name: "role_binding"}], cardinality: "Any"}
            }
        }
    }
}

#AddV1BasedPermission: {
    application: string
    resource: string
    verb: string
    v2_perm: string

    patch: kessel.#Schema & {
        resources: {
            role: {
                let boolean = kessel.#Assignable & {types: [{name: "principal"}], cardinality: "All"}

                let app_admin = "\(application)_all_all"
                let any_verb = "\(application)_\(resource)_all"
                let any_resource = "\(application)_any_\(verb)"
                let v1_perm = "\(application)_\(resource)_\(verb)"

                relations: {
                    "\(app_admin)": boolean
                    "\(any_verb)": boolean
                    "\(any_resource)": boolean
                    "\(v1_perm)": boolean
                    "\(v2_perm)": kessel.#Or & {left: kessel.#Ref & {name: app_admin}, right: kessel.#Or & {left: kessel.#Ref & {name: any_verb}, right: kessel.#Or & {left: kessel.#Ref & {name: any_resource}, right: kessel.#Or & {left: kessel.#Ref & {name: v1_perm}, right: kessel.#Ref & {name: "all_all_all"}}}}}
                }
            }

            role_binding: {
                relations: {
                    "\(v2_perm)": kessel.#And & {left: kessel.#Ref & {name: "subject"}, right: kessel.#Ref & {name: "granted", relation: "\(v2_perm)"}}
                }
            }

            workspace: {
                relations: {
                    "\(v2_perm)": kessel.#Or & {left: kessel.#Ref & {name: "binding", relation: "\(v2_perm)"}, right: kessel.#Ref & {name: "parent", relation: "\(v2_perm)"}}
                }
            }
        }
    }
}