/* $ANTLR 2.7.6 (2005-12-22): "mtsql_exec.g" -> "MTSQLTreeExecution.cpp"$ */
#include "MTSQLTreeExecution.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "mtsql_exec.g"
#line 11 "MTSQLTreeExecution.cpp"
MTSQLTreeExecution::MTSQLTreeExecution()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void MTSQLTreeExecution::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST sl = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_DECLARE)) {
				typeDeclaration(_t);
				_t = _retTree;
			}
			else {
				goto _loop3;
			}
			
		}
		_loop3:;
		} // ( ... )*
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_RETURNS:
		{
			returnsDeclaration(_t);
			_t = _retTree;
			break;
		}
		case SCOPE:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST __t5 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = _t;
		match(_t,SCOPE);
		_t = _t->getFirstChild();
#line 86 "mtsql_exec.g"
		
				mEnv->allocateActivationRecord(0); 
			
#line 64 "MTSQLTreeExecution.cpp"
		try { // for error handling
			sl = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			statementList(_t);
			_t = _retTree;
		}
		catch (MTSQLReturnException& ) {
#line 97 "mtsql_exec.g"
			
			
#line 74 "MTSQLTreeExecution.cpp"
		}
#line 90 "mtsql_exec.g"
		
				mEnv->freeActivationRecord(); 
			
#line 80 "MTSQLTreeExecution.cpp"
		_t = __t5;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t13 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = _t;
		match(_t,TK_DECLARE);
		_t = _t->getFirstChild();
		var = _t;
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		ty = _t;
		match(_t,BUILTIN_TYPE);
		_t = _t->getNextSibling();
		_t = __t13;
		_t = _t->getNextSibling();
#line 148 "mtsql_exec.g"
		
			
#line 113 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t7 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = _t;
		match(_t,TK_RETURNS);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = _t;
		match(_t,BUILTIN_TYPE);
		_t = _t->getNextSibling();
		_t = __t7;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_tokenSet_0.member(_t->getType()))) {
				statement(_t);
				_t = _retTree;
			}
			else {
				goto _loop10;
			}
			
		}
		_loop10:;
		} // ( ... )*
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 109 "mtsql_exec.g"
	
	RuntimeValue r; 
	
