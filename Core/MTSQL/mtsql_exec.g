header {
#include "Environment.h"
#include "MTSQLAST.h"
#include "MTDec.h"
#include "MTSQLSelectCommand.h"
#include "RuntimeValueCast.h"
#include "antlr/SemanticException.hpp"
#include <iostream>
}
options {
  language="Cpp";
}
class MTSQLTreeExecution extends TreeParser;
options {
  importVocab=MTSQLTreeParser;
}
{
  private: RuntimeEnvironment *mEnv;
  public: void setRuntimeEnvironment(RuntimeEnvironment *env) { mEnv = env; }
private:
  Logger* mLog;
  TransactionContext* mTrans;

  std::string getFullText(RefMTSQLAST q)
  {
		std::string str = q->getText();
		str = str + (q->getHiddenAfter()==ANTLR_USE_NAMESPACE(antlr)nullToken ? "" : q->getHiddenAfter()->getText());
		return str;
  }

private: NameIDProxy mNameIDProxy;
public: 
	NameIDImpl * getNameID()
  {
    return mNameIDProxy.GetNameID();
  }
 

private: RuntimeValue mReturnValue;
public: RuntimeValue getReturnValue() const { return mReturnValue; }
public:
  
	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  void setLog(Logger * log)
  {
	mLog = log;
  }

	void setTransactionContext(TransactionContext * trans)
  {
  mTrans = trans;
  }
  
  //BP: Just to get around inheritance issues.
  //This method is never used on MTSQLTreeExecution
  private: vector<MTSQLParam> mParams;
  public: virtual vector<MTSQLParam> getParams() 
	{
		return mParams;
	}
  
}

program
	:
	(typeDeclaration)* 
	(returnsDeclaration)?
	#(SCOPE 
	  { 
		mEnv->allocateActivationRecord(0); 
	  } 
	  sl:statementList 
	  { 
		mEnv->freeActivationRecord(); 
	  }
	)
	;
	exception [sl] // Handle the exception thrown by the RETURN statement
	catch [MTSQLReturnException& ]
  {
  }

returnsDeclaration
        :
	#(TK_RETURNS BUILTIN_TYPE)
        ;

statementList
	: (statement)*
	;

statement
{
  RuntimeValue r; 
}
	:
	r=setStatement 
	|
	typeDeclaration
	|
    stringPrintStatement
	|
    wstringPrintStatement
    |
	seq
    |
	queryStatement
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
    raiserrorIntegerStatement
  |
    raiserror2Statement
	;

typeDeclaration
	:
	#(TK_DECLARE var:LOCALVAR ty:BUILTIN_TYPE) 
	{ 
	}
	;

setStatement returns [RuntimeValue r]
{
  LexicalAddressPtr addr;
}
	:
	#(INTEGER_SETMEM addr=varAddress r=expression) { mEnv->setLongValue(addr.get(), &r); } 
	| #(BIGINT_SETMEM addr=varAddress r=expression) { mEnv->setLongLongValue(addr.get(), &r); }
	| #(DOUBLE_SETMEM addr=varAddress r=expression) { mEnv->setDoubleValue(addr.get(), &r); }
	| #(DECIMAL_SETMEM addr=varAddress r=expression) { mEnv->setDecimalValue(addr.get(), &r); }
	| #(BOOLEAN_SETMEM addr=varAddress r=expression) { mEnv->setBooleanValue(addr.get(), &r); }
	| #(STRING_SETMEM addr=varAddress r=expression) { mEnv->setStringValue(addr.get(), &r); }
	| #(WSTRING_SETMEM addr=varAddress r=expression) { mEnv->setWStringValue(addr.get(), &r); }
	| #(DATETIME_SETMEM addr=varAddress r=expression) { mEnv->setDatetimeValue(addr.get(), &r); }
	| #(TIME_SETMEM addr=varAddress r=expression) { mEnv->setTimeValue(addr.get(), &r); }
	| #(ENUM_SETMEM addr=varAddress r=expression) { mEnv->setEnumValue(addr.get(), &r); }
	;

