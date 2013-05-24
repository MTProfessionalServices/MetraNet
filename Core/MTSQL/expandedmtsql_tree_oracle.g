header {
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTSQLException.h"
#include "MTSQLSemanticException.h"
#include "RuntimeValueCast.h"
#include "SemanticException.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <boost/cstdint.hpp>
#include <boost/format.hpp>
#include "MTSQLParam.h"
  
using namespace std;

}
options {
	language= "Cpp";
}

class MTSQLOracleTreeParser extends TreeParser;

options {
	buildAST= true;
	defaultErrorHandler= false;
	importVocab=MTSQLTreeParser;
}

{
  public:
  enum BuiltinType {TYPE_INVALID=-1, TYPE_INTEGER, TYPE_DOUBLE, TYPE_STRING, TYPE_BOOLEAN, TYPE_DECIMAL, TYPE_DATETIME, TYPE_TIME, TYPE_ENUM, TYPE_WSTRING, TYPE_NULL, TYPE_BIGINTEGER, TYPE_BINARY};

  int mReturnType;
  
  int getReturnType() { return mReturnType; }

  static bool canImplicitCast(int sourceType, int targetType)
  {
    switch(sourceType)
    {
      case TYPE_INTEGER:
        return targetType == TYPE_INTEGER || targetType == TYPE_BIGINTEGER || targetType == TYPE_DECIMAL;
      case TYPE_BIGINTEGER:
        return targetType == TYPE_BIGINTEGER || targetType == TYPE_DECIMAL;
      case TYPE_NULL:
        return targetType != TYPE_INVALID;
      default:
        return sourceType == targetType;
    }
  }

  // If two BuiltinTypes are comparable, return the more general of the two
  // else return TYPE_INVALID
  static int unifyTypes(int a, int b)
  {
    if (canImplicitCast(a, b)) return b;
    if (canImplicitCast(b, a)) return a;
    return TYPE_INVALID;
  }

  int getCastTo(int type)
  {
    switch(type)
    {
      case TYPE_INTEGER:
        return CAST_TO_INTEGER;
      case TYPE_DOUBLE:
        return CAST_TO_DOUBLE;
      case TYPE_STRING:
        return CAST_TO_STRING;
      case TYPE_BOOLEAN:
        return CAST_TO_BOOLEAN;
      case TYPE_DECIMAL:
        return CAST_TO_DECIMAL;
      case TYPE_DATETIME:
        return CAST_TO_DATETIME;
      case TYPE_TIME:
        return CAST_TO_TIME;
      case TYPE_ENUM:
        return CAST_TO_ENUM;
      case TYPE_WSTRING:
        return CAST_TO_WSTRING;
      case TYPE_BIGINTEGER:
        return CAST_TO_BIGINT;
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
    }
  }

  int getPlus(int type)
  {
    switch(type)
    {
      case TYPE_INTEGER:
        return INTEGER_PLUS;
      case TYPE_DOUBLE:
        return DOUBLE_PLUS;
      case TYPE_STRING:
        return STRING_PLUS;
      case TYPE_DECIMAL:
        return DECIMAL_PLUS;
      case TYPE_WSTRING:
        return WSTRING_PLUS;
      case TYPE_BIGINTEGER:
        return BIGINT_PLUS;
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
    }
  }

  int getMinus(int type)
  {
    switch(type)
    {
      case TYPE_INTEGER:
        return INTEGER_MINUS;
      case TYPE_DOUBLE:
        return DOUBLE_MINUS;
      case TYPE_DECIMAL:
        return DECIMAL_MINUS;
      case TYPE_BIGINTEGER:
        return BIGINT_MINUS;
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non additive type to '-'");
    }
  }

  int getTimes(int type)
  {
    switch(type)
    {
      case TYPE_INTEGER:
        return INTEGER_TIMES;
      case TYPE_DOUBLE:
        return DOUBLE_TIMES;
      case TYPE_DECIMAL:
        return DECIMAL_TIMES;
      case TYPE_BIGINTEGER:
        return BIGINT_TIMES;
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non multiplicative type to '*'");
    }
  }

  int getDivide(int type)
  {
    switch(type)
    {
      case TYPE_INTEGER:
        return INTEGER_DIVIDE;
      case TYPE_DOUBLE:
        return DOUBLE_DIVIDE;
      case TYPE_DECIMAL:
        return DECIMAL_DIVIDE;
      case TYPE_BIGINTEGER:
        return BIGINT_DIVIDE;
      default:
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non multiplicative type to '/'");
    }
  }

  int getType(std::string name)
  {
	if(name == "INTEGER") return TYPE_INTEGER;
	if(name == "BIGINT") return TYPE_BIGINTEGER;
	if(name == "DOUBLE") return TYPE_DOUBLE;
	if(name == "VARCHAR") return mSupportVarchar ? TYPE_STRING : TYPE_WSTRING;
	if(name == "NVARCHAR") return TYPE_WSTRING;
	if(name == "DECIMAL") return TYPE_DECIMAL;
	if(name == "BOOLEAN") return TYPE_BOOLEAN;
	if(name == "DATETIME") return TYPE_DATETIME;
	if(name == "TIME") return TYPE_TIME;
	if(name == "ENUM") return TYPE_ENUM;
	if(name == "BINARY") return TYPE_BINARY;
	throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }

  std::string getType(int ty)
  {
	switch(ty)
    {
       case TYPE_INTEGER:
       return "INTEGER";
       case TYPE_BIGINTEGER:
       return "BIGINT";
       case TYPE_DOUBLE:
       return "DOUBLE";
       case TYPE_STRING:
       if (!mSupportVarchar)
         throw MTSQLInternalErrorException(__FILE__, __LINE__, 
               "TYPE_STRING should not be seen if VARCHAR to NVARCHAR translation is enabled");
       return "VARCHAR";
       case TYPE_WSTRING:
       return "NVARCHAR";
       case TYPE_DECIMAL:
       return "DECIMAL";
       case TYPE_BOOLEAN:
       return "BOOLEAN";
       case TYPE_DATETIME:
       return "DATETIME";
       case TYPE_TIME:
       return "TIME";
       case TYPE_ENUM:
       return "ENUM";
       case TYPE_BINARY:
       return "BINARY";
   }
	throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }

  ANTLR_USE_NAMESPACE(antlr)RefAST insertTypeConversionForConsequent(ANTLR_USE_NAMESPACE(antlr)RefAST cons, int expectedType, int type)
  {
    if (expectedType != type)
    {
      return #([EXPR], #([getCastTo(expectedType)], astFactory->dupTree(cons)));
    }
    else
    {
      return astFactory->dupTree(cons);
    }
  }

  ANTLR_USE_NAMESPACE(antlr)RefAST insertTypeConversionsForIfExpr(ANTLR_USE_NAMESPACE(antlr)RefAST ast, int expectedType, int type)
  {
    ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
    currentAST.root = astFactory->create(ast);
    currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
    
    ANTLR_USE_NAMESPACE(antlr)RefAST cond = ast->getFirstChild();
    if (cond->getType() != EXPR) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid IfBlock");
    astFactory->addASTChild(currentAST, astFactory->dupTree(cond));
    ANTLR_USE_NAMESPACE(antlr)RefAST cons = cond->getNextSibling();
    if (cons->getType() != EXPR) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid IfBlock");
    astFactory->addASTChild(currentAST, insertTypeConversionForConsequent(cons, expectedType, type));
    return currentAST.root;
  }
  
  ANTLR_USE_NAMESPACE(antlr)RefAST insertTypeConversionsForIfBlock(ANTLR_USE_NAMESPACE(antlr)RefAST ast, int r, const std::vector<int>& types)
  {
    // We have to splice in CAST anywhere necessary
    // First navigate to the consequent of the ifthenelse
    if (ast->getType() != IFBLOCK) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid IfBlock");

    ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
    currentAST.root = astFactory->create(ast);
    currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;

    // Descend into the tree cloning and adding conversions as appropriate
    ast = ast->getFirstChild();

    for(std::size_t idx = 0; idx < types.size(); idx++)
    {
      // Valid tree has IFEXPR in all but last position and has either EXPR or IFEXPR in 
      // last position.
      if ((idx+1 < types.size() && ast->getType() != IFEXPR) ||
          (idx+1 == types.size() && ast->getType() != EXPR && ast->getType() != IFEXPR)) 
        throw MTSQLInternalErrorException(__FILE__, __LINE__, "Invalid IfBlock");

      if (ast->getType() == IFEXPR)
        astFactory->addASTChild(currentAST, insertTypeConversionsForIfExpr(ast, r, types[idx]));
      else
        astFactory->addASTChild(currentAST, insertTypeConversionForConsequent(ast, r, types[idx]));        
      ast = ast->getNextSibling();
    }

    return currentAST.root;
  }

  static void checkAdditiveType(int lhs, RefMTSQLAST ast)
  {
	std::string s("non additive type");
	if (lhs != TYPE_INTEGER && lhs != TYPE_DOUBLE && lhs != TYPE_DECIMAL && lhs != TYPE_BIGINTEGER) 
    {
	  throw MTSQLSemanticException(s, ast);
	}
  }

  static void checkAdditiveTypeWithString(int lhs, RefMTSQLAST ast)
  {
	std::string s("non additive type");
	if (lhs != TYPE_INTEGER && lhs != TYPE_DOUBLE && lhs != TYPE_DECIMAL && lhs != TYPE_STRING && lhs != TYPE_WSTRING && lhs != TYPE_BIGINTEGER) 
    {
	  throw MTSQLSemanticException(s, ast);
	}
  }

  static void checkMultiplicativeType(int lhs, RefMTSQLAST ast)
  {
	if (lhs != TYPE_INTEGER && lhs != TYPE_DOUBLE && lhs != TYPE_DECIMAL && lhs != TYPE_BIGINTEGER) throw MTSQLSemanticException("non additive type", ast);
  }

  static int checkBinaryOperator(int lhs, int rhs, RefMTSQLAST ast)
  {
	if (canImplicitCast(lhs, rhs)) 
        {
          return rhs;
        }
	else if (canImplicitCast(rhs, lhs)) 
        {
          return lhs;
        }
        else 
        {
          throw MTSQLSemanticException("Binary Operator argument type mismatch error", ast);
        }
  }

  static int checkBinaryIntegerOperator(int lhs, int rhs, RefMTSQLAST ast) 
  {
	if (lhs != TYPE_INTEGER) MTSQLSemanticException("Left hand side not integer type", ast);
	if (rhs != TYPE_INTEGER) throw MTSQLSemanticException("Right hand side not integer type", ast);
	return TYPE_INTEGER;
  }

  static int checkUnaryIntegerOperator(int lhs, RefMTSQLAST ast) 
  {
	if (lhs != TYPE_INTEGER) throw MTSQLSemanticException("Unary operator argument not integer type", ast);
	return TYPE_INTEGER;
  }

  static int checkBinaryLogicalOperator(int lhs, int rhs, RefMTSQLAST ast) 
  {
	if (lhs != TYPE_BOOLEAN) throw MTSQLSemanticException("Left hand side not boolean type", ast);
	if (rhs != TYPE_BOOLEAN) throw MTSQLSemanticException("Right hand side not boolean type", ast);
	return TYPE_BOOLEAN;
  }

  static int checkUnaryLogicalOperator(int lhs, RefMTSQLAST ast)
  {
	if (lhs != TYPE_BOOLEAN) throw MTSQLSemanticException("Left hand side not boolean type", ast);
	return TYPE_BOOLEAN;
  }

  static int checkFunctionCall(FunEntryPtr fe, const std::vector<int>& typeList, RefMTSQLAST ast) 
  {
    const std::vector<int>& argType = fe->getArgType();
	if (argType.size() != typeList.size())
		{
			char buf[256];
			sprintf(buf,"Incorrect number (%d) of arguments in call to function", typeList.size()); 
			throw MTSQLSemanticException(buf, ast);
		}
	for(unsigned int i = 0; i < argType.size(); i++)
    {
       if(argType[i] != typeList[i]) throw MTSQLSemanticException("Argument type mismatch", ast);
    }

	return fe->getReturnType();
  }

  int getAssignmentToken(int ty) 
  {
	switch (ty) 
	{
	case TYPE_INTEGER:
	  return INTEGER_SETMEM;
	case TYPE_BIGINTEGER:
	  return BIGINT_SETMEM;
	case TYPE_DECIMAL:
	  return DECIMAL_SETMEM;
	case TYPE_DOUBLE:
	  return DOUBLE_SETMEM;
	case TYPE_STRING:
       if (!mSupportVarchar)
         throw MTSQLInternalErrorException(__FILE__, __LINE__, 
               "TYPE_STRING should not be seen if VARCHAR to NVARCHAR translation is enabled");
      return STRING_SETMEM;
	case TYPE_WSTRING:
	  return WSTRING_SETMEM;
	case TYPE_BOOLEAN:
	  return BOOLEAN_SETMEM;
	case TYPE_DATETIME:
	  return DATETIME_SETMEM;
	case TYPE_TIME:
	  return TIME_SETMEM;
	case TYPE_ENUM:
	  return ENUM_SETMEM;
	case TYPE_BINARY:
	  return BINARY_SETMEM;
	default:
	  throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
	}
  
	
  }

  bool canCast(int source, int target)
  {
    // TODO: For now we assume that all type casts are valid
    // I'm sure they are not!
    return true;
  }
  virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
	
private: NameIDProxy mNameID;
public: 
  NameIDImpl * getNameID()
  {
    return mNameID.GetNameID();
  }

	private:
		vector<MTSQLParam> mParams;

  class WhileContext
  {
	private: int mNumLoops;
	public: WhileContext() : mNumLoops(0) {}
	public: bool isAnalyzingWhile() { return mNumLoops > 0; }
	public: void pushAnalyzingWhile() { mNumLoops++; }
	public: void popAnalyzingWhile() 
	{ 
	  if(--mNumLoops < 0) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unbalanced WHILE loop analysis"); 
	}
  };
  WhileContext mWhileContext;

  class TempGenerator
  {
  private: int mTemp;
  private: char mBuf[256];
  public: TempGenerator() : mTemp(0) {}
  public: std::string getNextTemp()
  {
	sprintf(mBuf, "__tmp%d", mTemp++);
	return std::string(mBuf);
  }
  };
  TempGenerator mTempGen;
  Environment *mEnv;
  Logger* mLog;
  bool mSupportVarchar;


  // Tools for helping with query processing
  private: void enterQuery()
  {
    mNumInto = 0;
    mIntoAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
    mOutputVariables.clear();
    mVariables.clear();
    mQueryInputs.root = ANTLR_USE_NAMESPACE(antlr)nullAST;
    mQueryInputs.child = ANTLR_USE_NAMESPACE(antlr)nullAST;        
    getASTFactory()->makeASTRoot(mQueryInputs, #[ARRAY, "ARRAY"]);
  }

  private: int mNumInto;
  private: int mIntoIndex;
  private: ANTLR_USE_NAMESPACE(antlr)RefAST mIntoAST;
  private: void enterInto()
  {
    mNumInto++;
    mIntoIndex = 0;
  }
  private: void exitInto(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  {
    if(mNumInto == 1)
      mIntoAST = ast;
  }
  private: ANTLR_USE_NAMESPACE(antlr)RefAST getInto(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  { 
    if(mNumInto < 1) throw MTSQLSemanticException("All SELECT statments must have an INTO", (RefMTSQLAST) ast);
    ANTLR_USE_NAMESPACE(antlr)RefAST copy = getASTFactory()->dupTree(mIntoAST);
    mIntoAST = NULL;
    return copy;
  }

  private: std::vector<VarEntryPtr> mOutputVariables;
  private: void intoVariable(RefMTSQLAST ast)
  {
    // If this is the first INTO then we check that variables are defined and record the variable.
    // If this is not the first then we validate that this INTO
    // matches the first.
    if (mNumInto == 1)
    {
      VarEntryPtr vep = mEnv->lookupVar(ast->getText());
      if (VarEntryPtr() == vep) throw MTSQLSemanticException("Undefined Variable: " + ast->getText(), ast);
	  ast->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-vep->getLevel(), vep->getAccess()));
      mOutputVariables.push_back(vep);
      if (mIntoIndex+1 != mOutputVariables.size()) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Internal error processing INTO");
    }
    else
    {
      if (mNumInto < 2) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Internal error processing INTO");
      if ((unsigned int)mIntoIndex >= mOutputVariables.size()) throw MTSQLSemanticException("All INTO clauses in a SELECT query must be identical", ast);
      if (mOutputVariables[mIntoIndex] != mEnv->lookupVar(ast->getText())) throw MTSQLSemanticException("All INTO clauses in a SELECT query must be identical", ast);
    }
    mIntoIndex++; 
  }

  // Build an ANTLR AST out of the variables that are referenced.
  // This will give us easy access to the list of inputs to the query.
  ANTLR_USE_NAMESPACE(antlr)ASTPair mQueryInputs;

  private: ANTLR_USE_NAMESPACE(antlr)RefAST getQueryInputs()
  {
    return mQueryInputs.root;
  }

  private: std::map<std::string, VarEntryPtr> mVariables;
  private: void referenceVariable(RefMTSQLAST ast)
  {
    if(mVariables.find(ast->getText()) == mVariables.end())
    {
      VarEntryPtr vep = mEnv->lookupVar(ast->getText());
      if (VarEntryPtr() == vep) throw MTSQLSemanticException("Undefined Variable: " + ast->getText(), ast);
      mVariables[ast->getText()] = vep;
      // Add the variable to the list of inputs
      ANTLR_USE_NAMESPACE(antlr)RefAST ref = getASTFactory()->dup((ANTLR_USE_NAMESPACE(antlr)RefAST)ast);
	  ((RefMTSQLAST)ref)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-vep->getLevel(), vep->getAccess()));
	  switch (vep->getType()) 
	  {
		case TYPE_INTEGER:
		ref->setType(INTEGER_GETMEM);
		break;
		case TYPE_BIGINTEGER:
		ref->setType(BIGINT_GETMEM);
		break;
		case TYPE_DECIMAL:
		ref->setType(DECIMAL_GETMEM);
		break;
		case TYPE_DOUBLE:
		ref->setType(DOUBLE_GETMEM);
		break;
	    case TYPE_STRING:
		ref->setType(STRING_GETMEM);
		break;
		case TYPE_WSTRING:
		ref->setType(WSTRING_GETMEM);
		break;
		case TYPE_BOOLEAN:
		ref->setType(BOOLEAN_GETMEM);
		break;
		case TYPE_DATETIME:
		ref->setType(DATETIME_GETMEM);
		break;
		case TYPE_TIME:
		ref->setType(TIME_GETMEM);
		break;
		case TYPE_ENUM:
		ref->setType(ENUM_GETMEM);
		break;
		case TYPE_BINARY:
		ref->setType(BINARY_GETMEM);
		break;
		default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
      }
      getASTFactory()->addASTChild(mQueryInputs, ref);
    }
  }
