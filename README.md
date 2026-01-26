CUE as Schema Language Prototype
================================

First Atempt (Native Type System)
------------
See the `native_types` folder. The hope was that data and relation fields could be described in terms of user-defined types, but there was an early showstopping problem- CUE declarations that use variables to index an object in an rvalue don't use the variable value, they use the expression. This made extensions not really tenable.

Second Attempt (Internal DSL)
-------------

See the `internal_dsl` folder. The idea here is to model relationships as data constrained by a metaschema (see `internal_dsl/kessel/meta.cue`), which allows unification to build a schema from multiple compatible subschemas, which can in turn reference templates in other subschemas (to get extension-like behavior.) Each subschema is then the unification of its base schema with the templates it invokes, and the schema is the unification of all subschemas.

Use `cue eval -e schema schema.cue` from the `internal_dsl` folder to generate that output (or see `relations.cue`). This captures essentially the same information as a ksl file, with extensions implemened natively (though with some limitations, like consumers being able to extend another service's schema arbitrarily, not only by pre-defined extension points), and gains other native cue features like variables and compile-time conditions. Syntax is comparable to KSIL. Also note that you can include references to data fields in assignable blocks- the idea here is to indicate to a host process that a relationship should be populated based on the given type and the value of the given field from the reporter payload.

Use `cue export -e schema.resources.host.data --out jsonschema .` to generate a jsonschema file for HBI hosts (or see `host.json`) to validate the payload. Note that there are limitations here - ex: trying to use native jsonschema features (like uuid validation) via cue doesn't really work yet, hence everything being done via regexes. This same pattern (but with different type names) could be used to generate jsonschema files for other types.