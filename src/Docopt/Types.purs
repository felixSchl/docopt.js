module Docopt.Types where

import Prelude
import Data.Either
import Data.Maybe
import Data.List
import Data.Foldable (intercalate)
import Data.Monoid (Monoid)
import Data.String (fromChar)
import Control.Apply ((*>))

type Name = String
type IsRepeatable = Boolean
type IsOptional = Boolean
type TakesArgument = Boolean
type Flag = Char

data Program = Program (List Application)
data Application = Application (List Branch)
data Branch = Branch (List Argument)
data Argument
  = Command     String
  | Positional  String IsRepeatable
  | Option      (Maybe Flag)
                (Maybe Name)
                (Maybe OptionArgument)
                IsRepeatable
  | Group       IsOptional (List Branch) IsRepeatable
  | EOA

data OptionArgument = OptionArgument Name (Maybe Value)

data Value
  = StringValue String
  | BoolValue   Boolean
  | ArrayValue  (Array Value)

--------------------------------------------------------------------------------
-- Instances -------------------------------------------------------------------
--------------------------------------------------------------------------------

instance showApplication :: Show Application where
  show (Application xs) = "Application " ++ show (show <$> xs)

instance eqApplication :: Eq Application where
  eq (Application xs) (Application ys) = xs == ys

instance showBranch :: Show Branch where
  show (Branch xs) = "Branch " ++ show (show <$> xs)

instance eqBranch :: Eq Branch where
  eq (Branch xs) (Branch xs') = (xs == xs')

instance showArgument :: Show Argument where
  show (EOA) = "--"
  show (Command n)
    = intercalate " " [ "Command", show n ]
  show (Positional n r)
    = intercalate " " [ "Positional", show n, show r ]
  show (Group o bs r) 
    = intercalate " " [ "Group", show o, show bs, show r ]
  show (Option f n a r)
    = intercalate " " [ "Option", show f, show n, show a, show r ]

instance eqArgument :: Eq Argument where
  eq (EOA)            (EOA)                = true
  eq (Command n)      (Command n')         = (n == n')
  eq (Positional n r) (Positional n' r')   = (n == n') && (r == r')
  eq (Group o bs r)   (Group o' bs' r')    = (o == o') && (bs == bs') && (r == r')
  eq (Option f n a r) (Option f' n' a' r') = (f == f') && (n == n') && (a == a') && (r == r')

instance showOptionArgument :: Show OptionArgument where
  show (OptionArgument n a) = (show n) ++ " " ++ (show a)

instance eqOptionArgument :: Eq OptionArgument where
  eq (OptionArgument n a) (OptionArgument n' a') = (n == n') && (a == a')

instance showValue :: Show Value where
  show (StringValue s) = "StringValue " ++ s
  show (BoolValue b)   = "BoolValue "   ++ (show b)
  show (ArrayValue xs) = "ArrayValue "  ++ show (show <$> xs)

instance eqValue :: Eq Value where
  eq (ArrayValue xs) (ArrayValue xs') = (xs == xs')
  eq (StringValue s) (StringValue s') = (s == s')
  eq (BoolValue b)   (BoolValue b')   = (b == b')
  eq _               _                = false

instance semigroupApplication :: Semigroup Application where
  append (Application xs) (Application ys) = Application (xs <> ys)

instance monoidApplication :: Monoid Application where
  mempty = Application Nil

--------------------------------------------------------------------------------
-- Errors (XXX: needs migration and improvement) -------------------------------
--------------------------------------------------------------------------------

import qualified Text.Parsing.Parser as P

data SolveError = SolveError

instance showSolveError :: Show SolveError where
  show SolveError = "SolveError"

data DocoptError
  = DocoptScanError   P.ParseError
  | DocoptParseError  P.ParseError
  | DocoptSolveError  SolveError

instance showDocoptError :: Show DocoptError where
  show (DocoptScanError err)  = "DocoptScanError "  ++ show err
  show (DocoptParseError err) = "DocoptParseError " ++ show err
  show (DocoptSolveError err) = "DocoptSolveError"  ++ show err

--------------------------------------------------------------------------------
-- Utilities
--------------------------------------------------------------------------------

isRepeatable :: Argument -> Boolean
isRepeatable (Option _ _ _ r) = r
isRepeatable (Positional _ r) = r
isRepeatable _                = false

hasDefault :: Argument -> Boolean
hasDefault (Option _ _ (Just (OptionArgument _ (Just _))) _) = true
hasDefault _                                                 = false

takesArgument :: Argument -> Boolean
takesArgument (Option _ _ (Just _) _) = true
takesArgument _                       = false

isFlag :: Argument -> Boolean
isFlag (Option _ _ (Just (OptionArgument _ (Just (BoolValue _)))) _) = true
isFlag _                                                             = false

isSameValueType :: Value -> Value -> Boolean
isSameValueType (StringValue _) (StringValue _) = true
isSameValueType (BoolValue _)   (BoolValue _)   = true
isSameValueType _               _               = false

isBoolValue :: Value -> Boolean
isBoolValue (BoolValue _) = true
isBoolValue _             = false
