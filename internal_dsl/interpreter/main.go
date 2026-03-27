package main

import (
	"encoding/json"
	"fmt"
	"log"
	"strings"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/cuecontext"
	"cuelang.org/go/cue/load"
	"example.com/cue-interpreter/visitors"
)

func main() {
	moduleDir := "."

	ctx := cuecontext.New()
	cfg := &load.Config{Dir: moduleDir}
	insts := load.Instances([]string{"./schema.cue"}, cfg)
	doc := ctx.BuildInstance(insts[0])
	if err := doc.Err(); err != nil {
		log.Fatalf("build: %v", err)
	}

	root := doc.LookupPath(cue.ParsePath("schema"))
	if !root.Exists() || root.Err() != nil {
		fmt.Printf("Error looking up schema: %v\n", root.Err())
		return
	}

	spiceDbVisitor := visitors.NewSpiceDBSchemaGeneratingVisitor()
	visitSchema(root, spiceDbVisitor)
	spiceDbSchema, err := spiceDbVisitor.Generate()
	if err != nil {
		fmt.Printf("Error generating SpiceDB schema: %v\n", err)
		return
	}
	fmt.Printf("SpiceDB Schema: %s", spiceDbSchema)
	jsonSchemaVisitor := visitors.NewJSONSchemaVisitor()
	err = visitSchema(root, jsonSchemaVisitor)
	if err != nil {
		fmt.Printf("Error generating JSON schema: %v\n", err)
		return
	}

	fmt.Print("\n")
	fmt.Print("\n")

	for name, schema := range jsonSchemaVisitor.Schemas {
		data, err := json.MarshalIndent(schema, "", "  ")
		if err != nil {
			fmt.Printf("Error marshalling JSON schema for %s: %v\n", name, err)
			continue
		}

		fmt.Printf("JSON Schema for %s: %s\n", name, string(data))
	}

	fmt.Print("\n")
	fmt.Print("\n")

	metadata, err := extractMetadata(root)
	if err != nil {
		fmt.Printf("Error extracting metadata from cue schema: %s\n", err)
		return
	}

	output, err := json.MarshalIndent(metadata, "", "    ")
	if err != nil {
		fmt.Printf("Error marshalling extracted metadata to json: %s\n", err)
	}

	fmt.Printf(string(output))

}

func joinPath(prefix, sel string) string {
	if prefix == "" {
		return sel
	}
	return prefix + "." + sel
}

func extractMetadata(v cue.Value) (map[string]map[string]string, error) {
	data := map[string]map[string]string{}

	appIt, err := v.Fields(cue.Optional(true))
	if err != nil {
		return data, err
	}

	for appIt.Next() {
		app := appIt.Selector().String()
		appData := appIt.Value()
		appMetadataValue := appData.LookupPath(cue.ParsePath("metadata"))
		if !appMetadataValue.Exists() || appMetadataValue.Err() != nil {
			return data, appMetadataValue.Err()
		}

		appMetadata := map[string]string{}

		data[app] = appMetadata

		metaIt, err := appMetadataValue.Fields()
		if err != nil {
			return data, err
		}

		for metaIt.Next() {
			key := metaIt.Selector().String()
			value := metaIt.Value()

			contents, err := value.MarshalJSON()
			if err != nil {
				return data, err
			}

			appMetadata[key] = string(contents)
		}
	}

	return data, nil
}

