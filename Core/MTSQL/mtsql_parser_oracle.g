header {
  #include "MTSQLInterpreter.h"
  #include "RecognitionException.hpp"
  #include "ASTPair.hpp"
  #include "ASTFactory.hpp"
  #include "MTSQLParser.hpp"
}

options {
	mangleLiteralPrefix = "TK_";
	language="Cpp";
	genHashLines=false;
}

class MTSQLOracleParser extends MTSQLParser;
options 
{
	k = 3;
	//importVocab=MTSQL; // use vocab generated by lexer
	/* careful with importVocab order - it matters */
	//importVocab=MTSQLOracle; // use vocab generated by MTSQLOracleLexer
	//importVocab=MTSQLParser; // use vocab generated by MTSQLParser
	buildAST = true;
  defaultErrorHandler = false;
  //analyzerDebug=true;
	//namespaceAntlr="MTCAST";

}


protected
sql92_joinedTable
{
  std::string joinType = "INNER";
}
  :
  sql92_tableReference 
  (
    (
      (
        (
          TK_INNER! { joinType = "INNER"; } 
          | 
          (
            TK_FULL!  { joinType = "FULL OUTER"; } | TK_LEFT!  { joinType = "LEFT OUTER"; } | TK_RIGHT! { joinType = "RIGHT OUTER"; }
          )
          (TK_OUTER!)?
        )
        (id:ID! 
          { 
            joinType += " ";
            char buf[512];
            sprintf(buf, "SQL Server style join hints are not supported on Oracle, ignoring. (%s)!",  #id->getText().c_str());
            reportWarning(string(buf));
          }
         )?  // swallow join hints on Oracle, log warning
      )? 
      TK_JOIN^ { ##->setText(joinType + " JOIN"); } sql92_joinedTable sql92_joinCriteria
    ) 
    | TK_CROSS! { joinType = "CROSS JOIN"; } TK_JOIN^ { ##->setType(CROSS_JOIN); ##->setText(joinType); } sql92_tableReference
  )*
  ;
  protected
sql92_tableHint!
{
  std::string tableHint = "";
}
  :
  // NUM_INT as an alternative to ID allows INDEX(n) hint syntax
  id: TK_WITH^ LPAREN (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN)
                  (COMMA (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN))*
           RPAREN
  { 
   char buf[512];
   sprintf(buf, "SQL Server style locking hints are not supported on Oracle, ignoring!");
   reportWarning(string(buf));
  }
  ;
  protected
/*  sql92_tableHint rule should really not be allowed on Oracle grammar. 
    But we allow and skip it to keep things backward compatible.
 */
sql92_tableReference
  :
  ID^ { ##->setType(TABLE_REF); } ((TK_AS!)? alias:ID { #alias->setType(ALIAS); } )? (sql92_tableHint)? (oracle_for_update_of_hint)?
  |
  LPAREN^ { ##->setType(DERIVED_TABLE); } sql92_selectStatement RPAREN (TK_AS!)? alias2:ID { #alias2->setType(ALIAS); }
  |
  LPAREN^ { ##->setType(GROUPED_JOIN); } sql92_joinedTable RPAREN
  ;

protected
  oracle_for_update_of_hint
  :
  id:TK_FOR^ TK_UPDATE (TK_OF ID (DOT ID)? )?
  {
  
  }
  ;
  
statement
options {
  defaultErrorHandler = true;
}
	:
	(
	setStatement (SEMI!)?
	| variableDeclaration (SEMI!)?
	| printStatement (SEMI!)?
	| ifStatement
	| statementBlock (SEMI!)?
	| TK_RETURN^ (expression)? (SEMI!)?
	| TK_BREAK (SEMI!)?
	| TK_CONTINUE (SEMI!)?
	| TK_RAISERROR^ LPAREN! expression { ##->setType(RAISERROR1); } (COMMA! expression { ##->setType(RAISERROR2); } )? RPAREN! (SEMI!)?
	| whileStatement 
  | sql92_selectStatement (SEMI!)?
  | oracle_lock_statement!
	)
	;
protected
  oracle_lock_statement
  :
  l:TK_LOCK^ TK_TABLE schema:ID (DOT table:ID)? TK_IN (ID)* TK_MODE (TK_NOWAIT)? SEMI
  ;