public:
  void setSupportVarchar(bool supportVarchar)
  {
	mSupportVarchar = supportVarchar;
  }

  void setEnvironment(Environment* env) { mEnv = env; }

	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  virtual void setLog(Logger * log)
  {
	mLog = log;
  }
  
  virtual void initASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
  {
    initializeASTFactory(factory);
  }
}
sql92_tableSpecification :#(TK_JOIN sql92_tableSpecification sql92_tableSpecification sql92_joinCriteria)
  |
  #(TABLE_REF (ALIAS)? (sql92_tableHint)? (oracle_for_update_of_hint)?)
  |
  #(CROSS_JOIN sql92_tableSpecification sql92_tableSpecification)
  |
  #(GROUPED_JOIN sql92_tableSpecification RPAREN)
  |
  #(DERIVED_TABLE sql92_selectStatement RPAREN ALIAS 
  )
  ;

protected oracle_for_update_of_hint :#(TK_FOR TK_UPDATE (TK_OF ID (DOT ID)?)?)
  ;

sql92_selectStatement :(oracle_lock_statement)* sql92_querySpecification (TK_UNION (TK_ALL)? sql92_querySpecification)*
  (TK_ORDER TK_BY sql92_orderByExpression)?
  ;

protected oracle_lock_statement :#(TK_LOCK TK_TABLE ID (DOT ID)? TK_IN (ID)* TK_MODE (TK_NOWAIT)? SEMI)
  ;

