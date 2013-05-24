header {
  #include "MTSQLInterpreter.h"
  #include "RecognitionException.hpp"
  #include "ASTPair.hpp"
  #include "ASTFactory.hpp"
  #include "MTSQLParser.hpp"
}
options {
	mangleLiteralPrefix= "TK_";
	language="Cpp";
	genHashLines=false;
}

class MTSQLOracleParser extends Parser;

options {
	k= 3;
	buildAST= true;
	defaultErrorHandler= false;
	importVocab=MTSQLParser;
}

{
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
}
protected sql92_joinedTable {
  std::string joinType = "INNER";
}
:sql92_tableReference 
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

protected sql92_tableHint! {
  std::string tableHint = "";
}
:// NUM_INT as an alternative to ID allows INDEX(n) hint syntax
  id: TK_WITH^ LPAREN (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN)
                  (COMMA (ID | TK_INDEX LPAREN (ID | NUM_INT) (COMMA (ID | NUM_INT))* RPAREN))*
           RPAREN
  { 
   char buf[512];
   sprintf(buf, "SQL Server style locking hints are not supported on Oracle, ignoring!");
   reportWarning(string(buf));
  }
  ;

protected sql92_tableReference :ID^ { ##->setType(TABLE_REF); } ((TK_AS!)? alias:ID { #alias->setType(ALIAS); } )? (sql92_tableHint)? (oracle_for_update_of_hint)?
  |
  LPAREN^ { ##->setType(DERIVED_TABLE); } sql92_selectStatement RPAREN (TK_AS!)? alias2:ID { #alias2->setType(ALIAS); }
  |
  LPAREN^ { ##->setType(GROUPED_JOIN); } sql92_joinedTable RPAREN
  ;

protected oracle_for_update_of_hint :id:TK_FOR^ TK_UPDATE (TK_OF ID (DOT ID)? )?
  {
  
  }
  ;

statement 
options {
	defaultErrorHandler= true;
}
:(
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

protected oracle_lock_statement :l:TK_LOCK^ TK_TABLE schema:ID (DOT table:ID)? TK_IN (ID)* TK_MODE (TK_NOWAIT)? SEMI
  ;

// inherited from grammar MTSQLParser
program 
options {
	defaultErrorHandler= true;
}
:TK_CREATE! TK_PROCEDURE! ID! programArgList TK_AS! statementList EOF!
        | TK_CREATE! TK_FUNCTION! ID! LPAREN! programArgList RPAREN! returnsDecl TK_AS! statementList EOF!
  ;

// inherited from grammar MTSQLParser
returnsDecl :TK_RETURNS^ builtInType
        ;

// inherited from grammar MTSQLParser
programArgList :(programArgDecl (COMMA!)?)*
	
	;

// inherited from grammar MTSQLParser
programArgDecl! :lv:variableName bit:builtInType (ou:TK_OUTPUT)? { ## = #([TK_DECLARE, "DECLARE"], lv, bit, ou); }
	;

// inherited from grammar MTSQLParser
statementList 
options {
	defaultErrorHandler= true;
}
:(statement)*
	{ ## = #([SCOPE, "SCOPE"], ##); }
	;

// inherited from grammar MTSQLParser
localQueryVarList :localQueryVar (COMMA! localQueryVar)*  { ## = #([ARRAY, "ARRAY"], ##); }
    ;

// inherited from grammar MTSQLParser
localQueryVar :lv:variableName { ## = #([ASSIGN_QUERY, "ASSIGN_QUERY"], ##); }
	;

// inherited from grammar MTSQLParser
variableDeclaration :TK_DECLARE^ variableName builtInType
	;

// inherited from grammar MTSQLParser
builtInType :(i:TK_INTEGER^ { #i->setType(BUILTIN_TYPE); }
	  | dbl:TK_DOUBLE^ (TK_PRECISION!)? { #dbl->setType(BUILTIN_TYPE); }
	  | str:TK_VARCHAR^ (LPAREN! NUM_INT! RPAREN!)? { #str->setType(BUILTIN_TYPE); }
	  | wstr:TK_NVARCHAR^ (LPAREN! NUM_INT! RPAREN!)? { #wstr->setType(BUILTIN_TYPE); }
	  | dec:TK_DECIMAL^ { #dec->setType(BUILTIN_TYPE); }
	  | b:TK_BOOLEAN^ { #b->setType(BUILTIN_TYPE); }
	  | dt:TK_DATETIME^ { #dt->setType(BUILTIN_TYPE); }
	  | tm:TK_TIME^ { #tm->setType(BUILTIN_TYPE); }
	  | en:TK_ENUM^ { #en->setType(BUILTIN_TYPE); }	  
    | bi:TK_BIGINT^ { #bi->setType(BUILTIN_TYPE); }	
	  | bin:ID^ 
          { 
            if (boost::algorithm::iequals(#bin->getText(), "binary"))
            {
              #bin->setType(BUILTIN_TYPE); 
            }
            else
            {
              throw MTSQLSemanticException((boost::format("Expecting INTEGER, VARCHAR, NVARCHAR, DOUBLE PRECISION, DECIMAL, DATETIME, ENUM, BIGINT, BINARY: found %1%") % #bin->getText()).str(),  (RefMTSQLAST) #bin); 
            }
          }
        )
	;

// inherited from grammar MTSQLParser
protected variableName :localvarName
        |
        idName
        ;

// inherited from grammar MTSQLParser
protected localvarName {
  std::string qualifiedName;
}
:lv:LOCALVAR { qualifiedName = #lv->getText(); } (DOT! i:ID! { qualifiedName += "."; qualifiedName += #i->getText(); })*
        {
          #localvarName->setText(qualifiedName);
        }
        ;

// inherited from grammar MTSQLParser
protected idName {
  std::string qualifiedName;
}
:lv:ID { qualifiedName = #lv->getText(); } (DOT! i:ID! { qualifiedName += "."; qualifiedName += #i->getText(); })*
        {
          #idName->setText(qualifiedName);
          #idName->setType(LOCALVAR);
        }
        ;

// inherited from grammar MTSQLParser
setStatement :set:TK_SET^ { #set->setType(ASSIGN); }  variableName EQUALS! expression
	;

// inherited from grammar MTSQLParser
printStatement :TK_PRINT^ expression
    ;

// inherited from grammar MTSQLParser
ifStatement :i:TK_IF^ { #i->setType(IFTHENELSE); } expression delayedStatement 
		(
			options {
				warnWhenFollowAmbig = false;
			}
			:
			TK_ELSE! delayedStatement
		)?
	;

// inherited from grammar MTSQLParser
protected delayedStatement :statement { ## = #([DELAYED_STMT, "DELAYED_STMT"], ##); }
	;

// inherited from grammar MTSQLParser
statementBlock :b:TK_BEGIN^ { #b->setType(SLIST); } (statement)* TK_END!
	;

// inherited from grammar MTSQLParser
whileStatement :w:TK_WHILE^ { #w->setType(WHILE); } expression delayedStatement 
	;

// inherited from grammar MTSQLParser
expression :(weakExpression) { #expression = #(#[EXPR, "EXPR"], #expression); }
	;

// inherited from grammar MTSQLParser
weakExpression :conjunctiveExpression
		(
			lor:TK_OR^ 
				{ 
					#lor->setType(LOR); 
				}
			conj:conjunctiveExpression!
				{
					// Put an EXPR on top of rhs to allow runtime optimization of deferred execution
					// when lhs is true
					#conj = #([EXPR, "EXPR"], conj); 
					getASTFactory()->addASTChild(currentAST, #conj);
				}
		)*
	;

// inherited from grammar MTSQLParser
conjunctiveExpression :negatedExpression
	(land:TK_AND^ { #land->setType(LAND); } 
	neg:negatedExpression! 
	{ 
		// Put an EXPR on top of rhs to allow runtime optimization of deferred execution when lhs is false
		#neg = #([EXPR, "EXPR"], neg); 
		getASTFactory()->addASTChild(currentAST, #neg); 
	}
	)*
	;

// inherited from grammar MTSQLParser
negatedExpression :(lnot:TK_NOT^ { #lnot->setType(LNOT); })* isNullExpression
	;

// inherited from grammar MTSQLParser
isNullExpression :bitwiseExpression (isnull:TK_IS^ { #isnull->setType(ISNULL); } TK_NULL!)?
  ;

// inherited from grammar MTSQLParser
bitwiseExpression :conditionalExpression 
		( 
			(
				bxor:CARET^ { #bxor->setType(BXOR); }
			| bor:PIPE^ { #bor->setType(BOR); }
			| band:AMPERSAND^ { #band->setType(BAND); }
			) conditionalExpression
		)*
	;

// inherited from grammar MTSQLParser
conditionalExpression :additiveExpression
	(((
	EQUALS^
	| GT^
	| LTN^
	| GTEQ^ 
	| LTEQ^
	| NOTEQUALS^
	| neq:NOTEQUALS2^ { #neq->setType(NOTEQUALS); }
	) additiveExpression)?
  | TK_LIKE^ additiveExpression)
	;

// inherited from grammar MTSQLParser
additiveExpression :multiplicativeExpression
	((
	PLUS^ 
	| MINUS^
	) multiplicativeExpression)*
	;

// inherited from grammar MTSQLParser
multiplicativeExpression :unaryExpression
	((
	m:STAR^ { #m->setType(TIMES); }
	| d:SLASH^ { #d->setType(DIVIDE); }
	| mod:MODULO^ { #mod->setType(MODULUS); }
	) unaryExpression)*
	;

// inherited from grammar MTSQLParser
unaryExpression :(
	up:PLUS^ { #up->setType(UNARY_PLUS); }
	| um:MINUS^ { #um->setType(UNARY_MINUS); }
	| bnot:TILDE^ { #bnot->setType(BNOT); }
	)? postfixExpression
	;

// inherited from grammar MTSQLParser
postfixExpression :primaryExpression
    | castExpression
    | caseExpression
	;

// inherited from grammar MTSQLParser
protected caseExpression {
#pragma warning(disable : 4101)
}
:(TK_CASE TK_WHEN) => simple:TK_CASE^ { #simple->setType(SIMPLE_CASE); } (whenExpression[true])+ (elseExpression)? TK_END!
	| search:TK_CASE^ { #search->setType(SEARCHED_CASE); } weakExpression (whenExpression[false])+ (elseExpression)? TK_END!
	;

// inherited from grammar MTSQLParser
protected whenExpression[bool simple] :tkw:TK_WHEN^  { if(simple) #tkw->setType(SIMPLE_WHEN); }weakExpression TK_THEN! weakExpression
	;

// inherited from grammar MTSQLParser
protected elseExpression :TK_ELSE! weakExpression { #elseExpression = #([EXPR, "EXPR"], elseExpression); }
	;

// inherited from grammar MTSQLParser
castExpression :TK_CAST^ LPAREN! expression TK_AS! builtInType RPAREN!
	;

// inherited from grammar MTSQLParser
argList :(expressionList
	| {#argList = #[ELIST, "ELIST"]; })
	;

// inherited from grammar MTSQLParser
expressionList :expression (COMMA expression)*
		{#expressionList = #(#[ELIST,"ELIST"], expressionList);}
	;

// inherited from grammar MTSQLParser
primaryExpression {
  bool isFunctionCall = false;
}
:(NUM_INT
	| NUM_BIGINT
	| NUM_FLOAT
    | NUM_DECIMAL
	| sl:STRING_LITERAL
			{ 
				// Strip of the leading single quote and the trailing single quote
				#sl->setText(#sl->getText().substr(1, #sl->getText().length()-2)); 
			}
	| wsl:WSTRING_LITERAL
			{ 
				// Strip of the leading single quote and N and the trailing single quote
				#wsl->setText(#wsl->getText().substr(2, #wsl->getText().length()-3)); 
			}
	| el:ENUM_LITERAL
			{ 
				// Strip of the leading and the trailing delimeters
				#el->setText(#el->getText().substr(1, #el->getText().length()-2)); 
			}
	| TK_TRUE
	| TK_FALSE
	| id:ID
	(
	lp:LPAREN^ {isFunctionCall = true; #lp->setType(METHOD_CALL); }
	argList
	RPAREN
	)?
			{
                                if (!isFunctionCall)
                                { 
				  // Convert to LOCALVAR
				  #id->setText("@" + #id->getText());
                                  #id->setType(LOCALVAR);
                                }
			}
	| localvarName
	| GLOBALVAR
  | TK_NULL
  | LPAREN! expression RPAREN!
	);

// inherited from grammar MTSQLParser
sql92_selectStatement :sql92_queryExpression (TK_UNION (TK_ALL)? sql92_queryExpression)*
  (TK_ORDER TK_BY sql92_orderByExpression)?
  ;

// inherited from grammar MTSQLParser
sql92_orderByExpression :sql92_additiveExpression (TK_ASC | TK_DESC)? (COMMA sql92_additiveExpression (TK_ASC | TK_DESC)? )*
  ;

// inherited from grammar MTSQLParser
sql92_queryExpression ://  (LPAREN selectStatement RPAREN) => LPAREN selectStatement RPAREN
//  |
  sql92_querySpecification
  ;

// inherited from grammar MTSQLParser
sql92_querySpecification :TK_SELECT^ (TK_ALL | TK_DISTINCT)? sql92_selectList
  (sql92_intoList)?
  sql92_fromSpecification
  (sql92_whereClause)?
  (sql92_groupByClause)?
  ;

// inherited from grammar MTSQLParser
sql92_fromSpecification :TK_FROM^ sql92_tableReferenceList
  ;

// inherited from grammar MTSQLParser
sql92_whereClause :TK_WHERE^ sql92_weakExpression
  ;

// inherited from grammar MTSQLParser
sql92_groupByClause :TK_GROUP^ TK_BY sql92_groupByExpressionList (TK_HAVING sql92_weakExpression)? 
  ;

// inherited from grammar MTSQLParser
sql92_intoList :TK_INTO^ LOCALVAR (COMMA! LOCALVAR)*
  ;

// inherited from grammar MTSQLParser
protected sql92_selectList :(
  STAR
  |
  sql92_aliasedExpression (COMMA sql92_aliasedExpression)*
  ) { ## = #([SELECT_LIST, "SELECT_LIST"], ##); }
  ;

// inherited from grammar MTSQLParser
protected sql92_aliasedExpression :sql92_expression ((TK_AS!)? id:ID { #id->setType(ALIAS); } )?
  ;

// inherited from grammar MTSQLParser
protected sql92_tableReferenceList :sql92_joinedTable (COMMA sql92_joinedTable)*
  ;

// inherited from grammar MTSQLParser
protected sql92_joinCriteria :TK_ON^ sql92_weakExpression
  ;

// inherited from grammar MTSQLParser
protected sql92_groupByExpressionList :sql92_additiveExpression (COMMA sql92_additiveExpression)*
  ;

// inherited from grammar MTSQLParser
protected sql92_markedAdditiveExpression :sql92_additiveExpression 
  ;

// inherited from grammar MTSQLParser
sql92_expression :(sql92_weakExpression) { #sql92_expression = #(#[EXPR, "EXPR"], #sql92_expression); }
	;

// inherited from grammar MTSQLParser
sql92_weakExpression :sql92_conjunctiveExpression
		(
			lor:TK_OR^ 
				{ 
					#lor->setType(LOR); 
				}
			conj:sql92_conjunctiveExpression
		)*
	;

// inherited from grammar MTSQLParser
sql92_conjunctiveExpression :sql92_negatedExpression
	(land:TK_AND^ { #land->setType(LAND); } 
	neg:sql92_negatedExpression
	)*
	;

// inherited from grammar MTSQLParser
sql92_negatedExpression :(lnot:TK_NOT^ { #lnot->setType(LNOT); })* sql92_isNullExpression
	;

// inherited from grammar MTSQLParser
sql92_isNullExpression :sql92_bitwiseExpression (isnull:TK_IS^ (TK_NOT)? TK_NULL)?
  ;

// inherited from grammar MTSQLParser
sql92_bitwiseExpression :sql92_conditionalExpression 
		( 
			(
				bxor:CARET^ { #bxor->setType(BXOR); }
			| bor:PIPE^ { #bor->setType(BOR); }
			| band:AMPERSAND^ { #band->setType(BAND); }
			) sql92_conditionalExpression
		)*
	;

// inherited from grammar MTSQLParser
sql92_conditionalExpression :sql92_additiveExpression
        (
            (
                (
                    EQUALS^ |
                    GT^     |
                    LTN^    |
                    GTEQ^   |
                    LTEQ^   |
                    NOTEQUALS^ |
                    neq:NOTEQUALS2^ { #neq->setType(NOTEQUALS); }
                )
                sql92_additiveExpression
            )?
            |
            (TK_NOT)? 
            (
                TK_LIKE^ sql92_additiveExpression |
                TK_BETWEEN^ sql92_additiveExpression TK_AND sql92_additiveExpression |
                TK_IN^ LPAREN (sql92_selectStatement | sql92_additiveExpression (COMMA sql92_additiveExpression)*) RPAREN
            )
        ) 
        |
        TK_EXISTS^ LPAREN sql92_selectStatement RPAREN
	;

// inherited from grammar MTSQLParser
sql92_additiveExpression :sql92_multiplicativeExpression
	((
	PLUS^ 
	| MINUS^
	) sql92_multiplicativeExpression)*
	;

// inherited from grammar MTSQLParser
sql92_multiplicativeExpression :sql92_unaryExpression
	((
	m:STAR^ { #m->setType(TIMES); }
	| d:SLASH^ { #d->setType(DIVIDE); }
	| mod:MODULO^ { #mod->setType(MODULUS); }
	) sql92_unaryExpression)*
	;

// inherited from grammar MTSQLParser
sql92_unaryExpression :(
	up:PLUS^ { #up->setType(UNARY_PLUS); }
	| um:MINUS^ { #um->setType(UNARY_MINUS); }
	| bnot:TILDE^ { #bnot->setType(BNOT); }
	)? sql92_postfixExpression
	;

// inherited from grammar MTSQLParser
sql92_postfixExpression :sql92_primaryExpression
	(
	lp:LPAREN^ {#lp->setType(METHOD_CALL); }
	sql92_argList
	RPAREN
	)?
  | TK_COUNT^ LPAREN (STAR | (TK_DISTINCT | TK_ALL)? sql92_expression) RPAREN
  | TK_AVG^ LPAREN ((TK_DISTINCT | TK_ALL)? sql92_expression) RPAREN
  | TK_MAX^ LPAREN ((TK_DISTINCT | TK_ALL)? sql92_expression) RPAREN
  | TK_MIN^ LPAREN ((TK_DISTINCT | TK_ALL)? sql92_expression) RPAREN
  | TK_SUM^ LPAREN ((TK_DISTINCT | TK_ALL)? sql92_expression) RPAREN
  | sql92_castExpression
  | sql92_caseExpression
	;

// inherited from grammar MTSQLParser
sql92_caseExpression {
#pragma warning(disable : 4101)
}
:(TK_CASE TK_WHEN) => simple:TK_CASE^ { #simple->setType(SIMPLE_CASE); } (sql92_whenExpression[true])+ (sql92_elseExpression)? TK_END
	| search:TK_CASE^ { #search->setType(SEARCHED_CASE); } sql92_weakExpression (sql92_whenExpression[false])+ (sql92_elseExpression)? TK_END
	;

// inherited from grammar MTSQLParser
sql92_whenExpression[bool isSimple] :tkw:TK_WHEN^ { if (isSimple) #tkw->setType(SIMPLE_WHEN); } sql92_weakExpression TK_THEN sql92_weakExpression
	;

// inherited from grammar MTSQLParser
sql92_elseExpression :// Unlike the mtsql_elseExpression, don't bother to put in the parent [EXPR].  The only
  // reason that the extra node is needed is to control the order of execution (in particular,
  // the ELSE shouldn't execute unless none of the cases matched); since we are simply going to
  // rewrite the query and let the DB execute it we don't worry about the issue.
	TK_ELSE^ sql92_weakExpression 
	;

// inherited from grammar MTSQLParser
sql92_castExpression :TK_CAST^ LPAREN sql92_expression TK_AS sql92_builtInType RPAREN
	;

// inherited from grammar MTSQLParser
sql92_argList :(sql92_expressionList
	| {#sql92_argList = #[ELIST, "ELIST"]; })
	;

// inherited from grammar MTSQLParser
sql92_expressionList :sql92_expression (COMMA sql92_expression)*
		{#sql92_expressionList = #(#[ELIST,"ELIST"], sql92_expressionList);}
	;

// inherited from grammar MTSQLParser
sql92_primaryExpression :(NUM_INT
	| NUM_BIGINT
	| NUM_FLOAT
  | NUM_DECIMAL
	| sl:STRING_LITERAL
	| el:ENUM_LITERAL
			{ 
				// Strip of the leading and the trailing delimeters.  Store the
        // FQN.  This will be converted to an integer during semantic analysis.
				#el->setText(#el->getText().substr(1, #el->getText().length()-2)); 
			}
	|wsl:WSTRING_LITERAL 			
	| TK_TRUE
	| TK_FALSE
	| ID^ (DOT ID)?
	| LOCALVAR
  | TK_NULL
  | LPAREN^ sql92_expression RPAREN
  | lp:LPAREN^ sql92_selectStatement RPAREN { #lp->setType(SCALAR_SUBQUERY); }
	);

// inherited from grammar MTSQLParser
sql92_builtInType :(i:TK_INTEGER^ { #i->setType(BUILTIN_TYPE); }
	  | chr:TK_CHAR^ LPAREN NUM_INT RPAREN { #chr->setType(BUILTIN_TYPE); }
	  | dbl:TK_DOUBLE^ TK_PRECISION { #dbl->setType(BUILTIN_TYPE); }
	  | str:TK_VARCHAR^ LPAREN NUM_INT RPAREN { #str->setType(BUILTIN_TYPE); }
	  | wstr:TK_NVARCHAR^ LPAREN NUM_INT RPAREN { #wstr->setType(BUILTIN_TYPE); }
	  | dec:TK_DECIMAL^ LPAREN NUM_INT (COMMA NUM_INT)? RPAREN { #dec->setType(BUILTIN_TYPE); }
	  | dt:TK_DATETIME^ { #dt->setType(BUILTIN_TYPE); }
	  | bi:TK_BIGINT^ { #bi->setType(BUILTIN_TYPE); }
	)
	;


