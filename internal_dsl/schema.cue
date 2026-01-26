package schema

import ("example.com/schema/rbac" 
"example.com/schema/hbi"
"example.com/schema/kessel")

schema: kessel.base & rbac.rbac & hbi.hbi