func visitSchema(v cue.Value, visitor visitors.SchemaVisitor) error {
	if err := v.Err(); err != nil {
		return err
	}

	// Build an index of resource type name -> namespace.
	// assignable.types[].name references resource types by name only, so we need
	// this lookup to pass the correct typeNamespace to VisitAssignableExpression.
	typeNamespaceByTypeName := map[string]string{}
	if v.Kind() != cue.StructKind {
		return fmt.Errorf("visitSchema: expected struct root, got %v", v.Kind())
	}

	nsIt, err := v.Fields()
	if err != nil {
		return fmt.Errorf("visitSchema: iterating namespaces: %w", err)
	}
	for nsIt.Next() {
		nsName := nsIt.Selector().String()
		nsVal := nsIt.Value()

		resourcesVal := nsVal.LookupPath(cue.ParsePath("resources"))
		if !resourcesVal.Exists() || resourcesVal.Err() != nil {
			continue
		}

		resIt, err := resourcesVal.Fields(cue.Optional(true))
		if err != nil {
			return fmt.Errorf("visitSchema: iterating resources for namespace %q: %w", nsName, err)
		}
		for resIt.Next() {
			typeName := resIt.Selector().String()
			if _, exists := typeNamespaceByTypeName[typeName]; !exists {
				typeNamespaceByTypeName[typeName] = nsName
			}
		}
	}

	// Visit each namespace resource.
	nsIt2, err := v.Fields()
	if err != nil {
		return fmt.Errorf("visitSchema: iterating namespaces second time: %w", err)
	}
	for nsIt2.Next() {
		nsName := nsIt2.Selector().String()
		nsVal := nsIt2.Value()

		resourcesVal := nsVal.LookupPath(cue.ParsePath("resources"))
		if !resourcesVal.Exists() || resourcesVal.Err() != nil {
			continue
		}

		resIt, err := resourcesVal.Fields(cue.Optional(true))
		if err != nil {
			return fmt.Errorf("visitSchema: iterating resources for namespace %q: %w", nsName, err)
		}
		for resIt.Next() {
			typeName := resIt.Selector().String()
			resourceVal := resIt.Value()

			visitor.BeginType(nsName, typeName)

			var relations []any
			relationsVal := resourceVal.LookupPath(cue.ParsePath("relations"))
			if relationsVal.Exists() && relationsVal.Err() == nil {
				relIt, err := relationsVal.Fields(cue.Optional(true))
				if err != nil {
					return fmt.Errorf("visitSchema: iterating relations for %s.%s: %w", nsName, typeName, err)
				}
				for relIt.Next() {
					relName := relIt.Selector().String()
					relBodyVal := relIt.Value()

					visitor.BeginRelation(relName)

					currentDataVal := resourceVal.LookupPath(cue.ParsePath("data"))
					bodyExpr := visitRelationBody(relBodyVal, currentDataVal, typeNamespaceByTypeName, visitor)
					relations = append(relations, visitor.VisitRelation(relName, bodyExpr))
				}
			}

			var dataFields []any
			dataVal := resourceVal.LookupPath(cue.ParsePath("data"))
			if dataVal.Exists() && dataVal.Err() == nil {
				fieldIt, err := dataVal.Fields(cue.Optional(true))
				if err != nil {
					return fmt.Errorf("visitSchema: iterating data fields for %s.%s: %w", nsName, typeName, err)
				}
				for fieldIt.Next() {
					fieldSel := fieldIt.Selector()
					fieldName := fieldSel.Unquoted()

					// In JSON-schema terms, required fields are those that are not
					// marked as optional in the CUE source.
					// `sel.String()` renders a trailing `?` for optional fields.
					required := !strings.HasSuffix(fieldSel.String(), "?")

					fieldVal := fieldIt.Value()
					dataTypeExpr := visitDataType(fieldVal, visitor)
					dataFields = append(dataFields, visitor.VisitDataField(fieldName, required, dataTypeExpr))
				}
			}

			visitor.VisitType(nsName, typeName, relations, dataFields)
		}
	}

	return nil
}

func visitNamespace(v cue.Value, visitor visitors.SchemaVisitor) error {
	if err := v.Err(); err != nil {
		return err
	}

	return nil
}

