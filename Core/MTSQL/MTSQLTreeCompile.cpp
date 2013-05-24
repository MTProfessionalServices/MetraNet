/* $ANTLR 2.7.6 (2005-12-22): "mtsql_compile.g" -> "MTSQLTreeCompile.cpp"$ */
#include "MTSQLTreeCompile.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "mtsql_compile.g"
#line 11 "MTSQLTreeCompile.cpp"
MTSQLTreeCompile::MTSQLTreeCompile()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void MTSQLTreeCompile::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		sl = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		statementList(_t);
		_t = _retTree;
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

void MTSQLTreeCompile::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 175 "mtsql_compile.g"
		
		// Allocate a register
		allocateRegister(var->getText());
			
#line 97 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void MTSQLTreeCompile::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void MTSQLTreeCompile::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 133 "mtsql_compile.g"
	
	
#line 162 "MTSQLTreeCompile.cpp"
	
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
		case BINARY_SETMEM:
		{
			setStatement(_t);
			_t = _retTree;
			break;
		}
		case TK_DECLARE:
		{
			localVariableDeclaration(_t);
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
		case QUERY:
		{
			queryStatement(_t);
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
		case RAISERRORWSTRING:
		{
			raiserrorWStringStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERRORINTEGER:
		{
			raiserrorIntegerStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERROR2STRING:
		{
			raiserror2StringStatement(_t);
			_t = _retTree;
			break;
		}
		case RAISERROR2WSTRING:
		{
			raiserror2WStringStatement(_t);
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

void MTSQLTreeCompile::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST iva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST iex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST biva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST biex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST eva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST eex = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bina = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST binex = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 194 "mtsql_compile.g"
	
	LexicalAddressPtr addr;
	
#line 322 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case INTEGER_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t17 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = _t;
			match(_t,INTEGER_SETMEM);
			_t = _t->getFirstChild();
			iva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			iex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t17;
			_t = _t->getNextSibling();
#line 200 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)iva)->getText());
			expression(iex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(iex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalIntegerSetmem(addr->getFrameAccess(), e));
			}
				
#line 358 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t18 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = _t;
			match(_t,BIGINT_SETMEM);
			_t = _t->getFirstChild();
			biva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			biex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t18;
			_t = _t->getNextSibling();
#line 216 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)biva)->getText());
			expression(biex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(biex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalBigIntSetmem(addr->getFrameAccess(), e));
			}
				
#line 391 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = _t;
			match(_t,DOUBLE_SETMEM);
			_t = _t->getFirstChild();
			dva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			dex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t19;
			_t = _t->getNextSibling();
#line 232 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)dva)->getText());
			expression(dex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(dex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalDoubleSetmem(addr->getFrameAccess(), e));
			}
				
#line 424 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = _t;
			match(_t,DECIMAL_SETMEM);
			_t = _t->getFirstChild();
			decva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			decex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t20;
			_t = _t->getNextSibling();
#line 248 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)decva)->getText());
			expression(decex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(decex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalDecimalSetmem(addr->getFrameAccess(), e));
			}
				
#line 457 "MTSQLTreeCompile.cpp"
			break;
		}
		case BOOLEAN_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t21 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = _t;
			match(_t,BOOLEAN_SETMEM);
			_t = _t->getFirstChild();
			bva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			bex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t21;
			_t = _t->getNextSibling();
#line 264 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)bva)->getText());
			expression(bex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(bex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalBooleanSetmem(addr->getFrameAccess(), e));
			}
				
#line 490 "MTSQLTreeCompile.cpp"
			break;
		}
		case STRING_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = _t;
			match(_t,STRING_SETMEM);
			_t = _t->getFirstChild();
			sva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			sex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t22;
			_t = _t->getNextSibling();
#line 280 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)sva)->getText());
			expression(sex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(sex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalStringSetmem(addr->getFrameAccess(), e));
			}
				
#line 523 "MTSQLTreeCompile.cpp"
			break;
		}
		case WSTRING_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t23 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = _t;
			match(_t,WSTRING_SETMEM);
			_t = _t->getFirstChild();
			wva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			wex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t23;
			_t = _t->getNextSibling();
#line 296 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)wva)->getText());
			expression(wex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(wex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalWideStringSetmem(addr->getFrameAccess(), e));
			}
				
#line 556 "MTSQLTreeCompile.cpp"
			break;
		}
		case DATETIME_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t24 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = _t;
			match(_t,DATETIME_SETMEM);
			_t = _t->getFirstChild();
			dtva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			dtex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t24;
			_t = _t->getNextSibling();
#line 312 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)dtva)->getText());
			expression(dtex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(dtex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeSetmem(addr->getFrameAccess(), e));
			}
				
#line 589 "MTSQLTreeCompile.cpp"
			break;
		}
		case TIME_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t25 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST_in = _t;
			match(_t,TIME_SETMEM);
			_t = _t->getFirstChild();
			tva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			tex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t25;
			_t = _t->getNextSibling();
#line 328 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)tva)->getText());
			expression(tex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(tex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalTimeSetmem(addr->getFrameAccess(), e));
			}
				
#line 622 "MTSQLTreeCompile.cpp"
			break;
		}
		case ENUM_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t26 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST_in = _t;
			match(_t,ENUM_SETMEM);
			_t = _t->getFirstChild();
			eva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			eex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t26;
			_t = _t->getNextSibling();
#line 344 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)eva)->getText());
			expression(eex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(eex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalEnumSetmem(addr->getFrameAccess(), e));
			}
				
#line 655 "MTSQLTreeCompile.cpp"
			break;
		}
		case BINARY_SETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t27 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = _t;
			match(_t,BINARY_SETMEM);
			_t = _t->getFirstChild();
			bina = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			addr=varAddress(_t);
			_t = _retTree;
			binex = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t27;
			_t = _t->getNextSibling();
#line 360 "mtsql_compile.g"
			
				    // Classify whether we are assigning to a register variable or not
				    if (isRegister(addr))
			{
			MTSQLRegister e = getRegister(((RefMTSQLAST)bina)->getText());
			expression(binex, e);
			}
			else
			{
			// Here we must move from a register into the global environment (e.g. session server,...)
			MTSQLRegister e = allocateRegister();
			expression(binex, e);
			mProg.push_back(MTSQLInstruction::CreateGlobalBinarySetmem(addr->getFrameAccess(), e));
			}
				