// inherited from grammar MTSQLTreeParser
program :{ mReturnType = TYPE_BOOLEAN; } (typeDeclaration)* (returnsDeclaration)? #(SCOPE { mEnv->beginScope(); } statementList { mEnv->endScope(); })
	;

// inherited from grammar MTSQLTreeParser
returnsDeclaration :#(TK_RETURNS ty:BUILTIN_TYPE) { mReturnType = getType(ty->getText()); }
    ;

// inherited from grammar MTSQLTreeParser
statementList :(statement)*
	;

// inherited from grammar MTSQLTreeParser
statement :setStatement
	|
	typeDeclaration
    |
	printStatement
    |
	stringPrintStatement
    |
	wstringPrintStatement
    |
	seq
	|
    {
      enterQuery();
    }
	sql92_selectStatement
    { 
      ## = #([QUERY, "QUERY"], ##, getQueryInputs(), getInto(##)); 
    }
	|
    mtsql_selectStatement
    |
	ifStatement
	|
	listOfStatements
	| 
    returnStatement
	| 
    breakStatement
	| 
    continueStatement
	| 
    whileStatement
    |
    raiserror1Statement
    |
    raiserrorIntegerStatement
    |
    raiserrorStringStatement
    |
    raiserrorWStringStatement
    |
    raiserror2Statement
    |
    raiserror2StringStatement
    |
    raiserror2WStringStatement
	;

// inherited from grammar MTSQLTreeParser
typeDeclaration :#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE (ou:TK_OUTPUT)? ) 
		{ 
			AccessPtr varAccess(mEnv->allocateVariable(var->getText(), getType(ty->getText())));
			if (varAccess == nullAccess)
            {
              throw MTSQLSemanticException((boost::format("Undefined variable: %1%") % var->getText()).str(), (RefMTSQLAST)##);
            }
			mEnv->insertVar(
			var->getText(), 
			VarEntry::create(getType(ty->getText()), varAccess, mEnv->getCurrentLevel())); 
			//save parameter info in the vector
			if(mEnv->getCurrentLevel() == 1 /*we want to ignore local variables, is there a better way?*/)
			{
				MTSQLParam param;
				param.SetName(var->getText());
				param.SetType(getType(ty->getText()));
				if(ou.get() != 0)
					param.SetDirection(DIRECTION_OUT);
				mParams.push_back(param);
			}
		}
	;

// inherited from grammar MTSQLTreeParser
genericSetStatement {
  int r=TYPE_INVALID;
  int e=TYPE_INVALID;
}
:!
	#(a:ASSIGN r = left:varLValue e = right:expression)
	{
	  if (e != TYPE_NULL && !canImplicitCast(e, r)) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)#a);
          if (e != TYPE_NULL && e != r)
            #right = #([EXPR], #([getCastTo(r)], right));

          #genericSetStatement = #([getAssignmentToken(r)], left, right);
	}
  ;

// inherited from grammar MTSQLTreeParser
setStatement {
  int r=TYPE_INVALID;
  int e=TYPE_INVALID;
}
:genericSetStatement
	| #(INTEGER_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e) || r != TYPE_INTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(BIGINT_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e) || r != TYPE_BIGINTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(DOUBLE_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_DOUBLE) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(DECIMAL_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_DECIMAL) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(BOOLEAN_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_BOOLEAN) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(STRING_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_STRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 

		}
	| #(WSTRING_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_WSTRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(DATETIME_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_DATETIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(TIME_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_TIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(ENUM_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_ENUM) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	| #(BINARY_SETMEM r=varLValue e=expression) 
		{ 
			if ((e != TYPE_NULL && r != e)  || r != TYPE_BINARY) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)##); 
		}
	;

// inherited from grammar MTSQLTreeParser
printStatement {
	int e = TYPE_INVALID;
}
:#(TK_PRINT e = expression)
    {
	  if (e != TYPE_STRING && e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)##);
      ##->setType(e==TYPE_STRING ? STRING_PRINT : WSTRING_PRINT);
    }
	;

// inherited from grammar MTSQLTreeParser
stringPrintStatement {
	int e = TYPE_INVALID;
}
:#(STRING_PRINT e = expression)
    {
	  if (e != TYPE_STRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)##);
    }
	;

// inherited from grammar MTSQLTreeParser
wstringPrintStatement {
	int e = TYPE_INVALID;
}
:#(WSTRING_PRINT e = expression)
    {
	  if (e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)##);
    }
	;

// inherited from grammar MTSQLTreeParser
seq :#(SEQUENCE statement statement)
	;

// inherited from grammar MTSQLTreeParser
varLValue returns [int r]{
  r = TYPE_INVALID;
}
:lv:LOCALVAR 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#varLValue)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	}
	;

// inherited from grammar MTSQLTreeParser
ifStatement {
	int e = TYPE_INVALID;
}
:#(IFTHENELSE e = expression delayedStatement (delayedStatement)?) 
		{ 
			if (e != TYPE_BOOLEAN) throw MTSQLSemanticException("IF expression must be BOOLEAN type", (RefMTSQLAST)##); 
		}
	;

// inherited from grammar MTSQLTreeParser
listOfStatements :#(SLIST (statement)*)
	;

// inherited from grammar MTSQLTreeParser
delayedStatement :#(DELAYED_STMT statement)
    ;

// inherited from grammar MTSQLTreeParser
returnStatement {
  int ty;
  bool hasValue = false;
}
:!
	#(TK_RETURN (ty=e:expression
        { 
          if (!canImplicitCast(ty,mReturnType)) throw MTSQLSemanticException("RETURN type mismatch", (RefMTSQLAST)##); 
          if (ty != mReturnType)
            #e = #([EXPR], #([getCastTo(mReturnType)], e));

          hasValue = true;
        })?
        )
        {
          if(hasValue)
            #returnStatement = #([TK_RETURN], e);
          else
            #returnStatement = #([TK_RETURN]);
        }
    ;

