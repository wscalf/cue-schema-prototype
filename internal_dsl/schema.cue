package schema

import ("example.com/schema/rbac" 
"example.com/schema/hbi"
"example.com/schema/kessel")

// The schema is comprised of a Kessel base + rbac + hbi. As services are onboarded, their sub-schemas must be referenced here.
// Think of this like 'main'
schema: kessel.base & rbac.rbac & hbi.hbi