#line 688 "MTSQLTreeCompile.cpp"
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

void MTSQLTreeCompile::localVariableDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localVariableDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t15 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST_in = _t;
		match(_t,TK_DECLARE);
		_t = _t->getFirstChild();
		var = _t;
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		ty = _t;
		match(_t,BUILTIN_TYPE);
		_t = _t->getNextSibling();
		_t = __t15;
		_t = _t->getNextSibling();
#line 184 "mtsql_compile.g"
		
		// Allocate a register and set NULL value if local.
		allocateRegister(var->getText());
		MTSQLRegister reg = getRegister(var->getText());
		RuntimeValue nil;
			  mProg.push_back(MTSQLInstruction::CreateLoadNullImmediate(reg, nil));          
			
#line 731 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST print = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 382 "mtsql_compile.g"
	
	
#line 747 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t30 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST_in = _t;
		match(_t,STRING_PRINT);
		_t = _t->getFirstChild();
		print = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		_t = __t30;
		_t = _t->getNextSibling();
#line 387 "mtsql_compile.g"
		
		MTSQLRegister isOkToPrint=allocateRegister();
		MTSQLRegister printExpr=allocateRegister();
		// As an optimization, we only evaluate the argument to the print function if logging is enabled
		mProg.push_back(MTSQLInstruction::CreateIsOkPrint(isOkToPrint)); 
		// Use dummy label -1 for now, we find the branch location after the expression code is generated
		MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(isOkToPrint, -1);
		mProg.push_back(inst1);
		expression(print, printExpr);
		mProg.push_back(MTSQLInstruction::CreateStringPrint(printExpr));
		inst1->SetLabel(getNextLabel());
		
#line 772 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST print = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 401 "mtsql_compile.g"
	
	
#line 788 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t32 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST_in = _t;
		match(_t,WSTRING_PRINT);
		_t = _t->getFirstChild();
		print = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		_t = __t32;
		_t = _t->getNextSibling();
#line 406 "mtsql_compile.g"
		
		MTSQLRegister isOkToPrint=allocateRegister();
		MTSQLRegister printExpr=allocateRegister();
		// As an optimization, we only evaluate the argument to the print function if logging is enabled
		mProg.push_back(MTSQLInstruction::CreateIsOkPrint(isOkToPrint)); 
		// Use dummy label -1 for now, we find the branch location after the expression code is generated
		MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(isOkToPrint, -1);
		mProg.push_back(inst1);
		expression(print, printExpr);
		mProg.push_back(MTSQLInstruction::CreateWStringPrint(printExpr));
		inst1->SetLabel(getNextLabel());
		
#line 813 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t34 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST_in = _t;
		match(_t,SEQUENCE);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		statement(_t);
		_t = _retTree;
		_t = __t34;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifstmt = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elsestmt = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 646 "mtsql_compile.g"
	
	bool hasElse = false;
	MTSQLRegister ex=allocateRegister();
	
#line 855 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t57 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST_in = _t;
		match(_t,IFTHENELSE);
		_t = _t->getFirstChild();
		expression(_t,ex);
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
#line 652 "mtsql_compile.g"
			hasElse = true;
#line 878 "MTSQLTreeCompile.cpp"
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
		_t = __t57;
		_t = _t->getNextSibling();
#line 653 "mtsql_compile.g"
		
		MTSQLInstruction * inst = MTSQLInstruction::CreateBranchOnCondition(ex, 1);
		mProg.push_back(inst);
		// Don't know the branch label yet.  After generating code for if block we'll know,
		// so update then.
					delayedStatement(ifstmt);
					if(true == hasElse) 
		{
		// if there is an else block, then we need to have the if block skip to after
		// the else block
		MTSQLInstruction * inst2 = MTSQLInstruction::CreateGoto(-1);
		mProg.push_back(inst2);
		inst->SetLabel(getNextLabel());
		delayedStatement(elsestmt);
		inst2->SetLabel(getNextLabel());
		}
		else
		{
		inst->SetLabel(getNextLabel());
		}
				