// inherited from grammar MTSQLTreeParser
breakStatement :TK_BREAK 
	{
	  // Verify that we are inside a while statement
	  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("BREAK can only appear in WHILE loop", (RefMTSQLAST)##);
	}
    ;

// inherited from grammar MTSQLTreeParser
continueStatement :TK_CONTINUE
	{
	  // Verify that we are inside a while statement
	  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("CONTINUE can only appear in WHILE loop", (RefMTSQLAST)##);
	}
    ;

// inherited from grammar MTSQLTreeParser
whileStatement {
  int ty;
}
:#(WHILE 
	  { 
		mWhileContext.pushAnalyzingWhile(); 
	  } 
	  ty=expression delayedStatement
	) 
	{ 
	  mWhileContext.popAnalyzingWhile(); 
	  if (ty != TYPE_BOOLEAN) throw MTSQLSemanticException("WHILE expression must be BOOLEAN", (RefMTSQLAST)##);
	}
    ;

// inherited from grammar MTSQLTreeParser
raiserror1Statement {
  int ty1;
}
:#(RAISERROR1 
        ty1=expression 
        {
		  if(ty1 != TYPE_INTEGER && ty1 != TYPE_STRING && ty1 != TYPE_WSTRING) 
            throw MTSQLSemanticException("RAISERROR takes integer or string argument", (RefMTSQLAST)##); 
          ##->setType(ty1 == TYPE_INTEGER ? RAISERRORINTEGER : ty1==TYPE_STRING ? RAISERRORSTRING : RAISERRORWSTRING);
        } 
    )
    ;

// inherited from grammar MTSQLTreeParser
raiserrorIntegerStatement {
  int ty1;
}
:#(RAISERRORINTEGER
        ty1=expression 
        { 
            if(ty1 != TYPE_INTEGER) 
                throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)##); 
        } 
    )
    ;

// inherited from grammar MTSQLTreeParser
raiserrorStringStatement {
  int ty1;
}
:#(RAISERRORSTRING
        ty1=expression 
        {
			if(ty1 != TYPE_STRING) 
                throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)##); 
        } 
    )
    ;

// inherited from grammar MTSQLTreeParser
raiserrorWStringStatement {
  int ty1;
}
:#(RAISERRORWSTRING
        ty1=expression 
        {
			if(ty1 != TYPE_WSTRING) 
                throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)##); 
        } 
    )
    ;

// inherited from grammar MTSQLTreeParser
raiserror2Statement {
  int ty1;
  int ty2;
}
:#(RAISERROR2 
        ty1=expression 
        { 
            if(ty1 != TYPE_INTEGER) 
                throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)##); 
        } 
        ty2=expression 
        { 
            if(ty2 != TYPE_WSTRING && ty2 != TYPE_STRING) 
                throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)##);
        }
    )
    {
      ((RefMTSQLAST)##)->setType(ty2==TYPE_STRING ? RAISERROR2STRING : RAISERROR2WSTRING);
    }
    ;

// inherited from grammar MTSQLTreeParser
raiserror2StringStatement {
  int ty1;
  int ty2;
}
:#(RAISERROR2STRING 
        ty1=expression 
        { 
            if(ty1 != TYPE_INTEGER) 
                throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)##); 
        } 
        ty2=expression 
        { 
            if(ty2 != TYPE_STRING) 
                throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)##);
        }
    )
    ;

// inherited from grammar MTSQLTreeParser
raiserror2WStringStatement {
  int ty1;
  int ty2;
}
:#(RAISERROR2WSTRING 
        ty1=expression 
        { 
            if(ty1 != TYPE_INTEGER) 
                throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)##); 
        } 
        ty2=expression 
        { 
            if(ty2 != TYPE_WSTRING) 
                throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)##);
        }
    )
    ;

// inherited from grammar MTSQLTreeParser
elist returns [std::vector<int> v]{
	int ty;
}
:#(ELIST (ty=expression { v.push_back(ty); } (COMMA ty=expression { v.push_back(ty); })*)?)
	;

// inherited from grammar MTSQLTreeParser
expression returns [int r]{
  r = TYPE_INVALID;
}
:#(EXPR r = expr) 
	;

