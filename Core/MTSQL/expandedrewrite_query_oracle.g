header {
#include "RuntimeValue.h"
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTSQLException.h"
#include "MTSQLSemanticException.h"
#include "antlr/SemanticException.hpp"
#include <stdio.h>
#include <OdbcConnection.h>
#include <OdbcConnMan.h>
\#import <QueryAdapter.tlb> rename( "GetUserName", "QAGetUserName" )
\#import <mscorlib.tlb> rename ("ReportEvent", "ReportEventX") rename ("_Module", "_ModuleCorlib")
\#import <MetraTech.DataAccess.tlb> inject_statement("using namespace mscorlib;")


}
options {
	language= "Cpp";
	genHashLines= true;
}

class RewriteOracleTreeParser extends TreeParser;

options {
	buildAST= true;
	analyzerDebug= false;
	defaultErrorHandler= false;
	importVocab=RewriteTreeParser;
}

{
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
    static const std::string::size_type npos = -1;
    std::string::size_type fpos = tempTableName.find_first_not_of("\n\t\r ");
    if(fpos == npos) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Argument table name must be non-empty");
    std::string::size_type lpos = tempTableName.find_last_not_of("\n\t\r ");
    if(lpos == npos) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Argument table name must be non-empty");
    mTempTableName = tempTableName.substr(fpos, lpos-fpos+1);
    // Append the uniquifying tag (e.g. pluginname_hostname)
    mTempTableName += "_";
    mTempTableName += tagName;
    COdbcConnectionInfo stageDBInfo = COdbcConnectionManager::GetConnectionInfo("NetMeterStage");
    //stageDBInfo.GetCatalog().c_str()
    //use the hasher to get hashed table name
    MetraTech_DataAccess::IDBNameHashPtr nameHash(__uuidof(MetraTech_DataAccess::DBNameHash));
		mTempTableName = nameHash->GetDBNameHash(mTempTableName.c_str());
		//sanity check - should never be longer than 30
		if(getTempTableName().length() > 30)
    {
			char buf[512];
			sprintf(buf, "Identifer '%s' too long (%d bytes vs. maximum of 30 bytes on Oracle). Decrease stage name, plugin name or temp table prefix in plugin configuration file!", getTempTableName().c_str(), getTempTableName().length());
			throw MTSQLInternalErrorException(__FILE__, __LINE__, buf);
		}
		
		//and finally construct the fully qualified name of hashed temp table in staging database
		mTempTableTableSpaceName = stageDBInfo.GetCatalog();
    
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
		if(isTempTable() == true)
			return mTempTableName.substr(1, mTempTableName.length());
		else
			return mTempTableName;
  }
  private: std::string mTempTableTableSpaceName;
  public: virtual std::string getTempTableTableSpaceName()
  {
    if(isTempTable() == true)
      return "";
    else
      return mTempTableTableSpaceName;
  }
  
  //for convenience, full name is <tablespace>.<temptablename>
  public: virtual std::string getFullTempTableName()
  {
    if(isTempTable() == true)
			return getTempTableName();
		else
		{
			return getTempTableTableSpaceName() + "." + getTempTableName();
		}
  }
  public: bool isTempTable()
  {
    // If the first non-whitespace character is # then
    // we have a temp table (SQL Server only).
    return false;
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
      mWhereClause = #([LAND, " AND "], mWhereClause, ast);
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
       return "NUMBER(10, 0)";
       case RuntimeValue::TYPE_BIGINTEGER:
       /* TODO: Need to do some additional hacking to support 64 bit int */
       return "NUMBER(20, 0)";
       case RuntimeValue::TYPE_DOUBLE:
       /* TODO: ?? */
       return "DOUBLE PRECISION";
       case RuntimeValue::TYPE_STRING:
       return "VARCHAR2(256)";
       case RuntimeValue::TYPE_WSTRING:
       return "NVARCHAR2(256)";
       case RuntimeValue::TYPE_DECIMAL:
       return "NUMBER(22,10)";
       case RuntimeValue::TYPE_BOOLEAN:
       return "CHAR(1)";
       case RuntimeValue::TYPE_DATETIME:
       return "DATE";
       case RuntimeValue::TYPE_TIME:
       return "DATE";
       case RuntimeValue::TYPE_ENUM:
       return "NUMBER(10, 0)";
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
    if(param.length() > 27)
    {
			char buf[512];
			sprintf(buf, "Identifer '%s' too long (can not exceed 27 characters). Decrease session property name!", param.c_str());
		}
		//Oracle does not like underscore as a first character in identifier. Append "c" to it, but first cut out '@'
		string out = param.substr(1, param.length()-1);
		if(out[0] == '_')
			out = "c" + out;
		return out + "$#";
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
    buf.append("DECLARE table_exists int; \nBEGIN \ntable_exists := 0;");
    buf.append("\nselect case when (EXISTS (SELECT TABLE_NAME FROM ALL_TABLES ");
    buf.append("WHERE UPPER(TABLE_NAME) = UPPER('");
    buf.append(getTempTableName()+ "') AND UPPER(TABLESPACE_NAME) = UPPER('");
    buf.append(getTempTableTableSpaceName()+ "'))) then 1 else 0 end INTO table_exists FROM DUAL;");
    buf.append("\nIF table_exists = 1 THEN ");
    if(isTempTable() == true) //never true
    {
			buf.append("\nEXECUTE IMMEDIATE 'TRUNCATE TABLE ");
			buf.append(getTempTableName()+ "';");
		}
    buf.append("\nEXECUTE IMMEDIATE 'DROP TABLE ");
    buf.append(getFullTempTableName()+ "';");
    buf.append("\nEND IF;");
    if(isTempTable() == true)
    {
      buf.append("\nEXECUTE IMMEDIATE 'CREATE GLOBAL TEMPORARY TABLE " + getTempTableName() + " (");
    }
    else
    {
      buf.append("\nEXECUTE IMMEDIATE 'CREATE TABLE " + getFullTempTableName() + " (");
    }
    insert.append("INSERT INTO " + getFullTempTableName() +  " (");
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
    buf.append("requestid NUMBER(10, 0)");
    buf.append(")");
    if(isTempTable() == true)
      buf.append("\nON COMMIT PRESERVE ROWS'; \nEND;");
    else
      buf.append("';\nEND;");
  
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
}
sql92_tableSpecification :// We must handle the case of forced join order.
  // Example:
  // SELECT * FROM t_A INNER JOIN t_B LEFT OUTER JOIN t_C ON t_B.id_c=t_C.id_c AND t_C.foo=@foo ON t_A.id_b=t_B.id_b
  //
  // The trick here is that one has a nested scope with the join between t_B and t_C
  // and they cannot be correlated subqueries.  Therefore, we need to introduce the temp table
  // at the inner "scope":
  // SELECT * FROM t_A INNER JOIN #tmp_args tmp1 CROSS JOIN t_B LEFT OUTER JOIN t_C ON t_B.id_c=t_C.id_c AND t_C.foo=tmp1.foo ON t_A.id_b=t_B.id_b
  // Note the syntactic consideration here; since we are using SQL-92 JOIN syntax, we
  // have to specify a CROSS JOIN to get the temp table in the right place!
  #(TK_JOIN sql92_tableSpecification sql92_tableSpecification sql92_joinCriteria)
  |
  #(TABLE_REF (ALIAS)? (sql92_tableHint)?)
  |
  #(CROSS_JOIN sql92_tableSpecification sql92_tableSpecification)
  |
  // Grouped joins represent the syntatic class of joins that are regrouped with parentheses
  // (e.g. a CROSS JOIN (b CROSS JOIN c)).  These are only necessary with CROSS JOIN, but they
  // may also be used with other JOIN specifications.
  #(GROUPED_JOIN sql92_tableSpecification RPAREN)
  |
  // Derived tables are nested queries but they cannot be correlated subqueries (unlike IN,EXISTS, etc.).
  // As such, they cannot reference columns in the argument table from their containing
  // context.  They need to have their own copy of the argument table
  // against which parameters are bound.  Furthermore, the use of the
  // argument table within the derived table needs to be made consistent
  // with the argument table in the containing context via a join on the
  // requestid columns.
  // Example:
  // SELECT a.col1, foo.col3 FROM a INNER JOIN
  // (SELECT b.col2, c.col3 FROM b INNER JOIN c ON b.col4=c.col4 WHERE c.col5=@input) foo ON foo.col2=a.col2
  //
  // should be transformed to:
  //
  // SELECT a.col1, foo.col3, tmp0.requestid FROM a INNER JOIN
  // (SELECT b.col2, c.col3, tmp1.requestid FROM b INNER JOIN c ON b.col4=c.col4, #tmp_args tmp1 WHERE c.col5=tmp1.input) foo ON foo.col2=a.col2,
  // #tmp_args tmp0
  // WHERE
  // foo.requestid=tmp0.requestid
  //
  #(DERIVED_TABLE sql92_selectStatement RPAREN ALIAS 
  {
    // Use the current alias and the alias of the derived table to create the
    // join criteria.  This needs to be saved until later processing of the 
    // WHERE clause of the "containing" context.
    std::string innerColumn = #ALIAS->getText() + "." + "requestid ";
    std::string outerColumn = getCurrentAlias() + "." + "requestid ";
    ANTLR_USE_NAMESPACE(antlr)RefAST ast = #([EQUALS,"= "], [ID, innerColumn], [ID, outerColumn]);
    pushWhereClause(ast);
  }
  )
  ;