#line 915 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t62 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = _t;
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
				goto _loop64;
			}
			
		}
		_loop64:;
		} // ( ... )*
		_t = __t62;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t66 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = _t;
		match(_t,TK_RETURN);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case EXPR:
		{
			expression(_t,0);
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
#line 690 "mtsql_compile.g"
		
		MTSQLInstruction * inst = MTSQLInstruction::CreateReturn();
		mProg.push_back(inst);
		
#line 992 "MTSQLTreeCompile.cpp"
		_t = __t66;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST q = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST p = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST out = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 426 "mtsql_compile.g"
	
	std::wstring s;
	
#line 1013 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t36 = _t;
		q = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		match(_t,QUERY);
		_t = _t->getFirstChild();
		p = _t;
		match(_t,ARRAY);
		_t = _t->getNextSibling();
		out = _t;
		match(_t,TK_INTO);
		_t = _t->getNextSibling();
		_t = __t36;
		_t = _t->getNextSibling();
#line 432 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateQueryAlloc(((RefMTSQLAST)q)->getValue()));
		localParamList(p);
		MTSQLInstruction * inst = MTSQLInstruction::CreateQueryExecute(-1);
		mProg.push_back(inst);
		setmemQuery(out);
		inst->SetLabel(getNextLabel());
		mProg.push_back(MTSQLInstruction::CreateQueryFree());
			
#line 1038 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST_in = _t;
		match(_t,TK_BREAK);
		_t = _t->getNextSibling();
#line 700 "mtsql_compile.g"
		
		MTSQLInstruction * inst = MTSQLInstruction::CreateGoto(-1);
		mProg.push_back(inst);
		mBreak.back()->push_back(inst);
		
#line 1061 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST_in = _t;
		match(_t,TK_CONTINUE);
		_t = _t->getNextSibling();
#line 710 "mtsql_compile.g"
		
		MTSQLInstruction * inst = MTSQLInstruction::CreateGoto(-1);
		mProg.push_back(inst);
		mContinue.back()->push_back(inst);
		
#line 1084 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST e = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t71 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = _t;
		match(_t,WHILE);
		_t = _t->getFirstChild();
		e = _t;
		match(_t,EXPR);
		_t = _t->getNextSibling();
		s = _t;
		match(_t,DELAYED_STMT);
		_t = _t->getNextSibling();
		_t = __t71;
		_t = _t->getNextSibling();
#line 720 "mtsql_compile.g"
		
		// Create a program label for the test expression.
		// Don't know where to branch after loop is done until
		// after the block is generated
		mContinue.push_back(new std::list<MTSQLInstruction *>());
		mBreak.push_back(new std::list<MTSQLInstruction *>());
		MTSQLProgramLabel label = getNextLabel();
		MTSQLRegister reg = allocateRegister();
		expression(e, reg);
		MTSQLInstruction * inst = MTSQLInstruction::CreateBranchOnCondition(reg, -1);
		mProg.push_back(inst);
		delayedStatement(s);
		mProg.push_back(MTSQLInstruction::CreateGoto(label));
		MTSQLProgramLabel label2 = getNextLabel();
		inst->SetLabel(label2);
		
		for(std::list<MTSQLInstruction *>::iterator it = mContinue.back()->begin(); it != mContinue.back()->end(); it++)
		{
		(*it)->SetLabel(label);
		}
		std::list<MTSQLInstruction *> * l = mContinue.back();
		mContinue.pop_back();
		delete l;
		
		for(std::list<MTSQLInstruction *>::iterator it = mBreak.back()->begin(); it != mBreak.back()->end(); it++)
		{
		(*it)->SetLabel(label2);
		}
		l = mBreak.back();
		mBreak.pop_back();
		delete l;
			
#line 1145 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 766 "mtsql_compile.g"
	
	MTSQLRegister s;
	s = allocateRegister();
	
#line 1162 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t75 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST_in = _t;
		match(_t,RAISERRORSTRING);
		_t = _t->getFirstChild();
		expression(_t,s);
		_t = _retTree;
		_t = __t75;
		_t = _t->getNextSibling();
#line 773 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateRaiseErrorString(s));   
			
#line 1177 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 778 "mtsql_compile.g"
	
	MTSQLRegister s;
	s = allocateRegister();
	
#line 1194 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t77 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST_in = _t;
		match(_t,RAISERRORWSTRING);
		_t = _t->getFirstChild();
		expression(_t,s);
		_t = _retTree;
		_t = __t77;
		_t = _t->getNextSibling();
#line 785 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateRaiseErrorWString(s));   
			
#line 1209 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 754 "mtsql_compile.g"
	
	MTSQLRegister i;
	i = allocateRegister();
	
#line 1226 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t73 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST_in = _t;
		match(_t,RAISERRORINTEGER);
		_t = _t->getFirstChild();
		expression(_t,i);
		_t = _retTree;
		_t = __t73;
		_t = _t->getNextSibling();
#line 761 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateRaiseErrorInteger(i));   
			
#line 1241 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 790 "mtsql_compile.g"
	
	MTSQLRegister i,s;
	s = allocateRegister();
	i = allocateRegister();
	
#line 1259 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t79 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST_in = _t;
		match(_t,RAISERROR2STRING);
		_t = _t->getFirstChild();
		expression(_t,i);
		_t = _retTree;
		expression(_t,s);
		_t = _retTree;
		_t = __t79;
		_t = _t->getNextSibling();
#line 798 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateRaiseErrorStringInteger(i, s));   
			
#line 1276 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 803 "mtsql_compile.g"
	
	MTSQLRegister i,s;
	s = allocateRegister();
	i = allocateRegister();
	
#line 1294 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t81 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST_in = _t;
		match(_t,RAISERROR2WSTRING);
		_t = _t->getFirstChild();
		expression(_t,i);
		_t = _retTree;
		expression(_t,s);
		_t = _retTree;
		_t = __t81;
		_t = _t->getNextSibling();
#line 811 "mtsql_compile.g"
		
		mProg.push_back(MTSQLInstruction::CreateRaiseErrorWStringInteger(i, s));   
			
#line 1311 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

LexicalAddressPtr  MTSQLTreeCompile::varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 377 "mtsql_compile.g"
	LexicalAddressPtr a;
#line 1324 "MTSQLTreeCompile.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST varAddress_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST l = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		l = _t;
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
#line 379 "mtsql_compile.g"
		a = ((RefMTSQLAST)l)->getAccess();
#line 1334 "MTSQLTreeCompile.cpp"
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
	return a;
}

void MTSQLTreeCompile::setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST iva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST biva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST eva = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bina = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 443 "mtsql_compile.g"
	
	int i=0;
	LexicalAddressPtr addr;
	
#line 1363 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t38 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = _t;
		match(_t,TK_INTO);
		_t = _t->getFirstChild();
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case INTEGER_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t40 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = _t;
				match(_t,INTEGER_SETMEM_QUERY);
				_t = _t->getFirstChild();
				iva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t40;
				_t = _t->getNextSibling();
#line 451 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)iva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryIntegerBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryIntegerBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalIntegerSetmem(addr->getFrameAccess(), e));
				}
					
#line 1402 "MTSQLTreeCompile.cpp"
				break;
			}
			case BIGINT_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t41 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = _t;
				match(_t,BIGINT_SETMEM_QUERY);
				_t = _t->getFirstChild();
				biva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t41;
				_t = _t->getNextSibling();
#line 467 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)biva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryBigIntBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryBigIntBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalBigIntSetmem(addr->getFrameAccess(), e));
				}
					
#line 1432 "MTSQLTreeCompile.cpp"
				break;
			}
			case DOUBLE_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t42 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = _t;
				match(_t,DOUBLE_SETMEM_QUERY);
				_t = _t->getFirstChild();
				dva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t42;
				_t = _t->getNextSibling();
#line 483 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)dva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryDoubleBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryDoubleBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalDoubleSetmem(addr->getFrameAccess(), e));
				}
					
#line 1462 "MTSQLTreeCompile.cpp"
				break;
			}
			case DECIMAL_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t43 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = _t;
				match(_t,DECIMAL_SETMEM_QUERY);
				_t = _t->getFirstChild();
				decva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t43;
				_t = _t->getNextSibling();
#line 499 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)decva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryDecimalBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryDecimalBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalDecimalSetmem(addr->getFrameAccess(), e));
				}
					
#line 1492 "MTSQLTreeCompile.cpp"
				break;
			}
			case BOOLEAN_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t44 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = _t;
				match(_t,BOOLEAN_SETMEM_QUERY);
				_t = _t->getFirstChild();
				bva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t44;
				_t = _t->getNextSibling();
