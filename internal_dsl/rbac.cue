package kessel

rbac: #Schema & {
    resources: {
        principal: #Resource & {}

        role: #Resource & {
            relations: {
                all_all_all: #Assignable & {types: ["principal"], cardinality: "All"}
            }
        }

        role_binding: #Resource & {
            relations: {
                subject: #Assignable & {types: ["principal"], cardinality: "Any"}
                granted: #Assignable & {types: ["role"], cardinality: "Any"}
            }
        }

        workspace: #Resource & {
            relations: {
                parent: #Assignable & {types: ["workspace"], cardinality: "AtMostOne"} //Simplified since no tenant type
                binding: #Assignable & {types: ["role_binding"], cardinality: "Any"}
            }
        }
    }
}

#AddV1BasedPermission: {
    application: string
    resource: string
    verb: string
    v2_perm: string

    patch: #Schema & {
        resources: {
            role: {
                let boolean = #Assignable & {types: ["principal"], cardinality: "All"}

                let app_admin = "\(application)_all_all"
                let any_verb = "\(application)_\(resource)_all"
                let any_resource = "\(application)_any_\(verb)"
                let v1_perm = "\(application)_\(resource)_\(verb)"

                relations: {
                    "\(app_admin)": boolean
                    "\(any_verb)": boolean
                    "\(any_resource)": boolean
                    "\(v1_perm)": boolean
                    "\(v2_perm)": #Or & {left: #Ref & {name: app_admin}, right: #Or & {left: #Ref & {name: any_verb}, right: #Or & {left: #Ref & {name: any_resource}, right: #Or & {left: #Ref & {name: v1_perm}, right: #Ref & {name: "all_all_all"}}}}}
                }
            }

            role_binding: {
                relations: {
                    "\(v2_perm)": #And & {left: #Ref & {name: "subject"}, right: #Ref & {name: "granted", relation: "\(v2_perm)"}}
                }
            }

            workspace: {
                relations: {
                    "\(v2_perm)": #Or & {left: #Ref & {name: "binding", relation: "\(v2_perm)"}, right: #Ref & {name: "parent", relation: "\(v2_perm)"}}
                }
            }
        }
    }
}