func visitRelationBody(
	relationBody cue.Value,
	currentDataVal cue.Value,
	typeNamespaceByTypeName map[string]string,
	visitor visitors.SchemaVisitor,
) any {
	if relationBody.Err() != nil {
		// Caller checked root.Err(), but keep this resilient for partial traversal.
		return nil
	}
	if relationBody.IsNull() {
		return nil
	}
	if relationBody.Kind() != cue.StructKind {
		// Some relations may be represented as a direct expression.
		return nil
	}

	kindVal := relationBody.LookupPath(cue.ParsePath("kind"))
	kind, err := kindVal.String()
	if err != nil {
		return nil
	}

	switch kind {
	case "and":
		return foldParts(relationBody, currentDataVal, typeNamespaceByTypeName, visitor, "and")
	case "or":
		return foldParts(relationBody, currentDataVal, typeNamespaceByTypeName, visitor, "or")
	case "unless":
		return foldParts(relationBody, currentDataVal, typeNamespaceByTypeName, visitor, "unless")
	case "ref":
		name, _ := relationBody.LookupPath(cue.ParsePath("name")).String()
		subrelVal := relationBody.LookupPath(cue.ParsePath("relation"))
		if subrelVal.Exists() && subrelVal.Err() == nil {
			sub, subErr := subrelVal.String()
			if subErr == nil && !subrelVal.IsNull() {
				return visitor.VisitSubRelationExpression(name, sub)
			}
		}
		return visitor.VisitRelationExpression(name)
	case "assignable":
		cardinality, _ := relationBody.LookupPath(cue.ParsePath("cardinality")).String()
		typesVal := relationBody.LookupPath(cue.ParsePath("types"))
		list, err := typesVal.List()
		if err != nil {
			return nil
		}

		var typeName string
		var typeNamespace string
		var dataTypeParts []any
		i := 0
		for list.Next() {
			typeMapVal := list.Value()

			tName, _ := typeMapVal.LookupPath(cue.ParsePath("name")).String()
			if i == 0 {
				typeName = tName
				typeNamespace = typeNamespaceByTypeName[typeName]
			}

			// If multiple types are present, we currently assume they all refer to
			// the same resource type name. This matches the current DSL usage.
			if tName != typeName {
				// Best-effort: keep the first namespace/type; still union the data types.
			}

			dataFieldVal := typeMapVal.LookupPath(cue.ParsePath("data_field"))
			var dt any
			if dataFieldVal.Exists() && dataFieldVal.Err() == nil {
				dfName, dfErr := dataFieldVal.String()
				if dfErr == nil && !dataFieldVal.IsNull() {
					typedVal := currentDataVal.LookupPath(cue.ParsePath(dfName))
					dt = visitDataType(typedVal, visitor)
				}
			}
			if dt == nil {
				// Default representation for relations whose input isn't sourced from
				// a concrete data field.
				dt = visitor.VisitUUIDDataType()
			}

			dataTypeParts = append(dataTypeParts, dt)
			i++
		}

		// If multiple data type parts exist, represent them as a composite.
		var dataType any
		if len(dataTypeParts) == 1 {
			dataType = dataTypeParts[0]
		} else {
			dataType = visitor.VisitCompositeDataType(dataTypeParts)
		}

		return visitor.VisitAssignableExpression(typeNamespace, typeName, cardinality, dataType)
	default:
		return nil
	}
}

func foldParts(
	relationBody cue.Value,
	currentDataVal cue.Value,
	typeNamespaceByTypeName map[string]string,
	visitor visitors.SchemaVisitor,
	opKind string,
) any {
	partsVal := relationBody.LookupPath(cue.ParsePath("parts"))
	list, err := partsVal.List()
	if err != nil {
		return nil
	}

	var (
		acc     any
		hasAcc  bool
		visitFn func(left any, right any) any
	)

	switch opKind {
	case "and":
		visitFn = visitor.VisitAnd
	case "or":
		visitFn = visitor.VisitOr
	case "unless":
		visitFn = visitor.VisitUnless
	default:
		return nil
	}

	for list.Next() {
		partVal := list.Value()
		next := visitRelationBody(partVal, currentDataVal, typeNamespaceByTypeName, visitor)
		if !hasAcc {
			acc = next
			hasAcc = true
			continue
		}
		acc = visitFn(acc, next)
	}

	return acc
}