#line 515 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)bva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryBooleanBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryBooleanBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalBooleanSetmem(addr->getFrameAccess(), e));
				}
					
#line 1522 "MTSQLTreeCompile.cpp"
				break;
			}
			case STRING_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t45 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = _t;
				match(_t,STRING_SETMEM_QUERY);
				_t = _t->getFirstChild();
				sva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t45;
				_t = _t->getNextSibling();
#line 531 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)sva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryStringBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryStringBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalStringSetmem(addr->getFrameAccess(), e));
				}
					
#line 1552 "MTSQLTreeCompile.cpp"
				break;
			}
			case WSTRING_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t46 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = _t;
				match(_t,WSTRING_SETMEM_QUERY);
				_t = _t->getFirstChild();
				wva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t46;
				_t = _t->getNextSibling();
#line 547 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)wva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryWideStringBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryWideStringBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalWideStringSetmem(addr->getFrameAccess(), e));
				}
					
#line 1582 "MTSQLTreeCompile.cpp"
				break;
			}
			case DATETIME_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t47 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = _t;
				match(_t,DATETIME_SETMEM_QUERY);
				_t = _t->getFirstChild();
				dtva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t47;
				_t = _t->getNextSibling();
#line 563 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)dtva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryDatetimeBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryDatetimeBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeSetmem(addr->getFrameAccess(), e));
				}
					
#line 1612 "MTSQLTreeCompile.cpp"
				break;
			}
			case TIME_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t48 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = _t;
				match(_t,TIME_SETMEM_QUERY);
				_t = _t->getFirstChild();
				tva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t48;
				_t = _t->getNextSibling();
#line 579 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)tva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryTimeBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryTimeBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalTimeSetmem(addr->getFrameAccess(), e));
				}
					
#line 1642 "MTSQLTreeCompile.cpp"
				break;
			}
			case ENUM_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t49 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = _t;
				match(_t,ENUM_SETMEM_QUERY);
				_t = _t->getFirstChild();
				eva = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t49;
				_t = _t->getNextSibling();
#line 595 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)eva)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryEnumBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryEnumBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalEnumSetmem(addr->getFrameAccess(), e));
				}
					
#line 1672 "MTSQLTreeCompile.cpp"
				break;
			}
			case BINARY_SETMEM_QUERY:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST __t50 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = _t;
				match(_t,BINARY_SETMEM_QUERY);
				_t = _t->getFirstChild();
				bina = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
				addr=varAddress(_t);
				_t = _retTree;
				_t = __t50;
				_t = _t->getNextSibling();
#line 611 "mtsql_compile.g"
				
					    // Classify whether we are assigning to a register variable or not
					    if (isRegister(addr))
				{
				MTSQLRegister e = getRegister(((RefMTSQLAST)bina)->getText());
				mProg.push_back(MTSQLInstruction::CreateQueryBinaryBindColumn(RuntimeValue::createLong(i++), e));
				}
				else
				{
				// Here we must move from a register into the global environment (e.g. session server,...)
				MTSQLRegister e = allocateRegister();
				mProg.push_back(MTSQLInstruction::CreateQueryBinaryBindColumn(RuntimeValue::createLong(i++), e));
				mProg.push_back(MTSQLInstruction::CreateGlobalBinarySetmem(addr->getFrameAccess(), e));
				}
					
#line 1702 "MTSQLTreeCompile.cpp"
				break;
			}
			default:
			{
				goto _loop51;
			}
			}
		}
		_loop51:;
		} // ( ... )*
		_t = __t38;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 630 "mtsql_compile.g"
	
	int i = 0;
	
#line 1730 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t53 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = _t;
		match(_t,ARRAY);
		_t = _t->getFirstChild();
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_tokenSet_1.member(_t->getType()))) {
#line 636 "mtsql_compile.g"
				
				MTSQLRegister e = allocateRegister();
				
#line 1746 "MTSQLTreeCompile.cpp"
				primaryExpression(_t,e);
				_t = _retTree;
#line 640 "mtsql_compile.g"
				
				mProg.push_back(MTSQLInstruction::CreateQueryBindParam(RuntimeValue::createLong(i++), e)); 
				
#line 1753 "MTSQLTreeCompile.cpp"
			}
			else {
				goto _loop55;
			}
			
		}
		_loop55:;
		} // ( ... )*
		_t = __t53;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	MTSQLRegister reg
) {
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
	ANTLR_USE_NAMESPACE(antlr)RefAST mc = ANTLR_USE_NAMESPACE(antlr)nullAST;
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
	ANTLR_USE_NAMESPACE(antlr)RefAST bin = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1121 "mtsql_compile.g"
	
	std::vector<MTSQLRegister> r;
	
#line 1804 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case NUM_INT:
		{
			i = _t;
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 1127 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadIntegerImmediate(reg, ((RefMTSQLAST)i)->getValue()));
					
#line 1819 "MTSQLTreeCompile.cpp"
			break;
		}
		case NUM_BIGINT:
		{
			bi = _t;
			match(_t,NUM_BIGINT);
			_t = _t->getNextSibling();
#line 1131 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadBigIntImmediate(reg, ((RefMTSQLAST)bi)->getValue()));
					
#line 1831 "MTSQLTreeCompile.cpp"
			break;
		}
		case NUM_FLOAT:
		{
			d = _t;
			match(_t,NUM_FLOAT);
			_t = _t->getNextSibling();
#line 1135 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadDoubleImmediate(reg, ((RefMTSQLAST)d)->getValue()));
					
#line 1843 "MTSQLTreeCompile.cpp"
			break;
		}
		case NUM_DECIMAL:
		{
			dec = _t;
			match(_t,NUM_DECIMAL);
			_t = _t->getNextSibling();
#line 1139 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadDecimalImmediate(reg, ((RefMTSQLAST)dec)->getValue()));
					
#line 1855 "MTSQLTreeCompile.cpp"
			break;
		}
		case STRING_LITERAL:
		{
			s = _t;
			match(_t,STRING_LITERAL);
			_t = _t->getNextSibling();
#line 1143 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadStringImmediate(reg, ((RefMTSQLAST)s)->getValue()));
					
#line 1867 "MTSQLTreeCompile.cpp"
			break;
		}
		case WSTRING_LITERAL:
		{
			ws = _t;
			match(_t,WSTRING_LITERAL);
			_t = _t->getNextSibling();
#line 1147 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadWideStringImmediate(reg, ((RefMTSQLAST)ws)->getValue()));
					
#line 1879 "MTSQLTreeCompile.cpp"
			break;
		}
		case ENUM_LITERAL:
		{
			e = _t;
			match(_t,ENUM_LITERAL);
			_t = _t->getNextSibling();
#line 1151 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadEnumImmediate(reg, ((RefMTSQLAST)e)->getValue()));
					
#line 1891 "MTSQLTreeCompile.cpp"
			break;
		}
		case TK_TRUE:
		{
			t = _t;
			match(_t,TK_TRUE);
			_t = _t->getNextSibling();
#line 1155 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadBooleanImmediate(reg, ((RefMTSQLAST)t)->getValue()));
					
#line 1903 "MTSQLTreeCompile.cpp"
			break;
		}
		case TK_FALSE:
		{
			f = _t;
			match(_t,TK_FALSE);
			_t = _t->getNextSibling();
#line 1159 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadBooleanImmediate(reg, ((RefMTSQLAST)f)->getValue()));
					
#line 1915 "MTSQLTreeCompile.cpp"
			break;
		}
		case TK_NULL:
		{
			nil = _t;
			match(_t,TK_NULL);
			_t = _t->getNextSibling();
#line 1163 "mtsql_compile.g"
			
						mProg.push_back(MTSQLInstruction::CreateLoadNullImmediate(reg, ((RefMTSQLAST)nil)->getValue()));
					
#line 1927 "MTSQLTreeCompile.cpp"
			break;
		}
		case METHOD_CALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t149 = _t;
			mc = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
			match(_t,METHOD_CALL);
			_t = _t->getFirstChild();
			id = _t;
			match(_t,ID);
			_t = _t->getNextSibling();
			r=elist(_t);
			_t = _retTree;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = _t;
			match(_t,RPAREN);
			_t = _t->getNextSibling();
			_t = __t149;
			_t = _t->getNextSibling();