#line 179 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case INTEGER_SETMEM:
		case BIGINT_SETMEM:
		case DOUBLE_SETMEM:
		case DECIMAL_SETMEM:
		case STRING_SETMEM:
		case WSTRING_SETMEM:
		case BOOLEAN_SETMEM:
		case DATETIME_SETMEM:
		case TIME_SETMEM:
		case ENUM_SETMEM:
		{
			r=setStatement(_t);
			_t = _retTree;
			break;
		}
		case TK_DECLARE:
		{
			typeDeclaration(_t);
			_t = _retTree;
			break;
		}
		case STRING_PRINT:
		{
			stringPrintStatement(_t);
			_t = _retTree;
			break;
		}
		case WSTRING_PRINT:
		{
			wstringPrintStatement(_t);
			_t = _retTree;
			break;
		}
		case SEQUENCE:
		{
			seq(_t);
			_t = _retTree;
			break;
		}
		case QUERY:
		{
			queryStatement(_t);
			_t = _retTree;
			break;
		}
		case IFTHENELSE:
		{
			ifStatement(_t);
			_t = _retTree;
			break;
		}
		case SLIST:
		{
			listOfStatements(_t);
			_t = _retTree;
			break;
		}
		case TK_RETURN:
		{
			returnStatement(_t);
			_t = _retTree;
			break;
		}
		case TK_BREAK:
		{
			breakStatement(_t);
			_t = _retTree;
			break;
		}
		case TK_CONTINUE:
		{
			continueStatement(_t);
			_t = _retTree;
			break;
		}
		case WHILE:
		{
			whileStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERRORSTRING:
		{
			raiserrorStringStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERRORINTEGER:
		{
			raiserrorIntegerStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERROR2:
		{
			raiserror2Statement(_t);
			_t = _retTree;
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

RuntimeValue  MTSQLTreeExecution::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 152 "mtsql_exec.g"
	RuntimeValue r;
#line 301 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 152 "mtsql_exec.g"
	
	LexicalAddressPtr addr;
	
#line 307 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case INTEGER_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t15 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = _t;
			match(_t,INTEGER_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t15;
			_t = _t->getNextSibling();
#line 157 "mtsql_exec.g"
			mEnv->setLongValue(addr.get(), &r);
#line 327 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t16 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = _t;
			match(_t,BIGINT_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t16;
			_t = _t->getNextSibling();
#line 158 "mtsql_exec.g"
			mEnv->setLongLongValue(addr.get(), &r);
#line 344 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t17 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = _t;
			match(_t,DOUBLE_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t17;
			_t = _t->getNextSibling();
#line 159 "mtsql_exec.g"
			mEnv->setDoubleValue(addr.get(), &r);
#line 361 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t18 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = _t;
			match(_t,DECIMAL_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t18;
			_t = _t->getNextSibling();
#line 160 "mtsql_exec.g"
			mEnv->setDecimalValue(addr.get(), &r);
#line 378 "MTSQLTreeExecution.cpp"
			break;
		}
		case BOOLEAN_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = _t;
			match(_t,BOOLEAN_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t19;
			_t = _t->getNextSibling();
#line 161 "mtsql_exec.g"
			mEnv->setBooleanValue(addr.get(), &r);
#line 395 "MTSQLTreeExecution.cpp"
			break;
		}
		case STRING_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = _t;
			match(_t,STRING_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t20;
			_t = _t->getNextSibling();
#line 162 "mtsql_exec.g"
			mEnv->setStringValue(addr.get(), &r);
#line 412 "MTSQLTreeExecution.cpp"
			break;
		}
		case WSTRING_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t21 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = _t;
			match(_t,WSTRING_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t21;
			_t = _t->getNextSibling();
#line 163 "mtsql_exec.g"
			mEnv->setWStringValue(addr.get(), &r);
#line 429 "MTSQLTreeExecution.cpp"
			break;
		}
		case DATETIME_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = _t;
			match(_t,DATETIME_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t22;
			_t = _t->getNextSibling();
#line 164 "mtsql_exec.g"
			mEnv->setDatetimeValue(addr.get(), &r);
#line 446 "MTSQLTreeExecution.cpp"
			break;
		}
		case TIME_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t23 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST_in = _t;
			match(_t,TIME_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t23;
			_t = _t->getNextSibling();
#line 165 "mtsql_exec.g"
			mEnv->setTimeValue(addr.get(), &r);
#line 463 "MTSQLTreeExecution.cpp"
			break;
		}
		case ENUM_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t24 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST_in = _t;
			match(_t,ENUM_SETMEM);
			_t = _t->getFirstChild();
			addr=varAddress(_t);
			_t = _retTree;
			r=expression(_t);
			_t = _retTree;
			_t = __t24;
			_t = _t->getNextSibling();
#line 166 "mtsql_exec.g"
			mEnv->setEnumValue(addr.get(), &r);
#line 480 "MTSQLTreeExecution.cpp"
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

void MTSQLTreeExecution::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST printExpr = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 174 "mtsql_exec.g"
	
	RuntimeValue r;
	
#line 505 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t27 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = _t;
		match(_t,STRING_PRINT);
		_t = _t->getFirstChild();
		printExpr = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		_t = __t27;
		_t = _t->getNextSibling();
#line 180 "mtsql_exec.g"
		
		if(mLog->isOkToLogDebug())
		{
		r = expression(printExpr);
			          mLog->logDebug(r.isNullRaw() ? "NULL" : r.getStringPtr());
		}
		
#line 525 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST printExpr = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 189 "mtsql_exec.g"
	
	RuntimeValue r;
	
#line 542 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t29 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST_in = _t;
		match(_t,WSTRING_PRINT);
		_t = _t->getFirstChild();
		printExpr = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		_t = __t29;
		_t = _t->getNextSibling();
#line 195 "mtsql_exec.g"
		
		if(mLog->isOkToLogDebug())
		{
		r = expression(printExpr);
			    mLog->logDebug(r.isNullRaw() ? "NULL" : r.castToString().getStringPtr());
		}
		
#line 562 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t31 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST_in = _t;
		match(_t,SEQUENCE);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		statement(_t);
		_t = _retTree;
		_t = __t31;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST q = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 209 "mtsql_exec.g"
	
	std::vector<RuntimeValue> p;
	const wchar_t * s;
	MTSQLSelectCommand cmd(mTrans->getRowset());
	
#line 604 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t33 = _t;
		q = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		match(_t,QUERY);
		_t = _t->getFirstChild();
		p=localParamList(_t);
		_t = _retTree;
#line 218 "mtsql_exec.g"
		
		s = ((RefMTSQLAST)q)->getValue().getWStringPtr();
				cmd.setQueryString(s);
				for(unsigned int i=0; i<p.size(); i++)
		{
				  cmd.setParam(i, p[i]);
		}
				cmd.execute();
				if (cmd.getRecordCount() > 1) mLog->logWarning("Multiple records returned from query; dropping all but the first");
			
#line 624 "MTSQLTreeExecution.cpp"
		localQueryVarList(_t,&cmd);
		_t = _retTree;
		_t = __t33;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifstmt = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elsestmt = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 282 "mtsql_exec.g"
	
		bool hasElse=false;
		RuntimeValue v;
	
#line 647 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t58 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST_in = _t;
		match(_t,IFTHENELSE);
		_t = _t->getFirstChild();
		v=expression(_t);
		_t = _retTree;
		ifstmt = _t;
		match(_t,DELAYED_STMT);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DELAYED_STMT:
		{
			elsestmt = _t;
			match(_t,DELAYED_STMT);
			_t = _t->getNextSibling();
#line 288 "mtsql_exec.g"
			hasElse = true;
#line 670 "MTSQLTreeExecution.cpp"
			break;
		}
		case 3:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		_t = __t58;
		_t = _t->getNextSibling();
#line 289 "mtsql_exec.g"
		
					if (false == v.isNullRaw() && true == v.getBool()) delayedStatement(ifstmt);
					else if(true == hasElse) delayedStatement(elsestmt);
				
#line 690 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t63 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST_in = _t;
		match(_t,SLIST);
		_t = _t->getFirstChild();
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_tokenSet_0.member(_t->getType()))) {
				statement(_t);
				_t = _retTree;
			}
			else {
				goto _loop65;
			}
			
		}
		_loop65:;
		} // ( ... )*
		_t = __t63;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t67 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST_in = _t;
		match(_t,TK_RETURN);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case EXPR:
		{
			mReturnValue=expression(_t);
			_t = _retTree;
			break;
		}
		case 3:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
#line 307 "mtsql_exec.g"
		throw MTSQLReturnException();
#line 764 "MTSQLTreeExecution.cpp"
		_t = __t67;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = _t;
		match(_t,TK_BREAK);
		_t = _t->getNextSibling();
#line 313 "mtsql_exec.g"
		
			  throw MTSQLBreakException();
			
#line 787 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = _t;
		match(_t,TK_CONTINUE);
		_t = _t->getNextSibling();
#line 321 "mtsql_exec.g"
		
			  throw MTSQLContinueException();
			
#line 808 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST e = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t72 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST_in = _t;
		match(_t,WHILE);
		_t = _t->getFirstChild();
		e = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		s = _t;
		match(_t,DELAYED_STMT);
		_t = _t->getNextSibling();
		_t = __t72;
		_t = _t->getNextSibling();
#line 329 "mtsql_exec.g"
		
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
			
#line 849 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 354 "mtsql_exec.g"
	
	RuntimeValue e;
	
#line 865 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t76 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST_in = _t;
		match(_t,RAISERRORSTRING);
		_t = _t->getFirstChild();
		e=expression(_t);
		_t = _retTree;
		_t = __t76;
		_t = _t->getNextSibling();
#line 360 "mtsql_exec.g"
		
		throw MTSQLUserException(e.getStringPtr(), E_FAIL);
			
#line 880 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 343 "mtsql_exec.g"
	
	RuntimeValue e;
	
#line 896 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t74 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = _t;
		match(_t,RAISERRORINTEGER);
		_t = _t->getFirstChild();
		e=expression(_t);
		_t = _retTree;
		_t = __t74;
		_t = _t->getNextSibling();
#line 349 "mtsql_exec.g"
		
		throw MTSQLUserException("", e.getLong());
			
#line 911 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeExecution::raiserror2Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2Statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 365 "mtsql_exec.g"
	
	RuntimeValue e1,e2;
	
#line 927 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t78 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST_in = _t;
		match(_t,RAISERROR2);
		_t = _t->getFirstChild();
		e1=expression(_t);
		_t = _retTree;
		e2=expression(_t);
		_t = _retTree;
		_t = __t78;
		_t = _t->getNextSibling();
#line 371 "mtsql_exec.g"
		
		throw MTSQLUserException(e2.getStringPtr(), e1.getLong());
			
#line 944 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

LexicalAddressPtr  MTSQLTreeExecution::varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 169 "mtsql_exec.g"
	LexicalAddressPtr a;
#line 957 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST varAddress_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST l = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		l = _t;
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
#line 171 "mtsql_exec.g"
		a = ((RefMTSQLAST)l)->getAccess();
#line 967 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return a;
}

RuntimeValue  MTSQLTreeExecution::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 384 "mtsql_exec.g"
	RuntimeValue r;
#line 981 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 384 "mtsql_exec.g"
	
	
#line 986 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t85 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST_in = _t;
		match(_t,EXPR);
		_t = _t->getFirstChild();
		r=expr(_t);
		_t = _retTree;
		_t = __t85;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

std::vector<RuntimeValue>  MTSQLTreeExecution::localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 274 "mtsql_exec.g"
	std::vector<RuntimeValue> r;
#line 1010 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 274 "mtsql_exec.g"
	
	RuntimeValue v;
	
#line 1016 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t54 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST_in = _t;
		match(_t,ARRAY);
		_t = _t->getFirstChild();
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_tokenSet_1.member(_t->getType()))) {
				v=primaryExpression(_t);
				_t = _retTree;
#line 279 "mtsql_exec.g"
				r.push_back(v);
#line 1032 "MTSQLTreeExecution.cpp"
			}
			else {
				goto _loop56;
			}
			
		}
		_loop56:;
		} // ( ... )*
		_t = __t54;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

