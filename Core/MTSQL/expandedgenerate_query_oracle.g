header {
#include "MTSQLAST.h"
#include "RuntimeValue.h"
#include "Environment.h"
#include "MTSQLException.h"
#include <MTUtil.h>
#include "TokenStreamHiddenTokenFilter.hpp"
}
options {
	language= "Cpp";
}

class GenerateOracleQueryTreeParser extends TreeParser;

options {
	buildAST= true;
	analyzerDebug= false;
	defaultErrorHandler= false;
	importVocab=GenerateQueryTreeParser;
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
 
  
}
sql92_tableSpecification :#(TK_JOIN sql92_tableSpecification  { printNode(#TK_JOIN); } sql92_tableSpecification sql92_joinCriteria)
  |
  #(TABLE_REF { printNode(#TABLE_REF); } (ALIAS { printNode(#ALIAS); })? (sql92_tableHint)? (oracle_for_update_of_hint)?)
  |
  #(CROSS_JOIN sql92_tableSpecification { printNode(#CROSS_JOIN); } sql92_tableSpecification)
  |
  #(GROUPED_JOIN { printNode(#GROUPED_JOIN); } sql92_tableSpecification RPAREN { printNode(#RPAREN); })
  |
  #(DERIVED_TABLE { printNode(#DERIVED_TABLE); } sql92_nestedSelectStatement RPAREN { printNode(#RPAREN); }  ALIAS { printNode(#ALIAS); })
  ;