#line 1167 "mtsql_compile.g"
			
			const char * text = ((RefMTSQLAST)mc)->getValue().getStringPtr();
				mProg.push_back(MTSQLInstruction::ExecutePrimitiveFunction(text, r, reg));
			
#line 1951 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_GETMEM:
		{
			igm = _t;
			match(_t,INTEGER_GETMEM);
			_t = _t->getNextSibling();
#line 1172 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)igm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)igm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalIntegerGetmem(((RefMTSQLAST)igm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 1970 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_GETMEM:
		{
			bigm = _t;
			match(_t,BIGINT_GETMEM);
			_t = _t->getNextSibling();
#line 1183 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)bigm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bigm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalBigIntGetmem(((RefMTSQLAST)bigm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 1989 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_GETMEM:
		{
			dgm = _t;
			match(_t,DOUBLE_GETMEM);
			_t = _t->getNextSibling();
#line 1194 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)dgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)dgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalDoubleGetmem(((RefMTSQLAST)dgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2008 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_GETMEM:
		{
			decgm = _t;
			match(_t,DECIMAL_GETMEM);
			_t = _t->getNextSibling();
#line 1205 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)decgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)decgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalDecimalGetmem(((RefMTSQLAST)decgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2027 "MTSQLTreeCompile.cpp"
			break;
		}
		case BOOLEAN_GETMEM:
		{
			bgm = _t;
			match(_t,BOOLEAN_GETMEM);
			_t = _t->getNextSibling();
#line 1216 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)bgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalBooleanGetmem(((RefMTSQLAST)bgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2046 "MTSQLTreeCompile.cpp"
			break;
		}
		case STRING_GETMEM:
		{
			sgm = _t;
			match(_t,STRING_GETMEM);
			_t = _t->getNextSibling();
#line 1227 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)sgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)sgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalStringGetmem(((RefMTSQLAST)sgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2065 "MTSQLTreeCompile.cpp"
			break;
		}
		case WSTRING_GETMEM:
		{
			wsgm = _t;
			match(_t,WSTRING_GETMEM);
			_t = _t->getNextSibling();
#line 1238 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)wsgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)wsgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalWideStringGetmem(((RefMTSQLAST)wsgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2084 "MTSQLTreeCompile.cpp"
			break;
		}
		case DATETIME_GETMEM:
		{
			dtgm = _t;
			match(_t,DATETIME_GETMEM);
			_t = _t->getNextSibling();
#line 1249 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)dtgm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)dtgm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalDatetimeGetmem(((RefMTSQLAST)dtgm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2103 "MTSQLTreeCompile.cpp"
			break;
		}
		case TIME_GETMEM:
		{
			tm = _t;
			match(_t,TIME_GETMEM);
			_t = _t->getNextSibling();
#line 1260 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)tm)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)tm)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalTimeGetmem(((RefMTSQLAST)tm)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2122 "MTSQLTreeCompile.cpp"
			break;
		}
		case ENUM_GETMEM:
		{
			en = _t;
			match(_t,ENUM_GETMEM);
			_t = _t->getNextSibling();
#line 1271 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)en)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)en)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalEnumGetmem(((RefMTSQLAST)en)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2141 "MTSQLTreeCompile.cpp"
			break;
		}
		case BINARY_GETMEM:
		{
			bin = _t;
			match(_t,BINARY_GETMEM);
			_t = _t->getNextSibling();
#line 1282 "mtsql_compile.g"
			
			if(isRegister(((RefMTSQLAST)bin)->getAccess()))
			{
			mProg.push_back(MTSQLInstruction::CreateMove(getRegister(((RefMTSQLAST)bin)->getText()), reg));
			}
			else
			{
			mProg.push_back(MTSQLInstruction::CreateGlobalBinaryGetmem(((RefMTSQLAST)bin)->getAccess()->getFrameAccess(), reg));
			}
			
#line 2160 "MTSQLTreeCompile.cpp"
			break;
		}
		case EXPR:
		{
			expression(_t,reg);
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

void MTSQLTreeCompile::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	MTSQLRegister result
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 824 "mtsql_compile.g"
	
	
#line 2190 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t88 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = _t;
		match(_t,EXPR);
		_t = _t->getFirstChild();
		expr(_t,result);
		_t = _retTree;
		_t = __t88;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

void MTSQLTreeCompile::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t60 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = _t;
		match(_t,DELAYED_STMT);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		_t = __t60;
		_t = _t->getNextSibling();
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		if ( _t != ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = _t->getNextSibling();
	}
	_retTree = _t;
}

std::vector<MTSQLRegister>  MTSQLTreeCompile::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 816 "mtsql_compile.g"
	std::vector<MTSQLRegister> r;
#line 2234 "MTSQLTreeCompile.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
#line 816 "mtsql_compile.g"
	
	MTSQLRegister reg;
	
#line 2240 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST __t83 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = _t;
		match(_t,ELIST);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case EXPR:
		{
			expression(_t,reg=allocateRegister());
			_t = _retTree;
#line 821 "mtsql_compile.g"
			r.push_back(reg);
#line 2257 "MTSQLTreeCompile.cpp"
			{ // ( ... )*
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == COMMA)) {
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = _t;
					match(_t,COMMA);
					_t = _t->getNextSibling();
					expression(_t,reg=allocateRegister());
					_t = _retTree;
#line 821 "mtsql_compile.g"
					r.push_back(reg);
#line 2270 "MTSQLTreeCompile.cpp"
				}
				else {
					goto _loop86;
				}
				
			}
			_loop86:;
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
		_t = __t83;
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

void MTSQLTreeCompile::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	MTSQLRegister result
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST andrhs = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST orrhs = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 831 "mtsql_compile.g"
	
	MTSQLRegister lhs, rhs, e;
	lhs = allocateRegister();
	rhs = allocateRegister();
	e = allocateRegister();
	
#line 2316 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case BAND:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t90 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = _t;
			match(_t,BAND);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t90;
			_t = _t->getNextSibling();
#line 841 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBitwiseAndInteger(lhs, rhs, result));   
					
#line 2338 "MTSQLTreeCompile.cpp"
			break;
		}
		case BNOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = _t;
			match(_t,BNOT);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t91;
			_t = _t->getNextSibling();
#line 845 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBitwiseNotInteger(lhs, result));   
					
#line 2355 "MTSQLTreeCompile.cpp"
			break;
		}
		case BOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t92 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = _t;
			match(_t,BOR);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t92;
			_t = _t->getNextSibling();