void MTSQLTreeExecution::localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	MTSQLSelectCommand* cmd
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localQueryVarList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST arr = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		arr = _t;
		match(_t,TK_INTO);
		_t = _t->getNextSibling();
#line 247 "mtsql_exec.g"
		
			  if (cmd->getRecordCount() > 0) setmemQuery(arr, cmd); 
			  else mLog->logWarning("No records returned from query; continuing");
			
#line 1068 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

std::string  MTSQLTreeExecution::queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 232 "mtsql_exec.g"
	std::string s;
#line 1081 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST q = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 232 "mtsql_exec.g"
	
	
#line 1087 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t35 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST_in = _t;
		match(_t,QUERYSTRING);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt37=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if (((_t->getType() >= TK_AND && _t->getType() <= BIGINT_MODULUS))) {
				q = _t;
				if ( _t == ANTLR_USE_NAMESPACE(antlr)nullAST ) throw ANTLR_USE_NAMESPACE(antlr)MismatchedTokenException();
				_t = _t->getNextSibling();
#line 236 "mtsql_exec.g"
				s = s + getFullText((RefMTSQLAST)q);
#line 1105 "MTSQLTreeExecution.cpp"
			}
			else {
				if ( _cnt37>=1 ) { goto _loop37; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt37++;
		}
		_loop37:;
		}  // ( ... )+
		_t = __t35;
		_t = _t->getNextSibling();
#line 237 "mtsql_exec.g"
		
			  mLog->logDebug("Query = '" + s + "'");
			
#line 1121 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return s;
}

void MTSQLTreeExecution::setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	MTSQLSelectCommand* cmd
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 253 "mtsql_exec.g"
	
	LexicalAddressPtr addr;
	int i=0;
	
#line 1141 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t40 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST_in = _t;
		match(_t,TK_INTO);
		_t = _t->getFirstChild();
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case BIGINT_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t43 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = _t;
				match(_t,BIGINT_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t43;
				_t = _t->getNextSibling();
#line 261 "mtsql_exec.g"
				mEnv->setLongLongValue(addr.get(), &(cmd->getLongLong(i++)));
#line 1165 "MTSQLTreeExecution.cpp"
				break;
			}
			case DOUBLE_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t44 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = _t;
				match(_t,DOUBLE_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t44;
				_t = _t->getNextSibling();
#line 262 "mtsql_exec.g"
				mEnv->setDoubleValue(addr.get(), &(cmd->getDouble(i++)));
#line 1180 "MTSQLTreeExecution.cpp"
				break;
			}
			case DECIMAL_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t45 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = _t;
				match(_t,DECIMAL_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t45;
				_t = _t->getNextSibling();
#line 263 "mtsql_exec.g"
				mEnv->setDecimalValue(addr.get(), &(cmd->getDec(i++)));
#line 1195 "MTSQLTreeExecution.cpp"
				break;
			}
			case BOOLEAN_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t46 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = _t;
				match(_t,BOOLEAN_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t46;
				_t = _t->getNextSibling();
#line 264 "mtsql_exec.g"
				mEnv->setBooleanValue(addr.get(), &(cmd->getBool(i++)));
#line 1210 "MTSQLTreeExecution.cpp"
				break;
			}
			case STRING_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t47 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = _t;
				match(_t,STRING_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t47;
				_t = _t->getNextSibling();
#line 265 "mtsql_exec.g"
				mEnv->setStringValue(addr.get(), &(cmd->getString(i++)));
#line 1225 "MTSQLTreeExecution.cpp"
				break;
			}
			case WSTRING_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t48 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = _t;
				match(_t,WSTRING_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t48;
				_t = _t->getNextSibling();
#line 266 "mtsql_exec.g"
				mEnv->setWStringValue(addr.get(), &(cmd->getWString(i++)));
#line 1240 "MTSQLTreeExecution.cpp"
				break;
			}
			case DATETIME_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t49 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = _t;
				match(_t,DATETIME_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t49;
				_t = _t->getNextSibling();
#line 267 "mtsql_exec.g"
				mEnv->setDatetimeValue(addr.get(), &(cmd->getDatetime(i++)));
#line 1255 "MTSQLTreeExecution.cpp"
				break;
			}
			case TIME_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t50 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = _t;
				match(_t,TIME_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t50;
				_t = _t->getNextSibling();
#line 268 "mtsql_exec.g"
				mEnv->setTimeValue(addr.get(), &(cmd->getTime(i++)));
#line 1270 "MTSQLTreeExecution.cpp"
				break;
			}
			case ENUM_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t51 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = _t;
				match(_t,ENUM_SETMEM_QUERY);
				_t = _t->getFirstChild();
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t51;
				_t = _t->getNextSibling();
#line 269 "mtsql_exec.g"
				mEnv->setEnumValue(addr.get(), &(cmd->getEnum(i++)));
#line 1285 "MTSQLTreeExecution.cpp"
				break;
			}
			default:
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if (((_t->getType() == INTEGER_SETMEM_QUERY))&&( (cmd->getRecordCount() > 0) )) {
					ANTLR_USE_NAMESPACE(antlr)RefAST __t42 = _t;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = _t;
					match(_t,INTEGER_SETMEM_QUERY);
					_t = _t->getFirstChild();
					addr=varAddress(_t);
					_t = _retTree;
					_t = __t42;
					_t = _t->getNextSibling();
#line 260 "mtsql_exec.g"
					mEnv->setLongValue(addr.get(), &(cmd->getLong(i++)));
#line 1302 "MTSQLTreeExecution.cpp"
				}
			else {
				goto _loop52;
			}
			}
		}
		_loop52:;
		} // ( ... )*
		_t = __t40;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

RuntimeValue  MTSQLTreeExecution::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 522 "mtsql_exec.g"
	RuntimeValue r;
#line 1325 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST i = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bi = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dec = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ws = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST t = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST f = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST nil = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST igm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bigm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wsgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST en = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 522 "mtsql_exec.g"
	
	std::vector<RuntimeValue> v;
	
