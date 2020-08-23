import AST
import Interpreter

/* type f :: (MyBoolean) -> MyBoolean */
/* type x :: MyBoolean */
/* func owo(_ bool: MyBoolean) -> MyBoolean :: #MyTrue */

/* var module: String = """ */
/* type MyBoolean :: #MyTrue or #MyFalse */
/* type Nat :: #zero or #succ(Nat) */
/*  */
/* func MyNot2(_ bool: MyBoolean) -> Nat :: */
/*     #zero */
/*  */
/* func add(_ x: Nat, _ y: Nat) -> MyBoolean :: */
/*   #MyFalse */
/*  */
/* func MyNot(_ bool: MyBoolean) -> MyBoolean :: */
/*   match(bool) */
/*     with #MyTrue :: */
/*       #MyFalse */
/*     with #MyFalse :: */
/*       #MyTrue */
/*  */
/* func toNat(_ foo: (MyBoolean) -> MyBoolean) -> (MyBoolean) -> Nat :: */
/*   func blahblah(_ bar: MyBoolean) -> Nat :: */
/*     match(foo(bar)) */
/*       with #MyTrue :: */
/*         #succ(#zero) */
/*       with #MyFalse :: */
/*         #zero */
/*  */
/* func plusOne(_ x: Int) -> Int :: */
/*   x + 1 */
/* """ */
/* type owo :: (MyBoolean) -> MyBoolean */
/* type x :: MyBoolean */
/* var falseAST = try! interpreter.eval(string: "#MyFalse")! */
/* let ret = try! interpreter.eval(string: "toNat(MyNot)", replace: ["xxx": falseAST])! */
/* let funcAST = try! interpreter.eval(string: "f(x)", replace: ["f": ret, "x": falseAST])! */
/* let funcAS2T = try! interpreter.eval(string: "f(x)", replace: ["f": ret, "x": falseAST])! */
/* dumper.dump(ast: funcAS2T) */

var module: String = """
func add(_ x: Int, _ y: Int) -> Int ::
  x + y

func sub(_ x: Int, _ y: Int) -> Int ::
x - y

func mul(_ x: Int, _ y: Int) -> Int ::
x * y

func operationCurry(_ x: Int, op: (Int, Int) -> Int) -> (Int) -> Int ::
  func partialApply(_ y: Int) -> Int ::
    op(x,y);
"""
/* module = """ */
/* type MyBoolean :: #MyTrue or #MyFalse */
/* type Nat :: #zero or #succ(Nat) */
/*  */
/* func Ident(_ bool: MyBoolean) -> MyBoolean :: */
/*   bool */
/*  */
/* func Id(_ n: Nat) -> Nat :: */
/*   n */
/*  */
/* func MyNot(_ bool: MyBoolean) -> MyBoolean :: */
/*   match(bool) */
/*     with #MyTrue :: */
/*       #MyFalse */
/*     with #MyFalse :: */
/*       #MyTrue */
/*  */
/* func toNat(_ foo: (MyBoolean) -> MyBoolean) -> (MyBoolean) -> Nat :: */
/*   func blahblah(_ bar: MyBoolean) -> Nat :: */
/*     match(foo(bar)) */
/*       with #MyTrue :: */
/*         #succ(#zero) */
/*       with #MyFalse :: */
/*         #zero */
/*  */
/* func eq(_ nat1: Nat, _ nat2: Nat) -> MyBoolean :: */
/*   match (nat1, nat2) */
/*     with (#zero, #zero) :: */
/*       #MyTrue */
/*     with (#succ(let x), #zero) :: */
/*       #MyFalse */
/*     with (#zero, #succ(let x)) :: */
/*       #MyFalse */
/*     with (#succ(let x), #succ(let y)) :: */
/*       eq(x, y) */
/* """ */
/* type owo :: (MyBoolean) -> MyBoolean */
/* type x :: MyBoolean */
/* var falseAST = try! interpreter.eval(string: "#MyFalse")! */
/* let ret = try! interpreter.eval(string: "toNat(MyNot)", replace: ["xxx": falseAST])! */
/* let funcAST = try! interpreter.eval(string: "f(x)", replace: ["f": ret, "x": falseAST])! */
/* let funcAS2T = try! interpreter.eval(string: "f(x)", replace: ["f": ret, "x": falseAST])! */
/* dumper.dump(ast: funcAS2T) */

let dumper = ASTDumper(outputTo: Console.out)

var interpreter = Interpreter(debug: false)
try! interpreter.loadModule(fromString: module)

/* var falseAST = try! interpreter.eval(string: "#MyTrue")! */
/* let ret = try! interpreter.eval(string: "toNat(MyNot)")! */
/* let foo = try! interpreter.eval(string: "fff(add(toNat(MyNot)(#MyFalse), #succ(#zero)))", replace: ["fff": ret])! */
/* dumper.dump(ast: ret) */
/* let n = try! interpreter.eval(string: "add(1,2)")! */
/* let n = try! interpreter.eval(string: "curry(1, op: add)")! */
/* let m = try! interpreter.eval(string: "fff(1,2), replace: ["fff": n])! */