#line 849 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBitwiseOrInteger(lhs, rhs, result));   
					
#line 2374 "MTSQLTreeCompile.cpp"
			break;
		}
		case BXOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = _t;
			match(_t,BXOR);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t93;
			_t = _t->getNextSibling();
#line 853 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBitwiseXorInteger(lhs, rhs, result));   
			
#line 2393 "MTSQLTreeCompile.cpp"
			break;
		}
		case LAND:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t94 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = _t;
			match(_t,LAND);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			andrhs = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t94;
			_t = _t->getNextSibling();
#line 858 "mtsql_compile.g"
			
			// Check the lhs first, if false then don't execute the rhs  
			MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(lhs, -1);
			mProg.push_back(inst1);
			expression(andrhs, result);
			MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
			mProg.push_back(gotoInst);
			inst1->SetLabel(getNextLabel());
			mProg.push_back(MTSQLInstruction::CreateMove(lhs, result));
			gotoInst->SetLabel(getNextLabel());
				
#line 2421 "MTSQLTreeCompile.cpp"
			break;
		}
		case LOR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = _t;
			match(_t,LOR);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			orrhs = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t95;
			_t = _t->getNextSibling();
#line 870 "mtsql_compile.g"
			
			// Check the lhs first, if true then don't execute the rhs  
			MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(lhs, -1);
			mProg.push_back(inst1);
			mProg.push_back(MTSQLInstruction::CreateMove(lhs, result));
			MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
			mProg.push_back(gotoInst);
			inst1->SetLabel(getNextLabel());
			expression(orrhs, result);
			gotoInst->SetLabel(getNextLabel());
					
#line 2449 "MTSQLTreeCompile.cpp"
			break;
		}
		case LNOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t96 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = _t;
			match(_t,LNOT);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t96;
			_t = _t->getNextSibling();
#line 882 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateLNot(lhs, result));
					
#line 2466 "MTSQLTreeCompile.cpp"
			break;
		}
		case EQUALS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t97 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = _t;
			match(_t,EQUALS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t97;
			_t = _t->getNextSibling();
#line 887 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateEquals(lhs, rhs, result));   
			
#line 2485 "MTSQLTreeCompile.cpp"
			break;
		}
		case GT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t98 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = _t;
			match(_t,GT);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t98;
			_t = _t->getNextSibling();
#line 891 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateGreaterThan(lhs, rhs, result));   
			
#line 2504 "MTSQLTreeCompile.cpp"
			break;
		}
		case GTEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t99 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = _t;
			match(_t,GTEQ);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t99;
			_t = _t->getNextSibling();
#line 895 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateGreaterThanEquals(lhs, rhs, result));   
			
#line 2523 "MTSQLTreeCompile.cpp"
			break;
		}
		case LTN:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = _t;
			match(_t,LTN);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t100;
			_t = _t->getNextSibling();
#line 899 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateLessThan(lhs, rhs, result));   
			
#line 2542 "MTSQLTreeCompile.cpp"
			break;
		}
		case LTEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t101 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = _t;
			match(_t,LTEQ);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t101;
			_t = _t->getNextSibling();
#line 903 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateLessThanEquals(lhs, rhs, result));   
			
#line 2561 "MTSQLTreeCompile.cpp"
			break;
		}
		case NOTEQUALS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t102 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = _t;
			match(_t,NOTEQUALS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t102;
			_t = _t->getNextSibling();
#line 907 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateNotEquals(lhs, rhs, result));   
			
#line 2580 "MTSQLTreeCompile.cpp"
			break;
		}
		case ISNULL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = _t;
			match(_t,ISNULL);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t103;
			_t = _t->getNextSibling();
#line 912 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIsNull(lhs, result));   
			
