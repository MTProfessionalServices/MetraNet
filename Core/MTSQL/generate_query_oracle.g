header {
#include "MTSQLAST.h"
#include "RuntimeValue.h"
#include "Environment.h"
#include "MTSQLException.h"
#include <MTUtil.h>
#include "TokenStreamHiddenTokenFilter.hpp"
}

options {
	language = "Cpp";
}
class GenerateOracleQueryTreeParser extends GenerateQueryTreeParser;
options {
	buildAST = true;
  analyzerDebug = false;
    defaultErrorHandler = false;
}
sql92_tableSpecification
  :
  #(TK_JOIN sql92_tableSpecification  { printNode(#TK_JOIN); } sql92_tableSpecification sql92_joinCriteria)
  |
  #(TABLE_REF { printNode(#TABLE_REF); } (ALIAS { printNode(#ALIAS); })? (sql92_tableHint)? (oracle_for_update_of_hint)?)
  |
  #(CROSS_JOIN sql92_tableSpecification { printNode(#CROSS_JOIN); } sql92_tableSpecification)
  |
  #(GROUPED_JOIN { printNode(#GROUPED_JOIN); } sql92_tableSpecification RPAREN { printNode(#RPAREN); })
  |
  #(DERIVED_TABLE { printNode(#DERIVED_TABLE); } sql92_nestedSelectStatement RPAREN { printNode(#RPAREN); }  ALIAS { printNode(#ALIAS); })
  ;
  
protected
oracle_for_update_of_hint
  :
  #(TK_FOR  {printNode(#TK_FOR); }  TK_UPDATE { printNode(#TK_UPDATE); } 
  (TK_OF {printNode(#TK_OF); } ID { printNode(#ID); } 
  (DOT  { printNode(#DOT); } ID  { printNode(#ID); })?)?)
  ;
sql92_querySpecification
  :
  #(s:TK_SELECT 
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

//The only reason to override sql92_expr rule is to replace 'x % y' with MOD(x, y) for Oracle.
sql92_expr
        :
	// Expression sequence
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

sql92_methodCall
{
    int trnsfrm=-1;
}
    :
	#(METHOD_CALL id:ID 
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

oracle_CharIndex
	:
	#(ELIST a:EXPR b:COMMA c:EXPR { sql92_expression(c); printNode(#b); sql92_expression(a); } (d:COMMA { printNode(#d); } sql92_expression)? )
	;

oracle_Log
	:
	#(ELIST { printString(L"10, "); } sql92_expression )
	;

sql92_selectStatement
  :
  (oracle_lock_statement)* sql92_querySpecification (TK_UNION { printNode(#TK_UNION); } (TK_ALL { printNode(#TK_ALL); })? sql92_querySpecification)* 
  (TK_ORDER { printNode(#TK_ORDER); } TK_BY { printNode(#TK_BY); } sql92_orderByExpression)?
  ;

protected
  oracle_lock_statement!
  :
  #(
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