#line 1352 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case NUM_INT:
		{
			i = _t;
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 528 "mtsql_exec.g"
			
						r = ((RefMTSQLAST)i)->getValue();
					
#line 1367 "MTSQLTreeExecution.cpp"
			break;
		}
		case NUM_BIGINT:
		{
			bi = _t;
			match(_t,NUM_BIGINT);
			_t = _t->getNextSibling();
#line 532 "mtsql_exec.g"
			
						r = ((RefMTSQLAST)bi)->getValue();
					
#line 1379 "MTSQLTreeExecution.cpp"
			break;
		}
		case NUM_FLOAT:
		{
			d = _t;
			match(_t,NUM_FLOAT);
			_t = _t->getNextSibling();
#line 536 "mtsql_exec.g"
			
						r = ((RefMTSQLAST)d)->getValue();
					
#line 1391 "MTSQLTreeExecution.cpp"
			break;
		}
		case NUM_DECIMAL:
		{
			dec = _t;
			match(_t,NUM_DECIMAL);
			_t = _t->getNextSibling();
#line 540 "mtsql_exec.g"
			
						r = ((RefMTSQLAST)dec)->getValue();
					
#line 1403 "MTSQLTreeExecution.cpp"
			break;
		}
		case STRING_LITERAL:
		{
			s = _t;
			match(_t,STRING_LITERAL);
			_t = _t->getNextSibling();
#line 543 "mtsql_exec.g"
			r = ((RefMTSQLAST)s)->getValue();
#line 1413 "MTSQLTreeExecution.cpp"
			break;
		}
		case WSTRING_LITERAL:
		{
			ws = _t;
			match(_t,WSTRING_LITERAL);
			_t = _t->getNextSibling();
#line 544 "mtsql_exec.g"
			r = ((RefMTSQLAST)ws)->getValue();
#line 1423 "MTSQLTreeExecution.cpp"
			break;
		}
		case ENUM_LITERAL:
		{
			e = _t;
			match(_t,ENUM_LITERAL);
			_t = _t->getNextSibling();
#line 545 "mtsql_exec.g"
			r = ((RefMTSQLAST)e)->getValue();
#line 1433 "MTSQLTreeExecution.cpp"
			break;
		}
		case TK_TRUE:
		{
			t = _t;
			match(_t,TK_TRUE);
			_t = _t->getNextSibling();
#line 546 "mtsql_exec.g"
			r = ((RefMTSQLAST)t)->getValue();
#line 1443 "MTSQLTreeExecution.cpp"
			break;
		}
		case TK_FALSE:
		{
			f = _t;
			match(_t,TK_FALSE);
			_t = _t->getNextSibling();
#line 547 "mtsql_exec.g"
			r = ((RefMTSQLAST)f)->getValue();
#line 1453 "MTSQLTreeExecution.cpp"
			break;
		}
		case TK_NULL:
		{
			nil = _t;
			match(_t,TK_NULL);
			_t = _t->getNextSibling();
#line 548 "mtsql_exec.g"
			r = ((RefMTSQLAST)nil)->getValue();
#line 1463 "MTSQLTreeExecution.cpp"
			break;
		}
		case METHOD_CALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = _t;
			match(_t,METHOD_CALL);
			_t = _t->getFirstChild();
			id = _t;
			match(_t,ID);
			_t = _t->getNextSibling();
			v=elist(_t);
			_t = _retTree;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = _t;
			match(_t,RPAREN);
			_t = _t->getNextSibling();
			_t = __t145;
			_t = _t->getNextSibling();
#line 550 "mtsql_exec.g"
			
			const RuntimeValue ** tmp = new const RuntimeValue * [v.size()];
			for(unsigned int i=0; i<v.size(); i++)
			tmp[i] = &v[i];
			mEnv->executePrimitiveFunction(((RefMTSQLAST)id)->getValue().getStringPtr(), tmp, int(v.size()), &r); 
			
#line 1489 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_GETMEM:
		{
			igm = _t;
			match(_t,INTEGER_GETMEM);
			_t = _t->getNextSibling();
#line 556 "mtsql_exec.g"
			mEnv->getLongValue(((RefMTSQLAST)igm)->getAccess().get(), &r);
#line 1499 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_GETMEM:
		{
			bigm = _t;
			match(_t,BIGINT_GETMEM);
			_t = _t->getNextSibling();
#line 557 "mtsql_exec.g"
			mEnv->getLongLongValue(((RefMTSQLAST)bigm)->getAccess().get(), &r);
#line 1509 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_GETMEM:
		{
			dgm = _t;
			match(_t,DOUBLE_GETMEM);
			_t = _t->getNextSibling();
#line 558 "mtsql_exec.g"
			mEnv->getDoubleValue(((RefMTSQLAST)dgm)->getAccess().get(), &r);
#line 1519 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_GETMEM:
		{
			decgm = _t;
			match(_t,DECIMAL_GETMEM);
			_t = _t->getNextSibling();
#line 559 "mtsql_exec.g"
			mEnv->getDecimalValue(((RefMTSQLAST)decgm)->getAccess().get(), &r);
#line 1529 "MTSQLTreeExecution.cpp"
			break;
		}
		case BOOLEAN_GETMEM:
		{
			bgm = _t;
			match(_t,BOOLEAN_GETMEM);
			_t = _t->getNextSibling();
#line 560 "mtsql_exec.g"
			mEnv->getBooleanValue(((RefMTSQLAST)bgm)->getAccess().get(), &r);
#line 1539 "MTSQLTreeExecution.cpp"
			break;
		}
		case STRING_GETMEM:
		{
			sgm = _t;
			match(_t,STRING_GETMEM);
			_t = _t->getNextSibling();
#line 561 "mtsql_exec.g"
			mEnv->getStringValue(((RefMTSQLAST)sgm)->getAccess().get(), &r);
#line 1549 "MTSQLTreeExecution.cpp"
			break;
		}
		case WSTRING_GETMEM:
		{
			wsgm = _t;
			match(_t,WSTRING_GETMEM);
			_t = _t->getNextSibling();
#line 562 "mtsql_exec.g"
			mEnv->getWStringValue(((RefMTSQLAST)wsgm)->getAccess().get(), &r);
#line 1559 "MTSQLTreeExecution.cpp"
			break;
		}
		case DATETIME_GETMEM:
		{
			dtgm = _t;
			match(_t,DATETIME_GETMEM);
			_t = _t->getNextSibling();
#line 563 "mtsql_exec.g"
			mEnv->getDatetimeValue(((RefMTSQLAST)dtgm)->getAccess().get(), &r);
#line 1569 "MTSQLTreeExecution.cpp"
			break;
		}
		case TIME_GETMEM:
		{
			tm = _t;
			match(_t,TIME_GETMEM);
			_t = _t->getNextSibling();
#line 564 "mtsql_exec.g"
			mEnv->getTimeValue(((RefMTSQLAST)tm)->getAccess().get(), &r);
#line 1579 "MTSQLTreeExecution.cpp"
			break;
		}
		case ENUM_GETMEM:
		{
			en = _t;
			match(_t,ENUM_GETMEM);
			_t = _t->getNextSibling();
#line 565 "mtsql_exec.g"
			mEnv->getEnumValue(((RefMTSQLAST)en)->getAccess().get(), &r);
#line 1589 "MTSQLTreeExecution.cpp"
			break;
		}
		case EXPR:
		{
			r=expression(_t);
			_t = _retTree;
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

void MTSQLTreeExecution::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t61 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = _t;
		match(_t,DELAYED_STMT);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		_t = __t61;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

std::vector<RuntimeValue>  MTSQLTreeExecution::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 376 "mtsql_exec.g"
	std::vector<RuntimeValue> r;
#line 1637 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 376 "mtsql_exec.g"
	
	RuntimeValue v;
	
#line 1643 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t80 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = _t;
		match(_t,ELIST);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case EXPR:
		{
			v=expression(_t);
			_t = _retTree;
#line 381 "mtsql_exec.g"
			r.push_back(v);
#line 1660 "MTSQLTreeExecution.cpp"
			{ // ( ... )*
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == COMMA)) {
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = _t;
					match(_t,COMMA);
					_t = _t->getNextSibling();
					v=expression(_t);
					_t = _retTree;
#line 381 "mtsql_exec.g"
					r.push_back(v);
#line 1673 "MTSQLTreeExecution.cpp"
				}
				else {
					goto _loop83;
				}
				
			}
			_loop83:;
			} // ( ... )*
			break;
		}
		case 3:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		_t = __t80;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

RuntimeValue  MTSQLTreeExecution::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 391 "mtsql_exec.g"
	RuntimeValue r;
#line 1709 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST andRhs = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST orRhs = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 391 "mtsql_exec.g"
	
	RuntimeValue lhs, rhs, e;
	
#line 1717 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case BAND:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t87 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = _t;
			match(_t,BAND);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t87;
			_t = _t->getNextSibling();
#line 397 "mtsql_exec.g"
			r = RuntimeValue::BitwiseAnd(lhs, rhs);
#line 1737 "MTSQLTreeExecution.cpp"
			break;
		}
		case BNOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t88 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = _t;
			match(_t,BNOT);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t88;
			_t = _t->getNextSibling();