/* let issou = try! interpreter.eval(string: "curry(1, op: add)")! */
/* let aaa = try! interpreter.eval(string: "curry(1, op: add)")! */
/* print(aaa.module, issou.module) */
/* dumper.dump(ast: issou) */
/* let bar = try! interpreter.eval(string: "f(5)", replace: ["f": issou.copy(), "g": issou.copy()])! */
/* dumper.dump(ast: bar) */
      /* switch n{ */
      /* case .tuple(let e, _, _): */
      /*   print("tuple", e) */
      /* case .function(let f, let closure): */
      /*   print("func", f) */
      /*   closure.forEach { print("  -", $0.key, $0.value) } */
      /*   print("sad") */
      /*   [> evalContext.merge(closure, uniquingKeysWith: { _, rhs in rhs }) <] */
      /* default: */
      /*   print("other") */
      /* } */
      /*  */

/* let m = try! interpreter.eval(string: "toNat(MyNot)") */
/* let n = try! interpreter.eval(string: "toNat(Ident)") */
/* let q = try! interpreter.eval(string: "MyNot") */
/* let eq = try! interpreter.eval(string: "Id") */
/* let r1 = try! interpreter.eval(string: "fff(#MyTrue)", replace: ["fff": n]) */
/* let r2 = try! interpreter.eval(string: "ggg(#MyTrue)", replace: ["ggg": m]) */
/* let o = try! interpreter.eval(string: "fff(#MyTrue)", replace: ["fff": q]) */
/* let o = try! interpreter.eval(string: "MyNot(fff(#MyTrue))", replace: ["fff": q]) */
/* let o = try! interpreter.eval(string: "(func owo(_ a: MyBoolean) -> MyBoolean :: MyNot(a))(#MyTrue)", replace: ["fff": q, "ggg": n]) */
/* let p = try! interpreter.eval(string: "eq(fff, ggg)", replace: ["fff": r1, "ggg": r2]) */
/* let p = try! interpreter.eval(string: "eq(fff(#MyTrue), ggg(#MyTrue))", replace: ["fff": m, "ggg": n]) */
/* let p = try! interpreter.eval(string: "fff(#zero)", replace: ["fff": eq, "ggg": n]) */

/* print(m) */
/* print(n) */
/* print(r1) */
/* print(r2) */
/* print(p) */
/* print(p) */

/* let p = try! interpreter.eval(string: "fff(add(fff(fff(0)), fff(xxx)))", replace: ["fff": n, "xxx": m]) */

let m = try! interpreter.eval(string: "add(1, 2)")
let n = try! interpreter.eval(string: "operationCurry(@x, op: add)", replace: ["@x": m])
let q = try! interpreter.eval(string: "operationCurry(2, op: mul)")
let s = try! interpreter.eval(string: "@g(@f(@f(@g(7) - 10)))", replace: ["@f": n, "@g": q])

print(s)

/* print(o) */
/* let m = try! interpreter.eval(string: "#MyTrue")! */
/* let ret = try! interpreter.eval(string: "toNat(MyNot)") */
/* let owo = try! interpreter.eval(string: "fff(#MyFalse)", replace: ["fff": ret])! */
/* let p = try! interpreter.eval(string: "fff(#MyTrue)", replace: ["fff": ret])! */
/*  */
/* let g = try! interpreter.eval(string: "MyNot")! */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* print("\n") */
/* let foo = try! interpreter.eval(string: "fff(MyNot(#MyFalse))", replace: ["fff": g])! */
/* let m = try! interpreter.eval(string: "add(xxx, 3)", replace: ["xxx": n])! */
/* let plusOne = try! interpreter.eval(string: "curry(1, op: add)")! */
/* let p = try! interpreter.eval(string: "fff(xxx)", replace: ["fff": plusOne, "xxx": m])! */
/* let mulTwo = try! interpreter.eval(string: "curry(2, op: mul)")! */
/* [> let foo = try! interpreter.eval( <] */
/* [>                 string: "sub(f(yyy), g(xxx))", <] */
/* [>                 replace: ["f": plusOne, "g": mulTwo, "xxx": n, "yyy": m] <] */
/* [>                 )! <] */
/* [>  <] */
/* dumper.dump(ast: interpreter.astContext.modules[0]) */
/* dumper.dump(ast: owo) */
/* dumper.dump(ast: p) */
/* dumper.dump(ast: foo) */
/* [> dumper.dump(ast: bar) <] */
/* [> dumper.dump(ast: bar) <] */
/* [> dumper.dump(ast: foo) <] */
/* [> [>  <] <] */