// inherited from grammar MTSQLTreeParser
expr returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID, e=TYPE_INVALID;
  r=TYPE_INVALID;
}
:// Bitwise
	#(BAND lhs = expr rhs = expr) { r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)##); }
	| #(BNOT lhs = expr) { r = checkUnaryIntegerOperator(lhs, (RefMTSQLAST)##); }
	| #(BOR lhs = expr rhs = expr) { r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)##); }
	| #(BXOR lhs = expr rhs = expr) { r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)##); }
	// Logical
	| #(LAND lhs = expr rhs = expression) { r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)##); }
	| #(LNOT lhs = expr) { r = checkUnaryLogicalOperator(lhs, (RefMTSQLAST)##); }
	| #(LOR lhs = expr rhs = expression) { r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)##); }
	// Comparison
	| r = equalsExpression
	| r = gtExpression
	| r = gteqExpression
	| r = ltExpression
	| r = lteqExpression
	| r = notEqualsExpression
	// null check is always boolean
    | #(ISNULL lhs = expr) { r = TYPE_BOOLEAN; }
	// Special String operators
	| #(STRING_PLUS lhs = expr rhs = expr) { if(lhs != TYPE_STRING || rhs != TYPE_STRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_STRING; }
	| #(WSTRING_PLUS lhs = expr rhs = expr) { if(lhs != TYPE_WSTRING || rhs != TYPE_WSTRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_WSTRING; }
    | #(TK_LIKE lhs = expr rhs = expr) 
    {
      if (lhs != TYPE_STRING && lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)##);
      if (rhs != TYPE_STRING && rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)##);
      if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)##);
      ##->setType(rhs == TYPE_STRING ? STRING_LIKE : WSTRING_LIKE);
      r = TYPE_BOOLEAN;
    }
    | #(STRING_LIKE lhs = expr rhs = expr) 
    {
      if (lhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)##);
      if (rhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)##);
      if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)##);
      r = TYPE_BOOLEAN;
    }
    | #(WSTRING_LIKE lhs = expr rhs = expr) 
    {
      if (lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)##);
      if (rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)##);
      if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)##);
      r = TYPE_BOOLEAN;
    }
	// Typed Arithmetic
	| #(INTEGER_MINUS lhs = expr rhs = expr) { if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER; }
	| #(INTEGER_DIVIDE lhs = expr rhs = expr)  { if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER; }
	| #(INTEGER_PLUS lhs = expr rhs = expr) { if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER; }
	| #(INTEGER_TIMES lhs = expr rhs = expr) { if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER; }
	| #(INTEGER_UNARY_MINUS lhs = expr) { if(lhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER; }
	| #(BIGINT_MINUS lhs = expr rhs = expr) { if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER; }
	| #(BIGINT_DIVIDE lhs = expr rhs = expr)  { if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER; }
	| #(BIGINT_PLUS lhs = expr rhs = expr) { if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER; }
	| #(BIGINT_TIMES lhs = expr rhs = expr) { if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER; }
	| #(BIGINT_UNARY_MINUS lhs = expr) { if(lhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER; }
	| #(DOUBLE_MINUS lhs = expr rhs = expr) { if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE; }
	| #(DOUBLE_DIVIDE lhs = expr rhs = expr) { if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE; }
	| #(DOUBLE_PLUS lhs = expr rhs = expr) { if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE; }
	| #(DOUBLE_TIMES lhs = expr rhs = expr) { if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE; }
	| #(DOUBLE_UNARY_MINUS lhs = expr) { if(lhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE; }
	| #(DECIMAL_MINUS lhs = expr rhs = expr) { if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL; }
	| #(DECIMAL_DIVIDE lhs = expr rhs = expr) { if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL; }
	| #(DECIMAL_PLUS lhs = expr rhs = expr) 
	{ 
	  if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) 
	  {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); 
	  }
	  r = TYPE_DECIMAL; 
	}
	| #(DECIMAL_TIMES lhs = expr rhs = expr) { if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL; }
	| #(DECIMAL_UNARY_MINUS lhs = expr) { if(lhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL; }
	// Generic Arithemetic
	| r = minusExpression
	| #(MODULUS lhs = expr rhs = expr) 
    {
	  if (!(lhs == TYPE_INTEGER && rhs == TYPE_INTEGER) &&
          !(lhs == TYPE_BIGINTEGER && rhs == TYPE_BIGINTEGER))
      {
		throw MTSQLSemanticException("Non integer argument to %", (RefMTSQLAST)##);
	  }
	  r = lhs; 
      ##->setType(r == TYPE_INTEGER ? INTEGER_MODULUS : BIGINT_MODULUS);
	}
	| #(INTEGER_MODULUS lhs = expr rhs = expr) 
    {
	  if (lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) 
      {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
	  }
	  r = TYPE_INTEGER; 
	}
	| #(BIGINT_MODULUS lhs = expr rhs = expr) 
    {
	  if (lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) 
      {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
	  }
	  r = TYPE_BIGINTEGER; 
	}
	| r = divideExpression
	| r = plusExpression
	| r = timesExpression
	| #(UNARY_MINUS e = expr)  
	{ 
	  r = e; 
	  checkAdditiveType(e, (RefMTSQLAST)##);  
	  if (e==TYPE_INTEGER) {
		#expr->setType(INTEGER_UNARY_MINUS);
	  } else if (e==TYPE_BIGINTEGER) {
		#expr->setType(BIGINT_UNARY_MINUS);
	  } else if (e==TYPE_DOUBLE) {
		#expr->setType(DOUBLE_UNARY_MINUS);
	  } else if (e==TYPE_DECIMAL) {
		#expr->setType(DECIMAL_UNARY_MINUS);
      } else {
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non additive type as argument to unary minus");
	  }
	}
	| #(ESEQ statement r = expr)
	// Expression
	| r = searchedCaseExpression
	| r = simpleCaseExpression
	| 
	{
	  std::vector<int> consTypes;
    }
	#(IFBLOCK ( rhs=ifThenElse { consTypes.push_back(rhs); } )+ (rhs = expression { consTypes.push_back(rhs); })?)	
	{
      unsigned int i;
      // Determine the type of the CASE expression to be the first non-NULL type
      for(i = 0; i<consTypes.size(); i++) 
      { 
        if (consTypes[i] != TYPE_NULL) 
        {
          r = consTypes[i];
          break;
        }
      }
      if (i == consTypes.size()) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)##);
	  for(i = 0; i<consTypes.size(); i++) { if(consTypes[i] != TYPE_NULL && consTypes[i] != r) throw MTSQLSemanticException("Type checking error", (RefMTSQLAST)##); }
	}
    | #(cast:TK_CAST lhs=expression ty:BUILTIN_TYPE!) 
		{ 
			r = getType(ty->getText()); 
            if (false == canCast(lhs, r)) throw MTSQLSemanticException("Cannot cast " + getType(lhs) + " to " + getType(r), (RefMTSQLAST)##);
			switch(r)
            {
				case TYPE_STRING:
				#cast->setType(CAST_TO_STRING);
                break;
				case TYPE_WSTRING:
				#cast->setType(CAST_TO_WSTRING);
                break;
				case TYPE_DECIMAL:
				#cast->setType(CAST_TO_DECIMAL);
                break;
				case TYPE_DOUBLE:
				#cast->setType(CAST_TO_DOUBLE);
                break;
				case TYPE_INTEGER:
				#cast->setType(CAST_TO_INTEGER);
                break;
				case TYPE_BIGINTEGER:
				#cast->setType(CAST_TO_BIGINT);
                break;
				case TYPE_BOOLEAN:
				#cast->setType(CAST_TO_BOOLEAN);
                break;
				case TYPE_DATETIME:
				#cast->setType(CAST_TO_DATETIME);
                break;
				case TYPE_TIME:
				#cast->setType(CAST_TO_TIME);
                break;
				case TYPE_ENUM:
				#cast->setType(CAST_TO_ENUM);
                break;
				case TYPE_BINARY:
				#cast->setType(CAST_TO_BINARY);
                break;
                default:
                throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
				break;
            }
		}
    | #(CAST_TO_STRING lhs=expression) { r = TYPE_STRING; }
    | #(CAST_TO_WSTRING lhs=expression) { r = TYPE_WSTRING; }
    | #(CAST_TO_INTEGER lhs=expression) { r = TYPE_INTEGER; }
    | #(CAST_TO_BIGINT lhs=expression) { r = TYPE_BIGINTEGER; }
    | #(CAST_TO_DECIMAL lhs=expression) { r = TYPE_DECIMAL; }
    | #(CAST_TO_DOUBLE lhs=expression) { r = TYPE_DOUBLE; }
    | #(CAST_TO_BOOLEAN lhs=expression) { r = TYPE_BOOLEAN; }
    | #(CAST_TO_DATETIME lhs=expression) { r = TYPE_DATETIME; }
    | #(CAST_TO_TIME lhs=expression) { r = TYPE_TIME; }
    | #(CAST_TO_ENUM lhs=expression) { r = TYPE_ENUM; }
    | #(CAST_TO_BINARY lhs=expression) { r = TYPE_BINARY; }
	| r = primaryExpression 
	;

// inherited from grammar MTSQLTreeParser
equalsExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(EQUALS lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #equalsExpression = #([EQUALS], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
gtExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(GT lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #gtExpression = #([GT], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
gteqExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(GTEQ lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #gteqExpression = #([GTEQ], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
ltExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(LTN lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #ltExpression = #([LTN], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
lteqExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(LTEQ lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #lteqExpression = #([LTEQ], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
notEqualsExpression returns [int ty]{
  ty = TYPE_BOOLEAN;
  int r = TYPE_INVALID;
  int lhs = TYPE_INVALID;
  int rhs = TYPE_INVALID;
}
:!
  #(NOTEQUALS lhs = left:expr rhs = right:expr) 
  { 
    r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
    if (lhs != TYPE_NULL && r != lhs)
      #left = #([getCastTo(r)], #([EXPR], left));
    if (rhs != TYPE_NULL && r != rhs)
      #right = #([getCastTo(r)], #([EXPR], right));
    #notEqualsExpression = #([NOTEQUALS], left, right);
  }
  ;

// inherited from grammar MTSQLTreeParser
plusExpression returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
  r=TYPE_INVALID;
}
:!
   #(p:PLUS lhs = left:expr rhs = right:expr) 
   { 
	  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)#p); 
	  checkAdditiveTypeWithString(lhs, (RefMTSQLAST)#p); 
	  checkAdditiveTypeWithString(rhs, (RefMTSQLAST)#p); 
          if (lhs != TYPE_NULL && r != lhs)
            #left = #([getCastTo(r)], #([EXPR], left));
          if (rhs != TYPE_NULL && r != rhs)
            #right = #([getCastTo(r)], #([EXPR], right));

          #plusExpression = #([getPlus(r)], left, right);
    }
    ;

// inherited from grammar MTSQLTreeParser
minusExpression returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
  r=TYPE_INVALID;
}
:!
   #(MINUS lhs = left:expr rhs = right:expr) 
   { 
	  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
	  checkAdditiveType(lhs, (RefMTSQLAST)##); 
	  checkAdditiveType(rhs, (RefMTSQLAST)##); 
          if (lhs != TYPE_NULL && r != lhs)
            #left = #([getCastTo(r)], #([EXPR], left));
          if (rhs != TYPE_NULL && r != rhs)
            #right = #([getCastTo(r)], #([EXPR], right));

          #minusExpression = #([getMinus(r)], left, right);
    }
    ;

// inherited from grammar MTSQLTreeParser
timesExpression returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
  r=TYPE_INVALID;
}
:!
   #(TIMES lhs = left:expr rhs = right:expr) 
   { 
	  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
	  checkMultiplicativeType(lhs, (RefMTSQLAST)##); 
	  checkMultiplicativeType(rhs, (RefMTSQLAST)##); 
          if (lhs != TYPE_NULL && r != lhs)
            #left = #([getCastTo(r)], #([EXPR], left));
          if (rhs != TYPE_NULL && r != rhs)
            #right = #([getCastTo(r)], #([EXPR], right));

          #timesExpression = #([getTimes(r)], left, right);
    }
    ;

// inherited from grammar MTSQLTreeParser
divideExpression returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
  r=TYPE_INVALID;
}
:!
   #(DIVIDE lhs = left:expr rhs = right:expr) 
   { 
	  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)##); 
	  checkMultiplicativeType(lhs, (RefMTSQLAST)##); 
	  checkMultiplicativeType(rhs, (RefMTSQLAST)##); 
          if (lhs != TYPE_NULL && r != lhs)
            #left = #([getCastTo(r)], #([EXPR], left));
          if (rhs != TYPE_NULL && r != rhs)
            #right = #([getCastTo(r)], #([EXPR], right));

          #divideExpression = #([getDivide(r)], left, right);
    }
    ;

// inherited from grammar MTSQLTreeParser
searchedCaseExpression returns [int r]{
  std::vector<int> condTypes;
  std::vector<int> consTypes;
  std::vector<int> typePair;
  std::string tmp = mTempGen.getNextTemp();
  int rhs=TYPE_INVALID;
  int e = TYPE_INVALID;
  r = TYPE_INVALID;
}
:#(
	search:SEARCHED_CASE 
    { 
		// We are converting the searched case into a simple case
		// We are doing this in the semantic analysis since we need to
		// know the type of the search expression in order to declare a
		// local temporary variable to store the search value
		#search->setType(IFBLOCK); 
	} 
    e = wk:expr! 
	(typePair = whenExpression[tmp] { condTypes.push_back(typePair[0]); consTypes.push_back(typePair[1]); } )+ 
	(rhs = expression { consTypes.push_back(rhs); })?
  	)
	{
	  unsigned int i;
	  for(i = 0; i<condTypes.size(); i++) { if(TYPE_INVALID == unifyTypes(e, condTypes[i])) throw MTSQLSemanticException("CASE condition has different incorrect type", (RefMTSQLAST)#search); }

      // Determine the type of the CASE expression to be the "maximum" of the non-NULL types
      for(i = 0; i<consTypes.size(); i++) 
      { 
        if (consTypes[i] != TYPE_NULL && r == TYPE_INVALID) 
        {
          // The first non-NULL type seen among the consequents.
          r = consTypes[i];
        }
        else if (TYPE_INVALID != unifyTypes(consTypes[i], r))
        {
          r = unifyTypes(consTypes[i], r);
        }
        else
        {
          throw MTSQLSemanticException("CASE consequent has incorrect type", (RefMTSQLAST)#search);
        }
      }
      if (r == TYPE_INVALID) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)#search);
          // Insert necessary conversions into the consequent
          #search = insertTypeConversionsForIfBlock(#search, r, consTypes);

	  // Do the tree construction but don't bother with semantic analysis, we will do a phase 2 pass
	  ## = #([ESEQ, "ESEQ"], ([SEQUENCE, "SEQUENCE"], ([TK_DECLARE, "DECLARE"], [LOCALVAR, tmp], [BUILTIN_TYPE, getType(e)]), ([ASSIGN, "ASSIGN"], [LOCALVAR, tmp], ([EXPR, "EXPR"], wk))), search);
	}
       ;

// inherited from grammar MTSQLTreeParser
simpleCaseExpression returns [int r]{
          std::vector<int> consTypes;
          bool simpleCaseHasElse = false;
          int rhs = TYPE_INVALID;
          r = TYPE_INVALID;
        }
:#(
	simple:SIMPLE_CASE
	{
	  #simple->setType(IFBLOCK);
        }
	(rhs = simpleWhenExpression { consTypes.push_back(rhs); } )+ 
	(rhs = expression { consTypes.push_back(rhs); })?
  	)
	{
          unsigned int i;
          // Determine the type of the CASE expression to be the "maximum" of the non-NULL types
          for(i = 0; i<consTypes.size(); i++) 
          { 
            if (consTypes[i] != TYPE_NULL && r == TYPE_INVALID) 
            {
              // The first non-NULL type seen among the consequents.
              r = consTypes[i];
            }
            else if (TYPE_INVALID != unifyTypes(consTypes[i], r))
            {
              r = unifyTypes(consTypes[i], r);
            }
            else
            {
              throw MTSQLSemanticException("CASE consequent has incorrect type", (RefMTSQLAST)#simple);
            }
          }
          if (r == TYPE_INVALID) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)#simple);
              
          ## = insertTypeConversionsForIfBlock(##, r, consTypes);
	}
        ;

// inherited from grammar MTSQLTreeParser
ifThenElse returns [int r]{
  r = TYPE_INVALID;
  int condTy=TYPE_INVALID;
}
:#(IFEXPR condTy = expression r = expression) 
	{ 
	  if (condTy != TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)##);
	}
	;

// inherited from grammar MTSQLTreeParser
whenExpression[const std::string& tmp] returns [std::vector<int> r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
}
:!
	#(TK_WHEN lhs = e1:expr rhs = e2:expr) 
	  {
		r.push_back(lhs);
		r.push_back(rhs);

	    // Construct the tree
        ## = #([IFEXPR, "IFEXPR"], ([EXPR, "EXPR"], ([EQUALS, "EQUALS"], [LOCALVAR, tmp], e1)), ([EXPR, "EXPR"], e2));
	  }
	;

// inherited from grammar MTSQLTreeParser
simpleWhenExpression returns [int r]{
  int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
  r = TYPE_INVALID;
}
:! #(sw:SIMPLE_WHEN lhs = e1:expr  rhs = e2:expr) 
	  {
		if(lhs!=TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)#e1); 
		r = rhs;

	    // Construct the tree
	    #simpleWhenExpression = #([IFEXPR, "IFEXPR"], ([EXPR, "EXPR"], e1), ([EXPR, "EXPR"], e2)); 
	  }
    ;

// inherited from grammar MTSQLTreeParser
primaryExpression returns [int r]{
  r = TYPE_INVALID;
  std::vector<int> v;
}
:ID 
		{ 
			// ID's are only used for function names;  I suppose we could add a function (or function pointer type)
			// but it isn't really necessary since we are only allowing ID's in method calls
			r = TYPE_INVALID; 
		}
	| NUM_INT 
		{ 
			long lVal=0;
			sscanf(##->getText().c_str(), ##->getText().size() > 2 && ##->getText()[1] == 'x' ? "%x" : "%d", &lVal);
			((RefMTSQLAST)##)->setValue(RuntimeValue::createLong(lVal)); 
	  		r = TYPE_INTEGER;
		}
	| NUM_BIGINT
		{ 
			boost::int64_t lVal=0;
                        std::stringstream sstr(##->getText().c_str());
                        if (##->getText().size() > 2 && ##->getText()[1] == 'x')
                        {
	                  sstr >> std::hex;
                        }
                        sstr >> lVal;
			((RefMTSQLAST)##)->setValue(RuntimeValue::createLongLong(lVal)); 
	  		r = TYPE_BIGINTEGER;
		}
	| NUM_FLOAT 
	{ 
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createString(##->getText().c_str()).castToDouble()); 
	  r = TYPE_DOUBLE; 
	}
	| NUM_DECIMAL 
	{ 
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createString(##->getText().c_str()).castToDec()); 
	  r = TYPE_DECIMAL; 
	}
	| STRING_LITERAL 
	{ 
      if(mSupportVarchar)
      {
	    ((RefMTSQLAST)##)->setValue(RuntimeValue::createString((##->getText().c_str()))); 
	    r = TYPE_STRING; 
      }
      else
      {
	    ((RefMTSQLAST)##)->setValue(RuntimeValue::createString((##->getText().c_str())).castToWString()); 
	    #primaryExpression->setType(WSTRING_LITERAL);
	    r = TYPE_WSTRING; 
      }
	}
	| WSTRING_LITERAL 
	{ 
      // This UTF-8 unencodes
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createWString((##->getText()))); 
	  r = TYPE_WSTRING; 
	}
	| ENUM_LITERAL 
	{ 
      // Create an enum from the string
      RuntimeValue strValue=RuntimeValue::createString((##->getText().c_str()));
      RuntimeValue enumValue;
      RuntimeValueCast::ToEnum(&enumValue, &strValue, getNameID());
	  ((RefMTSQLAST)##)->setValue(enumValue); 
	  r = TYPE_ENUM; 
	}
	| TK_TRUE 
	{ 
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createBool(true)); 
	  r = TYPE_BOOLEAN; 
	}
	| TK_FALSE 
	{ 
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createBool(false)); 
	  r = TYPE_BOOLEAN; 
	}
	| TK_NULL
	{ 
	  ((RefMTSQLAST)##)->setValue(RuntimeValue::createNull()); 
	  r = TYPE_NULL; 
	}
	| #(METHOD_CALL id:ID v = elist RPAREN) 
		{ 
			FunEntryPtr fe = mEnv->lookupFun(id->getText(), v); 
			if (FunEntryPtr() == fe) 
            {
              throw MTSQLSemanticException("Undefined function: " + id->getText(), (RefMTSQLAST)##); 
            }
			r = checkFunctionCall(fe, v, (RefMTSQLAST)##); 
			// Save the decorated name as a value
			((RefMTSQLAST)##)->setValue(RuntimeValue::createString(fe->getDecoratedName()));
		}
	| lv:LOCALVAR
	{ 
	  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
	  if (VarEntryPtr() == var) 
	  {
        throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)##);
	  }
	  r = var->getType();	
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));

	  switch (r) 
	  {
		case TYPE_INTEGER:
		#primaryExpression->setType(INTEGER_GETMEM);
		break;
		case TYPE_BIGINTEGER:
		#primaryExpression->setType(BIGINT_GETMEM);
		break;
		case TYPE_DECIMAL:
		#primaryExpression->setType(DECIMAL_GETMEM);
		break;
		case TYPE_DOUBLE:
		#primaryExpression->setType(DOUBLE_GETMEM);
		break;
		case TYPE_STRING:
		#primaryExpression->setType(STRING_GETMEM);
		break;
		case TYPE_WSTRING:
		#primaryExpression->setType(WSTRING_GETMEM);
		break;
		case TYPE_BOOLEAN:
		#primaryExpression->setType(BOOLEAN_GETMEM);
		break;
		case TYPE_DATETIME:
		#primaryExpression->setType(DATETIME_GETMEM);
		break;
		case TYPE_TIME:
		#primaryExpression->setType(TIME_GETMEM);
		break;
		case TYPE_ENUM:
		#primaryExpression->setType(ENUM_GETMEM);
		break;
		case TYPE_BINARY:
		#primaryExpression->setType(BINARY_GETMEM);
		break;
		default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
      }
	}
	| gv:GLOBALVAR
	{ 
	  VarEntryPtr var = mEnv->lookupVar(gv->getText()); 
	  if (VarEntryPtr() == var) 
	  {
        throw MTSQLSemanticException("Undefined Variable: " + gv->getText(), (RefMTSQLAST)##);
	  }
	  r = var->getType();	
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));

	  switch (r) 
	  {
		case TYPE_INTEGER:
		#primaryExpression->setType(INTEGER_GETMEM);
		break;
		case TYPE_BIGINTEGER:
		#primaryExpression->setType(BIGINT_GETMEM);
		break;
		case TYPE_DECIMAL:
		#primaryExpression->setType(DECIMAL_GETMEM);
		break;
		case TYPE_DOUBLE:
		#primaryExpression->setType(DOUBLE_GETMEM);
		break;
		case TYPE_STRING:
		#primaryExpression->setType(STRING_GETMEM);
		break;
		case TYPE_WSTRING:
		#primaryExpression->setType(WSTRING_GETMEM);
		break;
		case TYPE_BOOLEAN:
		#primaryExpression->setType(BOOLEAN_GETMEM);
		break;
		case TYPE_DATETIME:
		#primaryExpression->setType(DATETIME_GETMEM);
		break;
		case TYPE_TIME:
		#primaryExpression->setType(TIME_GETMEM);
		break;
		case TYPE_ENUM:
		#primaryExpression->setType(ENUM_GETMEM);
		break;
		case TYPE_BINARY:
		#primaryExpression->setType(BINARY_GETMEM);
		break;
		default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
      }
	}
	| igm:INTEGER_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(igm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_INTEGER; 
	}
	| bigm:BIGINT_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(bigm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_BIGINTEGER; 
	}
	| bgm:BOOLEAN_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(bgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_BOOLEAN; 
	}
	| dgm:DOUBLE_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(dgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_DOUBLE; 
	}
	| sgm:STRING_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(sgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_STRING; 
	}
	| wsgm:WSTRING_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(wsgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_WSTRING; 
	}
	| decgm:DECIMAL_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(decgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_DECIMAL; 
	}
	| dtgm:DATETIME_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(dtgm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_DATETIME; 
	}
	| tm:TIME_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(tm->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_TIME; 
	}
	| en:ENUM_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(en->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_ENUM; 
	}
	| bin:BINARY_GETMEM 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(bin->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  r = var->getType(); 
	  ((RefMTSQLAST)#primaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	  r = TYPE_BINARY; 
	}
	| r = expression
	;

// inherited from grammar MTSQLTreeParser
mtsql_selectStatement :#(QUERY sql92_selectStatement mtsql_paramList mtsql_intoList) 
  ;

// inherited from grammar MTSQLTreeParser
mtsql_paramList :#(ARRAY (mtsql_reference)*)
  ;

// inherited from grammar MTSQLTreeParser
mtsql_reference :LOCALVAR
  |INTEGER_GETMEM
  |BIGINT_GETMEM
  |DECIMAL_GETMEM
  |DOUBLE_GETMEM
  |STRING_GETMEM
  |WSTRING_GETMEM
  |BOOLEAN_GETMEM
  |DATETIME_GETMEM
  |TIME_GETMEM
  |ENUM_GETMEM  
  |BINARY_GETMEM  
  {
	  VarEntryPtr var = mEnv->lookupVar(##->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
	  ((RefMTSQLAST)##)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
  }
  ;

// inherited from grammar MTSQLTreeParser
mtsql_intoList :#(TK_INTO (mtsql_intoVarRef)+)
  ;

// inherited from grammar MTSQLTreeParser
mtsql_intoVarRef :#(INTEGER_SETMEM_QUERY mtsql_intoLValue)
  |
  #(BIGINT_SETMEM_QUERY mtsql_intoLValue)
  |
  #(DECIMAL_SETMEM_QUERY mtsql_intoLValue)
  |
  #(DOUBLE_SETMEM_QUERY mtsql_intoLValue)
  |
  #(STRING_SETMEM_QUERY mtsql_intoLValue)
  |
  #(WSTRING_SETMEM_QUERY mtsql_intoLValue)
  |
  #(BOOLEAN_SETMEM_QUERY mtsql_intoLValue)
  |
  #(DATETIME_SETMEM_QUERY mtsql_intoLValue)
  |
  #(TIME_SETMEM_QUERY mtsql_intoLValue)
  |
  #(ENUM_SETMEM_QUERY mtsql_intoLValue)
  |
  #(BINARY_SETMEM_QUERY mtsql_intoLValue)
  ;

// inherited from grammar MTSQLTreeParser
mtsql_intoLValue :lv:LOCALVAR 
	{ 
	  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)##); 
	  ((RefMTSQLAST)##)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
	}
	;

// inherited from grammar MTSQLTreeParser
sql92_orderByExpression :sql92_queryExpr (TK_ASC | TK_DESC)? (COMMA sql92_queryExpr (TK_ASC | TK_DESC)? )*
  ;

// inherited from grammar MTSQLTreeParser
sql92_querySpecification :#(TK_SELECT (TK_ALL | TK_DISTINCT)? sql92_selectList (sql92_intoList!)? sql92_fromClause 
  (sql92_whereClause)? 
  (sql92_groupByClause)?)
  ;

// inherited from grammar MTSQLTreeParser
sql92_selectList :#(SELECT_LIST (STAR | sql92_queryExpression (ALIAS)? (COMMA sql92_queryExpression (ALIAS)? )* )
  )
  ;

// inherited from grammar MTSQLTreeParser
sql92_intoList :#(TK_INTO  { enterInto(); } (sql92_intoVarRef)+) { exitInto(##); }
  ;

// inherited from grammar MTSQLTreeParser
sql92_intoVarRef :lv:LOCALVAR 
    { 
      intoVariable((RefMTSQLAST)#lv); 
      switch (mEnv->lookupVar(#lv->getText())->getType()) 
      {
			case TYPE_INTEGER:
			  ## = #([INTEGER_SETMEM_QUERY, "INTEGER_SETMEM_QUERY"], lv);
			  break;
			case TYPE_BIGINTEGER:
			  ## = #([BIGINT_SETMEM_QUERY, "BIGINT_SETMEM_QUERY"], lv);
			  break;
			case TYPE_DECIMAL:
			  ## = #([DECIMAL_SETMEM_QUERY, "DECIMAL_SETMEM_QUERY"], lv);
			  break;
			case TYPE_DOUBLE:
			  ## = #([DOUBLE_SETMEM_QUERY, "DOUBLE_SETMEM_QUERY"], lv);
			  break;
			case TYPE_STRING:
			  ## = #([STRING_SETMEM_QUERY, "STRING_SETMEM_QUERY"], lv);
			  break;
			case TYPE_WSTRING:
			  ## = #([WSTRING_SETMEM_QUERY, "WSTRING_SETMEM_QUERY"], lv);
			  break;
			case TYPE_BOOLEAN:
			  ## = #([BOOLEAN_SETMEM_QUERY, "BOOLEAN_SETMEM_QUERY"], lv);
			  break;
			case TYPE_DATETIME:
			  ## = #([DATETIME_SETMEM_QUERY, "DATETIME_SETMEM_QUERY"], lv);
			  break;
			case TYPE_TIME:
			  ## = #([TIME_SETMEM_QUERY, "TIME_SETMEM_QUERY"], lv);
			  break;
			case TYPE_ENUM:
			  ## = #([ENUM_SETMEM_QUERY, "ENUM_SETMEM_QUERY"], lv);
			  break;
			case TYPE_BINARY:
			  ## = #([BINARY_SETMEM_QUERY, "BINARY_SETMEM_QUERY"], lv);
			  break;
			default:
			  throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in query variable reference");
      }
    }
  ;

// inherited from grammar MTSQLTreeParser
sql92_fromClause :#(TK_FROM sql92_tableSpecification (COMMA sql92_tableSpecification)*
  )
  ;

// inherited from grammar MTSQLTreeParser
sql92_nestedSelectStatement :#(TK_SELECT (TK_ALL | TK_DISTINCT)? sql92_nestedSelectList sql92_nestedFromClause (sql92_whereClause)? (sql92_nestedGroupByClause)?)
  ;

// inherited from grammar MTSQLTreeParser
sql92_nestedSelectList :#(SELECT_LIST (STAR | sql92_queryExpression (ALIAS)? (COMMA sql92_queryExpression (ALIAS)?)* )
  )
  ;

// inherited from grammar MTSQLTreeParser
sql92_nestedFromClause :#(TK_FROM sql92_tableSpecification (COMMA sql92_tableSpecification)* 
  )
  ;

// inherited from grammar MTSQLTreeParser
sql92_tableHint :#(TK_WITH LPAREN (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN)
                   (COMMA (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN))*
            RPAREN)
  ;

// inherited from grammar MTSQLTreeParser
sql92_joinCriteria :#(TK_ON sql92_logicalExpression)
  ;

// inherited from grammar MTSQLTreeParser
sql92_whereClause :#(w:TK_WHERE sql92_searchCondition)
  ;

// inherited from grammar MTSQLTreeParser
sql92_groupByClause :#(TK_GROUP TK_BY sql92_queryExpr (COMMA sql92_queryExpr)* (TK_HAVING sql92_searchCondition)?) 
  ;

// inherited from grammar MTSQLTreeParser
sql92_nestedGroupByClause :#(TK_GROUP TK_BY sql92_queryExpr (COMMA sql92_queryExpr)* (TK_HAVING sql92_searchCondition)?) 
  ;

// inherited from grammar MTSQLTreeParser
sql92_searchCondition :sql92_logicalExpression
  ;

// inherited from grammar MTSQLTreeParser
sql92_logicalExpression :// Comparison
	#(EQUALS sql92_queryExpr sql92_queryExpr) 
	| #(GT sql92_queryExpr sql92_queryExpr) 
	| #(GTEQ sql92_queryExpr sql92_queryExpr) 
	| #(LTN sql92_queryExpr sql92_queryExpr) 
	| #(LTEQ sql92_queryExpr sql92_queryExpr) 
	| #(NOTEQUALS sql92_queryExpr sql92_queryExpr) 	
  |
  #(TK_LIKE sql92_queryExpr (TK_NOT)? sql92_queryExpr)
  |
  #(TK_IS sql92_queryExpr (TK_NOT)? TK_NULL)
  |
  #(TK_BETWEEN sql92_queryExpr (TK_NOT)? sql92_queryExpr TK_AND sql92_queryExpr)
  |
  #(TK_EXISTS (TK_NOT)? LPAREN sql92_nestedSelectStatement RPAREN)
  |  
  #(TK_IN sql92_queryExpr (TK_NOT)? LPAREN (sql92_nestedSelectStatement | sql92_queryExpr (COMMA sql92_queryExpr)*) RPAREN)
	// Logical
	| #(LAND sql92_logicalExpression sql92_logicalExpression) 
	| #(LNOT sql92_logicalExpression) 
	| #(LOR sql92_logicalExpression sql92_logicalExpression) 
	| #(LPAREN sql92_hackExpression RPAREN) 
  ;

// inherited from grammar MTSQLTreeParser
protected sql92_hackExpression :// The need for this is an artifact of some inconsistency in how
  // expressions are handled in the tree parsers and the parser.
  // In the parser, arithmetic expressions are a special case of 
  // logical expressions whereas in the tree parsers, logical and arithmetic
  // expressions are totally distinct.  However, the use of the construct
  // LPAREN expr RPAREN is handled in the parser and therefore treats 
  // logical and arithmetic expressions the same way.
  #(EXPR sql92_logicalExpression)
  ;

// inherited from grammar MTSQLTreeParser
sql92_elist :#(ELIST (sql92_queryExpression (COMMA sql92_queryExpression)*)?)
	;

// inherited from grammar MTSQLTreeParser
sql92_queryExpression :#(EXPR sql92_queryExpr)
  ;

// inherited from grammar MTSQLTreeParser
sql92_queryExpr :// Expression sequence
	// Bitwise
	#(BAND sql92_queryExpr sql92_queryExpr) 
	| #(BNOT sql92_queryExpr) 
	| #(BOR sql92_queryExpr sql92_queryExpr) 
	| #(BXOR sql92_queryExpr sql92_queryExpr) 
	// Arithmetic
	| #(MINUS sql92_queryExpr sql92_queryExpr) 
	| #(MODULUS sql92_queryExpr sql92_queryExpr) 
	| #(DIVIDE sql92_queryExpr sql92_queryExpr) 
	| #(PLUS sql92_queryExpr sql92_queryExpr) 
	| #(TIMES sql92_queryExpr sql92_queryExpr)  
	| #(UNARY_MINUS sql92_queryExpr)  
	| #(UNARY_PLUS sql92_queryExpr) 
    | #(TK_COUNT LPAREN (STAR | (TK_ALL | TK_DISTINCT)? sql92_queryExpression) RPAREN)
    | #(TK_AVG LPAREN ((TK_ALL | TK_DISTINCT)? sql92_queryExpression) RPAREN)
    | #(TK_MAX LPAREN ((TK_ALL | TK_DISTINCT)? sql92_queryExpression) RPAREN)
    | #(TK_MIN LPAREN ((TK_ALL | TK_DISTINCT)? sql92_queryExpression) RPAREN)
    | #(TK_SUM LPAREN ((TK_ALL | TK_DISTINCT)? sql92_queryExpression) RPAREN)
    | #(TK_CAST LPAREN sql92_queryExpression TK_AS sql92_builtInType RPAREN)
    | #(SIMPLE_CASE (sql92_simpleWhenExpression)+ (sql92_elseExpression)? TK_END)
    | #(SEARCHED_CASE sql92_queryExpr (sql92_whenExpression)+ (sql92_elseExpression)? TK_END)
	// Expression
	| sql92_queryPrimaryExpression 
  ;

// inherited from grammar MTSQLTreeParser
protected sql92_whenExpression :#(TK_WHEN sql92_queryExpr TK_THEN sql92_queryExpr)
  ;

// inherited from grammar MTSQLTreeParser
protected sql92_simpleWhenExpression :#(SIMPLE_WHEN sql92_logicalExpression TK_THEN sql92_queryExpr)
  ;

// inherited from grammar MTSQLTreeParser
protected sql92_elseExpression :#(TK_ELSE sql92_queryExpr)
  ;

// inherited from grammar MTSQLTreeParser
sql92_queryPrimaryExpression :#(ID (DOT ID)?)
	| NUM_INT
	| NUM_BIGINT
	| NUM_FLOAT
	| NUM_DECIMAL
	| STRING_LITERAL
	| WSTRING_LITERAL
	| ENUM_LITERAL
    {
      // Create an enum value from the string.  Convert this to an integer literal.
      RuntimeValue strVal = RuntimeValue::createString((##->getText().c_str()));
      RuntimeValue enumVal;
      RuntimeValueCast::ToEnum(&enumVal, &strVal, getNameID());
      enumVal = enumVal.castToLong();
	  ((RefMTSQLAST)##)->setValue(enumVal); 
      ((RefMTSQLAST)##)->setText(enumVal.castToString().getStringPtr());
      ((RefMTSQLAST)##)->setType(NUM_INT);
    }
	| #(METHOD_CALL ID sql92_elist RPAREN) 
	| lv:LOCALVAR
    {
	  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
	  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)##); 
      referenceVariable((RefMTSQLAST)#lv);
	  ((RefMTSQLAST)#sql92_queryPrimaryExpression)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
    }
    | #(LPAREN sql92_queryExpression RPAREN)
    | #(SCALAR_SUBQUERY sql92_selectStatement RPAREN)
	;

// inherited from grammar MTSQLTreeParser
sql92_builtInType :#(BUILTIN_TYPE (TK_PRECISION)? (LPAREN NUM_INT (COMMA NUM_INT)? RPAREN)?)
   ;