protected oracle_for_update_of_hint :#(TK_FOR  {printNode(#TK_FOR); }  TK_UPDATE { printNode(#TK_UPDATE); } 
  (TK_OF {printNode(#TK_OF); } ID { printNode(#ID); } 
  (DOT  { printNode(#DOT); } ID  { printNode(#ID); })?)?)
  ;

sql92_querySpecification :#(s:TK_SELECT 
  {
    printNode(#s); 
    //try to find ML_COMMENT (94) in hidden stream. Insert it into the query if found
    //We need this because Oracle join hints are passed in comments
    ANTLR_USE_NAMESPACE(antlr)RefToken hidden = 
    (ANTLR_USE_NAMESPACE(antlr)RefCommonASTWithHiddenTokens(#s))->getHiddenAfter();
    while(hidden != ANTLR_USE_NAMESPACE(antlr)nullToken)
    {
      if(hidden->getType() == ML_COMMENT)
      {
        std::string text = hidden->getText();
        std::wstring widetext;
        ::ASCIIToWide(widetext, (const char *)text.c_str(), -1, CP_UTF8);
        printString(widetext);
        break;
      }
      hidden = filter->getHiddenAfter(hidden);
    } 
    
  } 
  (TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_selectList sql92_fromClause (sql92_whereClause)? (sql92_groupByClause)?)
  ;

sql92_expr :// Expression sequence
	// Bitwise
	#(BAND sql92_expr { printNode(#BAND); } sql92_expr) 
	| #(BNOT { printNode(#BNOT); } sql92_expr) 
	| #(BOR sql92_expr { printNode(#BOR); } sql92_expr) 
	| #(BXOR sql92_expr { printNode(#BXOR); } sql92_expr) 
	// Arithmetic
	| #(MINUS sql92_expr { printNode(#MINUS); } sql92_expr) 
	| #(MODULUS 
    { 
	    printString(L" MOD"); 
	    printString(L"("); 
	  } 
	  x:sql92_expr
	  {
	    printString(L", ");
	  }
	  y:sql92_expr
	  {
	    printString(L") ");
	  }
	  ) 
	| #(DIVIDE sql92_expr { printNode(#DIVIDE); } sql92_expr) 
	| #(PLUS sql92_expr { printNode(#PLUS); } sql92_expr) 
	| #(TIMES sql92_expr { printNode(#TIMES); } sql92_expr)  
	| #(UNARY_MINUS { printNode(#UNARY_MINUS); } sql92_expr)  
	| #(UNARY_PLUS { printNode(#UNARY_PLUS); } sql92_expr) 
    | #(TK_CAST { printNode(#TK_CAST); } LPAREN { printNode(#LPAREN); } sql92_expression TK_AS { printNode(#TK_AS); } sql92_builtInType RPAREN { printNode(#RPAREN); })
    | #(TK_COUNT { printNode(#TK_COUNT); } LPAREN { printNode(#LPAREN); } (STAR { printNode(#STAR); } | (TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_expression) RPAREN { printNode(#RPAREN); })
    | #(TK_AVG { printNode(#TK_AVG); } LPAREN { printNode(#LPAREN); } ((TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_expression) RPAREN { printNode(#RPAREN); })
    | #(TK_MAX { printNode(#TK_MAX); } LPAREN { printNode(#LPAREN); } ((TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_expression) RPAREN { printNode(#RPAREN); })
    | #(TK_MIN { printNode(#TK_MIN); } LPAREN { printNode(#LPAREN); } ((TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_expression) RPAREN { printNode(#RPAREN); })
    | #(TK_SUM { printNode(#TK_SUM); } LPAREN { printNode(#LPAREN); } ((TK_ALL { printNode(#TK_ALL); } | TK_DISTINCT { printNode(#TK_DISTINCT); })? sql92_expression) RPAREN { printNode(#RPAREN); })
    | #(SIMPLE_CASE { printNode(#SIMPLE_CASE); } (sql92_simpleWhenExpression)+ (sql92_elseExpression)? TK_END { printNode(#TK_END); })
    | #(SEARCHED_CASE { printNode(#SEARCHED_CASE); } sql92_expr (sql92_whenExpression)+ (sql92_elseExpression)? TK_END { printNode(#TK_END); })
	// Expression
	| sql92_primaryExpression
;

sql92_methodCall {
    int trnsfrm=-1;
}
:#(METHOD_CALL id:ID 
    { 
        if (0 == stricmp("len", #id->getText().c_str()))
        {
           #id->setText("length");
        }
        else if (0 == stricmp("charindex", #id->getText().c_str()))
        {
           #id->setText("instr");
           trnsfrm = 0;
        }
        else if (0 == stricmp("substring", #id->getText().c_str()))
        {
           #id->setText("substr");
        }
        else if (0 == stricmp("isnull", #id->getText().c_str()))
        {
           #id->setText("nvl");
        }
        else if (0 == stricmp("ceiling", #id->getText().c_str()))
        {
           #id->setText("ceil");
        }
        else if (0 == stricmp("atn2", #id->getText().c_str()))
        {
           #id->setText("atan2");
        }
        else if (0 == stricmp("log", #id->getText().c_str()))
        {
           #id->setText("ln");
        }
        else if (0 == stricmp("log10", #id->getText().c_str()))
        {
           #id->setText("log");
           trnsfrm = 1;
        }
        printNode(#id); 
        printNode(#METHOD_CALL); 
    } 
    el:ELIST
    {
        switch(trnsfrm)
        {
        case 0:
            oracle_CharIndex(el);
            break;
        case 1:
            oracle_Log(el);
            break;
        default:
            sql92_elist(el);
            break;
        }
    }
    RPAREN 
    { 
        printNode(#RPAREN); 
    } 
    ) 
    ;

oracle_CharIndex :#(ELIST a:EXPR b:COMMA c:EXPR { sql92_expression(c); printNode(#b); sql92_expression(a); } (d:COMMA { printNode(#d); } sql92_expression)? )
	;

oracle_Log :#(ELIST { printString(L"10, "); } sql92_expression )
	;

sql92_selectStatement :(oracle_lock_statement)* sql92_querySpecification (TK_UNION { printNode(#TK_UNION); } (TK_ALL { printNode(#TK_ALL); })? sql92_querySpecification)* 
  (TK_ORDER { printNode(#TK_ORDER); } TK_BY { printNode(#TK_BY); } sql92_orderByExpression)?
  ;

protected oracle_lock_statement! :#(
  TK_LOCK { printNode(#TK_LOCK); } 
  TK_TABLE { printNode(#TK_TABLE); } 
  schema:ID { printNode(#schema); }
  (DOT  { printNode(#DOT); } tname:ID  { printNode(#tname); })?
  TK_IN { printNode(#TK_IN); }  
  modetype:ID { printNode(#modetype); }  
  TK_MODE { printNode(#TK_MODE);}
  SEMI { printNode(#SEMI);}
  )
  ;

// inherited from grammar GenerateQueryTreeParser
mtsql_selectStatement :#(QUERY sql92_selectStatement! mtsql_paramList mtsql_intoList) 
  ;

// inherited from grammar GenerateQueryTreeParser
mtsql_paramList :#(ARRAY (INTEGER_GETMEM|DECIMAL_GETMEM|DOUBLE_GETMEM|STRING_GETMEM|WSTRING_GETMEM|BOOLEAN_GETMEM|DATETIME_GETMEM|TIME_GETMEM|ENUM_GETMEM|BIGINT_GETMEM|BINARY_GETMEM)*)
  ;

// inherited from grammar GenerateQueryTreeParser
mtsql_intoList :#(TK_INTO (mtsql_intoVarRef)+)
  ;

// inherited from grammar GenerateQueryTreeParser
mtsql_intoVarRef :#(INTEGER_SETMEM_QUERY LOCALVAR)
  |
  #(BIGINT_SETMEM_QUERY LOCALVAR)
  |
  #(DECIMAL_SETMEM_QUERY LOCALVAR)
  |
  #(DOUBLE_SETMEM_QUERY LOCALVAR)
  |
  #(STRING_SETMEM_QUERY LOCALVAR)
  |
  #(WSTRING_SETMEM_QUERY LOCALVAR)
  |
  #(BOOLEAN_SETMEM_QUERY LOCALVAR)
  |
  #(DATETIME_SETMEM_QUERY LOCALVAR)
  |
  #(TIME_SETMEM_QUERY LOCALVAR)
  |
  #(ENUM_SETMEM_QUERY LOCALVAR)
  |
  #(BINARY_SETMEM_QUERY LOCALVAR)
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_orderByExpression :sql92_expr (a1:TK_ASC { printNode(#a1); } | d1:TK_DESC { printNode(#d1); })? (COMMA { printNode(#COMMA); } sql92_expr (a2:TK_ASC { printNode(#a2); } | d2:TK_DESC { printNode(#d2); })? )*
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_nestedSelectStatement :sql92_querySpecification (TK_UNION { printNode(#TK_UNION); } (TK_ALL { printNode(#TK_ALL); })? sql92_querySpecification)*
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_selectList :#(SELECT_LIST (s:STAR { printNode(#s); } | sql92_expression (a1:ALIAS { printNode(#a1); })? (COMMA { printNode(#COMMA); } sql92_expression (a2:ALIAS { printNode(#a2); })?)* )  )
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_fromClause :#(TK_FROM { printNode(#TK_FROM); } sql92_tableSpecification (COMMA { printNode(#COMMA); } sql92_tableSpecification)*  )
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_tableHint :#(TK_WITH { printNode(#TK_WITH); } LPAREN { printNode(#LPAREN); }
     (ID { printNode(#ID); } | TK_INDEX { printNode(#TK_INDEX); } LPAREN { printNode(#LPAREN); } 
     (ID { printNode(#ID); } | NUM_INT { printNode(#NUM_INT); })
       (COMMA { printNode(#COMMA); } (ID { printNode(#ID); } | NUM_INT { printNode(#NUM_INT); }))* RPAREN { printNode(#RPAREN); })
     (COMMA { printNode(#COMMA); } 
      (ID { printNode(#ID); } | TK_INDEX { printNode(#TK_INDEX); } LPAREN { printNode(#LPAREN); }
      (ID { printNode(#ID); } | NUM_INT { printNode(#NUM_INT); })
        (COMMA { printNode(#COMMA); } (ID { printNode(#ID); } | NUM_INT { printNode(#NUM_INT); }))* RPAREN { printNode(#RPAREN); }))*
   RPAREN { printNode(#RPAREN); })
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_joinCriteria :#(TK_ON { printNode(#TK_ON); } sql92_logicalExpression)
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_whereClause :#(TK_WHERE { printNode(#TK_WHERE); } (sql92_searchCondition)+ )
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_groupByClause :#(TK_GROUP { printNode(#TK_GROUP); } TK_BY { printNode(#TK_BY); } sql92_expr (COMMA { printNode(#COMMA); } sql92_expr)* (TK_HAVING { printNode(#TK_HAVING); } sql92_searchCondition)?) 
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_searchCondition :sql92_logicalExpression
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_elist :#(ELIST (sql92_expression (COMMA { printNode(#COMMA); } sql92_expression)*)? )
	;

// inherited from grammar GenerateQueryTreeParser
sql92_expression :#(EXPR sql92_expr)
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_logicalExpression :// Comparison
	#(EQUALS sql92_expr { printNode(#EQUALS); } sql92_expr) 
	| #(GT sql92_expr { printNode(#GT); } sql92_expr) 
	| #(GTEQ sql92_expr { printNode(#GTEQ); } sql92_expr) 
	| #(LTN sql92_expr { printNode(#LTN); } sql92_expr) 
	| #(LTEQ sql92_expr { printNode(#LTEQ); } sql92_expr) 
	| #(NOTEQUALS sql92_expr { printNode(#NOTEQUALS); } sql92_expr) 	
  |
  #(TK_LIKE sql92_expr (TK_NOT { printNode(#TK_NOT); })? { printNode(#TK_LIKE); } sql92_expr)
  |
  #(TK_IS sql92_expr { printNode(#TK_IS); } (TK_NOT { printNode(#TK_NOT); })? TK_NULL {printNode(#TK_NULL); })
  |
  #(TK_BETWEEN sql92_expr (TK_NOT { printNode(#TK_NOT); })? { printNode(#TK_BETWEEN); } sql92_expr TK_AND { printNode(#TK_AND); } sql92_expr)
  |
  #(TK_EXISTS (TK_NOT { printNode(#TK_NOT); })? { printNode(#TK_EXISTS); }
            LPAREN { printNode(#LPAREN); } 
                sql92_nestedSelectStatement 
            RPAREN { printNode(#RPAREN); })
  |  
  #(TK_IN sql92_expr (TK_NOT { printNode(#TK_NOT); })? { printNode(#TK_IN); }
            LPAREN { printNode(#LPAREN); }
                (sql92_nestedSelectStatement |
                sql92_expr (COMMA { printNode(#COMMA); } sql92_expr)*)
            RPAREN { printNode(#RPAREN); })
	// Logical
	| #(LAND sql92_logicalExpression { printNode(#LAND); } sql92_logicalExpression) 
	| #(LNOT { printNode(#LNOT); } sql92_logicalExpression) 
	| #(LOR sql92_logicalExpression { printNode(#LOR); } sql92_logicalExpression) 
	| #(LPAREN { printNode(#LPAREN); } sql92_hackExpression RPAREN { printNode(#RPAREN); }) 
  ;

// inherited from grammar GenerateQueryTreeParser
protected sql92_hackExpression :// The need for this is an artifact of some inconsistency in how
  // expressions are handled in the tree parsers and the parser.
  // In the parser, arithmetic expressions are a special case of 
  // logical expressions whereas in the tree parsers, logical and arithmetic
  // expressions are totally distinct.  However, the use of the construct
  // LPAREN expr RPAREN is handled in the parser and therefore treats 
  // logical and arithmetic expressions the same way.
  #(EXPR sql92_logicalExpression)
  ;

// inherited from grammar GenerateQueryTreeParser
protected sql92_whenExpression :#(TK_WHEN { printNode(#TK_WHEN); } sql92_expr TK_THEN { printNode(#TK_THEN); } sql92_expr)
  ;

// inherited from grammar GenerateQueryTreeParser
protected sql92_simpleWhenExpression :#(SIMPLE_WHEN { printNode(#SIMPLE_WHEN); } sql92_logicalExpression TK_THEN { printNode(#TK_THEN); } sql92_expr)
  ;

// inherited from grammar GenerateQueryTreeParser
protected sql92_elseExpression :#(TK_ELSE { printNode(#TK_ELSE); } sql92_expr)
  ;

// inherited from grammar GenerateQueryTreeParser
sql92_builtInType :#(BUILTIN_TYPE { printNode(#BUILTIN_TYPE); } (TK_PRECISION { printNode(#TK_PRECISION); })? (LPAREN { printNode(#LPAREN); } n1:NUM_INT { printNode(#n1); } (COMMA { printNode(#COMMA); } n2:NUM_INT { printNode(#n2); })? RPAREN { printNode(#RPAREN); })?)
   ;

// inherited from grammar GenerateQueryTreeParser
sql92_primaryExpression :(
	#(id1:ID { printNode(#id1); } (DOT { printNode(#DOT); } id2:ID { printNode(#id2); })?)
	| NUM_INT { printNode(#NUM_INT); }
	| NUM_BIGINT { printNode(#NUM_BIGINT); }
	| NUM_FLOAT { printNode(#NUM_FLOAT); }
	| NUM_DECIMAL { printNode(#NUM_DECIMAL); }
	| STRING_LITERAL { printNode(#STRING_LITERAL); }
	| WSTRING_LITERAL { printNode(#WSTRING_LITERAL); }
	| 
  LOCALVAR 
  { 
    printLocalvarNode(#LOCALVAR); 
  }
    | #(LPAREN { printNode(#LPAREN); }  sql92_expression RPAREN { printNode(#RPAREN); })
    | #(SCALAR_SUBQUERY { printNode(#SCALAR_SUBQUERY); } sql92_selectStatement RPAREN { printNode(#RPAREN); })
    | sql92_methodCall
        )
	;

// inherited from grammar GenerateQueryTreeParser
program :(typeDeclaration)* 
	(returnsDeclaration)?
	#(SCOPE { mEnv->beginScope(); } 
	  statementList { mEnv->endScope(); }
	)
	;

// inherited from grammar GenerateQueryTreeParser
returnsDeclaration :#(TK_RETURNS BUILTIN_TYPE)
        ;

// inherited from grammar GenerateQueryTreeParser
statementList :(statement)*
	;

// inherited from grammar GenerateQueryTreeParser
statement :setStatement 
	|
	typeDeclaration
	|
    wstringPrintStatement
	|
    stringPrintStatement
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
    {
      mQueryString = L"";
      mQueryParameters.clear();
    }   
    mtsql_selectStatement 
    { 
      RefMTSQLAST ast = ((RefMTSQLAST)##);
      ast->setValue(RuntimeValue::createWString(mQueryString)); 
    }
	;

// inherited from grammar GenerateQueryTreeParser
typeDeclaration :#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE) 
	{ 
			
		mEnv->insertVar(
		var->getText(), 
		VarEntry::create(getType(ty->getText()), mEnv->allocateVariable(var->getText(), getType(ty->getText())), mEnv->getCurrentLevel())); 
	}
	;

// inherited from grammar GenerateQueryTreeParser
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
	| #(BINARY_SETMEM varAddress expression) 
	;

// inherited from grammar GenerateQueryTreeParser
varAddress :l:LOCALVAR 
	;

// inherited from grammar GenerateQueryTreeParser
stringPrintStatement :#(STRING_PRINT expr)
	;

// inherited from grammar GenerateQueryTreeParser
wstringPrintStatement :#(WSTRING_PRINT expr)
	;

// inherited from grammar GenerateQueryTreeParser
seq :#(SEQUENCE statement statement)
	;

// inherited from grammar GenerateQueryTreeParser
queryStatement :#(QUERY 
	localParamList 
    queryString 
    localQueryVarList 
    )
	;

// inherited from grammar GenerateQueryTreeParser
queryString {
}
:#(QUERYSTRING (.)+)
    ;

// inherited from grammar GenerateQueryTreeParser
localQueryVarList :setmemQuery
	;

// inherited from grammar GenerateQueryTreeParser
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
	| #(BINARY_SETMEM_QUERY varAddress) 
	  )*
	)
    ;

// inherited from grammar GenerateQueryTreeParser
localParamList :#(ARRAY (primaryExpression)*)
    ;

// inherited from grammar GenerateQueryTreeParser
ifStatement :#(IFTHENELSE expression delayedStatement (delayedStatement)? )
    ;

// inherited from grammar GenerateQueryTreeParser
delayedStatement :#(DELAYED_STMT statement)
	;

// inherited from grammar GenerateQueryTreeParser
listOfStatements :#(SLIST (statement)*)
	;

// inherited from grammar GenerateQueryTreeParser
returnStatement :#(TK_RETURN (expression)?)
	;

// inherited from grammar GenerateQueryTreeParser
breakStatement :TK_BREAK 
    ;

// inherited from grammar GenerateQueryTreeParser
continueStatement :TK_CONTINUE
    ;

// inherited from grammar GenerateQueryTreeParser
whileStatement :#(WHILE expression delayedStatement) 
    ;

// inherited from grammar GenerateQueryTreeParser
raiserrorIntegerStatement :#(RAISERRORINTEGER expression) 
    ;

// inherited from grammar GenerateQueryTreeParser
raiserrorStringStatement :#(RAISERRORSTRING expression) 
    ;

// inherited from grammar GenerateQueryTreeParser
raiserrorWStringStatement :#(RAISERRORWSTRING expression) 
    ;

// inherited from grammar GenerateQueryTreeParser
raiserror2StringStatement :#(RAISERROR2STRING expression expression) 
    ;

// inherited from grammar GenerateQueryTreeParser
raiserror2WStringStatement :#(RAISERROR2WSTRING expression expression) 
    ;

// inherited from grammar GenerateQueryTreeParser
elist :#(ELIST (expression (COMMA expression)*)?)
	;

// inherited from grammar GenerateQueryTreeParser
expression :#(EXPR expr) 
	;

// inherited from grammar GenerateQueryTreeParser
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
    | #(CAST_TO_BINARY expression) 
	| primaryExpression 
	;

// inherited from grammar GenerateQueryTreeParser
ifThenElse :#(IFEXPR conditional) 
	| expression 
	;

// inherited from grammar GenerateQueryTreeParser
conditional {
}
:expr expr
	;

// inherited from grammar GenerateQueryTreeParser
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
	| BINARY_GETMEM 
    | expression
	;


