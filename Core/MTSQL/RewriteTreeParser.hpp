#ifndef INC_RewriteTreeParser_hpp_
#define INC_RewriteTreeParser_hpp_

#include <antlr/config.hpp>
#include "RewriteTreeParserTokenTypes.hpp"
/* $ANTLR 2.7.6 (2005-12-22): "rewrite_query.g" -> "RewriteTreeParser.hpp"$ */
#include <antlr/TreeParser.hpp>

#line 1 "rewrite_query.g"

#include "RuntimeValue.h"
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTSQLException.h"
#include "MTSQLSemanticException.h"
#include "antlr/SemanticException.hpp"
#include <stdio.h>

#line 20 "RewriteTreeParser.hpp"
class CUSTOM_API RewriteTreeParser : public ANTLR_USE_NAMESPACE(antlr)TreeParser, public RewriteTreeParserTokenTypes
{
#line 20 "rewrite_query.g"

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
	throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
  }

  public:  virtual void initialize(const std::string& tempTableName, const std::string& tagName)
  {
    mNextAlias = 0;
    // Trim whitespace of the beginning and end of the table name.
    std::string::size_type fpos = tempTableName.find_first_not_of("\n\t\r ");
    if(fpos == std::string::npos) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Argument table name must be non-empty");
    std::string::size_type lpos = tempTableName.find_last_not_of("\n\t\r ");
    if(lpos == std::string::npos) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Argument table name must be non-empty");
    mTempTableName = tempTableName.substr(fpos, lpos-fpos+1);
    // Append the uniquifying tag (e.g. pluginname_hostname)
    mTempTableName += "_";
    mTempTableName += tagName;
  }
  private: int mNextAlias;
  private: std::stack<int> mNesting;
  private: std::string getCurrentAlias()
  {
    char buf[32];
    sprintf(buf, "%d", mNesting.top());
    return std::string("tmp") + std::string(buf);
  }

  private: std::string mTempTableName;
  public: virtual std::string getTempTableName()
  {
    return mTempTableName;
  }
  public: bool isTempTable()
  {
    // If the first non-whitespace character is # then
    // we have a temp table (SQL Server only).
    return getTempTableName()[0] == '#' ? true : false;
  }

  private: void pushNestingLevel()
  {
    mNesting.push(mNextAlias++);
  }
  private: void popNestingLevel()
  {
    mNesting.pop();
  }

  // 
  private: ANTLR_USE_NAMESPACE(antlr)RefAST mWhereClause;
  private: void pushWhereClause(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  {
    if(mWhereClause == ANTLR_USE_NAMESPACE(antlr)RefAST(NULL))
    {
      mWhereClause = ast;
    }
    else
    {
      mWhereClause = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(LAND," AND "))->add(mWhereClause)->add(ast)));
    }
  }

  private: ANTLR_USE_NAMESPACE(antlr)RefAST getWhereClause()
  {
    return mWhereClause;
  }
 
  private: void clearWhereClause()
  {
    mWhereClause = ANTLR_USE_NAMESPACE(antlr)RefAST(NULL);
  }

  private: map<int, int> mAggregateCount;
  private: void incrementAggregateCount()
  {
    mAggregateCount[mNesting.top()]++;
  }
  private: int getAggregateCount()
  {
    return mAggregateCount[mNesting.top()];
  }

  private: map<int, int> mSelectListExprCount;
  private: void incrementSelectListExprCount()
  {
    mSelectListExprCount[mNesting.top()]++;
  }
  private: int getSelectListExprCount()
  {
    return mSelectListExprCount[mNesting.top()];
  }

  // Variable Management (symbol tables are needed for datatypes)
  public: void setEnvironment(Environment * env)
  {
    mEnv = env;
  }
  private: Environment* mEnv;
  private: std::map<std::string, VarEntryPtr> mVariables;

  private: void referenceVariable(RefMTSQLAST ast)
  {
    if(mVariables.find(ast->getText()) == mVariables.end())
    {
      VarEntryPtr vep = mEnv->lookupVar(ast->getText());
      if (VarEntryPtr() == vep) throw MTSQLSemanticException("Undefined Variable: " + ast->getText(), ast);
      mVariables[ast->getText()] = vep;
    }
  }

  public: std::vector<std::string> getVariables()
  {
    std::vector<std::string> v;
    for(std::map<std::string, VarEntryPtr>::iterator it = mVariables.begin(); it != mVariables.end(); it++)
    {
      v.push_back(it->first);
    }
    return v;
  }

  private: std::string getType(int type)
  {
    switch(type)
    {
       case RuntimeValue::TYPE_INTEGER:
       return "INTEGER";
       case RuntimeValue::TYPE_BIGINTEGER:
       return "BIGINT";
       case RuntimeValue::TYPE_DOUBLE:
       return "DOUBLE PRECISION";
       case RuntimeValue::TYPE_STRING:
       return "VARCHAR(256)";
       case RuntimeValue::TYPE_WSTRING:
       return "NVARCHAR(256)";
       case RuntimeValue::TYPE_DECIMAL:
       return "DECIMAL(22,10)";
       case RuntimeValue::TYPE_BOOLEAN:
       return "CHAR(1)";
       case RuntimeValue::TYPE_DATETIME:
       return "DATETIME";
       case RuntimeValue::TYPE_TIME:
       return "DATETIME";
       case RuntimeValue::TYPE_ENUM:
       return "INTEGER";
       default:
       throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
    }
  }

  private: std::string getTempColumn(const std::string& param)
  {
    // Remove the leading @ and then tack on some stuff that
    // will be unique for the temp table (we don't want to have
    // temp table columns with the same name as base tables because
    // this would force us to create aliases for base tables).
    return param.substr(1, param.length()-1) + "$#";
  }

  private: std::vector<VarEntryPtr> mOutputVariables;
  private: void pushOutput(ANTLR_USE_NAMESPACE(antlr)RefAST ast)
  {
    VarEntryPtr vep = mEnv->lookupVar(((RefMTSQLAST) ast)->getText());
    mOutputVariables.push_back(vep);
  }
  public: virtual void getTempTable(std::string& buf, std::string& insert, std::vector<VarEntryPtr>& params, std::vector<VarEntryPtr>& outputs)
  {
    outputs = mOutputVariables;
    std::string values;
    buf.append("if object_id('");
    if(isTempTable()) buf.append("tempdb..");
    buf.append(getTempTableName() + "') is not null\n  DROP TABLE " + getTempTableName());
    buf.append("\nCREATE TABLE " + getTempTableName() +  " (");
    insert.append("INSERT INTO " + getTempTableName() +  " (");
    values.append(" VALUES (");
    int pos = 0;
    for(std::map<std::string, VarEntryPtr>::iterator it = mVariables.begin(); it != mVariables.end(); it++ )
    {
      if(pos != 0)
      {
        buf.append(", ");
        insert.append(", ");
        values.append(", ");
      }
      params.push_back(it->second);
      buf.append(getTempColumn(it->first));
      buf.append(" ");
      buf.append(getType(it->second->getType()));
      insert.append(getTempColumn(it->first));
	    char buf2 [32];
	    sprintf(buf2, "%%%%%d%%%%", pos);
      values.append(buf2);
      pos++;
    }
    if(pos > 0)
    {
      buf.append(", ");
    }
    buf.append("requestid INTEGER NOT NULL PRIMARY KEY");
    buf.append(")");
  
    insert.append(")");
    values.append(")");
    insert.append(values);
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
#line 24 "RewriteTreeParser.hpp"
public:
	RewriteTreeParser();
	static void initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory );
	int getNumTokens() const
	{
		return RewriteTreeParser::NUM_TOKENS;
	}
	const char* getTokenName( int type ) const
	{
		if( type > getNumTokens() ) return 0;
		return RewriteTreeParser::tokenNames[type];
	}
	const char* const* getTokenNames() const
	{
		return RewriteTreeParser::tokenNames;
	}
	public: void mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedSelectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedFromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_nestedGroupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_aggregateExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	protected: void sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void sql92_primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void program(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
	public: void wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t);
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
};

#endif /*INC_RewriteTreeParser_hpp_*/
