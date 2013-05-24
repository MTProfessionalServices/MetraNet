#ifndef INC_MTSQLTreeCompile_hpp_
#define INC_MTSQLTreeCompile_hpp_

#include <antlr/config.hpp>
#include "MTSQLTreeCompileTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "mtsql_compile.g" -> "MTSQLTreeCompile.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "mtsql_compile.g"

#include "Environment.h"
#include "MTSQLAST.h"
#include "MTDec.h"
#include "MTSQLSelectCommand.h"
#include "RegisterMachine.h"
#include "antlr/SemanticException.hpp"
#include <iostream>

#line 20 "MTSQLTreeCompile.hpp"
class CUSTOM_API MTSQLTreeCompile : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public MTSQLTreeCompileTokenTypes
{
#line 17 "mtsql_compile.g"

  std::list<std::list<MTSQLInstruction*> *> mContinue;
  std::list<std::list<MTSQLInstruction*> *> mBreak;

  // Note that this isn't really safe if we introduce nested scopes (which don't exist today).
  private: std::map<std::string, MTSQLRegister> mLocals;
  private: void allocateRegister(const std::string& name)
  {
    mLocals[name] = allocateRegister();
  }
  private: MTSQLRegister getRegister(const std::string& name) const
  {
    return mLocals.find(name)->second;
  }
  private: std::vector<MTSQLInstruction *> mProg;
  public: std::vector<MTSQLInstruction *> getProgram() 
  { 
    return mProg; 
  }
  private: MTSQLRegister mNextRegister;
  private: MTSQLRegister allocateRegister()
  {
	return mNextRegister++;
  }
  public: int getNumRegisters() const
  {
    return mNextRegister;
  }
  private: bool isRegister(LexicalAddressPtr addr) const
  {
    return addr->getOffset() == 0;
  }
  private: MTSQLProgramLabel getNextLabel() const
  {
    return mProg.size() - 1;
  }

private:
  Logger* mLog;
  std::string mSourceCode;   // Code being compiled.  Used for error reporting
  TransactionContext* mTrans;

  std::string getFullText(RefMTSQLAST q)
  {
		std::string str = q->getText();
		str = str + (q->getHiddenAfter()==ANTLR_USE_NAMESPACE(antlr)nullToken ? "" : q->getHiddenAfter()->getText());
		return str;
  }
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

  /** 
   * Set the source code. 
   * In Compiler.cpp we set the source code in code_generate().
   * The source code is used here for error reporting only.
   */
  void setSourceCode(const char* sourceCode)
  {
    mSourceCode = sourceCode;
  }

  void initialize()
  {
    // Register 0 is reserved for return value if any.
    mNextRegister = 1;
  }
  
   //BP: Just to get around inheritance issues.
  //This method
  private: vector<MTSQLParam> mParams;
  public: virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
#line 24 "MTSQLTreeCompile.hpp"
public:
	MTSQLTreeCompile();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return MTSQLTreeCompile::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return MTSQLTreeCompile::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return MTSQLTreeCompile::tokenNames;
	}
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void localVariableDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: LexicalAddressPtr  varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		MTSQLRegister reg
	);
	public: void expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		MTSQLRegister result
	);
	public: void delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: std::vector<MTSQLRegister>  elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		MTSQLRegister result
	);
	public: void ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
		std::vector<MTSQLInstruction *>& gotos, bool& hasElse, MTSQLRegister result
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

#endif /*INC_MTSQLTreeCompile_hpp_*/
