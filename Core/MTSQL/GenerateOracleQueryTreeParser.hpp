#ifndef INC_GenerateOracleQueryTreeParser_hpp_
#define INC_GenerateOracleQueryTreeParser_hpp_

#include <antlr/config.hpp>
#include "GenerateOracleQueryTreeParserTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "expandedgenerate_query_oracle.g" -> "GenerateOracleQueryTreeParser.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "expandedgenerate_query_oracle.g"

#include "MTSQLAST.h"
#include "RuntimeValue.h"
#include "Environment.h"
#include "MTSQLException.h"
#include <MTUtil.h>
#include "TokenStreamHiddenTokenFilter.hpp"

#line 19 "GenerateOracleQueryTreeParser.hpp"
class CUSTOM_API GenerateOracleQueryTreeParser : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public GenerateOracleQueryTreeParserTokenTypes
{
#line 22 "expandedgenerate_query_oracle.g"

  static int getType(std::string name)
  {
	if(name == "INTEGER") return RuntimeValue::TYPE_INTEGER;
	if(name == "BIGINT") return RuntimeValue::TYPE_BIGINTEGER;
	if(name == "DOUBLE") return RuntimeValue::TYPE_DOUBLE;
	if(name == "VARCHAR") return RuntimeValue::TYPE_STRING;
	if(name == "NVARCHAR") return RuntimeValue::TYPE_WSTRING;
	if(name == "DECIMAL") return RuntimeValue::TYPE_DECIMAL;
	if(name == "BOOLEAN") return RuntimeValue::TYPE_BOOLEAN;
	if(name == "DATETIME") return RuntimeValue::TYPE_DATETIME;
	if(name == "TIME") return RuntimeValue::TYPE_TIME;
	if(name == "ENUM") return RuntimeValue::TYPE_ENUM;
	if(name == "BINARY") return RuntimeValue::TYPE_BINARY;
	throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }

  private: Environment* mEnv;
  public: void setEnvironment(Environment* env) { mEnv = env; }

  private: std::vector<std::string> mQueryParameters;
  private: void prepareBuffer(RefMTSQLAST ast, int pos, char * buf)
  {
        VarEntryPtr vep = mEnv->lookupVar(((RefMTSQLAST)ast)->getText());
        if(VarEntryPtr() == vep) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Undefined variable '" + ((RefMTSQLAST)ast)->getText() + "' in query processing");
        if(vep->getType() == RuntimeValue::TYPE_STRING)
        {
          sprintf(buf, "'%%%%%d%%%%'", pos);
        }
        else if(vep->getType() == RuntimeValue::TYPE_WSTRING)
        {
          sprintf(buf, "N'%%%%%d%%%%'", pos);
        }
        else
        {
          sprintf(buf, "%%%%%d%%%%", pos);
        }
  }
  private: void printLocalvarNode(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  {
    char buf [32];
    for(unsigned int i=0; i<mQueryParameters.size(); i++)
    {
      if(mQueryParameters[i] == ((RefMTSQLAST)ast)->getText())
      {
        prepareBuffer((RefMTSQLAST)ast, i, buf);
        break;
      }
    }
    if(i==mQueryParameters.size())
    {
      prepareBuffer((RefMTSQLAST)ast, i, buf);
      mQueryParameters.push_back(((RefMTSQLAST)ast)->getText());
    }
    ((RefMTSQLAST)ast)->setText(buf);
		return printNode(ast);
  }

  private: std::wstring mQueryString;

  public: std::wstring getQueryString()
  {
    return mQueryString;
  }

  private: std::wstring getFullText(RefMTSQLAST ast)
  {
    std::string text;
    std::wstring widetext;
    text = ast->getText() + (ANTLR_USE_NAMESPACE(antlr)nullToken==ast->getHiddenAfter() ? "" : ast->getHiddenAfter()->getText()); 
    ::ASCIIToWide(widetext, (const char *)text.c_str(), -1, CP_UTF8);
    return widetext;
  }

  private: void printNode(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  {
    mQueryString += getFullText((RefMTSQLAST) ast);
  }
  private: void printString(std::wstring str)
  {
    mQueryString += str;
  }
  private: void printString(std::string str)
  {
    std::wstring widetext;
    ::ASCIIToWide(widetext, (const char *)str.c_str(), -1, CP_UTF8);
    mQueryString += widetext;
  }
  
  private: ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter* filter;
  public: ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter* getFilter()
  {
    return filter;
  }
  public: void setFilter(ANTLR_USE_NAMESPACE(antlr)TokenStreamHiddenTokenFilter* aFilter)
  {
    filter = aFilter;
  }
  
  private: Logger* mLog;
  public: virtual void setLog(Logger * log)
  {
	  mLog = log;
  }
  
  private: vector<MTSQLParam> mParams;
  public: virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
	
	virtual void initASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
  {
    initializeASTFactory(factory);
  }
 
  
#line 23 "GenerateOracleQueryTreeParser.hpp"
public:
	GenerateOracleQueryTreeParser();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return GenerateOracleQueryTreeParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return GenerateOracleQueryTreeParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return GenerateOracleQueryTreeParser::tokenNames;
	}
	public: void sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void oracle_for_update_of_hint(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_methodCall(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void oracle_CharIndex(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void oracle_Log(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void oracle_lock_statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
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
	static const unsigned long _tokenSet_2_data_[];
	static const ANTLR_USE_NAMESPACE(antlr)BitSet _tokenSet_2;
};

#endif /*INC_GenerateOracleQueryTreeParser_hpp_*/