varAddress returns [LexicalAddressPtr a]
	:
	l:LOCALVAR { a = ((RefMTSQLAST)#l)->getAccess(); }
	;

stringPrintStatement
{
  RuntimeValue r;
}
	:
	#(STRING_PRINT printExpr:EXPR)
    {
        if(mLog->isOkToLogDebug())
        {
            r = expression(printExpr);
	          mLog->logDebug(r.isNullRaw() ? "NULL" : r.getStringPtr());
        }
    }
	;

wstringPrintStatement
{
  RuntimeValue r;
}
	:
	#(WSTRING_PRINT printExpr:EXPR)
    {
        if(mLog->isOkToLogDebug())
        {
            r = expression(printExpr);
	    mLog->logDebug(r.isNullRaw() ? "NULL" : r.castToString().getStringPtr());
        }
    }
	;

seq
	:
	#(SEQUENCE statement statement)
	;

queryStatement
{
  std::vector<RuntimeValue> p;
  const wchar_t * s;
  MTSQLSelectCommand cmd(mTrans->getRowset());
}
    :
    #(q:QUERY 
	p = localParamList 
	{
    s = ((RefMTSQLAST)q)->getValue().getWStringPtr();
		cmd.setQueryString(s);
		for(unsigned int i=0; i<p.size(); i++)
        {
		  cmd.setParam(i, p[i]);
        }
		cmd.execute();
		if (cmd.getRecordCount() > 1) mLog->logWarning("Multiple records returned from query; dropping all but the first");
	}
    localQueryVarList [&cmd]
    )
	;

queryString returns [std::string s]
{
}
	:
	#(QUERYSTRING (q:. { s = s + getFullText((RefMTSQLAST)q); })+)
	{
	  mLog->logDebug("Query = '" + s + "'");
	}
    ;

localQueryVarList[MTSQLSelectCommand* cmd]
    :
    // Match the array token.  Before descending into the setmem, make sure
	// that there is a record to process.
	arr:TK_INTO 
	{ 
	  if (cmd->getRecordCount() > 0) setmemQuery(#arr, cmd); 
	  else mLog->logWarning("No records returned from query; continuing");
	}
	;
	
setmemQuery[MTSQLSelectCommand* cmd] 
{
  LexicalAddressPtr addr;
  int i=0;
}
    :
    #(TK_INTO  ( { (cmd->getRecordCount() > 0) }?
	#(INTEGER_SETMEM_QUERY addr=varAddress) { mEnv->setLongValue(addr.get(), &(cmd->getLong(i++))); } 
	| #(BIGINT_SETMEM_QUERY addr=varAddress) { mEnv->setLongLongValue(addr.get(), &(cmd->getLongLong(i++))); }
	| #(DOUBLE_SETMEM_QUERY addr=varAddress) { mEnv->setDoubleValue(addr.get(), &(cmd->getDouble(i++))); }
	| #(DECIMAL_SETMEM_QUERY addr=varAddress) { mEnv->setDecimalValue(addr.get(), &(cmd->getDec(i++))); }
	| #(BOOLEAN_SETMEM_QUERY addr=varAddress) { mEnv->setBooleanValue(addr.get(), &(cmd->getBool(i++))); }
	| #(STRING_SETMEM_QUERY addr=varAddress) { mEnv->setStringValue(addr.get(), &(cmd->getString(i++))); }
	| #(WSTRING_SETMEM_QUERY addr=varAddress) { mEnv->setWStringValue(addr.get(), &(cmd->getWString(i++))); }
	| #(DATETIME_SETMEM_QUERY addr=varAddress) { mEnv->setDatetimeValue(addr.get(), &(cmd->getDatetime(i++))); }
	| #(TIME_SETMEM_QUERY addr=varAddress) { mEnv->setTimeValue(addr.get(), &(cmd->getTime(i++))); }
	| #(ENUM_SETMEM_QUERY addr=varAddress) { mEnv->setEnumValue(addr.get(), &(cmd->getEnum(i++))); }
	  )*
	)
    ;

localParamList returns [std::vector<RuntimeValue> r]
{
  RuntimeValue v;
}
    :
    #(ARRAY (v = primaryExpression { r.push_back(v); })*)
    ;

