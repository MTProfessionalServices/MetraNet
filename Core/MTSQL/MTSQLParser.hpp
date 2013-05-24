#ifndef INC_MTSQLParser_hpp_
#define INC_MTSQLParser_hpp_

#include <antlr/config.hpp>
/* $ANTLR 2.7.6 (2005-12-22): "mtsql_parser.g" -> "MTSQLParser.hpp"$ */
#include <antlr/TokenStream.hpp>
#include <antlr/TokenBuffer.hpp>
#include "MTSQLParserTokenTypes.hpp"
#include <antlr/LLkParser.hpp>

#line 1 "mtsql_parser.g"

#include "MTSQLInterpreter.h"
#include "RecognitionException.hpp"
#include "ASTPair.hpp"
#include "ASTFactory.hpp"
#include "MTSQLSemanticException.h"
#include <boost/format.hpp>
#include <boost/algorithm/string.hpp>

#line 22 "MTSQLParser.hpp"
class CUSTOM_API MTSQLParser : public ANTLR_USE_NAMESPACE(antlr)LLkParser, public MTSQLParserTokenTypes
{
#line 69 "mtsql_parser.g"

private:
  Logger* mLog;
  bool mHasError;
  
public:
  
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
    mHasError = true;
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
    mHasError = true;
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  // Override the recover method.  In some situations, the built in
  // recover method aborts.  When a syntax error is encountered,
  // ANTLR calls reportError(), followed by recover().  With this override,
  // our custom recover() will be called which will just throw the
  // exception.  This results in MTSQLInterpreter::analyze() returning
  // null.
  virtual void recover(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex,
                       const ANTLR_USE_NAMESPACE(antlr)BitSet& tokenSet)
  {
    throw ex;  // Just give up.
  }

  void setLog(Logger * log)
  {
	mLog = log;
    mHasError = false;
  }

  bool getHasError()
  {
	return mHasError;
  }
  
  virtual void initASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
  {
    initializeASTFactory(factory);
  }
#line 26 "MTSQLParser.hpp"
public:
	void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
protected:
	MTSQLParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k);
public:
	MTSQLParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf);
protected:
	MTSQLParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k);
public:
	MTSQLParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer);
	MTSQLParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state);
	int getNumTokens() const
	{
		return MTSQLParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return MTSQLParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return MTSQLParser::tokenNames;
	}
	public: void program();
	public: void programArgList();
	public: void statementList();
	public: void returnsDecl();
	public: void builtInType();
	public: void programArgDecl();
	protected: void variableName();
	public: void statement();
	public: void setStatement();
	public: void variableDeclaration();
	public: void printStatement();
	public: void ifStatement();
	public: void statementBlock();
	public: void expression();
	public: void whileStatement();
	public: void sql92_selectStatement();
	public: void localQueryVarList();
	public: void localQueryVar();
	protected: void localvarName();
	protected: void idName();
	protected: void delayedStatement();
	public: void weakExpression();
	public: void conjunctiveExpression();
	public: void negatedExpression();
	public: void isNullExpression();
	public: void bitwiseExpression();
	public: void conditionalExpression();
	public: void additiveExpression();
	public: void multiplicativeExpression();
	public: void unaryExpression();
	public: void postfixExpression();
	public: void primaryExpression();
	public: void castExpression();
	protected: void caseExpression();
	protected: void whenExpression(
		bool simple
	);
	protected: void elseExpression();
	public: void argList();
	public: void expressionList();
	public: void sql92_queryExpression();
	public: void sql92_orderByExpression();
	public: void sql92_additiveExpression();
	public: void sql92_querySpecification();
	protected: void sql92_selectList();
	public: void sql92_intoList();
	public: void sql92_fromSpecification();
	public: void sql92_whereClause();
	public: void sql92_groupByClause();
	protected: void sql92_tableReferenceList();
	public: void sql92_weakExpression();
	protected: void sql92_groupByExpressionList();
	protected: void sql92_aliasedExpression();
	public: void sql92_expression();
	protected: void sql92_joinedTable();
	protected: void sql92_tableReference();
	protected: void sql92_joinCriteria();
	protected: void sql92_tableHint();
	protected: void oracle_for_update_of_hint();
	protected: void sql92_markedAdditiveExpression();
	public: void sql92_conjunctiveExpression();
	public: void sql92_negatedExpression();
	public: void sql92_isNullExpression();
	public: void sql92_bitwiseExpression();
	public: void sql92_conditionalExpression();
	public: void sql92_multiplicativeExpression();
	public: void sql92_unaryExpression();
	public: void sql92_postfixExpression();
	public: void sql92_primaryExpression();
	public: void sql92_argList();
	public: void sql92_castExpression();
	public: void sql92_caseExpression();
	public: void sql92_whenExpression(
		bool isSimple
	);
	public: void sql92_elseExpression();
	public: void sql92_builtInType();
	public: void sql92_expressionList();
public:
	ANTLR_USE_NAMESPACE(antlr)RefAST getAST()
	{
		return returnAST;
	}
	
protected:
	ANTLR_USE_NAMESPACE(antlr)RefAST returnAST;
private:
	static const char* tokenNames[];
#ifndef NO_STATIC_CONSTS
	static const int NUM_TOKENS = 166;
#else
	enum {
		NUM_TOKENS = 166
	};
#endif
	
	static const unsigned long _tokenSet_0_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_0;
	static const unsigned long _tokenSet_1_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_1;
	static const unsigned long _tokenSet_2_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_2;
	static const unsigned long _tokenSet_3_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_3;
	static const unsigned long _tokenSet_4_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_4;
	static const unsigned long _tokenSet_5_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_5;
	static const unsigned long _tokenSet_6_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_6;
};

#endif /*INC_MTSQLParser_hpp_*/
