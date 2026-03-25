package main

import (
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
	root := ctx.BuildInstance(insts[0])
	if err := root.Err(); err != nil {
		log.Fatalf("build: %v", err)
	}

	spiceDbVisitor := visitors.NewSpiceDBSchemaGeneratingVisitor()
	visitSchema(root, spiceDbVisitor)
	jsonSchemaVisitor := visitors.NewJSONSchemaVisitor()
	visitSchema(root, jsonSchemaVisitor)

}

func splitComma(s string) []string {
	parts := strings.Split(s, ",")
	out := make([]string, 0, len(parts))
	for _, p := range parts {
		p = strings.TrimSpace(p)
		if p != "" {
			out = append(out, p)
		}
	}
	return out
}

func joinPath(prefix, sel string) string {
	if prefix == "" {
		return sel
	}
	return prefix + "." + sel
}

func visitSchema(v cue.Value, visitor visitors.SchemaVisitor) error {
	if err := v.Err(); err != nil {
		return err
	}

	return nil
}

func visitNamespace(v cue.Value, visitor visitors.SchemaVisitor) error {
	if err := v.Err(); err != nil {
		return err
	}

	return nil
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