protected oracle_for_update_of_hint :#(TK_FOR TK_UPDATE (TK_OF ID (DOT ID)?)?)
  ;

sql92_fromClause :#(TK_FROM sql92_tableSpecification (COMMA sql92_tableSpecification)*
  {
    std::string alias = getCurrentAlias() + " ";
    std::string table = getFullTempTableName() + " ";
    astFactory->addASTChild(currentAST, #([COMMA, ", "]));
    astFactory->addASTChild(currentAST, #([TABLE_REF, table], ([ALIAS, alias], ##))); 
  }
  )
  ;

// inherited from grammar RewriteTreeParser
mtsql_selectStatement :#(QUERY sql92_selectStatement mtsql_paramList mtsql_intoList) 
  ;

// inherited from grammar RewriteTreeParser
mtsql_paramList :#(ARRAY (INTEGER_GETMEM|DECIMAL_GETMEM|DOUBLE_GETMEM|STRING_GETMEM|WSTRING_GETMEM|BOOLEAN_GETMEM|DATETIME_GETMEM|TIME_GETMEM|ENUM_GETMEM|BIGINT_GETMEM)*)
  ;

// inherited from grammar RewriteTreeParser
mtsql_intoList :#(TK_INTO (mtsql_intoVarRef)+)
  ;

// inherited from grammar RewriteTreeParser
mtsql_intoVarRef :#(INTEGER_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(BIGINT_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(DECIMAL_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(DOUBLE_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(STRING_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(WSTRING_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(BOOLEAN_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(DATETIME_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(TIME_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  |
  #(ENUM_SETMEM_QUERY LOCALVAR) { pushOutput(#LOCALVAR); }
  ;

// inherited from grammar RewriteTreeParser
sql92_selectStatement :sql92_querySpecification (TK_UNION (TK_ALL)? sql92_querySpecification)* 
  (TK_ORDER TK_BY sql92_orderByExpression { throw MTSQLSemanticException("ORDER BY not supported in batch queries", (RefMTSQLAST)##); })?
  ;

// inherited from grammar RewriteTreeParser
sql92_orderByExpression :sql92_expr (TK_ASC | TK_DESC)? (COMMA sql92_expr (TK_ASC | TK_DESC)? )*
  ;

// inherited from grammar RewriteTreeParser
sql92_querySpecification :{
    bool hasWhere = false;
    bool hasGroupBy = false;
    bool allAggregates = false;
    pushNestingLevel();
  }
  #(TK_SELECT (TK_ALL | TK_DISTINCT)?
    sql92_selectList
    {
      if (getAggregateCount() == getSelectListExprCount())
        allAggregates = true;
    }
    sql92_fromClause 
    (w:sql92_whereClause { hasWhere = true; })? 
    {
      if(getWhereClause() != ANTLR_USE_NAMESPACE(antlr)RefAST(NULL))
      {
        getASTFactory()->addASTChild(currentAST, #([TK_WHERE, " WHERE "], getWhereClause()));
        clearWhereClause();
      }
    }
    (sql92_groupByClause { hasGroupBy = true; })?
    {
      // adds an implicit GROUP BY for queries that don't have their own (CR10840)
      if (!hasGroupBy && allAggregates)
      {
        std::string aliasedColumn = getCurrentAlias() + ".requestid ";
        getASTFactory()->addASTChild(currentAST, #([TK_GROUP, " GROUP "], [TK_BY, " BY "], ([ID, aliasedColumn])));
      }
    }
  )
  {
    popNestingLevel();
  }
  ;

// inherited from grammar RewriteTreeParser
sql92_selectList :#(SELECT_LIST 
            (
                STAR { incrementSelectListExprCount(); } 
                |
                sql92_expression { incrementSelectListExprCount(); } (ALIAS)? 
                    (COMMA sql92_expression { incrementSelectListExprCount(); } (ALIAS)? )*
            )
  {
    std::string aliasedColumn = getCurrentAlias() + ".requestid ";
    getASTFactory()->addASTChild(currentAST, #([COMMA, ", "]));
    getASTFactory()->addASTChild(currentAST, #([EXPR, "EXPR"], ([ID, aliasedColumn], ##)));
  }
  )
  ;

// inherited from grammar RewriteTreeParser
sql92_nestedSelectStatement :#(TK_SELECT (TK_ALL | TK_DISTINCT)? sql92_nestedSelectList sql92_nestedFromClause (sql92_whereClause)? (sql92_nestedGroupByClause)?)
  ;

// inherited from grammar RewriteTreeParser
sql92_nestedSelectList :#(SELECT_LIST 
            (
                STAR { incrementSelectListExprCount(); } 
                |
                sql92_expression { incrementSelectListExprCount(); } (ALIAS)? 
                    (COMMA sql92_expression { incrementSelectListExprCount(); } (ALIAS)? )*
            )
   )
  ;

// inherited from grammar RewriteTreeParser
sql92_nestedFromClause :#(TK_FROM sql92_tableSpecification (COMMA sql92_tableSpecification)*)
  ;

// inherited from grammar RewriteTreeParser
sql92_tableHint :#(TK_WITH LPAREN (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN)
                   (COMMA (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN))*
            RPAREN)
  ;

// inherited from grammar RewriteTreeParser
sql92_joinCriteria :#(TK_ON sql92_logicalExpression)
  ;

// inherited from grammar RewriteTreeParser
sql92_whereClause! :#(w:TK_WHERE s:sql92_searchCondition)
  {
    if(getWhereClause() != ANTLR_USE_NAMESPACE(antlr)RefAST(NULL))
    {
      ## = #(w, ([LAND, " AND "], getWhereClause(), s));
      clearWhereClause();
    }
    else
    {
      ## = #(w, s);
    }
  }
  ;

// inherited from grammar RewriteTreeParser
sql92_groupByClause :#(TK_GROUP TK_BY sql92_expr (COMMA sql92_expr)*
  {
    std::string aliasedColumn = getCurrentAlias() + ".requestid ";
    getASTFactory()->addASTChild(currentAST, #([COMMA, ", "]));
    getASTFactory()->addASTChild(currentAST, #([ID, aliasedColumn]));
  }
  (TK_HAVING sql92_searchCondition)?)  
  ;

// inherited from grammar RewriteTreeParser
sql92_nestedGroupByClause :#(TK_GROUP TK_BY sql92_expr (COMMA sql92_expr)* (TK_HAVING sql92_searchCondition)?)  
  ;

// inherited from grammar RewriteTreeParser
sql92_searchCondition :sql92_logicalExpression
  ;

// inherited from grammar RewriteTreeParser
sql92_elist :#(ELIST (sql92_expression (COMMA sql92_expression)*)?)
	;

// inherited from grammar RewriteTreeParser
sql92_expression :#(EXPR sql92_expr)
  ;

// inherited from grammar RewriteTreeParser
sql92_logicalExpression :// Comparison
	#(EQUALS sql92_expr sql92_expr) 
	| #(GT sql92_expr sql92_expr) 
	| #(GTEQ sql92_expr sql92_expr) 
	| #(LTN sql92_expr sql92_expr) 
	| #(LTEQ sql92_expr sql92_expr) 
	| #(NOTEQUALS sql92_expr sql92_expr) 	
  |
  #(TK_LIKE sql92_expr (TK_NOT)? sql92_expr)
  |
  #(TK_IS sql92_expr (TK_NOT)? TK_NULL)
  |
  #(TK_BETWEEN sql92_expr (TK_NOT)? sql92_expr TK_AND sql92_expr)
  |
  #(TK_EXISTS (TK_NOT)? LPAREN sql92_nestedSelectStatement RPAREN)
  |  
  #(TK_IN sql92_expr (TK_NOT)? LPAREN (sql92_nestedSelectStatement | sql92_expr (COMMA sql92_expr)*) RPAREN)
	// Logical
	| #(LAND sql92_logicalExpression sql92_logicalExpression) 
	| #(LNOT sql92_logicalExpression) 
	| #(LOR sql92_logicalExpression sql92_logicalExpression) 
	| #(LPAREN sql92_hackExpression RPAREN) 
  ;

// inherited from grammar RewriteTreeParser
protected sql92_hackExpression :// The need for this is an artifact of some inconsistency in how
  // expressions are handled in the tree parsers and the parser.
  // In the parser, arithmetic expressions are a special case of 
  // logical expressions whereas in the tree parsers, logical and arithmetic
  // expressions are totally distinct.  However, the use of the construct
  // LPAREN expr RPAREN is handled in the parser and therefore treats 
  // logical and arithmetic expressions the same way.
  #(EXPR sql92_logicalExpression)
  ;

// inherited from grammar RewriteTreeParser
sql92_expr :// Expression sequence
	// Bitwise
	#(BAND sql92_expr sql92_expr) 
	| #(BNOT sql92_expr) 
	| #(BOR sql92_expr sql92_expr) 
	| #(BXOR sql92_expr sql92_expr) 
	// Arithmetic
	| #(MINUS sql92_expr sql92_expr) 
	| #(MODULUS sql92_expr sql92_expr) 
	| #(DIVIDE sql92_expr sql92_expr) 
	| #(PLUS sql92_expr sql92_expr) 
	| #(TIMES sql92_expr sql92_expr)  
	| #(UNARY_MINUS sql92_expr)  
	| #(UNARY_PLUS sql92_expr) 
    | #(TK_CAST LPAREN sql92_expression TK_AS sql92_builtInType RPAREN)
    | sql92_aggregateExpression { incrementAggregateCount(); }
    | #(SIMPLE_CASE (sql92_simpleWhenExpression)+ (sql92_elseExpression)? TK_END)
    | #(SEARCHED_CASE sql92_expr (sql92_whenExpression)+ (sql92_elseExpression)? TK_END)
	// Expression
	| sql92_primaryExpression 
;

// inherited from grammar RewriteTreeParser
protected sql92_aggregateExpression :#(TK_COUNT LPAREN (STAR | (TK_ALL | TK_DISTINCT)? sql92_expression) RPAREN)
  | #(TK_AVG LPAREN ((TK_ALL | TK_DISTINCT)? sql92_expression) RPAREN)
  | #(TK_MAX LPAREN ((TK_ALL | TK_DISTINCT)? sql92_expression) RPAREN)
  | #(TK_MIN LPAREN ((TK_ALL | TK_DISTINCT)? sql92_expression) RPAREN)
  | #(TK_SUM LPAREN ((TK_ALL | TK_DISTINCT)? sql92_expression) RPAREN)
;

// inherited from grammar RewriteTreeParser
protected sql92_whenExpression :#(TK_WHEN sql92_expr TK_THEN sql92_expr)
  ;

// inherited from grammar RewriteTreeParser
protected sql92_simpleWhenExpression :#(SIMPLE_WHEN sql92_logicalExpression TK_THEN sql92_expr)
  ;

// inherited from grammar RewriteTreeParser
protected sql92_elseExpression :#(TK_ELSE sql92_expr)
  ;

// inherited from grammar RewriteTreeParser
sql92_builtInType :#(BUILTIN_TYPE (TK_PRECISION)? (LPAREN NUM_INT (COMMA NUM_INT)? RPAREN)?)
   ;

// inherited from grammar RewriteTreeParser
sql92_primaryExpression :#(ID (DOT ID)?)
	| NUM_INT
	| NUM_BIGINT
	| NUM_FLOAT
	| NUM_DECIMAL
	| STRING_LITERAL
	| WSTRING_LITERAL
	| #(METHOD_CALL ID sql92_elist RPAREN) 
	| lv:LOCALVAR
        {
          referenceVariable((RefMTSQLAST) #lv);
          #lv->setType(ID);
          #lv->setText(getCurrentAlias() + "." + getTempColumn(#lv->getText()));
        }
	| INTEGER_GETMEM 
	| BIGINT_GETMEM 
	| DOUBLE_GETMEM 
	| DECIMAL_GETMEM 
	| BOOLEAN_GETMEM 
	| STRING_GETMEM 
	| WSTRING_GETMEM 
    | #(LPAREN sql92_expression RPAREN)
    | #(SCALAR_SUBQUERY sql92_nestedSelectStatement RPAREN)
	;

// inherited from grammar RewriteTreeParser
program :(typeDeclaration)* 
	#(SCOPE { mEnv->beginScope(); } 
	  statementList { mEnv->endScope(); }
	)
	;

// inherited from grammar RewriteTreeParser
statementList :(statement)*
	;

// inherited from grammar RewriteTreeParser
statement :setStatement 
	|
	typeDeclaration
	|
    stringPrintStatement
	|
    wstringPrintStatement
    |
	seq
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
    raiserrorStringStatement
  |
    raiserrorWStringStatement
  |
    raiserrorIntegerStatement
  |
    raiserror2StringStatement
  |
    raiserror2WStringStatement
  |
  mtsql_selectStatement
	;

// inherited from grammar RewriteTreeParser
typeDeclaration :#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE) 
	{ 
			
		mEnv->insertVar(
		var->getText(), 
		VarEntry::create(getType(ty->getText()), mEnv->allocateVariable(var->getText(), getType(ty->getText())), mEnv->getCurrentLevel())); 
	}
	;

// inherited from grammar RewriteTreeParser
setStatement :#(INTEGER_SETMEM varAddress expression) 
	| #(BIGINT_SETMEM varAddress expression) 
	| #(DOUBLE_SETMEM varAddress expression) 
	| #(DECIMAL_SETMEM varAddress expression) 
	| #(BOOLEAN_SETMEM varAddress expression) 
	| #(STRING_SETMEM varAddress expression) 
	| #(WSTRING_SETMEM varAddress expression) 
	| #(DATETIME_SETMEM varAddress expression) 
	| #(TIME_SETMEM varAddress expression) 
	| #(ENUM_SETMEM varAddress expression) 
	;

// inherited from grammar RewriteTreeParser
varAddress :l:LOCALVAR 
	;

// inherited from grammar RewriteTreeParser
stringPrintStatement :#(STRING_PRINT expr)
	;

// inherited from grammar RewriteTreeParser
wstringPrintStatement :#(WSTRING_PRINT expr)
	;

// inherited from grammar RewriteTreeParser
seq :#(SEQUENCE statement statement)
	;

// inherited from grammar RewriteTreeParser
queryStatement :#(QUERY 
	localParamList 
    queryString 
    localQueryVarList 
    )
	;

// inherited from grammar RewriteTreeParser
queryString {
}
:#(QUERYSTRING (.)+)
    ;

// inherited from grammar RewriteTreeParser
localQueryVarList :setmemQuery
	;

// inherited from grammar RewriteTreeParser
setmemQuery :#(ARRAY  ( 
	#(INTEGER_SETMEM_QUERY varAddress) 
	| #(BIGINT_SETMEM_QUERY varAddress) 
	| #(DOUBLE_SETMEM_QUERY varAddress) 
	| #(DECIMAL_SETMEM_QUERY varAddress) 
	| #(BOOLEAN_SETMEM_QUERY varAddress) 
	| #(STRING_SETMEM_QUERY varAddress) 
	| #(WSTRING_SETMEM_QUERY varAddress) 
	| #(DATETIME_SETMEM_QUERY varAddress) 
	| #(TIME_SETMEM_QUERY varAddress) 
	| #(ENUM_SETMEM_QUERY varAddress) 
	  )*
	)
    ;

// inherited from grammar RewriteTreeParser
localParamList :#(ARRAY (primaryExpression)*)
    ;

// inherited from grammar RewriteTreeParser
ifStatement :#(IFTHENELSE expression delayedStatement (delayedStatement)? )
    ;

// inherited from grammar RewriteTreeParser
delayedStatement :#(DELAYED_STMT statement)
	;

// inherited from grammar RewriteTreeParser
listOfStatements :#(SLIST (statement)*)
	;

// inherited from grammar RewriteTreeParser
returnStatement :#(TK_RETURN (expression)?)
	;

// inherited from grammar RewriteTreeParser
breakStatement :TK_BREAK 
    ;

// inherited from grammar RewriteTreeParser
continueStatement :TK_CONTINUE
    ;

// inherited from grammar RewriteTreeParser
whileStatement :#(WHILE expression delayedStatement) 
    ;

// inherited from grammar RewriteTreeParser
raiserrorIntegerStatement :#(RAISERRORINTEGER expression) 
    ;

// inherited from grammar RewriteTreeParser
raiserrorStringStatement :#(RAISERRORSTRING expression) 
    ;

// inherited from grammar RewriteTreeParser
raiserrorWStringStatement :#(RAISERRORWSTRING expression) 
    ;

// inherited from grammar RewriteTreeParser
raiserror2StringStatement :#(RAISERROR2STRING expression expression) 
    ;

// inherited from grammar RewriteTreeParser
raiserror2WStringStatement :#(RAISERROR2WSTRING expression expression) 
    ;

// inherited from grammar RewriteTreeParser
elist :#(ELIST (expression (COMMA expression)*)?)
	;

// inherited from grammar RewriteTreeParser
expression :#(EXPR expr) 
	;

// inherited from grammar RewriteTreeParser
expr :// Bitwise
	#(BAND expr expr) 
	| #(BNOT expr) 
	| #(BOR expr expr) 
	| #(BXOR expr expr) 
	// Logical
	| #(LAND expr expr) 
	| #(LOR expr expr) 
	| #(LNOT expr) 
	// Comparison
	| #(EQUALS expr expr) 
	| #(GT expr expr) 
	| #(GTEQ expr expr) 
	| #(LTN expr expr) 
	| #(LTEQ expr expr) 
	| #(NOTEQUALS expr expr) 
  // null checking
	| #(ISNULL expr) 
	// String operators
	| #(STRING_PLUS expr expr) 
	| #(WSTRING_PLUS expr expr) 
	| #(STRING_LIKE expr expr) 
	| #(WSTRING_LIKE expr expr) 
	// Arithmetic
	| #(INTEGER_MINUS expr expr) 
	| #(INTEGER_DIVIDE expr expr) 
	| #(INTEGER_PLUS expr expr) 
	| #(INTEGER_TIMES expr expr)  
	| #(INTEGER_UNARY_MINUS expr)  
	| #(BIGINT_MINUS expr expr) 
	| #(BIGINT_DIVIDE expr expr) 
	| #(BIGINT_PLUS expr expr) 
	| #(BIGINT_TIMES expr expr)  
	| #(BIGINT_UNARY_MINUS expr)  
	| #(DOUBLE_MINUS expr expr) 
	| #(DOUBLE_DIVIDE expr expr) 
	| #(DOUBLE_PLUS expr expr) 
	| #(DOUBLE_TIMES expr expr)  
	| #(DOUBLE_UNARY_MINUS expr)  
	| #(DECIMAL_MINUS expr expr) 
	| #(DECIMAL_DIVIDE expr expr) 
	| #(DECIMAL_PLUS expr expr) 
	| #(DECIMAL_TIMES expr expr)  
	| #(DECIMAL_UNARY_MINUS expr)  
	| #(INTEGER_MODULUS expr expr) 
	| #(BIGINT_MODULUS expr expr) 
	// Expression
	| 
	#(IFBLOCK ( ifThenElse )+ 
		)
	| #(ESEQ statement expr)
    | #(CAST_TO_INTEGER expression) 
    | #(CAST_TO_BIGINT expression) 
    | #(CAST_TO_DOUBLE expression) 
    | #(CAST_TO_DECIMAL expression) 
    | #(CAST_TO_STRING expression) 
    | #(CAST_TO_WSTRING expression) 
    | #(CAST_TO_BOOLEAN expression) 
    | #(CAST_TO_DATETIME expression) 
    | #(CAST_TO_TIME expression)
    | #(CAST_TO_ENUM expression) 
	| primaryExpression 
	;

// inherited from grammar RewriteTreeParser
ifThenElse :#(IFEXPR conditional) 
	| expression 
	;

// inherited from grammar RewriteTreeParser
conditional {
}
:expr expr
	;

// inherited from grammar RewriteTreeParser
primaryExpression :NUM_INT 
	| NUM_BIGINT
	| NUM_FLOAT 
	| NUM_DECIMAL 
	| STRING_LITERAL 
	| WSTRING_LITERAL 
	| ENUM_LITERAL 
	| TK_TRUE 
	| TK_FALSE 
	| TK_NULL 
	| #(METHOD_CALL ID elist RPAREN) 
	| INTEGER_GETMEM 
	| BIGINT_GETMEM 
	| DOUBLE_GETMEM 
	| DECIMAL_GETMEM 
	| BOOLEAN_GETMEM 
	| STRING_GETMEM 
	| WSTRING_GETMEM 
	| DATETIME_GETMEM 
	| TIME_GETMEM 
	| ENUM_GETMEM 
    | expression
	;