ifStatement
{
	bool hasElse=false;
	RuntimeValue v;
}
    :
	#(IFTHENELSE v = expression ifstmt:DELAYED_STMT (elsestmt:DELAYED_STMT { hasElse = true; })? )
		{
			if (false == v.isNullRaw() && true == v.getBool()) delayedStatement(#ifstmt);
			else if(true == hasElse) delayedStatement(#elsestmt);
		}
    ;

delayedStatement
	:
	#(DELAYED_STMT statement)
	;

listOfStatements
	:
	#(SLIST (statement)*)
	;

returnStatement
	:
	#(TK_RETURN (mReturnValue=expression)? { throw MTSQLReturnException(); })
	;

breakStatement
	:
	TK_BREAK 
	{
	  throw MTSQLBreakException();
	}
    ;

continueStatement
	:
	TK_CONTINUE
	{
	  throw MTSQLContinueException();
	}
    ;

whileStatement
	:
	#(WHILE e:EXPR s:DELAYED_STMT) 
	{ 
	  while(expression(e).getBool())
	  {
		try {
		  delayedStatement(s);
		} catch(MTSQLContinueException& ) {
		  continue;
		} catch(MTSQLBreakException& ) {
		  break;
		}
	  }
	}
    ;

raiserrorIntegerStatement
{
  RuntimeValue e;
}
	:
	#(RAISERRORINTEGER e=expression) 
	{ 
    throw MTSQLUserException("", e.getLong());
	}
    ;

raiserrorStringStatement
{
  RuntimeValue e;
}
	:
	#(RAISERRORSTRING e=expression) 
	{ 
    throw MTSQLUserException(e.getStringPtr(), E_FAIL);
	}
    ;

raiserror2Statement
{
  RuntimeValue e1,e2;
}
	:
	#(RAISERROR2 e1=expression e2=expression) 
	{ 
    throw MTSQLUserException(e2.getStringPtr(), e1.getLong());
	}
    ;

elist returns [std::vector<RuntimeValue> r]
{
  RuntimeValue v;
}
	:
	#(ELIST (v = expression { r.push_back(v); } (COMMA v = expression { r.push_back(v); })*)?)
	;

expression returns [RuntimeValue r]
{
}
	:
	#(EXPR r = expr) 
	;

expr returns [RuntimeValue r]
{
  RuntimeValue lhs, rhs, e;
}
	:
	// Bitwise
	#(BAND lhs = expr rhs = expr) { r = RuntimeValue::BitwiseAnd(lhs, rhs); }
	| #(BNOT lhs = expr) { r = RuntimeValue::BitwiseNot(lhs); }
	| #(BOR lhs = expr rhs = expr) { r = RuntimeValue::BitwiseOr(lhs, rhs); }
	| #(BXOR lhs = expr rhs = expr) { r = RuntimeValue::BitwiseXor(lhs, rhs); }
	// Logical
	| #(LAND lhs = expr andRhs:EXPR) 
		{
			// Only evaluate the rhs if the lhs is true
			if(true == lhs.getBool())
			{
				rhs = expression(andRhs);
				r = RuntimeValue::createBool(rhs.getBool()); 				
			}
			else
			{
				r = RuntimeValue::createBool(false);
			}
		}
	| #(LOR lhs = expr orRhs:EXPR) 
		{
			// Only both with the rhs if the lhs is false
			if(false == lhs.getBool())
			{
				rhs = expression(orRhs);
				r = RuntimeValue::createBool(rhs.getBool()); 
			}
			else
			{
				r = RuntimeValue::createBool(true);
			}
		}
	| #(LNOT lhs = expr) { r = RuntimeValue::createBool(!lhs.getBool()); }
	// Comparison
	| #(EQUALS lhs = expr rhs = expr) { r = (lhs == rhs); }
	| #(GT lhs = expr rhs = expr) { r = (lhs > rhs); }
	| #(GTEQ lhs = expr rhs = expr) { r = (lhs >= rhs); }
	| #(LTN lhs = expr rhs = expr) { r = (lhs < rhs); }
	| #(LTEQ lhs = expr rhs = expr) { r = (lhs <= rhs); }
	| #(NOTEQUALS lhs = expr rhs = expr) { r = (lhs != rhs); }
  // null checking
	| #(ISNULL lhs = expr) { return lhs.isNull(); }
	// String operators
	| #(STRING_PLUS lhs = expr rhs = expr) { r = RuntimeValue::StringPlus(lhs, rhs);  }
	| #(WSTRING_PLUS lhs = expr rhs = expr) { r = RuntimeValue::WStringPlus(lhs, rhs);  }
  | #(STRING_LIKE lhs = expr rhs = expr) { r = RuntimeValue::StringLike(lhs, rhs); }
  | #(WSTRING_LIKE lhs = expr rhs = expr) { r = RuntimeValue::WStringLike(lhs, rhs); }
	// Arithmetic
	| #(INTEGER_MINUS lhs = expr rhs = expr) { r = RuntimeValue::LongMinus(lhs, rhs);  }
	| #(INTEGER_DIVIDE lhs = expr rhs = expr) { r = RuntimeValue::LongDivide(lhs, rhs);  }
	| #(INTEGER_PLUS lhs = expr rhs = expr) { r = RuntimeValue::LongPlus(lhs, rhs);  }
	| #(INTEGER_TIMES lhs = expr rhs = expr)  { r = RuntimeValue::LongTimes(lhs, rhs);  }
	| #(INTEGER_UNARY_MINUS lhs = expr)  { r = RuntimeValue::LongUnaryMinus(lhs);  }
	| #(BIGINT_MINUS lhs = expr rhs = expr) { r = RuntimeValue::LongLongMinus(lhs, rhs);  }
	| #(BIGINT_DIVIDE lhs = expr rhs = expr) { r = RuntimeValue::LongLongDivide(lhs, rhs);  }
	| #(BIGINT_PLUS lhs = expr rhs = expr) { r = RuntimeValue::LongLongPlus(lhs, rhs);  }
	| #(BIGINT_TIMES lhs = expr rhs = expr)  { r = RuntimeValue::LongLongTimes(lhs, rhs);  }
	| #(BIGINT_UNARY_MINUS lhs = expr)  { r = RuntimeValue::LongLongUnaryMinus(lhs);  }
	| #(DOUBLE_MINUS lhs = expr rhs = expr) { r = RuntimeValue::DoubleMinus(lhs, rhs);  }
	| #(DOUBLE_DIVIDE lhs = expr rhs = expr) { r = RuntimeValue::DoubleDivide(lhs, rhs);  }
	| #(DOUBLE_PLUS lhs = expr rhs = expr) { r = RuntimeValue::DoublePlus(lhs, rhs);  }
	| #(DOUBLE_TIMES lhs = expr rhs = expr)  { r = RuntimeValue::DoubleTimes(lhs, rhs);  }
	| #(DOUBLE_UNARY_MINUS lhs = expr)  { r = RuntimeValue::DoubleUnaryMinus(lhs);  }
	| #(DECIMAL_MINUS lhs = expr rhs = expr) { r = RuntimeValue::DecimalMinus(lhs, rhs); }
	| #(DECIMAL_DIVIDE lhs = expr rhs = expr) { r = RuntimeValue::DecimalDivide(lhs, rhs); }
	| #(DECIMAL_PLUS lhs = expr rhs = expr) { r = RuntimeValue::DecimalPlus(lhs, rhs); }
	| #(DECIMAL_TIMES lhs = expr rhs = expr)  { r = RuntimeValue::DecimalTimes(lhs, rhs); }
	| #(DECIMAL_UNARY_MINUS lhs = expr)  { r = RuntimeValue::DecimalUnaryMinus(lhs); }
	| #(INTEGER_MODULUS lhs = expr rhs = expr) { r = RuntimeValue::LongModulus(lhs, rhs); }
	| #(BIGINT_MODULUS lhs = expr rhs = expr) { r = RuntimeValue::LongLongModulus(lhs, rhs); }
	// Expression
	| 
	{ 
	  bool done = false; 
	  std::vector<RuntimeValue> ret; 
	}
	#(IFBLOCK ( {done == false}? 
                ret=ifThenElse 
				{ 
					done = ret[0].getBool(); 
					if(done==true) 
					  r = ret[1]; 
				} )+ 
			{
				// After we have processed all of the blocks check that one has fired.
				if (done == false) throw MTSQLRuntimeErrorException("No branch of CASE statement matched; consider adding an ELSE clause");
			}
		)
	| #(ESEQ statement r=expr)
    | #(CAST_TO_INTEGER lhs = expression) { r = lhs.castToLong(); }
    | #(CAST_TO_BIGINT lhs = expression) { r = lhs.castToLongLong(); }
    | #(CAST_TO_DOUBLE lhs = expression) { r = lhs.castToDouble(); }
    | #(CAST_TO_DECIMAL lhs = expression) { r = lhs.castToDec(); }
    | #(CAST_TO_STRING lhs = expression) { r = lhs.castToString(); }
    | #(CAST_TO_WSTRING lhs = expression) { r = lhs.castToWString(); }
    | #(CAST_TO_BOOLEAN lhs = expression) { r = lhs.castToBool(); }
    | #(CAST_TO_DATETIME lhs = expression) { r = lhs.castToDatetime(); }
    | #(CAST_TO_TIME lhs = expression) { r = lhs.castToTime(); }
    | #(CAST_TO_ENUM lhs = expression) { RuntimeValueCast::ToEnum(&r, &lhs, getNameID()); }
	| r = primaryExpression 
	;

