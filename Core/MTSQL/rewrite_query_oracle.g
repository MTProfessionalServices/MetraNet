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
	language = "Cpp";
	genHashLines = true;
}
class RewriteOracleTreeParser extends RewriteTreeParser;//("RewriteTreeParser");
options {
	buildAST = true;
  analyzerDebug = false;
    defaultErrorHandler = false;
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

sql92_tableSpecification
  :
  // We must handle the case of forced join order.
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
protected
  oracle_for_update_of_hint
  :
  #(TK_FOR TK_UPDATE (TK_OF ID (DOT ID)?)?)
  ;
  
sql92_fromClause
  :
  #(TK_FROM sql92_tableSpecification (COMMA sql92_tableSpecification)*
  {
    std::string alias = getCurrentAlias() + " ";
    std::string table = getFullTempTableName() + " ";
    astFactory->addASTChild(currentAST, #([COMMA, ", "]));
    astFactory->addASTChild(currentAST, #([TABLE_REF, table], ([ALIAS, alias], ##))); 
  }
  )
  ;