#line 398 "mtsql_exec.g"
			r = RuntimeValue::BitwiseNot(lhs);
#line 1752 "MTSQLTreeExecution.cpp"
			break;
		}
		case BOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t89 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = _t;
			match(_t,BOR);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t89;
			_t = _t->getNextSibling();
#line 399 "mtsql_exec.g"
			r = RuntimeValue::BitwiseOr(lhs, rhs);
#line 1769 "MTSQLTreeExecution.cpp"
			break;
		}
		case BXOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t90 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = _t;
			match(_t,BXOR);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t90;
			_t = _t->getNextSibling();
#line 400 "mtsql_exec.g"
			r = RuntimeValue::BitwiseXor(lhs, rhs);
#line 1786 "MTSQLTreeExecution.cpp"
			break;
		}
		case LAND:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = _t;
			match(_t,LAND);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			andRhs = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t91;
			_t = _t->getNextSibling();
#line 403 "mtsql_exec.g"
			
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
					
#line 1815 "MTSQLTreeExecution.cpp"
			break;
		}
		case LOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t92 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = _t;
			match(_t,LOR);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			orRhs = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t92;
			_t = _t->getNextSibling();
#line 416 "mtsql_exec.g"
			
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
					
#line 1844 "MTSQLTreeExecution.cpp"
			break;
		}
		case LNOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = _t;
			match(_t,LNOT);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t93;
			_t = _t->getNextSibling();
#line 428 "mtsql_exec.g"
			r = RuntimeValue::createBool(!lhs.getBool());
#line 1859 "MTSQLTreeExecution.cpp"
			break;
		}
		case EQUALS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t94 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = _t;
			match(_t,EQUALS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t94;
			_t = _t->getNextSibling();
#line 430 "mtsql_exec.g"
			r = (lhs == rhs);
#line 1876 "MTSQLTreeExecution.cpp"
			break;
		}
		case GT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = _t;
			match(_t,GT);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t95;
			_t = _t->getNextSibling();
#line 431 "mtsql_exec.g"
			r = (lhs > rhs);
#line 1893 "MTSQLTreeExecution.cpp"
			break;
		}
		case GTEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t96 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = _t;
			match(_t,GTEQ);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t96;
			_t = _t->getNextSibling();
#line 432 "mtsql_exec.g"
			r = (lhs >= rhs);
#line 1910 "MTSQLTreeExecution.cpp"
			break;
		}
		case LTN:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t97 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = _t;
			match(_t,LTN);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t97;
			_t = _t->getNextSibling();
#line 433 "mtsql_exec.g"
			r = (lhs < rhs);
#line 1927 "MTSQLTreeExecution.cpp"
			break;
		}
		case LTEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t98 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = _t;
			match(_t,LTEQ);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t98;
			_t = _t->getNextSibling();
#line 434 "mtsql_exec.g"
			r = (lhs <= rhs);
#line 1944 "MTSQLTreeExecution.cpp"
			break;
		}
		case NOTEQUALS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t99 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = _t;
			match(_t,NOTEQUALS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t99;
			_t = _t->getNextSibling();
#line 435 "mtsql_exec.g"
			r = (lhs != rhs);
#line 1961 "MTSQLTreeExecution.cpp"
			break;
		}
		case ISNULL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = _t;
			match(_t,ISNULL);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t100;
			_t = _t->getNextSibling();
#line 437 "mtsql_exec.g"
			return lhs.isNull();