ifThenElse returns [std::vector<RuntimeValue> r]
{
  RuntimeValue tmp;
}
	: #(IFEXPR r = conditional[RuntimeValue::createBool(true)]) 
	| tmp = expression { r.push_back(RuntimeValue::createBool(true)); r.push_back(tmp); }
	;


conditional[RuntimeValue forWhat]  returns [std::vector<RuntimeValue> r]
{
}
	:
	cond:EXPR cons:EXPR
    {
	  r.push_back(expression(cond));
    RuntimeValue cmp = (forWhat == r[0]);
	  if (cmp.getBool())
      {
		r.push_back(expression(cons));
	  }
    }
	;

primaryExpression returns [RuntimeValue r]
{
  std::vector<RuntimeValue> v;
}
	:
	i:NUM_INT 
		{ 
			r = ((RefMTSQLAST)i)->getValue();
		}
	| bi:NUM_BIGINT 
		{ 
			r = ((RefMTSQLAST)bi)->getValue();
		}
	| d:NUM_FLOAT 
		{ 
			r = ((RefMTSQLAST)d)->getValue();
		}
	| dec:NUM_DECIMAL 
		{ 
			r = ((RefMTSQLAST)dec)->getValue();
		}
	| s:STRING_LITERAL { r = ((RefMTSQLAST)s)->getValue(); }
	| ws:WSTRING_LITERAL { r = ((RefMTSQLAST)ws)->getValue(); }
	| e:ENUM_LITERAL { r = ((RefMTSQLAST)e)->getValue(); }
	| t:TK_TRUE { r = ((RefMTSQLAST)t)->getValue(); }
	| f:TK_FALSE { r = ((RefMTSQLAST)f)->getValue(); }
	| nil:TK_NULL { r = ((RefMTSQLAST)nil)->getValue(); }
	| #(METHOD_CALL id:ID v = elist RPAREN) 
    {
      const RuntimeValue ** tmp = new const RuntimeValue * [v.size()];
      for(unsigned int i=0; i<v.size(); i++)
        tmp[i] = &v[i];
      mEnv->executePrimitiveFunction(((RefMTSQLAST)id)->getValue().getStringPtr(), tmp, int(v.size()), &r); 
    }
	| igm:INTEGER_GETMEM { mEnv->getLongValue(((RefMTSQLAST)igm)->getAccess().get(), &r); }
	| bigm:BIGINT_GETMEM { mEnv->getLongLongValue(((RefMTSQLAST)bigm)->getAccess().get(), &r); }
	| dgm:DOUBLE_GETMEM { mEnv->getDoubleValue(((RefMTSQLAST)dgm)->getAccess().get(), &r); }
	| decgm:DECIMAL_GETMEM { mEnv->getDecimalValue(((RefMTSQLAST)decgm)->getAccess().get(), &r); }
	| bgm:BOOLEAN_GETMEM { mEnv->getBooleanValue(((RefMTSQLAST)bgm)->getAccess().get(), &r); }
	| sgm:STRING_GETMEM { mEnv->getStringValue(((RefMTSQLAST)sgm)->getAccess().get(), &r); }
	| wsgm:WSTRING_GETMEM { mEnv->getWStringValue(((RefMTSQLAST)wsgm)->getAccess().get(), &r); }
	| dtgm:DATETIME_GETMEM { mEnv->getDatetimeValue(((RefMTSQLAST)dtgm)->getAccess().get(), &r); }
	| tm:TIME_GETMEM { mEnv->getTimeValue(((RefMTSQLAST)tm)->getAccess().get(), &r); }
	| en:ENUM_GETMEM { mEnv->getEnumValue(((RefMTSQLAST)en)->getAccess().get(), &r); }
    | r = expression
	;
