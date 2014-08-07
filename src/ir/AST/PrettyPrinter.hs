{-# LANGUAGE NamedFieldPuns #-}

{-|

Prints the source code that an "AST.AST" represents. Each node in
the abstract syntax tree has a corresponding pretty-print function
(although not all are exported)

-}

module AST.PrettyPrinter (ppExpr,ppProgram,ppParamDecl, ppFieldDecl, ppLVal, indent) where

-- Library dependencies
import Text.PrettyPrint

-- Module dependencies
import Identifiers
import Types
import AST.AST

ppClass = text "class"
ppSkip = text "()"
ppLet = text "let"
ppIn = text "in"
ppIf = text "if"
ppThen = text "then"
ppElse = text "else"
ppWhile = text "while"
ppGet = text "get"
ppNull = text "null"
ppTrue = text "true"
ppFalse = text "false"
ppNew = text "new"
ppPrint = text "print"
ppEmbed = text "embed"
ppDot = text "."
ppBang = text "!"
ppColon = text ":"
ppComma = text ","
ppSemicolon = text ";"
ppEquals = text "="
ppSpace = text " "
ppLambda = text "\\"
ppArrow = text "->"

indent = nest 2

commaSep l = cat $ punctuate (ppComma <> ppSpace) l

ppName :: Name -> Doc
ppName (Name x) = text x

ppType :: Type -> Doc
ppType = text . show

ppProgram :: Program -> Doc
ppProgram (Program (EmbedTL _ code) classDecls) = text "embed" $+$ text code $+$ text "end" $+$
                                                  vcat (map ppClassDecl classDecls)

ppClassDecl :: ClassDecl -> Doc
ppClassDecl Class {cname, fields, methods} = 
    ppClass <+> ppType cname $+$
             (indent $
                   vcat (map ppFieldDecl fields) $$
                   vcat (map ppMethodDecl methods))

ppFieldDecl :: FieldDecl -> Doc
ppFieldDecl Field {fname, ftype} = ppName fname <+> ppColon <+> ppType ftype

ppParamDecl :: ParamDecl -> Doc
ppParamDecl (Param {pname, ptype}) =  ppName pname <+> text ":" <+> ppType ptype

ppMethodDecl :: MethodDecl -> Doc
ppMethodDecl Method {mname, mtype, mparams, mbody} = 
    text "def" <+>
    ppName mname <> 
    parens (commaSep (map ppParamDecl mparams)) <+>
    text ":" <+> ppType mtype $+$
    (indent (ppExpr mbody))

isSimple :: Expr -> Bool
isSimple VarAccess {} = True
isSimple FieldAccess {target} = isSimple target
isSimple MethodCall {target} = isSimple target
isSimple MessageSend {target} = isSimple target
isSimple FunctionCall {} = True
isSimple _ = False

maybeParens :: Expr -> Doc
maybeParens e 
    | isSimple e = ppExpr e
    | otherwise  = parens $ ppExpr e

ppExpr :: Expr -> Doc
ppExpr Skip {} = ppSkip
ppExpr MethodCall {target, name, args} = 
    maybeParens target <> ppDot <> ppName name <> 
      parens (commaSep (map ppExpr args))
ppExpr MessageSend {target, name, args} = 
    maybeParens target <> ppBang <> ppName name <> 
      parens (commaSep (map ppExpr args))
ppExpr FunctionCall {name, args} = 
    ppName name <> parens (commaSep (map ppExpr args))
ppExpr Closure {eparams, body} = 
    ppLambda <> parens (commaSep (map ppParamDecl eparams)) <+> ppArrow <+> ppExpr body
ppExpr Let {decls, body} = 
    ppLet <+> vcat (map (\(Name x, e) -> text x <+> equals <+> ppExpr e) decls) $+$ ppIn $+$ 
      indent (ppExpr body)
ppExpr Seq {eseq} = braces $ vcat $ punctuate ppSemicolon (map ppExpr eseq)
ppExpr IfThenElse {cond, thn, els} = 
    ppIf <+> ppExpr cond <+> ppThen $+$
         indent (ppExpr thn) $+$
    ppElse $+$
         indent (ppExpr els)
ppExpr While {cond, body} = 
    ppWhile <+> ppExpr cond $+$
         indent (ppExpr body)
ppExpr Get {val} = ppGet <+> ppExpr val
ppExpr FieldAccess {target, name} = maybeParens target <> ppDot <> ppName name
ppExpr VarAccess {name} = ppName name
ppExpr Assign {lhs, rhs} = ppLVal lhs <+> ppEquals <+> ppExpr rhs
ppExpr Null {} = ppNull
ppExpr BTrue {} = ppTrue
ppExpr BFalse {} = ppFalse
ppExpr New {ty} = ppNew <+> ppType ty
ppExpr Print {stringLit, args} = doubleQuotes (text stringLit) <> commaSep (map ppExpr args)
ppExpr StringLiteral {stringLit} = doubleQuotes (text stringLit)
ppExpr IntLiteral {intLit} = int intLit
ppExpr RealLiteral {realLit} = double realLit
ppExpr Embed {ty, code} = ppEmbed <+> ppType ty <+> doubleQuotes (text code)
ppExpr Unary {op, operand} = ppUnary op <+> ppExpr operand
ppExpr Binop {op, loper, roper} = ppExpr loper <+> ppBinop op <+> ppExpr roper
ppExpr TypedExpr {body, ty} = ppExpr body <+> ppColon <+> ppType ty

ppUnary :: Op -> Doc
ppUnary Identifiers.NOT = text "!"

ppBinop :: Op -> Doc
ppBinop Identifiers.AND = text "&&"
ppBinop Identifiers.OR = text "||"
ppBinop Identifiers.LT  = text "<"
ppBinop Identifiers.GT  = text ">"
ppBinop Identifiers.EQ  = text "=="
ppBinop Identifiers.NEQ = text "!="
ppBinop Identifiers.PLUS  = text "+"
ppBinop Identifiers.MINUS = text "-"
ppBinop Identifiers.TIMES  = text "*"
ppBinop Identifiers.DIV = text "/"
ppBinop Identifiers.MOD = text "%"

ppLVal :: LVal -> Doc
ppLVal LVal {lname = (Name x)}  = text x
ppLVal LField {ltarget, lname = Name f} = maybeParens ltarget <> ppDot <> text f