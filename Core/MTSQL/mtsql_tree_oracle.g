header {
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTSQLException.h"
#include "MTSQLSemanticException.h"
#include "RuntimeValueCast.h"
#include "SemanticException.hpp"
#include <iostream>
#include <vector>
#include <string>
#include <sstream>
#include <boost/cstdint.hpp>
#include <boost/format.hpp>
#include "MTSQLParam.h"
  
using namespace std;

}
options {
	language = "Cpp";
}
class MTSQLOracleTreeParser extends MTSQLTreeParser;
options {
	buildAST = true;
 defaultErrorHandler = false;
}

sql92_tableSpecification
  :
  #(TK_JOIN sql92_tableSpecification sql92_tableSpecification sql92_joinCriteria)
  |
  #(TABLE_REF (ALIAS)? (sql92_tableHint)? (oracle_for_update_of_hint)?)
  |
  #(CROSS_JOIN sql92_tableSpecification sql92_tableSpecification)
  |
  #(GROUPED_JOIN sql92_tableSpecification RPAREN)
  |
  #(DERIVED_TABLE sql92_selectStatement RPAREN ALIAS 
  )
  ;

protected
  oracle_for_update_of_hint
  :
  #(TK_FOR TK_UPDATE (TK_OF ID (DOT ID)?)?)
  ;
  
  sql92_selectStatement
  :
  (oracle_lock_statement)* sql92_querySpecification (TK_UNION (TK_ALL)? sql92_querySpecification)*
  (TK_ORDER TK_BY sql92_orderByExpression)?
  ;
	
	protected
  oracle_lock_statement
  :
  #(TK_LOCK TK_TABLE ID (DOT ID)? TK_IN (ID)* TK_MODE (TK_NOWAIT)? SEMI)
  ;
