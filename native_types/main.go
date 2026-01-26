package main

import (
	"fmt"
	"os"
	"strings"

	"cuelang.org/go/cue"
	"cuelang.org/go/cue/ast"
	"cuelang.org/go/cue/cuecontext"
)

func main() {
	ctx := cuecontext.New()
	data, err := os.ReadFile("rbac.cue")
	if err != nil {
		fmt.Printf("Error reading file: %s", err)
		return
	}

	v := ctx.CompileBytes(data)

	if err = v.Validate(); err != nil {
		fmt.Printf("Error compiling file: %s", err)
		return
	}

	if output, err := printData(v, "<root>", 0); err != nil {
		fmt.Printf("Error printing data: %s", err)
	} else {
		fmt.Println(output)
	}
}

func printData(v cue.Value, label string, indent int) (string, error) { //This could build a big string with appends rather than trying to manage the console writer
	v = v.Eval()

	switch v.IncompleteKind() {
	case cue.StructKind:
		it, err := v.Fields()
		if err != nil {
			return "", err
		}

		for it.Next() {
			selector := it.Selector()
			value := it.Value()
			_, err := printData(value, selector.String(), indent+1)
			if err != nil {
				return "", err
			}
		}
	case cue.BoolKind:
		_ = 42
	case cue.ListKind:
		_ = 42
	case cue.BottomKind:
		n := v.Syntax()
		printAST(n, 0)
		if err := v.Err(); err != nil {
			fmt.Printf("Error at %s: %v", label, err)
		} else {
			fmt.Printf("BottomKind hit at %s without error", label)
		}
	default:
		_ = 42
	}

	return "", nil
}

func printAST(n ast.Node, indent int) {
	if n == nil {
		return
	}

	prefix := strings.Repeat("  ", indent)

	switch x := n.(type) {

	case *ast.File:
		fmt.Println(prefix + "File")
		for _, d := range x.Decls {
			printAST(d, indent+1)
		}

	case *ast.Field:
		fmt.Printf("%sField: %s\n", prefix, labelString(x.Label))
		printAST(x.Value, indent+1)

	case *ast.StructLit:
		fmt.Println(prefix + "Struct")
		for _, e := range x.Elts {
			printAST(e, indent+1)
		}

	case *ast.BinaryExpr:
		fmt.Printf("%sBinaryExpr: %s\n", prefix, x.Op)
		printAST(x.X, indent+1)
		printAST(x.Y, indent+1)

	case *ast.UnaryExpr:
		fmt.Printf("%sUnaryExpr: %s\n", prefix, x.Op)
		printAST(x.X, indent+1)

	case *ast.Ident:
		fmt.Printf("%sIdent: %s\n", prefix, x.Name)

	case *ast.BasicLit:
		fmt.Printf("%sLiteral: %s (%s)\n", prefix, x.Value, x.Kind)

	case *ast.SelectorExpr:
		fmt.Println(prefix + "Selector")
		printAST(x.X, indent+1)
		fmt.Printf("%s  .%s\n", prefix, labelString(x.Sel))

	case *ast.IndexExpr:
		fmt.Println(prefix + "Index")
		printAST(x.X, indent+1)
		printAST(x.Index, indent+1)

	case *ast.CallExpr:
		fmt.Println(prefix + "Call")
		printAST(x.Fun, indent+1)
		for _, a := range x.Args {
			printAST(a, indent+2)
		}

	case *ast.ParenExpr:
		fmt.Println(prefix + "Paren")
		printAST(x.X, indent+1)

	default:
		// Fallback for node types you haven't handled yet
		fmt.Printf("%s%T\n", prefix, x)
	}
}

// labelString renders a label (field name / selector) safely.
func labelString(l ast.Label) string {
	switch t := l.(type) {
	case *ast.Ident:
		return t.Name
	case *ast.BasicLit:
		return t.Value
	default:
		return fmt.Sprintf("%T", t)
	}
}

func printlnfindented(indent int, format string, args ...any) {
	indentation := strings.Repeat(" ", indent)

	body := fmt.Sprintf(format, args...)
	fmt.Printf("%s%s\n", indentation, body)
}
