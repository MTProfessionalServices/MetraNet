#ifndef INC_MTSQLTreeExecution_hpp_
#define INC_MTSQLTreeExecution_hpp_

#include <antlr/config.hpp>
#include "MTSQLTreeExecutionTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "mtsql_exec.g" -> "MTSQLTreeExecution.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "mtsql_exec.g"

#include "Environment.h"
#include "MTSQLAST.h"
#include "MTDec.h"
#include "MTSQLSelectCommand.h"
#include "RuntimeValueCast.h"
#include "antlr/SemanticException.hpp"
#include <iostream>

#line 20 "MTSQLTreeExecution.hpp"
class CUSTOM_API MTSQLTreeExecution : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public MTSQLTreeExecutionTokenTypes
{
#line 17 "mtsql_exec.g"

  private: RuntimeEnvironment *mEnv;
  public: void setRuntimeEnvironment(RuntimeEnvironment *env) { mEnv = env; }
private:
  Logger* mLog;
  TransactionContext* mTrans;

  std::string getFullText(RefMTSQLAST q)
  {
		std::string str = q->getText();
		str = str + (q->getHiddenAfter()==ANTLR_USE_NAMESPACE(antlr)nullToken ? "" : q->getHiddenAfter()->getText());
		return str;
  }

private: NameIDProxy mNameIDProxy;
public: 
	NameIDImpl * getNameID()
  {
    return mNameIDProxy.GetNameID();
  }
 

private: RuntimeValue mReturnValue;
public: RuntimeValue getReturnValue() const { return mReturnValue; }
public:
  
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

  void setLog(Logger * log)
  {
	mLog = log;
  }

	void setTransactionContext(TransactionContext * trans)
  {
  mTrans = trans;
  }
  
  //BP: Just to get around inheritance issues.
  //This method is never used on MTSQLTreeExecution
  private: vector<MTSQLParam> mParams;
  public: virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
  
#line 24 "MTSQLTreeExecution.hpp"
public:
	MTSQLTreeExecution();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return MTSQLTreeExecution::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return MTSQLTreeExecution::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return MTSQLTreeExecution::tokenNames;
	}
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: RuntimeValue  setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: LexicalAddressPtr  varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: RuntimeValue  expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<RuntimeValue>  localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		MTSQLSelectCommand* cmd
	);
	public: std::string  queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		MTSQLSelectCommand* cmd
	);
	public: RuntimeValue  primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<RuntimeValue>  elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: RuntimeValue  expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<RuntimeValue>  ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<RuntimeValue>  conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		RuntimeValue forWhat
	);
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

#endif /*INC_MTSQLTreeExecution_hpp_*/