#line 2597 "MTSQLTreeCompile.cpp"
			break;
		}
		case STRING_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t104 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = _t;
			match(_t,STRING_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t104;
			_t = _t->getNextSibling();
#line 917 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateStringPlus(lhs, rhs, result));   
			
#line 2616 "MTSQLTreeCompile.cpp"
			break;
		}
		case WSTRING_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = _t;
			match(_t,WSTRING_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t105;
			_t = _t->getNextSibling();
#line 921 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateWideStringPlus(lhs, rhs, result));   
			
#line 2635 "MTSQLTreeCompile.cpp"
			break;
		}
		case STRING_LIKE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t106 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = _t;
			match(_t,STRING_LIKE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t106;
			_t = _t->getNextSibling();
#line 925 "mtsql_compile.g"
			
									mProg.push_back(MTSQLInstruction::CreateStringLike(lhs, rhs, result));
			
#line 2654 "MTSQLTreeCompile.cpp"
			break;
		}
		case WSTRING_LIKE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t107 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = _t;
			match(_t,WSTRING_LIKE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t107;
			_t = _t->getNextSibling();
#line 929 "mtsql_compile.g"
			
									mProg.push_back(MTSQLInstruction::CreateWideStringLike(lhs, rhs, result));
			
#line 2673 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t108 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = _t;
			match(_t,INTEGER_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t108;
			_t = _t->getNextSibling();
#line 934 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerMinus(lhs, rhs, result));   
			
#line 2692 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = _t;
			match(_t,INTEGER_DIVIDE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t109;
			_t = _t->getNextSibling();
#line 938 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerDivide(lhs, rhs, result));   
			
#line 2711 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t110 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = _t;
			match(_t,INTEGER_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t110;
			_t = _t->getNextSibling();
#line 942 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerPlus(lhs, rhs, result));   
			
#line 2730 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = _t;
			match(_t,INTEGER_TIMES);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t111;
			_t = _t->getNextSibling();
#line 946 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerTimes(lhs, rhs, result));   
			
#line 2749 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t112 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = _t;
			match(_t,INTEGER_UNARY_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t112;
			_t = _t->getNextSibling();
#line 950 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerUnaryMinus(lhs, result));   
			
#line 2766 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t113 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = _t;
			match(_t,BIGINT_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t113;
			_t = _t->getNextSibling();
#line 954 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntMinus(lhs, rhs, result));   
			
#line 2785 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = _t;
			match(_t,BIGINT_DIVIDE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t114;
			_t = _t->getNextSibling();
#line 958 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntDivide(lhs, rhs, result));   
			
#line 2804 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = _t;
			match(_t,BIGINT_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t115;
			_t = _t->getNextSibling();
#line 962 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntPlus(lhs, rhs, result));   
			
#line 2823 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t116 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = _t;
			match(_t,BIGINT_TIMES);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t116;
			_t = _t->getNextSibling();
#line 966 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntTimes(lhs, rhs, result));   
			
#line 2842 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = _t;
			match(_t,BIGINT_UNARY_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t117;
			_t = _t->getNextSibling();
#line 970 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntUnaryMinus(lhs, result));   
			
#line 2859 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t118 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = _t;
			match(_t,DOUBLE_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t118;
			_t = _t->getNextSibling();
#line 974 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDoubleMinus(lhs, rhs, result));   
			
#line 2878 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = _t;
			match(_t,DOUBLE_DIVIDE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t119;
			_t = _t->getNextSibling();
#line 978 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDoubleDivide(lhs, rhs, result));   
			
#line 2897 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t120 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = _t;
			match(_t,DOUBLE_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t120;
			_t = _t->getNextSibling();
#line 982 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDoublePlus(lhs, rhs, result));   
			
#line 2916 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = _t;
			match(_t,DOUBLE_TIMES);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t121;
			_t = _t->getNextSibling();
#line 986 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDoubleTimes(lhs, rhs, result));   
			
#line 2935 "MTSQLTreeCompile.cpp"
			break;
		}
		case DOUBLE_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t122 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = _t;
			match(_t,DOUBLE_UNARY_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t122;
			_t = _t->getNextSibling();
#line 990 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDoubleUnaryMinus(lhs, result));   
			
#line 2952 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = _t;
			match(_t,DECIMAL_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t123;
			_t = _t->getNextSibling();
#line 994 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDecimalMinus(lhs, rhs, result));   
			
#line 2971 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_DIVIDE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t124 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = _t;
			match(_t,DECIMAL_DIVIDE);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t124;
			_t = _t->getNextSibling();
#line 998 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDecimalDivide(lhs, rhs, result));   
			
#line 2990 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_PLUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = _t;
			match(_t,DECIMAL_PLUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t125;
			_t = _t->getNextSibling();
#line 1002 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDecimalPlus(lhs, rhs, result));   
			
#line 3009 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_TIMES:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t126 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = _t;
			match(_t,DECIMAL_TIMES);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t126;
			_t = _t->getNextSibling();
#line 1006 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDecimalTimes(lhs, rhs, result));   
			
#line 3028 "MTSQLTreeCompile.cpp"
			break;
		}
		case DECIMAL_UNARY_MINUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = _t;
			match(_t,DECIMAL_UNARY_MINUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			_t = __t127;
			_t = _t->getNextSibling();
#line 1010 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateDecimalUnaryMinus(lhs, result));   
			
#line 3045 "MTSQLTreeCompile.cpp"
			break;
		}
		case INTEGER_MODULUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t128 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = _t;
			match(_t,INTEGER_MODULUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t128;
			_t = _t->getNextSibling();
#line 1014 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateIntegerModulus(lhs, rhs, result));   
			
#line 3064 "MTSQLTreeCompile.cpp"
			break;
		}
		case BIGINT_MODULUS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = _t;
			match(_t,BIGINT_MODULUS);
			_t = _t->getFirstChild();
			expr(_t,lhs);
			_t = _retTree;
			expr(_t,rhs);
			_t = _retTree;
			_t = __t129;
			_t = _t->getNextSibling();
#line 1018 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateBigIntModulus(lhs, rhs, result));   
			
#line 3083 "MTSQLTreeCompile.cpp"
			break;
		}
		case IFBLOCK:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t130 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = _t;
			match(_t,IFBLOCK);
			_t = _t->getFirstChild();
			{
#line 1023 "mtsql_compile.g"
			
			std::vector<MTSQLInstruction*> gotos;
			bool hasElse = false;
			
#line 3098 "MTSQLTreeCompile.cpp"
			{ // ( ... )+
			int _cnt133=0;
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == EXPR || _t->getType() == IFEXPR)) {
					ifThenElse(_t,gotos, hasElse, result);
					_t = _retTree;
				}
				else {
					if ( _cnt133>=1 ) { goto _loop133; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
				}
				
				_cnt133++;
			}
			_loop133:;
			}  // ( ... )+
#line 1028 "mtsql_compile.g"
			
			if (false == hasElse)
			{
			std::string errMsg = 
			"While executing an MTSQL statement, encountered a "
			"'case' statement that could not be evaluated.  None of "
			"'when' branches matched the value being processed.  "
			"Consider adding an 'else' statement which "
			"would be executed when there "
			"are no matching 'when' branches.  This is the code "
			"causing the error: ";
			errMsg += mSourceCode;
											  mProg.push_back(MTSQLInstruction::CreateThrow(
			RuntimeValue::createString(errMsg.c_str())));
			}
			// Fix up all gotos to branch after the case statement.
			for(std::size_t i = 0; i<gotos.size(); i++)
			{
			gotos[i]->SetLabel(getNextLabel());
			}
			
#line 3138 "MTSQLTreeCompile.cpp"
			}
			_t = __t130;
			_t = _t->getNextSibling();
			break;
		}
		case ESEQ:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t134 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = _t;
			match(_t,ESEQ);
			_t = _t->getFirstChild();
			statement(_t);
			_t = _retTree;
			expr(_t,result);
			_t = _retTree;
			_t = __t134;
			_t = _t->getNextSibling();
			break;
		}
		case CAST_TO_INTEGER:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = _t;
			match(_t,CAST_TO_INTEGER);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t135;
			_t = _t->getNextSibling();
#line 1053 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToInteger(lhs, result));
			
#line 3172 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_BIGINT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t136 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = _t;
			match(_t,CAST_TO_BIGINT);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t136;
			_t = _t->getNextSibling();
#line 1057 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToBigInt(lhs, result));
			
#line 3189 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_DOUBLE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t137 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = _t;
			match(_t,CAST_TO_DOUBLE);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t137;
			_t = _t->getNextSibling();
#line 1061 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToDouble(lhs, result));
			
#line 3206 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_DECIMAL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t138 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = _t;
			match(_t,CAST_TO_DECIMAL);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t138;
			_t = _t->getNextSibling();
#line 1065 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToDecimal(lhs, result));
			
#line 3223 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_STRING:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = _t;
			match(_t,CAST_TO_STRING);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t139;
			_t = _t->getNextSibling();
#line 1069 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToString(lhs, result));
			
#line 3240 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_WSTRING:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t140 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = _t;
			match(_t,CAST_TO_WSTRING);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t140;
			_t = _t->getNextSibling();
#line 1073 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToWideString(lhs, result));
			
#line 3257 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_BOOLEAN:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t141 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = _t;
			match(_t,CAST_TO_BOOLEAN);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t141;
			_t = _t->getNextSibling();
#line 1077 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToBoolean(lhs, result));
			
#line 3274 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_DATETIME:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t142 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = _t;
			match(_t,CAST_TO_DATETIME);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t142;
			_t = _t->getNextSibling();
#line 1081 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToDatetime(lhs, result));
			
#line 3291 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_TIME:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t143 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = _t;
			match(_t,CAST_TO_TIME);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t143;
			_t = _t->getNextSibling();
#line 1085 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToTime(lhs, result));
			
#line 3308 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_ENUM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t144 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = _t;
			match(_t,CAST_TO_ENUM);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t144;
			_t = _t->getNextSibling();
#line 1089 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToEnum(lhs, result));
			
#line 3325 "MTSQLTreeCompile.cpp"
			break;
		}
		case CAST_TO_BINARY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = _t;
			match(_t,CAST_TO_BINARY);
			_t = _t->getFirstChild();
			expression(_t,lhs);
			_t = _retTree;
			_t = __t145;
			_t = _t->getNextSibling();
#line 1093 "mtsql_compile.g"
			
			mProg.push_back(MTSQLInstruction::CreateCastToBinary(lhs, result));
			
#line 3342 "MTSQLTreeCompile.cpp"
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
		case BINARY_GETMEM:
		{
			primaryExpression(_t,result);
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

void MTSQLTreeCompile::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	std::vector<MTSQLInstruction *>& gotos, bool& hasElse, MTSQLRegister result
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST action = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1099 "mtsql_compile.g"
	
	MTSQLRegister cond;
	cond = allocateRegister();
	
#line 3397 "MTSQLTreeCompile.cpp"
	
	try {      // for error handling
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case IFEXPR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t147 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = _t;
			match(_t,IFEXPR);
			_t = _t->getFirstChild();
			expr(_t,cond);
			_t = _retTree;
			action = _t;
			match(_t,EXPR);
			_t = _t->getNextSibling();
			_t = __t147;
			_t = _t->getNextSibling();
#line 1105 "mtsql_compile.g"
			
			// Check the value in condition and branch to as yet undetermined label after action.
			// If match, then evaluate action and branch to end of case statement (not yet determined).
			// Fix up branch of false to after action.
			MTSQLInstruction * inst1 = MTSQLInstruction::CreateBranchOnCondition(cond, -1);
			mProg.push_back(inst1);
			expression(action, result);
			MTSQLInstruction * gotoInst = MTSQLInstruction::CreateGoto(-1);
			mProg.push_back(gotoInst);
			gotos.push_back(gotoInst);
			inst1->SetLabel(getNextLabel());
			
#line 3429 "MTSQLTreeCompile.cpp"
			break;
		}
		case EXPR:
		{
			expression(_t,result);
			_t = _retTree;
#line 1117 "mtsql_compile.g"
			hasElse = true;
#line 3438 "MTSQLTreeCompile.cpp"
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

void MTSQLTreeCompile::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* MTSQLTreeCompile::tokenNames[] = {
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

const unsigned long MTSQLTreeCompile::_tokenSet_0_data_[] = { 17317888UL, 0UL, 1UL, 0UL, 2113536UL, 161UL, 2146435072UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "RETURN" IFTHENELSE QUERY SLIST WHILE SEQUENCE 
// INTEGER_SETMEM BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM 
// WSTRING_SETMEM BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM 
// BINARY_SETMEM RAISERRORINTEGER RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING 
// RAISERROR2WSTRING STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeCompile::_tokenSet_0(_tokenSet_0_data_,16);
const unsigned long MTSQLTreeCompile::_tokenSet_1_data_[] = { 0UL, 2097154UL, 459264UL, 17235968UL, 526336UL, 0UL, 1048064UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "FALSE" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL NUM_INT EXPR METHOD_CALL INTEGER_GETMEM 
// BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM WSTRING_GETMEM 
// BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM BINARY_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeCompile::_tokenSet_1(_tokenSet_1_data_,16);