#line 1976 "MTSQLTreeExecution.cpp"
			break;
		}
		case STRING_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t101 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = _t;
			match(_t,STRING_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t101;
			_t = _t->getNextSibling();
#line 439 "mtsql_exec.g"
			r = RuntimeValue::StringPlus(lhs, rhs);
#line 1993 "MTSQLTreeExecution.cpp"
			break;
		}
		case WSTRING_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t102 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = _t;
			match(_t,WSTRING_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t102;
			_t = _t->getNextSibling();
#line 440 "mtsql_exec.g"
			r = RuntimeValue::WStringPlus(lhs, rhs);
#line 2010 "MTSQLTreeExecution.cpp"
			break;
		}
		case STRING_LIKE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = _t;
			match(_t,STRING_LIKE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t103;
			_t = _t->getNextSibling();
#line 441 "mtsql_exec.g"
			r = RuntimeValue::StringLike(lhs, rhs);
#line 2027 "MTSQLTreeExecution.cpp"
			break;
		}
		case WSTRING_LIKE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t104 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = _t;
			match(_t,WSTRING_LIKE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t104;
			_t = _t->getNextSibling();
#line 442 "mtsql_exec.g"
			r = RuntimeValue::WStringLike(lhs, rhs);
#line 2044 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = _t;
			match(_t,INTEGER_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t105;
			_t = _t->getNextSibling();
#line 444 "mtsql_exec.g"
			r = RuntimeValue::LongMinus(lhs, rhs);
#line 2061 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t106 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = _t;
			match(_t,INTEGER_DIVIDE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t106;
			_t = _t->getNextSibling();
#line 445 "mtsql_exec.g"
			r = RuntimeValue::LongDivide(lhs, rhs);
#line 2078 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t107 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = _t;
			match(_t,INTEGER_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t107;
			_t = _t->getNextSibling();
#line 446 "mtsql_exec.g"
			r = RuntimeValue::LongPlus(lhs, rhs);
#line 2095 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t108 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = _t;
			match(_t,INTEGER_TIMES);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t108;
			_t = _t->getNextSibling();
#line 447 "mtsql_exec.g"
			r = RuntimeValue::LongTimes(lhs, rhs);
#line 2112 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = _t;
			match(_t,INTEGER_UNARY_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t109;
			_t = _t->getNextSibling();
#line 448 "mtsql_exec.g"
			r = RuntimeValue::LongUnaryMinus(lhs);
#line 2127 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t110 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = _t;
			match(_t,BIGINT_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t110;
			_t = _t->getNextSibling();
#line 449 "mtsql_exec.g"
			r = RuntimeValue::LongLongMinus(lhs, rhs);
#line 2144 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = _t;
			match(_t,BIGINT_DIVIDE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t111;
			_t = _t->getNextSibling();
#line 450 "mtsql_exec.g"
			r = RuntimeValue::LongLongDivide(lhs, rhs);
#line 2161 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t112 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = _t;
			match(_t,BIGINT_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t112;
			_t = _t->getNextSibling();
#line 451 "mtsql_exec.g"
			r = RuntimeValue::LongLongPlus(lhs, rhs);
#line 2178 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t113 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = _t;
			match(_t,BIGINT_TIMES);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t113;
			_t = _t->getNextSibling();
#line 452 "mtsql_exec.g"
			r = RuntimeValue::LongLongTimes(lhs, rhs);
#line 2195 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = _t;
			match(_t,BIGINT_UNARY_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t114;
			_t = _t->getNextSibling();
#line 453 "mtsql_exec.g"
			r = RuntimeValue::LongLongUnaryMinus(lhs);
#line 2210 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = _t;
			match(_t,DOUBLE_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t115;
			_t = _t->getNextSibling();
#line 454 "mtsql_exec.g"
			r = RuntimeValue::DoubleMinus(lhs, rhs);
#line 2227 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t116 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = _t;
			match(_t,DOUBLE_DIVIDE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t116;
			_t = _t->getNextSibling();
#line 455 "mtsql_exec.g"
			r = RuntimeValue::DoubleDivide(lhs, rhs);
#line 2244 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = _t;
			match(_t,DOUBLE_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t117;
			_t = _t->getNextSibling();
#line 456 "mtsql_exec.g"
			r = RuntimeValue::DoublePlus(lhs, rhs);
#line 2261 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t118 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = _t;
			match(_t,DOUBLE_TIMES);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t118;
			_t = _t->getNextSibling();
#line 457 "mtsql_exec.g"
			r = RuntimeValue::DoubleTimes(lhs, rhs);
#line 2278 "MTSQLTreeExecution.cpp"
			break;
		}
		case DOUBLE_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = _t;
			match(_t,DOUBLE_UNARY_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t119;
			_t = _t->getNextSibling();
#line 458 "mtsql_exec.g"
			r = RuntimeValue::DoubleUnaryMinus(lhs);
#line 2293 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t120 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = _t;
			match(_t,DECIMAL_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t120;
			_t = _t->getNextSibling();
#line 459 "mtsql_exec.g"
			r = RuntimeValue::DecimalMinus(lhs, rhs);
#line 2310 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = _t;
			match(_t,DECIMAL_DIVIDE);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t121;
			_t = _t->getNextSibling();
#line 460 "mtsql_exec.g"
			r = RuntimeValue::DecimalDivide(lhs, rhs);
#line 2327 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t122 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = _t;
			match(_t,DECIMAL_PLUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t122;
			_t = _t->getNextSibling();
#line 461 "mtsql_exec.g"
			r = RuntimeValue::DecimalPlus(lhs, rhs);
#line 2344 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = _t;
			match(_t,DECIMAL_TIMES);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t123;
			_t = _t->getNextSibling();
#line 462 "mtsql_exec.g"
			r = RuntimeValue::DecimalTimes(lhs, rhs);
#line 2361 "MTSQLTreeExecution.cpp"
			break;
		}
		case DECIMAL_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t124 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = _t;
			match(_t,DECIMAL_UNARY_MINUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			_t = __t124;
			_t = _t->getNextSibling();
#line 463 "mtsql_exec.g"
			r = RuntimeValue::DecimalUnaryMinus(lhs);
#line 2376 "MTSQLTreeExecution.cpp"
			break;
		}
		case INTEGER_MODULUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = _t;
			match(_t,INTEGER_MODULUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t125;
			_t = _t->getNextSibling();
#line 464 "mtsql_exec.g"
			r = RuntimeValue::LongModulus(lhs, rhs);
#line 2393 "MTSQLTreeExecution.cpp"
			break;
		}
		case BIGINT_MODULUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t126 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = _t;
			match(_t,BIGINT_MODULUS);
			_t = _t->getFirstChild();
			lhs=expr(_t);
			_t = _retTree;
			rhs=expr(_t);
			_t = _retTree;
			_t = __t126;
			_t = _t->getNextSibling();
#line 465 "mtsql_exec.g"
			r = RuntimeValue::LongLongModulus(lhs, rhs);
#line 2410 "MTSQLTreeExecution.cpp"
			break;
		}
		case IFBLOCK:
		{
#line 468 "mtsql_exec.g"
			
				  bool done = false; 
				  std::vector<RuntimeValue> ret; 
				
#line 2420 "MTSQLTreeExecution.cpp"
			ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = _t;
			match(_t,IFBLOCK);
			_t = _t->getFirstChild();
			{ // ( ... )+
			int _cnt129=0;
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if (((_t->getType() == EXPR || _t->getType() == IFEXPR))&&(done == false)) {
					ret=ifThenElse(_t);
					_t = _retTree;
#line 474 "mtsql_exec.g"
					
										done = ret[0].getBool(); 
										if(done==true) 
										  r = ret[1]; 
									
#line 2439 "MTSQLTreeExecution.cpp"
				}
				else {
					if ( _cnt129>=1 ) { goto _loop129; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
				}
				
				_cnt129++;
			}
			_loop129:;
			}  // ( ... )+
#line 479 "mtsql_exec.g"
			
							// After we have processed all of the blocks check that one has fired.
							if (done == false) throw MTSQLRuntimeErrorException("No branch of CASE statement matched; consider adding an ELSE clause");
						
#line 2454 "MTSQLTreeExecution.cpp"
			_t = __t127;
			_t = _t->getNextSibling();
			break;
		}
		case ESEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t130 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = _t;
			match(_t,ESEQ);
			_t = _t->getFirstChild();
			statement(_t);
			_t = _retTree;
			r=expr(_t);
			_t = _retTree;
			_t = __t130;
			_t = _t->getNextSibling();
			break;
		}
		case CAST_TO_INTEGER:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t131 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = _t;
			match(_t,CAST_TO_INTEGER);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t131;
			_t = _t->getNextSibling();
#line 485 "mtsql_exec.g"
			r = lhs.castToLong();
#line 2485 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_BIGINT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t132 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = _t;
			match(_t,CAST_TO_BIGINT);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t132;
			_t = _t->getNextSibling();
#line 486 "mtsql_exec.g"
			r = lhs.castToLongLong();
#line 2500 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_DOUBLE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = _t;
			match(_t,CAST_TO_DOUBLE);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t133;
			_t = _t->getNextSibling();
#line 487 "mtsql_exec.g"
			r = lhs.castToDouble();
#line 2515 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_DECIMAL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t134 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = _t;
			match(_t,CAST_TO_DECIMAL);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t134;
			_t = _t->getNextSibling();
#line 488 "mtsql_exec.g"
			r = lhs.castToDec();
#line 2530 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_STRING:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = _t;
			match(_t,CAST_TO_STRING);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t135;
			_t = _t->getNextSibling();
#line 489 "mtsql_exec.g"
			r = lhs.castToString();
#line 2545 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_WSTRING:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t136 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = _t;
			match(_t,CAST_TO_WSTRING);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t136;
			_t = _t->getNextSibling();
#line 490 "mtsql_exec.g"
			r = lhs.castToWString();
#line 2560 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_BOOLEAN:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t137 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = _t;
			match(_t,CAST_TO_BOOLEAN);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t137;
			_t = _t->getNextSibling();
#line 491 "mtsql_exec.g"
			r = lhs.castToBool();
#line 2575 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_DATETIME:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t138 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = _t;
			match(_t,CAST_TO_DATETIME);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t138;
			_t = _t->getNextSibling();
#line 492 "mtsql_exec.g"
			r = lhs.castToDatetime();
#line 2590 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_TIME:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = _t;
			match(_t,CAST_TO_TIME);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t139;
			_t = _t->getNextSibling();
#line 493 "mtsql_exec.g"
			r = lhs.castToTime();
#line 2605 "MTSQLTreeExecution.cpp"
			break;
		}
		case CAST_TO_ENUM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t140 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = _t;
			match(_t,CAST_TO_ENUM);
			_t = _t->getFirstChild();
			lhs=expression(_t);
			_t = _retTree;
			_t = __t140;
			_t = _t->getNextSibling();
#line 494 "mtsql_exec.g"
			RuntimeValueCast::ToEnum(&r, &lhs, getNameID());
#line 2620 "MTSQLTreeExecution.cpp"
			break;
		}
		case TK_FALSE:
		case TK_NULL:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case NUM_INT:
		case EXPR:
		case METHOD_CALL:
		case INTEGER_GETMEM:
		case BIGINT_GETMEM:
		case DOUBLE_GETMEM:
		case DECIMAL_GETMEM:
		case STRING_GETMEM:
		case WSTRING_GETMEM:
		case BOOLEAN_GETMEM:
		case DATETIME_GETMEM:
		case TIME_GETMEM:
		case ENUM_GETMEM:
		{
			r=primaryExpression(_t);
			_t = _retTree;
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

std::vector<RuntimeValue>  MTSQLTreeExecution::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 498 "mtsql_exec.g"
	std::vector<RuntimeValue> r;
#line 2668 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 498 "mtsql_exec.g"
	
	RuntimeValue tmp;
	
#line 2674 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case IFEXPR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t142 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = _t;
			match(_t,IFEXPR);
			_t = _t->getFirstChild();
			r=conditional(_t,RuntimeValue::createBool(true));
			_t = _retTree;
			_t = __t142;
			_t = _t->getNextSibling();
			break;
		}
		case EXPR:
		{
			tmp=expression(_t);
			_t = _retTree;
#line 503 "mtsql_exec.g"
			r.push_back(RuntimeValue::createBool(true)); r.push_back(tmp);
#line 2698 "MTSQLTreeExecution.cpp"
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

std::vector<RuntimeValue>  MTSQLTreeExecution::conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	RuntimeValue forWhat
) {
#line 507 "mtsql_exec.g"
	std::vector<RuntimeValue> r;
#line 2721 "MTSQLTreeExecution.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST cond = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST cons = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 507 "mtsql_exec.g"
	
	
#line 2728 "MTSQLTreeExecution.cpp"
	
	try {      // for error handling
		cond = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		cons = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
#line 512 "mtsql_exec.g"
		
			  r.push_back(expression(cond));
		RuntimeValue cmp = (forWhat == r[0]);
			  if (cmp.getBool())
		{
				r.push_back(expression(cons));
			  }
		
#line 2746 "MTSQLTreeExecution.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return r;
}

void MTSQLTreeExecution::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* MTSQLTreeExecution::tokenNames[] = {
	"<0>",
	"EOF",
	"<2>",
	"NULL_TREE_LOOKAHEAD",
	"\"AND\"",
	"\"ALL\"",
	"\"ANY\"",
	"\"AS\"",
	"\"ASC\"",
	"\"AVG\"",
	"\"BEGIN\"",
	"\"BETWEEN\"",
	"\"BIGINT\"",
	"\"BOOLEAN\"",
	"\"BREAK\"",
	"\"BY\"",
	"\"CASE\"",
	"\"CAST\"",
	"\"CHAR\"",
	"\"CONTINUE\"",
	"\"COUNT\"",
	"\"CREATE\"",
	"\"CROSS\"",
	"\"DATETIME\"",
	"\"DECLARE\"",
	"\"DECIMAL\"",
	"\"DESC\"",
	"\"DISTINCT\"",
	"\"DOUBLE\"",
	"\"ELSE\"",
	"\"END\"",
	"\"ENUM\"",
	"\"EXISTS\"",
	"\"FALSE\"",
	"\"FROM\"",
	"\"FULL\"",
	"\"FUNCTION\"",
	"\"GROUP\"",
	"\"HAVING\"",
	"\"IF\"",
	"\"IN\"",
	"\"INDEX\"",
	"\"INNER\"",
	"\"INTO\"",
	"\"INTEGER\"",
	"\"IS\"",
	"\"JOIN\"",
	"\"KEY\"",
	"\"LEFT\"",
	"\"LIKE\"",
	"\"MAX\"",
	"\"MIN\"",
	"\"NOT\"",
	"\"NULL\"",
	"\"NVARCHAR\"",
	"\"ON\"",
	"\"OR\"",
	"\"ORDER\"",
	"\"OUTER\"",
	"\"OUTPUT\"",
	"\"PRECISION\"",
	"\"PRINT\"",
	"\"PROCEDURE\"",
	"\"RAISERROR\"",
	"\"RETURN\"",
	"\"RETURNS\"",
	"\"RIGHT\"",
	"\"SELECT\"",
	"\"SET\"",
	"\"SOME\"",
	"\"SUM\"",
	"\"THEN\"",
	"\"TIME\"",
	"\"TRUE\"",
	"\"UNION\"",
	"\"VARCHAR\"",
	"\"WHEN\"",
	"\"WHERE\"",
	"\"WHILE\"",
	"\"WITH\"",
	"NUM_DECIMAL",
	"NUM_FLOAT",
	"NUM_BIGINT",
	"\"LOCK\"",
	"\"TABLE\"",
	"\"MODE\"",
	"\"FOR\"",
	"\"UPDATE\"",
	"\"OF\"",
	"\"NOWAIT\"",
	"AMPERSAND",
	"EQUALS",
	"NOTEQUALS",
	"NOTEQUALS2",
	"LTN",
	"LTEQ",
	"GT",
	"GTEQ",
	"MODULO",
	"SL_COMMENT",
	"ML_COMMENT",
	"CARET",
	"COMMA",
	"DOT",
	"\'(\'",
	"\')\'",
	"MINUS",
	"PIPE",
	"PLUS",
	"SEMI",
	"SLASH",
	"STAR",
	"STRING_LITERAL",
	"ENUM_LITERAL",
	"WSTRING_LITERAL",
	"TILDE",
	"WS",
	"ID",
	"LOCALVAR",
	"GLOBALVAR",
	"NUM_INT",
	"EXPONENT",
	"FLOAT_SUFFIX",
	"BIGINT_SUFFIX",
	"HEX_DIGIT",
	"ALIAS",
	"ARRAY",
	"ASSIGN",
	"ASSIGN_QUERY",
	"BAND",
	"BNOT",
	"BOR",
	"BXOR",
	"BUILTIN_TYPE",
	"CROSS_JOIN",
	"DELAYED_STMT",
	"DERIVED_TABLE",
	"DIVIDE",
	"ELIST",
	"EXPR",
	"GROUPED_JOIN",
	"IDENT",
	"IFTHENELSE",
	"ISNULL",
	"LAND",
	"LNOT",
	"LOR",
	"METHOD_CALL",
	"MODULUS",
	"QUERY",
	"QUERYPARAM",
	"QUERYSTRING",
	"RAISERROR1",
	"RAISERROR2",
	"SCALAR_SUBQUERY",
	"SCOPE",
	"SEARCHED_CASE",
	"SELECT_LIST",
	"SIMPLE_CASE",
	"SIMPLE_WHEN",
	"SLIST",
	"TABLE_REF",
	"TIMES",
	"UNARY_MINUS",
	"UNARY_PLUS",
	"WHILE",
	"ESEQ",
	"SEQUENCE",
	"CAST_TO_INTEGER",
	"CAST_TO_BIGINT",
	"CAST_TO_DOUBLE",
	"CAST_TO_DECIMAL",
	"CAST_TO_STRING",
	"CAST_TO_WSTRING",
	"CAST_TO_BOOLEAN",
	"CAST_TO_DATETIME",
	"CAST_TO_TIME",
	"CAST_TO_ENUM",
	"CAST_TO_BINARY",
	"INTEGER_PLUS",
	"BIGINT_PLUS",
	"DOUBLE_PLUS",
	"DECIMAL_PLUS",
	"STRING_PLUS",
	"WSTRING_PLUS",
	"INTEGER_MINUS",
	"BIGINT_MINUS",
	"DOUBLE_MINUS",
	"DECIMAL_MINUS",
	"INTEGER_TIMES",
	"BIGINT_TIMES",
	"DOUBLE_TIMES",
	"DECIMAL_TIMES",
	"INTEGER_DIVIDE",
	"BIGINT_DIVIDE",
	"DOUBLE_DIVIDE",
	"DECIMAL_DIVIDE",
	"INTEGER_UNARY_MINUS",
	"BIGINT_UNARY_MINUS",
	"DOUBLE_UNARY_MINUS",
	"DECIMAL_UNARY_MINUS",
	"INTEGER_GETMEM",
	"BIGINT_GETMEM",
	"DOUBLE_GETMEM",
	"DECIMAL_GETMEM",
	"STRING_GETMEM",
	"WSTRING_GETMEM",
	"BOOLEAN_GETMEM",
	"DATETIME_GETMEM",
	"TIME_GETMEM",
	"ENUM_GETMEM",
	"BINARY_GETMEM",
	"INTEGER_SETMEM",
	"BIGINT_SETMEM",
	"DOUBLE_SETMEM",
	"DECIMAL_SETMEM",
	"STRING_SETMEM",
	"WSTRING_SETMEM",
	"BOOLEAN_SETMEM",
	"DATETIME_SETMEM",
	"TIME_SETMEM",
	"ENUM_SETMEM",
	"BINARY_SETMEM",
	"INTEGER_SETMEM_QUERY",
	"BIGINT_SETMEM_QUERY",
	"DOUBLE_SETMEM_QUERY",
	"DECIMAL_SETMEM_QUERY",
	"STRING_SETMEM_QUERY",
	"WSTRING_SETMEM_QUERY",
	"BOOLEAN_SETMEM_QUERY",
	"DATETIME_SETMEM_QUERY",
	"TIME_SETMEM_QUERY",
	"ENUM_SETMEM_QUERY",
	"BINARY_SETMEM_QUERY",
	"IFEXPR",
	"IFBLOCK",
	"RAISERRORINTEGER",
	"RAISERRORSTRING",
	"RAISERRORWSTRING",
	"RAISERROR2STRING",
	"RAISERROR2WSTRING",
	"STRING_LIKE",
	"WSTRING_LIKE",
	"STRING_PRINT",
	"WSTRING_PRINT",
	"INTEGER_MODULUS",
	"BIGINT_MODULUS",
	0
};

const unsigned long MTSQLTreeExecution::_tokenSet_0_data_[] = { 17317888UL, 0UL, 1UL, 0UL, 35667968UL, 161UL, 1072693248UL, 1585152UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "RETURN" IFTHENELSE QUERY RAISERROR2 SLIST 
// WHILE SEQUENCE INTEGER_SETMEM BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM 
// STRING_SETMEM WSTRING_SETMEM BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM 
// ENUM_SETMEM RAISERRORINTEGER RAISERRORSTRING STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeExecution::_tokenSet_0(_tokenSet_0_data_,16);
const unsigned long MTSQLTreeExecution::_tokenSet_1_data_[] = { 0UL, 2097154UL, 459264UL, 17235968UL, 526336UL, 0UL, 523776UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "FALSE" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL NUM_INT EXPR METHOD_CALL INTEGER_GETMEM 
// BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM WSTRING_GETMEM 
// BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeExecution::_tokenSet_1(_tokenSet_1_data_,16);


