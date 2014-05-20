{-|

Types for different kinds of identifiers

-}

module Identifiers where

-- | An identifier of a variable, a method, a parameter, etc.
newtype Name = Name String deriving (Read, Eq)
instance Show Name where
  show (Name n) = n

thisName :: Name
thisName = Name "this"

-- | A type identifier
newtype Type = Type String deriving (Read, Eq)
instance Show Type where
  show (Type t) = t

newtype ParamDecl = Param (Name, Type) deriving(Read, Show, Eq)

-- | Used to give types to AST nodes during parsing (i.e. before
-- typechecking)
emptyType :: Type
emptyType = Type "*** UN-TYPED ***"

voidType :: Type
voidType = Type "void"

isVoidType :: Type -> Bool
isVoidType = (== voidType)

nullType :: Type
nullType = Type "_NullType"

isNullType :: Type -> Bool
isNullType = (== nullType)

boolType :: Type
boolType = Type "bool"

isBoolType :: Type -> Bool
isBoolType = (== boolType)

intType :: Type
intType = Type "int"

isIntType :: Type -> Bool
isIntType = (== intType)

stringType :: Type
stringType = Type "string"

isStringType :: Type -> Bool
isStringType = (== stringType)

primitives :: [Type]
primitives = [voidType, intType, boolType, stringType]

isPrimitive :: Type -> Bool
isPrimitive = flip elem primitives

-- | The supported (infix) operators
data Op = LT | GT | EQ | NEQ | PLUS | MINUS | TIMES | DIV deriving(Read, Eq)
instance Show Op where
    show Identifiers.LT = "<"
    show Identifiers.GT = ">"
    show Identifiers.EQ = "="
    show NEQ            = "!="
    show PLUS           = "+"
    show MINUS          = "-"
    show TIMES          = "*"
    show DIV            = "/"
