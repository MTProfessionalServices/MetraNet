#ifndef INC_MTSQLTreeParser_hpp_
#define INC_MTSQLTreeParser_hpp_

#include <antlr/config.hpp>
#include "MTSQLTreeParserTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "mtsql_tree.g" -> "MTSQLTreeParser.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "mtsql_tree.g"

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


#line 29 "MTSQLTreeParser.hpp"
class CUSTOM_API MTSQLTreeParser : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public MTSQLTreeParserTokenTypes
{
#line 109 "mtsql_tree.g"

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
      return ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(expectedType)))->add(astFactory->dupTree(cons)))))));
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
    getASTFactory()->makeASTRoot(mQueryInputs, astFactory->create(ARRAY,"ARRAY"));
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
#line 33 "MTSQLTreeParser.hpp"
public:
	MTSQLTreeParser();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return MTSQLTreeParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return MTSQLTreeParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return MTSQLTreeParser::tokenNames;
	}
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void printStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror1Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void genericSetStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  varLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<int>  elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  equalsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  gtExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  gteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  ltExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  lteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  notEqualsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  minusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  divideExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  plusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  timesExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  searchedCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  simpleCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: int  primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<int>  whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		const std::string& tmp
	);
	public: int  simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_reference(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_queryExpr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_queryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedSelectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedFromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedGroupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_queryPrimaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return returnAST;
	}
	
protected:
	ANTLR_USE_NAMESPACE(antlr)RefAST returnAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST _retTree;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 247;
#else
	enum {
		NUM_TOKENS = 247
	};
#endif
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
	static const unsigned long _tokenSet_1_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_1;
};

#endif /*INC_MTSQLTreeParser_hpp_*/