func visitDataType(v cue.Value, visitor visitors.SchemaVisitor) any {
	if v.Err() != nil {
		return nil
	}
	if v.IsNull() {
		return nil
	}

	// Handle unions first.
	op, args := v.Expr()
	if op == cue.OrOp {
		parts := make([]any, 0, len(args))
		for _, a := range args {
			parts = append(parts, visitDataType(a, visitor))
		}
		return visitor.VisitCompositeDataType(parts)
	}

	incKind := v.IncompleteKind()
	switch incKind {
	case cue.NumberKind:
		return visitor.VisitNumericIDDataType(nil, nil)
	case cue.StringKind:
		// Try to extract a regex constraint. If none exists, return a plain text type.
		regex := extractRegexString(v)
		if regex != nil && *regex == uuidRegexLiteral {
			return visitor.VisitUUIDDataType()
		}
		return visitor.VisitTextDataType(nil, nil, regex)
	case cue.NullKind:
		return nil
	default:
		// Best-effort: if it looks like it can be treated as a string/number, rely on
		// the expr/regex extraction. Otherwise, return nil.
		if op == cue.RegexMatchOp && len(args) == 1 {
			regex := stringPtrFromValue(args[0])
			if regex != nil && *regex == uuidRegexLiteral {
				return visitor.VisitUUIDDataType()
			}
			return visitor.VisitTextDataType(nil, nil, regex)
		}
		return nil
	}
}

const uuidRegexLiteral = "^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$"

func extractRegexString(v cue.Value) *string {
	op, args := v.Expr()
	switch op {
	case cue.RegexMatchOp:
		if len(args) == 1 {
			return stringPtrFromValue(args[0])
		}
		return nil
	case cue.AndOp:
		for _, a := range args {
			if r := extractRegexString(a); r != nil {
				return r
			}
		}
		return nil
	default:
		return nil
	}
}

func stringPtrFromValue(v cue.Value) *string {
	if v.Err() != nil || !v.IsConcrete() {
		return nil
	}
	s, err := v.String()
	if err != nil {
		return nil
	}
	return &s
}

/*
func enumerate(prefix string, v cue.Value, visitor visitors.SchemaVisitor) {
	if err := v.Err(); err != nil {
		fmt.Fprintf(os.Stderr, "%s\terror\t%v\n", prefix, err)
		return
	}

	switch v.Kind() {
	case cue.StructKind:
		it, err := v.Fields()
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\t(fields)\t%v\n", prefix, err)
			return
		}
		for it.Next() {
			p := joinPath(prefix, it.Selector().String())
			sub := it.Value()
			if isComposite(sub) {
				enumerate(p, sub)
			} else {
				printLeaf(p, sub)
			}
		}
	case cue.ListKind:
		list, err := v.List()
		if err != nil {
			fmt.Fprintf(os.Stderr, "%s\t(list)\t%v\n", prefix, err)
			return
		}
		i := 0
		for list.Next() {
			p := fmt.Sprintf("%s[%d]", prefix, i)
			sub := list.Value()
			if isComposite(sub) {
				enumerate(p, sub)
			} else {
				printLeaf(p, sub)
			}
			i++
		}
	default:
		printLeaf(prefix, v)
	}
}

func isComposite(v cue.Value) bool {
	switch v.Kind() {
	case cue.StructKind, cue.ListKind:
		return true
	default:
		return false
	}
}

func printLeaf(path string, v cue.Value) {
	s, err := cuejson.Marshal(v)
	if err != nil {
		s = fmt.Sprintf("<%s marshal: %v>", v.Kind(), err)
	}
	s = strings.ReplaceAll(s, "\n", " ")
	const max = 120
	if len(s) > max {
		s = s[:max-3] + "..."
	}
	if path == "" {
		path = "."
	}
	fmt.Printf("%s\t%s\t%s\n", path, v.Kind(), s)
}
*/
