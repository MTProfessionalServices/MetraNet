/* $ANTLR 2.7.6 (2005-12-22): "mtsql_tree.g" -> "MTSQLTreeParser.cpp"$ */
#include "MTSQLTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "mtsql_tree.g"
#line 11 "MTSQLTreeParser.cpp"
MTSQLTreeParser::MTSQLTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void MTSQLTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
#line 675 "mtsql_tree.g"
	mReturnType = TYPE_BOOLEAN;
#line 24 "MTSQLTreeParser.cpp"
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_DECLARE)) {
			typeDeclaration(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
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
		astFactory->addASTChild( currentAST, returnAST );
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
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp1_AST = astFactory->create(_t);
	tmp1_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp1_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST5 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SCOPE);
	_t = _t->getFirstChild();
#line 675 "mtsql_tree.g"
	mEnv->beginScope();
#line 75 "MTSQLTreeParser.cpp"
	statementList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
#line 675 "mtsql_tree.g"
	mEnv->endScope();
#line 81 "MTSQLTreeParser.cpp"
	currentAST = __currentAST5;
	_t = __t5;
	_t = _t->getNextSibling();
	program_AST = currentAST.root;
	returnAST = program_AST;
	_retTree = _t;
}

void MTSQLTreeParser::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ou = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ou_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t13 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp2_AST = astFactory->create(_t);
	tmp2_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp2_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST13 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_DECLARE);
	_t = _t->getFirstChild();
	var = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST var_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	var_AST = astFactory->create(var);
	astFactory->addASTChild(currentAST, var_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	ty = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ty_AST = astFactory->create(ty);
	astFactory->addASTChild(currentAST, ty_AST);
	match(_t,BUILTIN_TYPE);
	_t = _t->getNextSibling();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_OUTPUT:
	{
		ou = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST ou_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ou_AST = astFactory->create(ou);
		astFactory->addASTChild(currentAST, ou_AST);
		match(_t,TK_OUTPUT);
		_t = _t->getNextSibling();
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
	currentAST = __currentAST13;
	_t = __t13;
	_t = _t->getNextSibling();
	typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 741 "mtsql_tree.g"
	
				AccessPtr varAccess(mEnv->allocateVariable(var->getText(), getType(ty->getText())));
				if (varAccess == nullAccess)
	{
	throw MTSQLSemanticException((boost::format("Undefined variable: %1%") % var->getText()).str(), (RefMTSQLAST)typeDeclaration_AST);
	}
				mEnv->insertVar(
				var->getText(), 
				VarEntry::create(getType(ty->getText()), varAccess, mEnv->getCurrentLevel())); 
				//save parameter info in the vector
				if(mEnv->getCurrentLevel() == 1 /*we want to ignore local variables, is there a better way?*/)
				{
					MTSQLParam param;
					param.SetName(var->getText());
					param.SetType(getType(ty->getText()));
					if(ou.get() != 0)
						param.SetDirection(DIRECTION_OUT);
					mParams.push_back(param);
				}
			
#line 174 "MTSQLTreeParser.cpp"
	typeDeclaration_AST = currentAST.root;
	returnAST = typeDeclaration_AST;
	_retTree = _t;
}

void MTSQLTreeParser::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t7 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp3_AST = astFactory->create(_t);
	tmp3_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp3_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST7 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_RETURNS);
	_t = _t->getFirstChild();
	ty = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ty_AST = astFactory->create(ty);
	astFactory->addASTChild(currentAST, ty_AST);
	match(_t,BUILTIN_TYPE);
	_t = _t->getNextSibling();
	currentAST = __currentAST7;
	_t = __t7;
	_t = _t->getNextSibling();
#line 680 "mtsql_tree.g"
	mReturnType = getType(ty->getText());
#line 210 "MTSQLTreeParser.cpp"
	returnsDeclaration_AST = currentAST.root;
	returnAST = returnsDeclaration_AST;
	_retTree = _t;
}

void MTSQLTreeParser::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_0.member(_t->getType()))) {
			statement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop10;
		}
		
	}
	_loop10:;
	} // ( ... )*
	statementList_AST = currentAST.root;
	returnAST = statementList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ASSIGN:
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
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_DECLARE:
	{
		typeDeclaration(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_PRINT:
	{
		printStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case STRING_PRINT:
	{
		stringPrintStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case WSTRING_PRINT:
	{
		wstringPrintStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case SEQUENCE:
	{
		seq(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_SELECT:
	{
#line 701 "mtsql_tree.g"
		
		enterQuery();
		
#line 317 "MTSQLTreeParser.cpp"
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 705 "mtsql_tree.g"
		
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(4))->add(astFactory->create(QUERY,"QUERY"))->add(statement_AST)->add(getQueryInputs())->add(getInto(statement_AST)))); 
		
#line 326 "MTSQLTreeParser.cpp"
		currentAST.root = statement_AST;
		if ( statement_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			statement_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = statement_AST->getFirstChild();
		else
			currentAST.child = statement_AST;
		currentAST.advanceChildToEnd();
		statement_AST = currentAST.root;
		break;
	}
	case QUERY:
	{
		mtsql_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case IFTHENELSE:
	{
		ifStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case SLIST:
	{
		listOfStatements(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_RETURN:
	{
		returnStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_BREAK:
	{
		breakStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case TK_CONTINUE:
	{
		continueStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case WHILE:
	{
		whileStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERROR1:
	{
		raiserror1Statement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERRORINTEGER:
	{
		raiserrorIntegerStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERRORSTRING:
	{
		raiserrorStringStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERRORWSTRING:
	{
		raiserrorWStringStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERROR2:
	{
		raiserror2Statement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERROR2STRING:
	{
		raiserror2StringStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	case RAISERROR2WSTRING:
	{
		raiserror2WStringStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = statement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 779 "mtsql_tree.g"
	
	int r=TYPE_INVALID;
	int e=TYPE_INVALID;
	
#line 468 "MTSQLTreeParser.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ASSIGN:
	{
		genericSetStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		setStatement_AST = currentAST.root;
		break;
	}
	case INTEGER_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t18 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp4_AST = astFactory->create(_t);
		tmp4_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp4_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST18 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST18;
		_t = __t18;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 787 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e) || r != TYPE_INTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 508 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp5_AST = astFactory->create(_t);
		tmp5_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp5_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST19 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST19;
		_t = __t19;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 791 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e) || r != TYPE_BIGINTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 539 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp6_AST = astFactory->create(_t);
		tmp6_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp6_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST20 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST20;
		_t = __t20;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 795 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DOUBLE) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 570 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t21 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp7_AST = astFactory->create(_t);
		tmp7_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp7_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST21 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST21;
		_t = __t21;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 799 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DECIMAL) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 601 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp8_AST = astFactory->create(_t);
		tmp8_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp8_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST22 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST22;
		_t = __t22;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 803 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_BOOLEAN) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 632 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t23 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp9_AST = astFactory->create(_t);
		tmp9_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp9_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST23 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST23;
		_t = __t23;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 807 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_STRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
		
				
#line 664 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t24 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp10_AST = astFactory->create(_t);
		tmp10_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp10_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST24 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST24;
		_t = __t24;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 812 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_WSTRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 695 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t25 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp11_AST = astFactory->create(_t);
		tmp11_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp11_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST25 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST25;
		_t = __t25;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 816 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DATETIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 726 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t26 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp12_AST = astFactory->create(_t);
		tmp12_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp12_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST26 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST26;
		_t = __t26;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 820 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_TIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 757 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t27 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp13_AST = astFactory->create(_t);
		tmp13_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp13_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST27 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST27;
		_t = __t27;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 824 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_ENUM) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 788 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t28 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp14_AST = astFactory->create(_t);
		tmp14_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp14_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST28 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM);
		_t = _t->getFirstChild();
		r=varLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		e=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST28;
		_t = __t28;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 828 "mtsql_tree.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_BINARY) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 819 "MTSQLTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = setStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::printStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 833 "mtsql_tree.g"
	
		int e = TYPE_INVALID;
	
#line 841 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t30 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp15_AST = astFactory->create(_t);
	tmp15_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp15_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST30 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST30;
	_t = __t30;
	_t = _t->getNextSibling();
	printStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 839 "mtsql_tree.g"
	
		  if (e != TYPE_STRING && e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)printStatement_AST);
	printStatement_AST->setType(e==TYPE_STRING ? STRING_PRINT : WSTRING_PRINT);
	
#line 866 "MTSQLTreeParser.cpp"
	printStatement_AST = currentAST.root;
	returnAST = printStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 845 "mtsql_tree.g"
	
		int e = TYPE_INVALID;
	
#line 881 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t32 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp16_AST = astFactory->create(_t);
	tmp16_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp16_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST32 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,STRING_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST32;
	_t = __t32;
	_t = _t->getNextSibling();
	stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 851 "mtsql_tree.g"
	
		  if (e != TYPE_STRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)stringPrintStatement_AST);
	
#line 905 "MTSQLTreeParser.cpp"
	stringPrintStatement_AST = currentAST.root;
	returnAST = stringPrintStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 856 "mtsql_tree.g"
	
		int e = TYPE_INVALID;
	
#line 920 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t34 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp17_AST = astFactory->create(_t);
	tmp17_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp17_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST34 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WSTRING_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST34;
	_t = __t34;
	_t = _t->getNextSibling();
	wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 862 "mtsql_tree.g"
	
		  if (e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)wstringPrintStatement_AST);
	
#line 944 "MTSQLTreeParser.cpp"
	wstringPrintStatement_AST = currentAST.root;
	returnAST = wstringPrintStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t36 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp18_AST = astFactory->create(_t);
	tmp18_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp18_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST36 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SEQUENCE);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST36;
	_t = __t36;
	_t = _t->getNextSibling();
	seq_AST = currentAST.root;
	returnAST = seq_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_querySpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_UNION)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp19_AST = astFactory->create(_t);
			tmp19_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp19_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp20_AST = astFactory->create(_t);
				tmp20_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp20_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
				break;
			}
			case TK_SELECT:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
			}
			}
			}
			sql92_querySpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop195;
		}
		
	}
	_loop195:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp21_AST = astFactory->create(_t);
		tmp21_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp21_AST);
		match(_t,TK_ORDER);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp22_AST = astFactory->create(_t);
		tmp22_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp22_AST);
		match(_t,TK_BY);
		_t = _t->getNextSibling();
		sql92_orderByExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		break;
	}
	case 3:
	case TK_BREAK:
	case TK_CAST:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_FALSE:
	case TK_LIKE:
	case TK_NULL:
	case TK_PRINT:
	case TK_RETURN:
	case TK_SELECT:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case EQUALS:
	case NOTEQUALS:
	case LTN:
	case LTEQ:
	case GT:
	case GTEQ:
	case RPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
	case NUM_INT:
	case ARRAY:
	case ASSIGN:
	case BAND:
	case BNOT:
	case BOR:
	case BXOR:
	case DIVIDE:
	case EXPR:
	case IFTHENELSE:
	case ISNULL:
	case LAND:
	case LNOT:
	case LOR:
	case METHOD_CALL:
	case MODULUS:
	case QUERY:
	case RAISERROR1:
	case RAISERROR2:
	case SEARCHED_CASE:
	case SIMPLE_CASE:
	case SLIST:
	case TIMES:
	case UNARY_MINUS:
	case WHILE:
	case ESEQ:
	case SEQUENCE:
	case CAST_TO_INTEGER:
	case CAST_TO_BIGINT:
	case CAST_TO_DOUBLE:
	case CAST_TO_DECIMAL:
	case CAST_TO_STRING:
	case CAST_TO_WSTRING:
	case CAST_TO_BOOLEAN:
	case CAST_TO_DATETIME:
	case CAST_TO_TIME:
	case CAST_TO_ENUM:
	case CAST_TO_BINARY:
	case INTEGER_PLUS:
	case BIGINT_PLUS:
	case DOUBLE_PLUS:
	case DECIMAL_PLUS:
	case STRING_PLUS:
	case WSTRING_PLUS:
	case INTEGER_MINUS:
	case BIGINT_MINUS:
	case DOUBLE_MINUS:
	case DECIMAL_MINUS:
	case INTEGER_TIMES:
	case BIGINT_TIMES:
	case DOUBLE_TIMES:
	case DECIMAL_TIMES:
	case INTEGER_DIVIDE:
	case BIGINT_DIVIDE:
	case DOUBLE_DIVIDE:
	case DECIMAL_DIVIDE:
	case INTEGER_UNARY_MINUS:
	case BIGINT_UNARY_MINUS:
	case DOUBLE_UNARY_MINUS:
	case DECIMAL_UNARY_MINUS:
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
	case IFBLOCK:
	case RAISERRORINTEGER:
	case RAISERRORSTRING:
	case RAISERRORWSTRING:
	case RAISERROR2STRING:
	case RAISERROR2WSTRING:
	case STRING_LIKE:
	case WSTRING_LIKE:
	case STRING_PRINT:
	case WSTRING_PRINT:
	case INTEGER_MODULUS:
	case BIGINT_MODULUS:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	sql92_selectStatement_AST = currentAST.root;
	returnAST = sql92_selectStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp23_AST = astFactory->create(_t);
	tmp23_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp23_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST169 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERY);
	_t = _t->getFirstChild();
	sql92_selectStatement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	mtsql_paramList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	mtsql_intoList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST169;
	_t = __t169;
	_t = _t->getNextSibling();
	mtsql_selectStatement_AST = currentAST.root;
	returnAST = mtsql_selectStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 886 "mtsql_tree.g"
	
		int e = TYPE_INVALID;
	
#line 1244 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t39 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp24_AST = astFactory->create(_t);
	tmp24_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp24_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST39 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,IFTHENELSE);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	delayedStatement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case DELAYED_STMT:
	{
		delayedStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
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
	currentAST = __currentAST39;
	_t = __t39;
	_t = _t->getNextSibling();
	ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 892 "mtsql_tree.g"
	
				if (e != TYPE_BOOLEAN) throw MTSQLSemanticException("IF expression must be BOOLEAN type", (RefMTSQLAST)ifStatement_AST); 
			
#line 1292 "MTSQLTreeParser.cpp"
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t42 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp25_AST = astFactory->create(_t);
	tmp25_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp25_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST42 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SLIST);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_0.member(_t->getType()))) {
			statement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop44;
		}
		
	}
	_loop44:;
	} // ( ... )*
	currentAST = __currentAST42;
	_t = __t42;
	_t = _t->getNextSibling();
	listOfStatements_AST = currentAST.root;
	returnAST = listOfStatements_AST;
	_retTree = _t;
}

void MTSQLTreeParser::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 907 "mtsql_tree.g"
	
	int ty;
	bool hasValue = false;
	
#line 1351 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t48 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp26_AST = astFactory->create(_t);
	tmp26_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST48 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_RETURN);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EXPR:
	{
		e = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		ty=expression(_t);
		_t = _retTree;
		e_AST = returnAST;
		returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 914 "mtsql_tree.g"
		
		if (!canImplicitCast(ty,mReturnType)) throw MTSQLSemanticException("RETURN type mismatch", (RefMTSQLAST)returnStatement_AST); 
		if (ty != mReturnType)
		e_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(mReturnType)))->add(e_AST))))));
		
		hasValue = true;
		
#line 1382 "MTSQLTreeParser.cpp"
		currentAST.root = returnStatement_AST;
		if ( returnStatement_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			returnStatement_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = returnStatement_AST->getFirstChild();
		else
			currentAST.child = returnStatement_AST;
		currentAST.advanceChildToEnd();
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
	currentAST = __currentAST48;
	_t = __t48;
	_t = _t->getNextSibling();
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 922 "mtsql_tree.g"
	
	if(hasValue)
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(tmp26_AST))->add(e_AST)));
	else
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(tmp26_AST))));
	
#line 1413 "MTSQLTreeParser.cpp"
	currentAST.root = returnStatement_AST;
	if ( returnStatement_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		returnStatement_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = returnStatement_AST->getFirstChild();
	else
		currentAST.child = returnStatement_AST;
	currentAST.advanceChildToEnd();
	returnAST = returnStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp27_AST = astFactory->create(_t);
	tmp27_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp27_AST);
	match(_t,TK_BREAK);
	_t = _t->getNextSibling();
	breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 933 "mtsql_tree.g"
	
		  // Verify that we are inside a while statement
		  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("BREAK can only appear in WHILE loop", (RefMTSQLAST)breakStatement_AST);
		
#line 1444 "MTSQLTreeParser.cpp"
	breakStatement_AST = currentAST.root;
	returnAST = breakStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp28_AST = astFactory->create(_t);
	tmp28_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp28_AST);
	match(_t,TK_CONTINUE);
	_t = _t->getNextSibling();
	continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 942 "mtsql_tree.g"
	
		  // Verify that we are inside a while statement
		  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("CONTINUE can only appear in WHILE loop", (RefMTSQLAST)continueStatement_AST);
		
#line 1469 "MTSQLTreeParser.cpp"
	continueStatement_AST = currentAST.root;
	returnAST = continueStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 948 "mtsql_tree.g"
	
	int ty;
	
#line 1484 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t53 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp29_AST = astFactory->create(_t);
	tmp29_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp29_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST53 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WHILE);
	_t = _t->getFirstChild();
#line 954 "mtsql_tree.g"
	
			mWhileContext.pushAnalyzingWhile(); 
		
#line 1501 "MTSQLTreeParser.cpp"
	ty=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	delayedStatement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST53;
	_t = __t53;
	_t = _t->getNextSibling();
	whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 959 "mtsql_tree.g"
	
		  mWhileContext.popAnalyzingWhile(); 
		  if (ty != TYPE_BOOLEAN) throw MTSQLSemanticException("WHILE expression must be BOOLEAN", (RefMTSQLAST)whileStatement_AST);
		
#line 1517 "MTSQLTreeParser.cpp"
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserror1Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror1Statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror1Statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 965 "mtsql_tree.g"
	
	int ty1;
	
#line 1532 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t55 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp30_AST = astFactory->create(_t);
	tmp30_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp30_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST55 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR1);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror1Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 972 "mtsql_tree.g"
	
			  if(ty1 != TYPE_INTEGER && ty1 != TYPE_STRING && ty1 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes integer or string argument", (RefMTSQLAST)raiserror1Statement_AST); 
	raiserror1Statement_AST->setType(ty1 == TYPE_INTEGER ? RAISERRORINTEGER : ty1==TYPE_STRING ? RAISERRORSTRING : RAISERRORWSTRING);
	
#line 1555 "MTSQLTreeParser.cpp"
	currentAST = __currentAST55;
	_t = __t55;
	_t = _t->getNextSibling();
	raiserror1Statement_AST = currentAST.root;
	returnAST = raiserror1Statement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 980 "mtsql_tree.g"
	
	int ty1;
	
#line 1573 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t57 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp31_AST = astFactory->create(_t);
	tmp31_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp31_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST57 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORINTEGER);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 987 "mtsql_tree.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserrorIntegerStatement_AST); 
	
#line 1595 "MTSQLTreeParser.cpp"
	currentAST = __currentAST57;
	_t = __t57;
	_t = _t->getNextSibling();
	raiserrorIntegerStatement_AST = currentAST.root;
	returnAST = raiserrorIntegerStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 994 "mtsql_tree.g"
	
	int ty1;
	
#line 1613 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t59 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp32_AST = astFactory->create(_t);
	tmp32_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp32_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST59 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1001 "mtsql_tree.g"
	
				if(ty1 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserrorStringStatement_AST); 
	
#line 1635 "MTSQLTreeParser.cpp"
	currentAST = __currentAST59;
	_t = __t59;
	_t = _t->getNextSibling();
	raiserrorStringStatement_AST = currentAST.root;
	returnAST = raiserrorStringStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1008 "mtsql_tree.g"
	
	int ty1;
	
#line 1653 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t61 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp33_AST = astFactory->create(_t);
	tmp33_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp33_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST61 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORWSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1015 "mtsql_tree.g"
	
				if(ty1 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserrorWStringStatement_AST); 
	
#line 1675 "MTSQLTreeParser.cpp"
	currentAST = __currentAST61;
	_t = __t61;
	_t = _t->getNextSibling();
	raiserrorWStringStatement_AST = currentAST.root;
	returnAST = raiserrorWStringStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserror2Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2Statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1022 "mtsql_tree.g"
	
	int ty1;
	int ty2;
	
#line 1694 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t63 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp34_AST = astFactory->create(_t);
	tmp34_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp34_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST63 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1030 "mtsql_tree.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2Statement_AST); 
	
#line 1716 "MTSQLTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1035 "mtsql_tree.g"
	
	if(ty2 != TYPE_WSTRING && ty2 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2Statement_AST);
	
#line 1726 "MTSQLTreeParser.cpp"
	currentAST = __currentAST63;
	_t = __t63;
	_t = _t->getNextSibling();
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1040 "mtsql_tree.g"
	
	((RefMTSQLAST)raiserror2Statement_AST)->setType(ty2==TYPE_STRING ? RAISERROR2STRING : RAISERROR2WSTRING);
	
#line 1735 "MTSQLTreeParser.cpp"
	raiserror2Statement_AST = currentAST.root;
	returnAST = raiserror2Statement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1045 "mtsql_tree.g"
	
	int ty1;
	int ty2;
	
#line 1751 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t65 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp35_AST = astFactory->create(_t);
	tmp35_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp35_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST65 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2STRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1053 "mtsql_tree.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2StringStatement_AST); 
	
#line 1773 "MTSQLTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1058 "mtsql_tree.g"
	
	if(ty2 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2StringStatement_AST);
	
#line 1783 "MTSQLTreeParser.cpp"
	currentAST = __currentAST65;
	_t = __t65;
	_t = _t->getNextSibling();
	raiserror2StringStatement_AST = currentAST.root;
	returnAST = raiserror2StringStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1065 "mtsql_tree.g"
	
	int ty1;
	int ty2;
	
#line 1802 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t67 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp36_AST = astFactory->create(_t);
	tmp36_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp36_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST67 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2WSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1073 "mtsql_tree.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2WStringStatement_AST); 
	
#line 1824 "MTSQLTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1078 "mtsql_tree.g"
	
	if(ty2 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2WStringStatement_AST);
	
#line 1834 "MTSQLTreeParser.cpp"
	currentAST = __currentAST67;
	_t = __t67;
	_t = _t->getNextSibling();
	raiserror2WStringStatement_AST = currentAST.root;
	returnAST = raiserror2WStringStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::genericSetStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST genericSetStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST genericSetStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 763 "mtsql_tree.g"
	
	int r=TYPE_INVALID;
	int e=TYPE_INVALID;
	
#line 1859 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t16 = _t;
	a = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST a_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	a_AST = astFactory->create(a);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST16 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ASSIGN);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	r=varLValue(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	e=expression(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST16;
	_t = __t16;
	_t = _t->getNextSibling();
	genericSetStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 770 "mtsql_tree.g"
	
		  if (e != TYPE_NULL && !canImplicitCast(e, r)) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)a_AST);
	if (e != TYPE_NULL && e != r)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(right_AST))))));
	
	genericSetStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getAssignmentToken(r)))->add(left_AST)->add(right_AST)));
		
#line 1890 "MTSQLTreeParser.cpp"
	currentAST.root = genericSetStatement_AST;
	if ( genericSetStatement_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		genericSetStatement_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = genericSetStatement_AST->getFirstChild();
	else
		currentAST.child = genericSetStatement_AST;
	currentAST.advanceChildToEnd();
	returnAST = genericSetStatement_AST;
	_retTree = _t;
}

int  MTSQLTreeParser::varLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 871 "mtsql_tree.g"
	int r;
#line 1905 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST varLValue_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST varLValue_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 871 "mtsql_tree.g"
	
	r = TYPE_INVALID;
	
#line 1916 "MTSQLTreeParser.cpp"
	
	lv = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	lv_AST = astFactory->create(lv);
	astFactory->addASTChild(currentAST, lv_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	varLValue_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 877 "mtsql_tree.g"
	
		  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
		  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)varLValue_AST); 
		  r = var->getType(); 
		  ((RefMTSQLAST)varLValue_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 1932 "MTSQLTreeParser.cpp"
	varLValue_AST = currentAST.root;
	returnAST = varLValue_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1093 "mtsql_tree.g"
	int r;
#line 1942 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1093 "mtsql_tree.g"
	
	r = TYPE_INVALID;
	
#line 1951 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t74 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp37_AST = astFactory->create(_t);
	tmp37_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp37_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST74 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	r=expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST74;
	_t = __t74;
	_t = _t->getNextSibling();
	expression_AST = currentAST.root;
	returnAST = expression_AST;
	_retTree = _t;
	return r;
}

void MTSQLTreeParser::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t46 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp38_AST = astFactory->create(_t);
	tmp38_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp38_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST46 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DELAYED_STMT);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST46;
	_t = __t46;
	_t = _t->getNextSibling();
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
	_retTree = _t;
}

std::vector<int>  MTSQLTreeParser::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1085 "mtsql_tree.g"
	std::vector<int> v;
#line 2007 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1085 "mtsql_tree.g"
	
		int ty;
	
#line 2016 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t69 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp39_AST = astFactory->create(_t);
	tmp39_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp39_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST69 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ELIST);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EXPR:
	{
		ty=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 1090 "mtsql_tree.g"
		v.push_back(ty);
#line 2040 "MTSQLTreeParser.cpp"
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp40_AST = astFactory->create(_t);
				tmp40_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp40_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				ty=expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 1090 "mtsql_tree.g"
				v.push_back(ty);
#line 2058 "MTSQLTreeParser.cpp"
			}
			else {
				goto _loop72;
			}
			
		}
		_loop72:;
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
	currentAST = __currentAST69;
	_t = __t69;
	_t = _t->getNextSibling();
	elist_AST = currentAST.root;
	returnAST = elist_AST;
	_retTree = _t;
	return v;
}

int  MTSQLTreeParser::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1101 "mtsql_tree.g"
	int r;
#line 2091 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST cast = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST cast_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1101 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID, e=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 2105 "MTSQLTreeParser.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t76 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp41_AST = astFactory->create(_t);
		tmp41_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp41_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST76 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST76;
		_t = __t76;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1108 "mtsql_tree.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 2135 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t77 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp42_AST = astFactory->create(_t);
		tmp42_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp42_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST77 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST77;
		_t = __t77;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1109 "mtsql_tree.g"
		r = checkUnaryIntegerOperator(lhs, (RefMTSQLAST)expr_AST);
#line 2161 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t78 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp43_AST = astFactory->create(_t);
		tmp43_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp43_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST78 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST78;
		_t = __t78;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1110 "mtsql_tree.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 2190 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t79 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp44_AST = astFactory->create(_t);
		tmp44_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp44_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST79 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST79;
		_t = __t79;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1111 "mtsql_tree.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 2219 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t80 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp45_AST = astFactory->create(_t);
		tmp45_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp45_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST80 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LAND);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST80;
		_t = __t80;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1113 "mtsql_tree.g"
		r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 2248 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t81 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp46_AST = astFactory->create(_t);
		tmp46_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp46_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST81 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST81;
		_t = __t81;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1114 "mtsql_tree.g"
		r = checkUnaryLogicalOperator(lhs, (RefMTSQLAST)expr_AST);
#line 2274 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t82 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp47_AST = astFactory->create(_t);
		tmp47_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp47_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST82 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LOR);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST82;
		_t = __t82;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1115 "mtsql_tree.g"
		r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 2303 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case EQUALS:
	{
		r=equalsExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case GT:
	{
		r=gtExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		r=gteqExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		r=ltExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		r=lteqExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		r=notEqualsExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case ISNULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t83 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp48_AST = astFactory->create(_t);
		tmp48_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp48_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST83 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ISNULL);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST83;
		_t = __t83;
		_t = _t->getNextSibling();
#line 1124 "mtsql_tree.g"
		r = TYPE_BOOLEAN;
#line 2376 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case STRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t84 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp49_AST = astFactory->create(_t);
		tmp49_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp49_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST84 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST84;
		_t = __t84;
		_t = _t->getNextSibling();
#line 1126 "mtsql_tree.g"
		if(lhs != TYPE_STRING || rhs != TYPE_STRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_STRING;
#line 2404 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t85 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp50_AST = astFactory->create(_t);
		tmp50_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp50_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST85 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST85;
		_t = __t85;
		_t = _t->getNextSibling();
#line 1127 "mtsql_tree.g"
		if(lhs != TYPE_WSTRING || rhs != TYPE_WSTRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_WSTRING;
#line 2432 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t86 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp51_AST = astFactory->create(_t);
		tmp51_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp51_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST86 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_LIKE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST86;
		_t = __t86;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1129 "mtsql_tree.g"
		
		if (lhs != TYPE_STRING && lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_STRING && rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		expr_AST->setType(rhs == TYPE_STRING ? STRING_LIKE : WSTRING_LIKE);
		r = TYPE_BOOLEAN;
		
#line 2467 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case STRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t87 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp52_AST = astFactory->create(_t);
		tmp52_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp52_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST87 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_LIKE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST87;
		_t = __t87;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1137 "mtsql_tree.g"
		
		if (lhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		r = TYPE_BOOLEAN;
		
#line 2501 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t88 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp53_AST = astFactory->create(_t);
		tmp53_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp53_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST88 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_LIKE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST88;
		_t = __t88;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1144 "mtsql_tree.g"
		
		if (lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		r = TYPE_BOOLEAN;
		
#line 2535 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t89 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp54_AST = astFactory->create(_t);
		tmp54_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp54_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST89 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST89;
		_t = __t89;
		_t = _t->getNextSibling();
#line 1151 "mtsql_tree.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 2563 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t90 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp55_AST = astFactory->create(_t);
		tmp55_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp55_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST90 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_DIVIDE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST90;
		_t = __t90;
		_t = _t->getNextSibling();
#line 1152 "mtsql_tree.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 2591 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp56_AST = astFactory->create(_t);
		tmp56_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp56_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST91 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST91;
		_t = __t91;
		_t = _t->getNextSibling();
#line 1153 "mtsql_tree.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 2619 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t92 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp57_AST = astFactory->create(_t);
		tmp57_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp57_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST92 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_TIMES);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST92;
		_t = __t92;
		_t = _t->getNextSibling();
#line 1154 "mtsql_tree.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 2647 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp58_AST = astFactory->create(_t);
		tmp58_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp58_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST93;
		_t = __t93;
		_t = _t->getNextSibling();
#line 1155 "mtsql_tree.g"
		if(lhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 2672 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t94 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp59_AST = astFactory->create(_t);
		tmp59_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp59_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST94 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST94;
		_t = __t94;
		_t = _t->getNextSibling();
#line 1156 "mtsql_tree.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 2700 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp60_AST = astFactory->create(_t);
		tmp60_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp60_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST95 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_DIVIDE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST95;
		_t = __t95;
		_t = _t->getNextSibling();
#line 1157 "mtsql_tree.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 2728 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t96 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp61_AST = astFactory->create(_t);
		tmp61_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp61_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST96 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST96;
		_t = __t96;
		_t = _t->getNextSibling();
#line 1158 "mtsql_tree.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 2756 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t97 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp62_AST = astFactory->create(_t);
		tmp62_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp62_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST97 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_TIMES);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST97;
		_t = __t97;
		_t = _t->getNextSibling();
#line 1159 "mtsql_tree.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 2784 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t98 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp63_AST = astFactory->create(_t);
		tmp63_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp63_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST98 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST98;
		_t = __t98;
		_t = _t->getNextSibling();
#line 1160 "mtsql_tree.g"
		if(lhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 2809 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t99 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp64_AST = astFactory->create(_t);
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp64_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST99 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST99;
		_t = __t99;
		_t = _t->getNextSibling();
#line 1161 "mtsql_tree.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 2837 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp65_AST = astFactory->create(_t);
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp65_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST100 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_DIVIDE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST100;
		_t = __t100;
		_t = _t->getNextSibling();
#line 1162 "mtsql_tree.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 2865 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t101 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp66_AST = astFactory->create(_t);
		tmp66_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp66_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST101 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST101;
		_t = __t101;
		_t = _t->getNextSibling();
#line 1163 "mtsql_tree.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 2893 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t102 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp67_AST = astFactory->create(_t);
		tmp67_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp67_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST102 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_TIMES);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST102;
		_t = __t102;
		_t = _t->getNextSibling();
#line 1164 "mtsql_tree.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 2921 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp68_AST = astFactory->create(_t);
		tmp68_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp68_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST103 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST103;
		_t = __t103;
		_t = _t->getNextSibling();
#line 1165 "mtsql_tree.g"
		if(lhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 2946 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t104 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp69_AST = astFactory->create(_t);
		tmp69_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp69_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST104 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST104;
		_t = __t104;
		_t = _t->getNextSibling();
#line 1166 "mtsql_tree.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 2974 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp70_AST = astFactory->create(_t);
		tmp70_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp70_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST105 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_DIVIDE);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST105;
		_t = __t105;
		_t = _t->getNextSibling();
#line 1167 "mtsql_tree.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 3002 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t106 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp71_AST = astFactory->create(_t);
		tmp71_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp71_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST106 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_PLUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST106;
		_t = __t106;
		_t = _t->getNextSibling();
#line 1169 "mtsql_tree.g"
		
			  if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) 
			  {
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); 
			  }
			  r = TYPE_DECIMAL; 
			
#line 3036 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t107 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp72_AST = astFactory->create(_t);
		tmp72_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp72_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST107 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_TIMES);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST107;
		_t = __t107;
		_t = _t->getNextSibling();
#line 1176 "mtsql_tree.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 3064 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t108 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp73_AST = astFactory->create(_t);
		tmp73_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp73_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST108 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST108;
		_t = __t108;
		_t = _t->getNextSibling();
#line 1177 "mtsql_tree.g"
		if(lhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 3089 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		r=minusExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp74_AST = astFactory->create(_t);
		tmp74_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp74_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST109 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MODULUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST109;
		_t = __t109;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1181 "mtsql_tree.g"
		
			  if (!(lhs == TYPE_INTEGER && rhs == TYPE_INTEGER) &&
		!(lhs == TYPE_BIGINTEGER && rhs == TYPE_BIGINTEGER))
		{
				throw MTSQLSemanticException("Non integer argument to %", (RefMTSQLAST)expr_AST);
			  }
			  r = lhs; 
		expr_AST->setType(r == TYPE_INTEGER ? INTEGER_MODULUS : BIGINT_MODULUS);
			
#line 3134 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t110 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp75_AST = astFactory->create(_t);
		tmp75_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp75_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST110 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_MODULUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST110;
		_t = __t110;
		_t = _t->getNextSibling();
#line 1191 "mtsql_tree.g"
		
			  if (lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) 
		{
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
			  }
			  r = TYPE_INTEGER; 
			
#line 3168 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp76_AST = astFactory->create(_t);
		tmp76_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp76_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST111 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_MODULUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		rhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST111;
		_t = __t111;
		_t = _t->getNextSibling();
#line 1199 "mtsql_tree.g"
		
			  if (lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) 
		{
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
			  }
			  r = TYPE_BIGINTEGER; 
			
#line 3202 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		r=divideExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		r=plusExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		r=timesExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t112 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp77_AST = astFactory->create(_t);
		tmp77_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp77_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST112 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
		e=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST112;
		_t = __t112;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1210 "mtsql_tree.g"
		
			  r = e; 
			  checkAdditiveType(e, (RefMTSQLAST)expr_AST);  
			  if (e==TYPE_INTEGER) {
				expr_AST->setType(INTEGER_UNARY_MINUS);
			  } else if (e==TYPE_BIGINTEGER) {
				expr_AST->setType(BIGINT_UNARY_MINUS);
			  } else if (e==TYPE_DOUBLE) {
				expr_AST->setType(DOUBLE_UNARY_MINUS);
			  } else if (e==TYPE_DECIMAL) {
				expr_AST->setType(DECIMAL_UNARY_MINUS);
		} else {
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non additive type as argument to unary minus");
			  }
			
#line 3266 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case ESEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t113 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp78_AST = astFactory->create(_t);
		tmp78_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp78_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST113 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ESEQ);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		r=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST113;
		_t = __t113;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		r=searchedCaseExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		r=simpleCaseExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	case IFBLOCK:
	{
#line 1230 "mtsql_tree.g"
		
			  std::vector<int> consTypes;
		
#line 3317 "MTSQLTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp79_AST = astFactory->create(_t);
		tmp79_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp79_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST114 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFBLOCK);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt116=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == IFEXPR)) {
				rhs=ifThenElse(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 1233 "mtsql_tree.g"
				consTypes.push_back(rhs);
#line 3340 "MTSQLTreeParser.cpp"
			}
			else {
				if ( _cnt116>=1 ) { goto _loop116; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt116++;
		}
		_loop116:;
		}  // ( ... )+
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case EXPR:
		{
			rhs=expression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
#line 1233 "mtsql_tree.g"
			consTypes.push_back(rhs);
#line 3361 "MTSQLTreeParser.cpp"
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
		currentAST = __currentAST114;
		_t = __t114;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1234 "mtsql_tree.g"
		
		unsigned int i;
		// Determine the type of the CASE expression to be the first non-NULL type
		for(i = 0; i<consTypes.size(); i++) 
		{ 
		if (consTypes[i] != TYPE_NULL) 
		{
		r = consTypes[i];
		break;
		}
		}
		if (i == consTypes.size()) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)expr_AST);
			  for(i = 0; i<consTypes.size(); i++) { if(consTypes[i] != TYPE_NULL && consTypes[i] != r) throw MTSQLSemanticException("Type checking error", (RefMTSQLAST)expr_AST); }
			
#line 3393 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t118 = _t;
		cast = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST cast_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		cast_AST = astFactory->create(cast);
		astFactory->addASTChild(currentAST, cast_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST118 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ty = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ty_AST = astFactory->create(ty);
		match(_t,BUILTIN_TYPE);
		_t = _t->getNextSibling();
		currentAST = __currentAST118;
		_t = __t118;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1249 "mtsql_tree.g"
		
					r = getType(ty->getText()); 
		if (false == canCast(lhs, r)) throw MTSQLSemanticException("Cannot cast " + getType(lhs) + " to " + getType(r), (RefMTSQLAST)expr_AST);
					switch(r)
		{
						case TYPE_STRING:
						cast_AST->setType(CAST_TO_STRING);
		break;
						case TYPE_WSTRING:
						cast_AST->setType(CAST_TO_WSTRING);
		break;
						case TYPE_DECIMAL:
						cast_AST->setType(CAST_TO_DECIMAL);
		break;
						case TYPE_DOUBLE:
						cast_AST->setType(CAST_TO_DOUBLE);
		break;
						case TYPE_INTEGER:
						cast_AST->setType(CAST_TO_INTEGER);
		break;
						case TYPE_BIGINTEGER:
						cast_AST->setType(CAST_TO_BIGINT);
		break;
						case TYPE_BOOLEAN:
						cast_AST->setType(CAST_TO_BOOLEAN);
		break;
						case TYPE_DATETIME:
						cast_AST->setType(CAST_TO_DATETIME);
		break;
						case TYPE_TIME:
						cast_AST->setType(CAST_TO_TIME);
		break;
						case TYPE_ENUM:
						cast_AST->setType(CAST_TO_ENUM);
		break;
						case TYPE_BINARY:
						cast_AST->setType(CAST_TO_BINARY);
		break;
		default:
		throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type");
						break;
		}
				
#line 3465 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_STRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp80_AST = astFactory->create(_t);
		tmp80_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp80_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST119 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_STRING);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST119;
		_t = __t119;
		_t = _t->getNextSibling();
#line 1292 "mtsql_tree.g"
		r = TYPE_STRING;
#line 3490 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_WSTRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t120 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp81_AST = astFactory->create(_t);
		tmp81_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp81_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST120 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_WSTRING);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST120;
		_t = __t120;
		_t = _t->getNextSibling();
#line 1293 "mtsql_tree.g"
		r = TYPE_WSTRING;
#line 3515 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_INTEGER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp82_AST = astFactory->create(_t);
		tmp82_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp82_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST121 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_INTEGER);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST121;
		_t = __t121;
		_t = _t->getNextSibling();
#line 1294 "mtsql_tree.g"
		r = TYPE_INTEGER;
#line 3540 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t122 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp83_AST = astFactory->create(_t);
		tmp83_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp83_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST122 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BIGINT);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST122;
		_t = __t122;
		_t = _t->getNextSibling();
#line 1295 "mtsql_tree.g"
		r = TYPE_BIGINTEGER;
#line 3565 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp84_AST = astFactory->create(_t);
		tmp84_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp84_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST123 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DECIMAL);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST123;
		_t = __t123;
		_t = _t->getNextSibling();
#line 1296 "mtsql_tree.g"
		r = TYPE_DECIMAL;
#line 3590 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DOUBLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t124 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp85_AST = astFactory->create(_t);
		tmp85_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp85_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST124 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DOUBLE);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST124;
		_t = __t124;
		_t = _t->getNextSibling();
#line 1297 "mtsql_tree.g"
		r = TYPE_DOUBLE;
#line 3615 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BOOLEAN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp86_AST = astFactory->create(_t);
		tmp86_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp86_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST125 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BOOLEAN);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST125;
		_t = __t125;
		_t = _t->getNextSibling();
#line 1298 "mtsql_tree.g"
		r = TYPE_BOOLEAN;
#line 3640 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DATETIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t126 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp87_AST = astFactory->create(_t);
		tmp87_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp87_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST126 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DATETIME);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST126;
		_t = __t126;
		_t = _t->getNextSibling();
#line 1299 "mtsql_tree.g"
		r = TYPE_DATETIME;
#line 3665 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_TIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp88_AST = astFactory->create(_t);
		tmp88_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp88_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST127 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_TIME);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST127;
		_t = __t127;
		_t = _t->getNextSibling();
#line 1300 "mtsql_tree.g"
		r = TYPE_TIME;
#line 3690 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_ENUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t128 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp89_AST = astFactory->create(_t);
		tmp89_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp89_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST128 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_ENUM);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST128;
		_t = __t128;
		_t = _t->getNextSibling();
#line 1301 "mtsql_tree.g"
		r = TYPE_ENUM;
#line 3715 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BINARY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp90_AST = astFactory->create(_t);
		tmp90_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp90_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST129 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BINARY);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST129;
		_t = __t129;
		_t = _t->getNextSibling();
#line 1302 "mtsql_tree.g"
		r = TYPE_BINARY;
#line 3740 "MTSQLTreeParser.cpp"
		expr_AST = currentAST.root;
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
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
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
		r=primaryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = expr_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::equalsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1306 "mtsql_tree.g"
	int ty;
#line 3790 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST equalsExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1306 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 3806 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t131 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp91_AST = astFactory->create(_t);
	tmp91_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST131 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EQUALS);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST131;
	_t = __t131;
	_t = _t->getNextSibling();
	equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1315 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)equalsExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp91_AST))->add(left_AST)->add(right_AST)));
	
#line 3839 "MTSQLTreeParser.cpp"
	currentAST.root = equalsExpression_AST;
	if ( equalsExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		equalsExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = equalsExpression_AST->getFirstChild();
	else
		currentAST.child = equalsExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = equalsExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::gtExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1325 "mtsql_tree.g"
	int ty;
#line 3855 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST gtExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1325 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 3871 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp92_AST = astFactory->create(_t);
	tmp92_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST133 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,GT);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST133;
	_t = __t133;
	_t = _t->getNextSibling();
	gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1334 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)gtExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp92_AST))->add(left_AST)->add(right_AST)));
	
#line 3904 "MTSQLTreeParser.cpp"
	currentAST.root = gtExpression_AST;
	if ( gtExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		gtExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = gtExpression_AST->getFirstChild();
	else
		currentAST.child = gtExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = gtExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::gteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1344 "mtsql_tree.g"
	int ty;
#line 3920 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST gteqExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1344 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 3936 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp93_AST = astFactory->create(_t);
	tmp93_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST135 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,GTEQ);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST135;
	_t = __t135;
	_t = _t->getNextSibling();
	gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1353 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)gteqExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp93_AST))->add(left_AST)->add(right_AST)));
	
#line 3969 "MTSQLTreeParser.cpp"
	currentAST.root = gteqExpression_AST;
	if ( gteqExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		gteqExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = gteqExpression_AST->getFirstChild();
	else
		currentAST.child = gteqExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = gteqExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::ltExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1363 "mtsql_tree.g"
	int ty;
#line 3985 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST ltExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1363 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 4001 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t137 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp94_AST = astFactory->create(_t);
	tmp94_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST137 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,LTN);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST137;
	_t = __t137;
	_t = _t->getNextSibling();
	ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1372 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)ltExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp94_AST))->add(left_AST)->add(right_AST)));
	
#line 4034 "MTSQLTreeParser.cpp"
	currentAST.root = ltExpression_AST;
	if ( ltExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		ltExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = ltExpression_AST->getFirstChild();
	else
		currentAST.child = ltExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = ltExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::lteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1382 "mtsql_tree.g"
	int ty;
#line 4050 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST lteqExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1382 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 4066 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp95_AST = astFactory->create(_t);
	tmp95_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST139 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,LTEQ);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST139;
	_t = __t139;
	_t = _t->getNextSibling();
	lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1391 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)lteqExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp95_AST))->add(left_AST)->add(right_AST)));
	
#line 4099 "MTSQLTreeParser.cpp"
	currentAST.root = lteqExpression_AST;
	if ( lteqExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		lteqExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = lteqExpression_AST->getFirstChild();
	else
		currentAST.child = lteqExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = lteqExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::notEqualsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1401 "mtsql_tree.g"
	int ty;
#line 4115 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST notEqualsExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1401 "mtsql_tree.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 4131 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t141 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp96_AST = astFactory->create(_t);
	tmp96_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST141 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,NOTEQUALS);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST141;
	_t = __t141;
	_t = _t->getNextSibling();
	notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1410 "mtsql_tree.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)notEqualsExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp96_AST))->add(left_AST)->add(right_AST)));
	
#line 4164 "MTSQLTreeParser.cpp"
	currentAST.root = notEqualsExpression_AST;
	if ( notEqualsExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		notEqualsExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = notEqualsExpression_AST->getFirstChild();
	else
		currentAST.child = notEqualsExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = notEqualsExpression_AST;
	_retTree = _t;
	return ty;
}

int  MTSQLTreeParser::minusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1442 "mtsql_tree.g"
	int r;
#line 4180 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST minusExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1442 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 4194 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp97_AST = astFactory->create(_t);
	tmp97_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST145 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,MINUS);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST145;
	_t = __t145;
	_t = _t->getNextSibling();
	minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1449 "mtsql_tree.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)minusExpression_AST); 
		  checkAdditiveType(lhs, (RefMTSQLAST)minusExpression_AST); 
		  checkAdditiveType(rhs, (RefMTSQLAST)minusExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getMinus(r)))->add(left_AST)->add(right_AST)));
	
#line 4230 "MTSQLTreeParser.cpp"
	currentAST.root = minusExpression_AST;
	if ( minusExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		minusExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = minusExpression_AST->getFirstChild();
	else
		currentAST.child = minusExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = minusExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::divideExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1482 "mtsql_tree.g"
	int r;
#line 4246 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST divideExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1482 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 4260 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t149 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp98_AST = astFactory->create(_t);
	tmp98_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST149 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DIVIDE);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST149;
	_t = __t149;
	_t = _t->getNextSibling();
	divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1489 "mtsql_tree.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)divideExpression_AST); 
		  checkMultiplicativeType(lhs, (RefMTSQLAST)divideExpression_AST); 
		  checkMultiplicativeType(rhs, (RefMTSQLAST)divideExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getDivide(r)))->add(left_AST)->add(right_AST)));
	
#line 4296 "MTSQLTreeParser.cpp"
	currentAST.root = divideExpression_AST;
	if ( divideExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		divideExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = divideExpression_AST->getFirstChild();
	else
		currentAST.child = divideExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = divideExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::plusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1422 "mtsql_tree.g"
	int r;
#line 4312 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST plusExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST plusExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST p = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST p_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1422 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 4328 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t143 = _t;
	p = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST p_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	p_AST = astFactory->create(p);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST143 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,PLUS);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST143;
	_t = __t143;
	_t = _t->getNextSibling();
	plusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1429 "mtsql_tree.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)p_AST); 
		  checkAdditiveTypeWithString(lhs, (RefMTSQLAST)p_AST); 
		  checkAdditiveTypeWithString(rhs, (RefMTSQLAST)p_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	plusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getPlus(r)))->add(left_AST)->add(right_AST)));
	
#line 4363 "MTSQLTreeParser.cpp"
	currentAST.root = plusExpression_AST;
	if ( plusExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		plusExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = plusExpression_AST->getFirstChild();
	else
		currentAST.child = plusExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = plusExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::timesExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1462 "mtsql_tree.g"
	int r;
#line 4379 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST timesExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1462 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 4393 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t147 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp99_AST = astFactory->create(_t);
	tmp99_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST147 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TIMES);
	_t = _t->getFirstChild();
	left = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	left_AST = returnAST;
	right = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	right_AST = returnAST;
	currentAST = __currentAST147;
	_t = __t147;
	_t = _t->getNextSibling();
	timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1469 "mtsql_tree.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)timesExpression_AST); 
		  checkMultiplicativeType(lhs, (RefMTSQLAST)timesExpression_AST); 
		  checkMultiplicativeType(rhs, (RefMTSQLAST)timesExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getTimes(r)))->add(left_AST)->add(right_AST)));
	
#line 4429 "MTSQLTreeParser.cpp"
	currentAST.root = timesExpression_AST;
	if ( timesExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		timesExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = timesExpression_AST->getFirstChild();
	else
		currentAST.child = timesExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = timesExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::searchedCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1502 "mtsql_tree.g"
	int r;
#line 4445 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST searchedCaseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST searchedCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST search = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wk_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wk = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1502 "mtsql_tree.g"
	
	std::vector<int> condTypes;
	std::vector<int> consTypes;
	std::vector<int> typePair;
	std::string tmp = mTempGen.getNextTemp();
	int rhs=TYPE_INVALID;
	int e = TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 4464 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t151 = _t;
	search = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	search_AST = astFactory->create(search);
	astFactory->addASTChild(currentAST, search_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST151 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SEARCHED_CASE);
	_t = _t->getFirstChild();
#line 1515 "mtsql_tree.g"
	
			// We are converting the searched case into a simple case
			// We are doing this in the semantic analysis since we need to
			// know the type of the search expression in order to declare a
			// local temporary variable to store the search value
			search_AST->setType(IFBLOCK); 
		
#line 4484 "MTSQLTreeParser.cpp"
	wk = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	e=expr(_t);
	_t = _retTree;
	wk_AST = returnAST;
	{ // ( ... )+
	int _cnt153=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_WHEN)) {
			typePair=whenExpression(_t,tmp);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
#line 1523 "mtsql_tree.g"
			condTypes.push_back(typePair[0]); consTypes.push_back(typePair[1]);
#line 4500 "MTSQLTreeParser.cpp"
		}
		else {
			if ( _cnt153>=1 ) { goto _loop153; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt153++;
	}
	_loop153:;
	}  // ( ... )+
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EXPR:
	{
		rhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 1524 "mtsql_tree.g"
		consTypes.push_back(rhs);
#line 4521 "MTSQLTreeParser.cpp"
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
	currentAST = __currentAST151;
	_t = __t151;
	_t = _t->getNextSibling();
	searchedCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1526 "mtsql_tree.g"
	
		  unsigned int i;
		  for(i = 0; i<condTypes.size(); i++) { if(TYPE_INVALID == unifyTypes(e, condTypes[i])) throw MTSQLSemanticException("CASE condition has different incorrect type", (RefMTSQLAST)search_AST); }
	
	// Determine the type of the CASE expression to be the "maximum" of the non-NULL types
	for(i = 0; i<consTypes.size(); i++) 
	{ 
	if (consTypes[i] != TYPE_NULL && r == TYPE_INVALID) 
	{
	// The first non-NULL type seen among the consequents.
	r = consTypes[i];
	}
	else if (TYPE_INVALID != unifyTypes(consTypes[i], r))
	{
	r = unifyTypes(consTypes[i], r);
	}
	else
	{
	throw MTSQLSemanticException("CASE consequent has incorrect type", (RefMTSQLAST)search_AST);
	}
	}
	if (r == TYPE_INVALID) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)search_AST);
	// Insert necessary conversions into the consequent
	search_AST = insertTypeConversionsForIfBlock(search_AST, r, consTypes);
	
		  // Do the tree construction but don't bother with semantic analysis, we will do a phase 2 pass
		  searchedCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(ESEQ,"ESEQ"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(SEQUENCE,"SEQUENCE"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(TK_DECLARE,"DECLARE"))->add(astFactory->create(LOCALVAR,tmp))->add(astFactory->create(BUILTIN_TYPE,getType(e))))))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(ASSIGN,"ASSIGN"))->add(astFactory->create(LOCALVAR,tmp))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(wk_AST))))))))))->add(search_AST)));
		
#line 4567 "MTSQLTreeParser.cpp"
	currentAST.root = searchedCaseExpression_AST;
	if ( searchedCaseExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		searchedCaseExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = searchedCaseExpression_AST->getFirstChild();
	else
		currentAST.child = searchedCaseExpression_AST;
	currentAST.advanceChildToEnd();
	searchedCaseExpression_AST = currentAST.root;
	returnAST = searchedCaseExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::simpleCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1556 "mtsql_tree.g"
	int r;
#line 4584 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleCaseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1556 "mtsql_tree.g"
	
	std::vector<int> consTypes;
	bool simpleCaseHasElse = false;
	int rhs = TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 4598 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t156 = _t;
	simple = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	simple_AST = astFactory->create(simple);
	astFactory->addASTChild(currentAST, simple_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST156 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_CASE);
	_t = _t->getFirstChild();
#line 1566 "mtsql_tree.g"
	
		  simple_AST->setType(IFBLOCK);
	
#line 4614 "MTSQLTreeParser.cpp"
	{ // ( ... )+
	int _cnt158=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == SIMPLE_WHEN)) {
			rhs=simpleWhenExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
#line 1569 "mtsql_tree.g"
			consTypes.push_back(rhs);
#line 4626 "MTSQLTreeParser.cpp"
		}
		else {
			if ( _cnt158>=1 ) { goto _loop158; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt158++;
	}
	_loop158:;
	}  // ( ... )+
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EXPR:
	{
		rhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 1570 "mtsql_tree.g"
		consTypes.push_back(rhs);
#line 4647 "MTSQLTreeParser.cpp"
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
	currentAST = __currentAST156;
	_t = __t156;
	_t = _t->getNextSibling();
	simpleCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1572 "mtsql_tree.g"
	
	unsigned int i;
	// Determine the type of the CASE expression to be the "maximum" of the non-NULL types
	for(i = 0; i<consTypes.size(); i++) 
	{ 
	if (consTypes[i] != TYPE_NULL && r == TYPE_INVALID) 
	{
	// The first non-NULL type seen among the consequents.
	r = consTypes[i];
	}
	else if (TYPE_INVALID != unifyTypes(consTypes[i], r))
	{
	r = unifyTypes(consTypes[i], r);
	}
	else
	{
	throw MTSQLSemanticException("CASE consequent has incorrect type", (RefMTSQLAST)simple_AST);
	}
	}
	if (r == TYPE_INVALID) throw MTSQLSemanticException("All CASE statement consequents are NULL", (RefMTSQLAST)simple_AST);
	
	simpleCaseExpression_AST = insertTypeConversionsForIfBlock(simpleCaseExpression_AST, r, consTypes);
		
#line 4688 "MTSQLTreeParser.cpp"
	currentAST.root = simpleCaseExpression_AST;
	if ( simpleCaseExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		simpleCaseExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = simpleCaseExpression_AST->getFirstChild();
	else
		currentAST.child = simpleCaseExpression_AST;
	currentAST.advanceChildToEnd();
	simpleCaseExpression_AST = currentAST.root;
	returnAST = simpleCaseExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1597 "mtsql_tree.g"
	int r;
#line 4705 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1597 "mtsql_tree.g"
	
	r = TYPE_INVALID;
	int condTy=TYPE_INVALID;
	
#line 4715 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t161 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp100_AST = astFactory->create(_t);
	tmp100_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp100_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST161 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,IFEXPR);
	_t = _t->getFirstChild();
	condTy=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	r=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST161;
	_t = __t161;
	_t = _t->getNextSibling();
	ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1603 "mtsql_tree.g"
	
		  if (condTy != TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)ifThenElse_AST);
		
#line 4742 "MTSQLTreeParser.cpp"
	ifThenElse_AST = currentAST.root;
	returnAST = ifThenElse_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1638 "mtsql_tree.g"
	int r;
#line 4752 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST igm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST igm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bigm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bigm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wsgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wsgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST decgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtgm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST dtgm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tm = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST en = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST en_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bin = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bin_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1638 "mtsql_tree.g"
	
	r = TYPE_INVALID;
	std::vector<int> v;
	
#line 4790 "MTSQLTreeParser.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp101_AST = astFactory->create(_t);
		tmp101_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp101_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 1645 "mtsql_tree.g"
		
					// ID's are only used for function names;  I suppose we could add a function (or function pointer type)
					// but it isn't really necessary since we are only allowing ID's in method calls
					r = TYPE_INVALID; 
				
#line 4810 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp102_AST = astFactory->create(_t);
		tmp102_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp102_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1651 "mtsql_tree.g"
		
					long lVal=0;
					sscanf(primaryExpression_AST->getText().c_str(), primaryExpression_AST->getText().size() > 2 && primaryExpression_AST->getText()[1] == 'x' ? "%x" : "%d", &lVal);
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createLong(lVal)); 
			  		r = TYPE_INTEGER;
				
#line 4831 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp103_AST = astFactory->create(_t);
		tmp103_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp103_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1658 "mtsql_tree.g"
		
					boost::int64_t lVal=0;
		std::stringstream sstr(primaryExpression_AST->getText().c_str());
		if (primaryExpression_AST->getText().size() > 2 && primaryExpression_AST->getText()[1] == 'x')
		{
			                  sstr >> std::hex;
		}
		sstr >> lVal;
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createLongLong(lVal)); 
			  		r = TYPE_BIGINTEGER;
				
#line 4857 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp104_AST = astFactory->create(_t);
		tmp104_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp104_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1670 "mtsql_tree.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(primaryExpression_AST->getText().c_str()).castToDouble()); 
			  r = TYPE_DOUBLE; 
			
#line 4876 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp105_AST = astFactory->create(_t);
		tmp105_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp105_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1675 "mtsql_tree.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(primaryExpression_AST->getText().c_str()).castToDec()); 
			  r = TYPE_DECIMAL; 
			
#line 4895 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp106_AST = astFactory->create(_t);
		tmp106_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp106_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1680 "mtsql_tree.g"
		
		if(mSupportVarchar)
		{
			    ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString((primaryExpression_AST->getText().c_str()))); 
			    r = TYPE_STRING; 
		}
		else
		{
			    ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString((primaryExpression_AST->getText().c_str())).castToWString()); 
			    primaryExpression_AST->setType(WSTRING_LITERAL);
			    r = TYPE_WSTRING; 
		}
			
#line 4923 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp107_AST = astFactory->create(_t);
		tmp107_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp107_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1694 "mtsql_tree.g"
		
		// This UTF-8 unencodes
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createWString((primaryExpression_AST->getText()))); 
			  r = TYPE_WSTRING; 
			
#line 4943 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp108_AST = astFactory->create(_t);
		tmp108_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp108_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1700 "mtsql_tree.g"
		
		// Create an enum from the string
		RuntimeValue strValue=RuntimeValue::createString((primaryExpression_AST->getText().c_str()));
		RuntimeValue enumValue;
		RuntimeValueCast::ToEnum(&enumValue, &strValue, getNameID());
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(enumValue); 
			  r = TYPE_ENUM; 
			
#line 4966 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp109_AST = astFactory->create(_t);
		tmp109_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp109_AST);
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1709 "mtsql_tree.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createBool(true)); 
			  r = TYPE_BOOLEAN; 
			
#line 4985 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp110_AST = astFactory->create(_t);
		tmp110_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp110_AST);
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1714 "mtsql_tree.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createBool(false)); 
			  r = TYPE_BOOLEAN; 
			
#line 5004 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp111_AST = astFactory->create(_t);
		tmp111_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp111_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1719 "mtsql_tree.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createNull()); 
			  r = TYPE_NULL; 
			
#line 5023 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t167 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp112_AST = astFactory->create(_t);
		tmp112_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp112_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST167 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		id = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST id_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		id_AST = astFactory->create(id);
		astFactory->addASTChild(currentAST, id_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		v=elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp113_AST = astFactory->create(_t);
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp113_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST167;
		_t = __t167;
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1724 "mtsql_tree.g"
		
					FunEntryPtr fe = mEnv->lookupFun(id->getText(), v); 
					if (FunEntryPtr() == fe) 
		{
		throw MTSQLSemanticException("Undefined function: " + id->getText(), (RefMTSQLAST)primaryExpression_AST); 
		}
					r = checkFunctionCall(fe, v, (RefMTSQLAST)primaryExpression_AST); 
					// Save the decorated name as a value
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(fe->getDecoratedName()));
				
#line 5071 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case LOCALVAR:
	{
		lv = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		lv_AST = astFactory->create(lv);
		astFactory->addASTChild(currentAST, lv_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1735 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
			  if (VarEntryPtr() == var) 
			  {
		throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)primaryExpression_AST);
			  }
			  r = var->getType();	
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
			  switch (r) 
			  {
				case TYPE_INTEGER:
				primaryExpression_AST->setType(INTEGER_GETMEM);
				break;
				case TYPE_BIGINTEGER:
				primaryExpression_AST->setType(BIGINT_GETMEM);
				break;
				case TYPE_DECIMAL:
				primaryExpression_AST->setType(DECIMAL_GETMEM);
				break;
				case TYPE_DOUBLE:
				primaryExpression_AST->setType(DOUBLE_GETMEM);
				break;
				case TYPE_STRING:
				primaryExpression_AST->setType(STRING_GETMEM);
				break;
				case TYPE_WSTRING:
				primaryExpression_AST->setType(WSTRING_GETMEM);
				break;
				case TYPE_BOOLEAN:
				primaryExpression_AST->setType(BOOLEAN_GETMEM);
				break;
				case TYPE_DATETIME:
				primaryExpression_AST->setType(DATETIME_GETMEM);
				break;
				case TYPE_TIME:
				primaryExpression_AST->setType(TIME_GETMEM);
				break;
				case TYPE_ENUM:
				primaryExpression_AST->setType(ENUM_GETMEM);
				break;
				case TYPE_BINARY:
				primaryExpression_AST->setType(BINARY_GETMEM);
				break;
				default:
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
		}
			
#line 5133 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case GLOBALVAR:
	{
		gv = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST gv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		gv_AST = astFactory->create(gv);
		astFactory->addASTChild(currentAST, gv_AST);
		match(_t,GLOBALVAR);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1784 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(gv->getText()); 
			  if (VarEntryPtr() == var) 
			  {
		throw MTSQLSemanticException("Undefined Variable: " + gv->getText(), (RefMTSQLAST)primaryExpression_AST);
			  }
			  r = var->getType();	
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
			  switch (r) 
			  {
				case TYPE_INTEGER:
				primaryExpression_AST->setType(INTEGER_GETMEM);
				break;
				case TYPE_BIGINTEGER:
				primaryExpression_AST->setType(BIGINT_GETMEM);
				break;
				case TYPE_DECIMAL:
				primaryExpression_AST->setType(DECIMAL_GETMEM);
				break;
				case TYPE_DOUBLE:
				primaryExpression_AST->setType(DOUBLE_GETMEM);
				break;
				case TYPE_STRING:
				primaryExpression_AST->setType(STRING_GETMEM);
				break;
				case TYPE_WSTRING:
				primaryExpression_AST->setType(WSTRING_GETMEM);
				break;
				case TYPE_BOOLEAN:
				primaryExpression_AST->setType(BOOLEAN_GETMEM);
				break;
				case TYPE_DATETIME:
				primaryExpression_AST->setType(DATETIME_GETMEM);
				break;
				case TYPE_TIME:
				primaryExpression_AST->setType(TIME_GETMEM);
				break;
				case TYPE_ENUM:
				primaryExpression_AST->setType(ENUM_GETMEM);
				break;
				case TYPE_BINARY:
				primaryExpression_AST->setType(BINARY_GETMEM);
				break;
				default:
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in local variable reference");
		}
			
#line 5195 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		igm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST igm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		igm_AST = astFactory->create(igm);
		astFactory->addASTChild(currentAST, igm_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1833 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(igm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_INTEGER; 
			
#line 5216 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		bigm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST bigm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		bigm_AST = astFactory->create(bigm);
		astFactory->addASTChild(currentAST, bigm_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1841 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bigm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BIGINTEGER; 
			
#line 5237 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		bgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST bgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		bgm_AST = astFactory->create(bgm);
		astFactory->addASTChild(currentAST, bgm_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1849 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BOOLEAN; 
			
#line 5258 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		dgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST dgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		dgm_AST = astFactory->create(dgm);
		astFactory->addASTChild(currentAST, dgm_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1857 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(dgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DOUBLE; 
			
#line 5279 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		sgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST sgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		sgm_AST = astFactory->create(sgm);
		astFactory->addASTChild(currentAST, sgm_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1865 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(sgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_STRING; 
			
#line 5300 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		wsgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST wsgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		wsgm_AST = astFactory->create(wsgm);
		astFactory->addASTChild(currentAST, wsgm_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1873 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(wsgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_WSTRING; 
			
#line 5321 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		decgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST decgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		decgm_AST = astFactory->create(decgm);
		astFactory->addASTChild(currentAST, decgm_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1881 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(decgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DECIMAL; 
			
#line 5342 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		dtgm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST dtgm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		dtgm_AST = astFactory->create(dtgm);
		astFactory->addASTChild(currentAST, dtgm_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1889 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(dtgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DATETIME; 
			
#line 5363 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		tm = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tm_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tm_AST = astFactory->create(tm);
		astFactory->addASTChild(currentAST, tm_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1897 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(tm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_TIME; 
			
#line 5384 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		en = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST en_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		en_AST = astFactory->create(en);
		astFactory->addASTChild(currentAST, en_AST);
		match(_t,ENUM_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1905 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(en->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_ENUM; 
			
#line 5405 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BINARY_GETMEM:
	{
		bin = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST bin_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		bin_AST = astFactory->create(bin);
		astFactory->addASTChild(currentAST, bin_AST);
		match(_t,BINARY_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1913 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bin->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BINARY; 
			
#line 5426 "MTSQLTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case EXPR:
	{
		r=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		primaryExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = primaryExpression_AST;
	_retTree = _t;
	return r;
}

std::vector<int>  MTSQLTreeParser::whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	const std::string& tmp
) {
#line 1608 "mtsql_tree.g"
	std::vector<int> r;
#line 5453 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1608 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	
#line 5466 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t163 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp114_AST = astFactory->create(_t);
	tmp114_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST163 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
	e1 = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	e1_AST = returnAST;
	e2 = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	e2_AST = returnAST;
	currentAST = __currentAST163;
	_t = __t163;
	_t = _t->getNextSibling();
	whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1614 "mtsql_tree.g"
	
			r.push_back(lhs);
			r.push_back(rhs);
	
		    // Construct the tree
	whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(IFEXPR,"IFEXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(EQUALS,"EQUALS"))->add(astFactory->create(LOCALVAR,tmp))->add(e1_AST)))))))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e2_AST))))));
		
#line 5498 "MTSQLTreeParser.cpp"
	currentAST.root = whenExpression_AST;
	if ( whenExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		whenExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = whenExpression_AST->getFirstChild();
	else
		currentAST.child = whenExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = whenExpression_AST;
	_retTree = _t;
	return r;
}

int  MTSQLTreeParser::simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1623 "mtsql_tree.g"
	int r;
#line 5514 "MTSQLTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sw = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sw_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1623 "mtsql_tree.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 5530 "MTSQLTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t165 = _t;
	sw = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST sw_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	sw_AST = astFactory->create(sw);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST165 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
	e1 = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	lhs=expr(_t);
	_t = _retTree;
	e1_AST = returnAST;
	e2 = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	rhs=expr(_t);
	_t = _retTree;
	e2_AST = returnAST;
	currentAST = __currentAST165;
	_t = __t165;
	_t = _t->getNextSibling();
	simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1629 "mtsql_tree.g"
	
			if(lhs!=TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)e1_AST); 
			r = rhs;
	
		    // Construct the tree
		    simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(IFEXPR,"IFEXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e1_AST))))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e2_AST)))))); 
		
#line 5561 "MTSQLTreeParser.cpp"
	currentAST.root = simpleWhenExpression_AST;
	if ( simpleWhenExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		simpleWhenExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = simpleWhenExpression_AST->getFirstChild();
	else
		currentAST.child = simpleWhenExpression_AST;
	currentAST.advanceChildToEnd();
	returnAST = simpleWhenExpression_AST;
	_retTree = _t;
	return r;
}

void MTSQLTreeParser::mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t171 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp115_AST = astFactory->create(_t);
	tmp115_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp115_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST171 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ARRAY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_1.member(_t->getType()))) {
			mtsql_reference(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop173;
		}
		
	}
	_loop173:;
	} // ( ... )*
	currentAST = __currentAST171;
	_t = __t171;
	_t = _t->getNextSibling();
	mtsql_paramList_AST = currentAST.root;
	returnAST = mtsql_paramList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t176 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp116_AST = astFactory->create(_t);
	tmp116_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp116_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST176 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt178=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= INTEGER_SETMEM_QUERY && _t->getType() <= BINARY_SETMEM_QUERY))) {
			mtsql_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt178>=1 ) { goto _loop178; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt178++;
	}
	_loop178:;
	}  // ( ... )+
	currentAST = __currentAST176;
	_t = __t176;
	_t = _t->getNextSibling();
	mtsql_intoList_AST = currentAST.root;
	returnAST = mtsql_intoList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::mtsql_reference(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_reference_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_reference_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LOCALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp117_AST = astFactory->create(_t);
		tmp117_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp117_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp118_AST = astFactory->create(_t);
		tmp118_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp118_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp119_AST = astFactory->create(_t);
		tmp119_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp119_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp120_AST = astFactory->create(_t);
		tmp120_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp120_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp121_AST = astFactory->create(_t);
		tmp121_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp121_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp122_AST = astFactory->create(_t);
		tmp122_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp122_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp123_AST = astFactory->create(_t);
		tmp123_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp123_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp124_AST = astFactory->create(_t);
		tmp124_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp124_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp125_AST = astFactory->create(_t);
		tmp125_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp125_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp126_AST = astFactory->create(_t);
		tmp126_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp126_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp127_AST = astFactory->create(_t);
		tmp127_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp127_AST);
		match(_t,ENUM_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BINARY_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp128_AST = astFactory->create(_t);
		tmp128_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp128_AST);
		match(_t,BINARY_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1949 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(mtsql_reference_AST->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)mtsql_reference_AST); 
			  ((RefMTSQLAST)mtsql_reference_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 5815 "MTSQLTreeParser.cpp"
		mtsql_reference_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = mtsql_reference_AST;
	_retTree = _t;
}

void MTSQLTreeParser::mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t180 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp129_AST = astFactory->create(_t);
		tmp129_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp129_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST180 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST180;
		_t = __t180;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t181 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp130_AST = astFactory->create(_t);
		tmp130_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp130_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST181 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST181;
		_t = __t181;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t182 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp131_AST = astFactory->create(_t);
		tmp131_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp131_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST182 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST182;
		_t = __t182;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t183 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp132_AST = astFactory->create(_t);
		tmp132_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp132_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST183 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST183;
		_t = __t183;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t184 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp133_AST = astFactory->create(_t);
		tmp133_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp133_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST184 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST184;
		_t = __t184;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t185 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp134_AST = astFactory->create(_t);
		tmp134_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp134_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST185 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST185;
		_t = __t185;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t186 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp135_AST = astFactory->create(_t);
		tmp135_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp135_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST186 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST186;
		_t = __t186;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t187 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp136_AST = astFactory->create(_t);
		tmp136_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp136_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST187 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST187;
		_t = __t187;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t188 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp137_AST = astFactory->create(_t);
		tmp137_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp137_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST188 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST188;
		_t = __t188;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp138_AST = astFactory->create(_t);
		tmp138_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp138_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST189 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST189;
		_t = __t189;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t190 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp139_AST = astFactory->create(_t);
		tmp139_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp139_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST190 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST190;
		_t = __t190;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = mtsql_intoVarRef_AST;
	_retTree = _t;
}

void MTSQLTreeParser::mtsql_intoLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoLValue_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoLValue_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	lv = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	lv_AST = astFactory->create(lv);
	astFactory->addASTChild(currentAST, lv_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	mtsql_intoLValue_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1989 "mtsql_tree.g"
	
		  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
		  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)mtsql_intoLValue_AST); 
		  ((RefMTSQLAST)mtsql_intoLValue_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 6109 "MTSQLTreeParser.cpp"
	mtsql_intoLValue_AST = currentAST.root;
	returnAST = mtsql_intoLValue_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t203 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp140_AST = astFactory->create(_t);
	tmp140_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp140_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST203 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_SELECT);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp141_AST = astFactory->create(_t);
		tmp141_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp141_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp142_AST = astFactory->create(_t);
		tmp142_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp142_AST);
		match(_t,TK_DISTINCT);
		_t = _t->getNextSibling();
		break;
	}
	case SELECT_LIST:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	sql92_selectList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_INTO:
	{
		sql92_intoList(_t);
		_t = _retTree;
		break;
	}
	case TK_FROM:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	sql92_fromClause(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_WHERE:
	{
		sql92_whereClause(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		break;
	}
	case 3:
	case TK_GROUP:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_GROUP:
	{
		sql92_groupByClause(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
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
	currentAST = __currentAST203;
	_t = __t203;
	_t = _t->getNextSibling();
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ASC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp143_AST = astFactory->create(_t);
		tmp143_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp143_AST);
		match(_t,TK_ASC);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DESC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp144_AST = astFactory->create(_t);
		tmp144_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp144_AST);
		match(_t,TK_DESC);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case TK_BREAK:
	case TK_CAST:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_FALSE:
	case TK_LIKE:
	case TK_NULL:
	case TK_PRINT:
	case TK_RETURN:
	case TK_SELECT:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case EQUALS:
	case NOTEQUALS:
	case LTN:
	case LTEQ:
	case GT:
	case GTEQ:
	case COMMA:
	case RPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
	case NUM_INT:
	case ARRAY:
	case ASSIGN:
	case BAND:
	case BNOT:
	case BOR:
	case BXOR:
	case DIVIDE:
	case EXPR:
	case IFTHENELSE:
	case ISNULL:
	case LAND:
	case LNOT:
	case LOR:
	case METHOD_CALL:
	case MODULUS:
	case QUERY:
	case RAISERROR1:
	case RAISERROR2:
	case SEARCHED_CASE:
	case SIMPLE_CASE:
	case SLIST:
	case TIMES:
	case UNARY_MINUS:
	case WHILE:
	case ESEQ:
	case SEQUENCE:
	case CAST_TO_INTEGER:
	case CAST_TO_BIGINT:
	case CAST_TO_DOUBLE:
	case CAST_TO_DECIMAL:
	case CAST_TO_STRING:
	case CAST_TO_WSTRING:
	case CAST_TO_BOOLEAN:
	case CAST_TO_DATETIME:
	case CAST_TO_TIME:
	case CAST_TO_ENUM:
	case CAST_TO_BINARY:
	case INTEGER_PLUS:
	case BIGINT_PLUS:
	case DOUBLE_PLUS:
	case DECIMAL_PLUS:
	case STRING_PLUS:
	case WSTRING_PLUS:
	case INTEGER_MINUS:
	case BIGINT_MINUS:
	case DOUBLE_MINUS:
	case DECIMAL_MINUS:
	case INTEGER_TIMES:
	case BIGINT_TIMES:
	case DOUBLE_TIMES:
	case DECIMAL_TIMES:
	case INTEGER_DIVIDE:
	case BIGINT_DIVIDE:
	case DOUBLE_DIVIDE:
	case DECIMAL_DIVIDE:
	case INTEGER_UNARY_MINUS:
	case BIGINT_UNARY_MINUS:
	case DOUBLE_UNARY_MINUS:
	case DECIMAL_UNARY_MINUS:
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
	case IFBLOCK:
	case RAISERRORINTEGER:
	case RAISERRORSTRING:
	case RAISERRORWSTRING:
	case RAISERROR2STRING:
	case RAISERROR2WSTRING:
	case STRING_LIKE:
	case WSTRING_LIKE:
	case STRING_PRINT:
	case WSTRING_PRINT:
	case INTEGER_MODULUS:
	case BIGINT_MODULUS:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp145_AST = astFactory->create(_t);
			tmp145_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp145_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ASC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp146_AST = astFactory->create(_t);
				tmp146_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp146_AST);
				match(_t,TK_ASC);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DESC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp147_AST = astFactory->create(_t);
				tmp147_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp147_AST);
				match(_t,TK_DESC);
				_t = _t->getNextSibling();
				break;
			}
			case 3:
			case TK_BREAK:
			case TK_CAST:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_FALSE:
			case TK_LIKE:
			case TK_NULL:
			case TK_PRINT:
			case TK_RETURN:
			case TK_SELECT:
			case TK_TRUE:
			case NUM_DECIMAL:
			case NUM_FLOAT:
			case NUM_BIGINT:
			case EQUALS:
			case NOTEQUALS:
			case LTN:
			case LTEQ:
			case GT:
			case GTEQ:
			case COMMA:
			case RPAREN:
			case MINUS:
			case PLUS:
			case STRING_LITERAL:
			case ENUM_LITERAL:
			case WSTRING_LITERAL:
			case ID:
			case LOCALVAR:
			case GLOBALVAR:
			case NUM_INT:
			case ARRAY:
			case ASSIGN:
			case BAND:
			case BNOT:
			case BOR:
			case BXOR:
			case DIVIDE:
			case EXPR:
			case IFTHENELSE:
			case ISNULL:
			case LAND:
			case LNOT:
			case LOR:
			case METHOD_CALL:
			case MODULUS:
			case QUERY:
			case RAISERROR1:
			case RAISERROR2:
			case SEARCHED_CASE:
			case SIMPLE_CASE:
			case SLIST:
			case TIMES:
			case UNARY_MINUS:
			case WHILE:
			case ESEQ:
			case SEQUENCE:
			case CAST_TO_INTEGER:
			case CAST_TO_BIGINT:
			case CAST_TO_DOUBLE:
			case CAST_TO_DECIMAL:
			case CAST_TO_STRING:
			case CAST_TO_WSTRING:
			case CAST_TO_BOOLEAN:
			case CAST_TO_DATETIME:
			case CAST_TO_TIME:
			case CAST_TO_ENUM:
			case CAST_TO_BINARY:
			case INTEGER_PLUS:
			case BIGINT_PLUS:
			case DOUBLE_PLUS:
			case DECIMAL_PLUS:
			case STRING_PLUS:
			case WSTRING_PLUS:
			case INTEGER_MINUS:
			case BIGINT_MINUS:
			case DOUBLE_MINUS:
			case DECIMAL_MINUS:
			case INTEGER_TIMES:
			case BIGINT_TIMES:
			case DOUBLE_TIMES:
			case DECIMAL_TIMES:
			case INTEGER_DIVIDE:
			case BIGINT_DIVIDE:
			case DOUBLE_DIVIDE:
			case DECIMAL_DIVIDE:
			case INTEGER_UNARY_MINUS:
			case BIGINT_UNARY_MINUS:
			case DOUBLE_UNARY_MINUS:
			case DECIMAL_UNARY_MINUS:
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
			case IFBLOCK:
			case RAISERRORINTEGER:
			case RAISERRORSTRING:
			case RAISERRORWSTRING:
			case RAISERROR2STRING:
			case RAISERROR2WSTRING:
			case STRING_LIKE:
			case WSTRING_LIKE:
			case STRING_PRINT:
			case WSTRING_PRINT:
			case INTEGER_MODULUS:
			case BIGINT_MODULUS:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
			}
			}
			}
		}
		else {
			goto _loop201;
		}
		
	}
	_loop201:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_queryExpr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t311 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp148_AST = astFactory->create(_t);
		tmp148_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp148_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST311 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST311;
		_t = __t311;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t312 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp149_AST = astFactory->create(_t);
		tmp149_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp149_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST312 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST312;
		_t = __t312;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t313 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp150_AST = astFactory->create(_t);
		tmp150_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp150_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST313;
		_t = __t313;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t314 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp151_AST = astFactory->create(_t);
		tmp151_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp151_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST314 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST314;
		_t = __t314;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t315 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp152_AST = astFactory->create(_t);
		tmp152_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp152_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST315 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MINUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST315;
		_t = __t315;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t316 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp153_AST = astFactory->create(_t);
		tmp153_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp153_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST316 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MODULUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST316;
		_t = __t316;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t317 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp154_AST = astFactory->create(_t);
		tmp154_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp154_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST317 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DIVIDE);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST317;
		_t = __t317;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t318 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp155_AST = astFactory->create(_t);
		tmp155_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp155_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST318 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,PLUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST318;
		_t = __t318;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t319 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp156_AST = astFactory->create(_t);
		tmp156_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp156_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST319 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIMES);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST319;
		_t = __t319;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t320 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp157_AST = astFactory->create(_t);
		tmp157_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp157_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST320 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST320;
		_t = __t320;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case UNARY_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t321 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp158_AST = astFactory->create(_t);
		tmp158_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp158_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST321 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_PLUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST321;
		_t = __t321;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t322 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp159_AST = astFactory->create(_t);
		tmp159_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp159_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST322 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_COUNT);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp160_AST = astFactory->create(_t);
		tmp160_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp160_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp161_AST = astFactory->create(_t);
			tmp161_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp161_AST);
			match(_t,STAR);
			_t = _t->getNextSibling();
			break;
		}
		case TK_ALL:
		case TK_DISTINCT:
		case EXPR:
		{
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp162_AST = astFactory->create(_t);
				tmp162_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp162_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp163_AST = astFactory->create(_t);
				tmp163_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp163_AST);
				match(_t,TK_DISTINCT);
				_t = _t->getNextSibling();
				break;
			}
			case EXPR:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
			}
			}
			}
			sql92_queryExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp164_AST = astFactory->create(_t);
		tmp164_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp164_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST322;
		_t = __t322;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t325 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp165_AST = astFactory->create(_t);
		tmp165_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp165_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST325 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_AVG);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp166_AST = astFactory->create(_t);
		tmp166_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp166_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp167_AST = astFactory->create(_t);
			tmp167_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp167_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp168_AST = astFactory->create(_t);
			tmp168_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp168_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
			break;
		}
		case EXPR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp169_AST = astFactory->create(_t);
		tmp169_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp169_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST325;
		_t = __t325;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t328 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp170_AST = astFactory->create(_t);
		tmp170_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp170_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST328 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MAX);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp171_AST = astFactory->create(_t);
		tmp171_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp171_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp172_AST = astFactory->create(_t);
			tmp172_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp172_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp173_AST = astFactory->create(_t);
			tmp173_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp173_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
			break;
		}
		case EXPR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp174_AST = astFactory->create(_t);
		tmp174_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp174_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST328;
		_t = __t328;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t331 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp175_AST = astFactory->create(_t);
		tmp175_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp175_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST331 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MIN);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp176_AST = astFactory->create(_t);
		tmp176_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp176_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp177_AST = astFactory->create(_t);
			tmp177_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp177_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp178_AST = astFactory->create(_t);
			tmp178_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp178_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
			break;
		}
		case EXPR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp179_AST = astFactory->create(_t);
		tmp179_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp179_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST331;
		_t = __t331;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t334 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp180_AST = astFactory->create(_t);
		tmp180_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp180_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST334 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_SUM);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp181_AST = astFactory->create(_t);
		tmp181_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp181_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp182_AST = astFactory->create(_t);
			tmp182_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp182_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp183_AST = astFactory->create(_t);
			tmp183_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp183_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
			break;
		}
		case EXPR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp184_AST = astFactory->create(_t);
		tmp184_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp184_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST334;
		_t = __t334;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t337 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp185_AST = astFactory->create(_t);
		tmp185_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp185_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST337 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp186_AST = astFactory->create(_t);
		tmp186_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp186_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp187_AST = astFactory->create(_t);
		tmp187_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp187_AST);
		match(_t,TK_AS);
		_t = _t->getNextSibling();
		sql92_builtInType(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp188_AST = astFactory->create(_t);
		tmp188_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp188_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST337;
		_t = __t337;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t338 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp189_AST = astFactory->create(_t);
		tmp189_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp189_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST338 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SIMPLE_CASE);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt340=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == SIMPLE_WHEN)) {
				sql92_simpleWhenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt340>=1 ) { goto _loop340; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt340++;
		}
		_loop340:;
		}  // ( ... )+
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ELSE:
		{
			sql92_elseExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp190_AST = astFactory->create(_t);
		tmp190_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp190_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST338;
		_t = __t338;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t342 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp191_AST = astFactory->create(_t);
		tmp191_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp191_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST342 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SEARCHED_CASE);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )+
		int _cnt344=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_WHEN)) {
				sql92_whenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt344>=1 ) { goto _loop344; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt344++;
		}
		_loop344:;
		}  // ( ... )+
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ELSE:
		{
			sql92_elseExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp192_AST = astFactory->create(_t);
		tmp192_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp192_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST342;
		_t = __t342;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	case METHOD_CALL:
	case SCALAR_SUBQUERY:
	{
		sql92_queryPrimaryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_queryExpr_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t209 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp193_AST = astFactory->create(_t);
	tmp193_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp193_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST209 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SELECT_LIST);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp194_AST = astFactory->create(_t);
		tmp194_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp194_AST);
		match(_t,STAR);
		_t = _t->getNextSibling();
		break;
	}
	case EXPR:
	{
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp195_AST = astFactory->create(_t);
			tmp195_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp195_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
			break;
		}
		case 3:
		case COMMA:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp196_AST = astFactory->create(_t);
				tmp196_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp196_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_queryExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ALIAS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp197_AST = astFactory->create(_t);
					tmp197_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp197_AST);
					match(_t,ALIAS);
					_t = _t->getNextSibling();
					break;
				}
				case 3:
				case COMMA:
				{
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
				}
				}
				}
			}
			else {
				goto _loop214;
			}
			
		}
		_loop214:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST209;
	_t = __t209;
	_t = _t->getNextSibling();
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t216 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp198_AST = astFactory->create(_t);
	tmp198_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp198_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST216 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
#line 2022 "mtsql_tree.g"
	enterInto();
#line 7626 "MTSQLTreeParser.cpp"
	{ // ( ... )+
	int _cnt218=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == LOCALVAR)) {
			sql92_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt218>=1 ) { goto _loop218; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt218++;
	}
	_loop218:;
	}  // ( ... )+
	currentAST = __currentAST216;
	_t = __t216;
	_t = _t->getNextSibling();
	sql92_intoList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 2022 "mtsql_tree.g"
	exitInto(sql92_intoList_AST);
#line 7651 "MTSQLTreeParser.cpp"
	sql92_intoList_AST = currentAST.root;
	returnAST = sql92_intoList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t221 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp199_AST = astFactory->create(_t);
	tmp199_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp199_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST221 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FROM);
	_t = _t->getFirstChild();
	sql92_tableSpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp200_AST = astFactory->create(_t);
			tmp200_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp200_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop223;
		}
		
	}
	_loop223:;
	} // ( ... )*
	currentAST = __currentAST221;
	_t = __t221;
	_t = _t->getNextSibling();
	sql92_fromClause_AST = currentAST.root;
	returnAST = sql92_fromClause_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t265 = _t;
	w = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	w_AST = astFactory->create(w);
	astFactory->addASTChild(currentAST, w_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST265 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHERE);
	_t = _t->getFirstChild();
	sql92_searchCondition(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST265;
	_t = __t265;
	_t = _t->getNextSibling();
	sql92_whereClause_AST = currentAST.root;
	returnAST = sql92_whereClause_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t267 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp201_AST = astFactory->create(_t);
	tmp201_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp201_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST267 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp202_AST = astFactory->create(_t);
	tmp202_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp202_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp203_AST = astFactory->create(_t);
			tmp203_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp203_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop269;
		}
		
	}
	_loop269:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp204_AST = astFactory->create(_t);
		tmp204_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp204_AST);
		match(_t,TK_HAVING);
		_t = _t->getNextSibling();
		sql92_searchCondition(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
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
	currentAST = __currentAST267;
	_t = __t267;
	_t = _t->getNextSibling();
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_queryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t309 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp205_AST = astFactory->create(_t);
	tmp205_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp205_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST309 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST309;
	_t = __t309;
	_t = _t->getNextSibling();
	sql92_queryExpression_AST = currentAST.root;
	returnAST = sql92_queryExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	lv = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	lv_AST = astFactory->create(lv);
	astFactory->addASTChild(currentAST, lv_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 2028 "mtsql_tree.g"
	
	intoVariable((RefMTSQLAST)lv_AST); 
	switch (mEnv->lookupVar(lv_AST->getText())->getType()) 
	{
				case TYPE_INTEGER:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(INTEGER_SETMEM_QUERY,"INTEGER_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_BIGINTEGER:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(BIGINT_SETMEM_QUERY,"BIGINT_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_DECIMAL:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(DECIMAL_SETMEM_QUERY,"DECIMAL_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_DOUBLE:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(DOUBLE_SETMEM_QUERY,"DOUBLE_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_STRING:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(STRING_SETMEM_QUERY,"STRING_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_WSTRING:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(WSTRING_SETMEM_QUERY,"WSTRING_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_BOOLEAN:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(BOOLEAN_SETMEM_QUERY,"BOOLEAN_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_DATETIME:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(DATETIME_SETMEM_QUERY,"DATETIME_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_TIME:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(TIME_SETMEM_QUERY,"TIME_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_ENUM:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ENUM_SETMEM_QUERY,"ENUM_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				case TYPE_BINARY:
				  sql92_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(BINARY_SETMEM_QUERY,"BINARY_SETMEM_QUERY"))->add(lv_AST)));
				  break;
				default:
				  throw MTSQLInternalErrorException(__FILE__, __LINE__, "Unknown type in query variable reference");
	}
	
#line 7908 "MTSQLTreeParser.cpp"
	currentAST.root = sql92_intoVarRef_AST;
	if ( sql92_intoVarRef_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		sql92_intoVarRef_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = sql92_intoVarRef_AST->getFirstChild();
	else
		currentAST.child = sql92_intoVarRef_AST;
	currentAST.advanceChildToEnd();
	sql92_intoVarRef_AST = currentAST.root;
	returnAST = sql92_intoVarRef_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t241 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp206_AST = astFactory->create(_t);
		tmp206_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp206_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST241 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_joinCriteria(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST241;
		_t = __t241;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case TABLE_REF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t242 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp207_AST = astFactory->create(_t);
		tmp207_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp207_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST242 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TABLE_REF);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp208_AST = astFactory->create(_t);
			tmp208_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp208_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
			break;
		}
		case 3:
		case TK_WITH:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_WITH:
		{
			sql92_tableHint(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
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
		currentAST = __currentAST242;
		_t = __t242;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case CROSS_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t245 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp209_AST = astFactory->create(_t);
		tmp209_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp209_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST245 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CROSS_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST245;
		_t = __t245;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case GROUPED_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t246 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp210_AST = astFactory->create(_t);
		tmp210_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp210_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST246 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GROUPED_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp211_AST = astFactory->create(_t);
		tmp211_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp211_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST246;
		_t = __t246;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case DERIVED_TABLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t247 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp212_AST = astFactory->create(_t);
		tmp212_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp212_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST247 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DERIVED_TABLE);
		_t = _t->getFirstChild();
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp213_AST = astFactory->create(_t);
		tmp213_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp213_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp214_AST = astFactory->create(_t);
		tmp214_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp214_AST);
		match(_t,ALIAS);
		_t = _t->getNextSibling();
		currentAST = __currentAST247;
		_t = __t247;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_tableSpecification_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t225 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp215_AST = astFactory->create(_t);
	tmp215_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp215_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST225 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_SELECT);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp216_AST = astFactory->create(_t);
		tmp216_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp216_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp217_AST = astFactory->create(_t);
		tmp217_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp217_AST);
		match(_t,TK_DISTINCT);
		_t = _t->getNextSibling();
		break;
	}
	case SELECT_LIST:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	sql92_nestedSelectList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	sql92_nestedFromClause(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_WHERE:
	{
		sql92_whereClause(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		break;
	}
	case 3:
	case TK_GROUP:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_GROUP:
	{
		sql92_nestedGroupByClause(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
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
	currentAST = __currentAST225;
	_t = __t225;
	_t = _t->getNextSibling();
	sql92_nestedSelectStatement_AST = currentAST.root;
	returnAST = sql92_nestedSelectStatement_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_nestedSelectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t230 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp218_AST = astFactory->create(_t);
	tmp218_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp218_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST230 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SELECT_LIST);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp219_AST = astFactory->create(_t);
		tmp219_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp219_AST);
		match(_t,STAR);
		_t = _t->getNextSibling();
		break;
	}
	case EXPR:
	{
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp220_AST = astFactory->create(_t);
			tmp220_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp220_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
			break;
		}
		case 3:
		case COMMA:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp221_AST = astFactory->create(_t);
				tmp221_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp221_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_queryExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ALIAS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp222_AST = astFactory->create(_t);
					tmp222_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp222_AST);
					match(_t,ALIAS);
					_t = _t->getNextSibling();
					break;
				}
				case 3:
				case COMMA:
				{
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
				}
				}
				}
			}
			else {
				goto _loop235;
			}
			
		}
		_loop235:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST230;
	_t = __t230;
	_t = _t->getNextSibling();
	sql92_nestedSelectList_AST = currentAST.root;
	returnAST = sql92_nestedSelectList_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_nestedFromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t237 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp223_AST = astFactory->create(_t);
	tmp223_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp223_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST237 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FROM);
	_t = _t->getFirstChild();
	sql92_tableSpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp224_AST = astFactory->create(_t);
			tmp224_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp224_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop239;
		}
		
	}
	_loop239:;
	} // ( ... )*
	currentAST = __currentAST237;
	_t = __t237;
	_t = _t->getNextSibling();
	sql92_nestedFromClause_AST = currentAST.root;
	returnAST = sql92_nestedFromClause_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_nestedGroupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t272 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp225_AST = astFactory->create(_t);
	tmp225_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp225_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST272 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp226_AST = astFactory->create(_t);
	tmp226_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp226_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp227_AST = astFactory->create(_t);
			tmp227_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp227_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop274;
		}
		
	}
	_loop274:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp228_AST = astFactory->create(_t);
		tmp228_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp228_AST);
		match(_t,TK_HAVING);
		_t = _t->getNextSibling();
		sql92_searchCondition(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
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
	currentAST = __currentAST272;
	_t = __t272;
	_t = _t->getNextSibling();
	sql92_nestedGroupByClause_AST = currentAST.root;
	returnAST = sql92_nestedGroupByClause_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t263 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp229_AST = astFactory->create(_t);
	tmp229_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp229_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST263 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ON);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST263;
	_t = __t263;
	_t = _t->getNextSibling();
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t249 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp230_AST = astFactory->create(_t);
	tmp230_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp230_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST249 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WITH);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp231_AST = astFactory->create(_t);
	tmp231_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp231_AST);
	match(_t,LPAREN);
	_t = _t->getNextSibling();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp232_AST = astFactory->create(_t);
		tmp232_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp232_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		break;
	}
	case TK_INDEX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp233_AST = astFactory->create(_t);
		tmp233_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp233_AST);
		match(_t,TK_INDEX);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp234_AST = astFactory->create(_t);
		tmp234_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp234_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ID:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp235_AST = astFactory->create(_t);
			tmp235_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp235_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
			break;
		}
		case NUM_INT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp236_AST = astFactory->create(_t);
			tmp236_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp236_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp237_AST = astFactory->create(_t);
				tmp237_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp237_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp238_AST = astFactory->create(_t);
					tmp238_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp238_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp239_AST = astFactory->create(_t);
					tmp239_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp239_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
				}
				}
				}
			}
			else {
				goto _loop254;
			}
			
		}
		_loop254:;
		} // ( ... )*
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp240_AST = astFactory->create(_t);
		tmp240_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp240_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp241_AST = astFactory->create(_t);
			tmp241_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp241_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case ID:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp242_AST = astFactory->create(_t);
				tmp242_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp242_AST);
				match(_t,ID);
				_t = _t->getNextSibling();
				break;
			}
			case TK_INDEX:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp243_AST = astFactory->create(_t);
				tmp243_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp243_AST);
				match(_t,TK_INDEX);
				_t = _t->getNextSibling();
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp244_AST = astFactory->create(_t);
				tmp244_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp244_AST);
				match(_t,LPAREN);
				_t = _t->getNextSibling();
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp245_AST = astFactory->create(_t);
					tmp245_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp245_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp246_AST = astFactory->create(_t);
					tmp246_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp246_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
				}
				}
				}
				{ // ( ... )*
				for (;;) {
					if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
						_t = ASTNULL;
					if ((_t->getType() == COMMA)) {
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
						tmp247_AST = astFactory->create(_t);
						tmp247_AST_in = _t;
						astFactory->addASTChild(currentAST, tmp247_AST);
						match(_t,COMMA);
						_t = _t->getNextSibling();
						{
						if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
							_t = ASTNULL;
						switch ( _t->getType()) {
						case ID:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp248_AST = astFactory->create(_t);
							tmp248_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp248_AST);
							match(_t,ID);
							_t = _t->getNextSibling();
							break;
						}
						case NUM_INT:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp249_AST = astFactory->create(_t);
							tmp249_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp249_AST);
							match(_t,NUM_INT);
							_t = _t->getNextSibling();
							break;
						}
						default:
						{
							throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
						}
						}
						}
					}
					else {
						goto _loop260;
					}
					
				}
				_loop260:;
				} // ( ... )*
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp250_AST = astFactory->create(_t);
				tmp250_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp250_AST);
				match(_t,RPAREN);
				_t = _t->getNextSibling();
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
			}
			}
			}
		}
		else {
			goto _loop261;
		}
		
	}
	_loop261:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp251_AST = astFactory->create(_t);
	tmp251_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp251_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
	currentAST = __currentAST249;
	_t = __t249;
	_t = _t->getNextSibling();
	sql92_tableHint_AST = currentAST.root;
	returnAST = sql92_tableHint_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t278 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp252_AST = astFactory->create(_t);
		tmp252_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp252_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST278 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,EQUALS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST278;
		_t = __t278;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t279 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp253_AST = astFactory->create(_t);
		tmp253_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp253_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST279 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GT);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST279;
		_t = __t279;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t280 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp254_AST = astFactory->create(_t);
		tmp254_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp254_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST280 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GTEQ);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST280;
		_t = __t280;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t281 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp255_AST = astFactory->create(_t);
		tmp255_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp255_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST281 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTN);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST281;
		_t = __t281;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t282 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp256_AST = astFactory->create(_t);
		tmp256_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp256_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST282 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTEQ);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST282;
		_t = __t282;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t283 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp257_AST = astFactory->create(_t);
		tmp257_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp257_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST283 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,NOTEQUALS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST283;
		_t = __t283;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t284 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp258_AST = astFactory->create(_t);
		tmp258_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp258_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST284 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_LIKE);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp259_AST = astFactory->create(_t);
			tmp259_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp259_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
			break;
		}
		case TK_AVG:
		case TK_CAST:
		case TK_COUNT:
		case TK_MAX:
		case TK_MIN:
		case TK_SUM:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		case BAND:
		case BNOT:
		case BOR:
		case BXOR:
		case DIVIDE:
		case METHOD_CALL:
		case MODULUS:
		case SCALAR_SUBQUERY:
		case SEARCHED_CASE:
		case SIMPLE_CASE:
		case TIMES:
		case UNARY_MINUS:
		case UNARY_PLUS:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST284;
		_t = __t284;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t286 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp260_AST = astFactory->create(_t);
		tmp260_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp260_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST286 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp261_AST = astFactory->create(_t);
			tmp261_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp261_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
			break;
		}
		case TK_NULL:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp262_AST = astFactory->create(_t);
		tmp262_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp262_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		currentAST = __currentAST286;
		_t = __t286;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_BETWEEN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t288 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp263_AST = astFactory->create(_t);
		tmp263_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp263_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST288 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_BETWEEN);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp264_AST = astFactory->create(_t);
			tmp264_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp264_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
			break;
		}
		case TK_AVG:
		case TK_CAST:
		case TK_COUNT:
		case TK_MAX:
		case TK_MIN:
		case TK_SUM:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		case BAND:
		case BNOT:
		case BOR:
		case BXOR:
		case DIVIDE:
		case METHOD_CALL:
		case MODULUS:
		case SCALAR_SUBQUERY:
		case SEARCHED_CASE:
		case SIMPLE_CASE:
		case TIMES:
		case UNARY_MINUS:
		case UNARY_PLUS:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp265_AST = astFactory->create(_t);
		tmp265_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp265_AST);
		match(_t,TK_AND);
		_t = _t->getNextSibling();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST288;
		_t = __t288;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t290 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp266_AST = astFactory->create(_t);
		tmp266_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp266_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST290 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_EXISTS);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp267_AST = astFactory->create(_t);
			tmp267_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp267_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
			break;
		}
		case LPAREN:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp268_AST = astFactory->create(_t);
		tmp268_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp268_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp269_AST = astFactory->create(_t);
		tmp269_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp269_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST290;
		_t = __t290;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t292 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp270_AST = astFactory->create(_t);
		tmp270_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp270_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST292 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IN);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp271_AST = astFactory->create(_t);
			tmp271_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp271_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
			break;
		}
		case LPAREN:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp272_AST = astFactory->create(_t);
		tmp272_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp272_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_SELECT:
		{
			sql92_nestedSelectStatement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			break;
		}
		case TK_AVG:
		case TK_CAST:
		case TK_COUNT:
		case TK_MAX:
		case TK_MIN:
		case TK_SUM:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		case BAND:
		case BNOT:
		case BOR:
		case BXOR:
		case DIVIDE:
		case METHOD_CALL:
		case MODULUS:
		case SCALAR_SUBQUERY:
		case SEARCHED_CASE:
		case SIMPLE_CASE:
		case TIMES:
		case UNARY_MINUS:
		case UNARY_PLUS:
		{
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{ // ( ... )*
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == COMMA)) {
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp273_AST = astFactory->create(_t);
					tmp273_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp273_AST);
					match(_t,COMMA);
					_t = _t->getNextSibling();
					sql92_queryExpr(_t);
					_t = _retTree;
					astFactory->addASTChild( currentAST, returnAST );
				}
				else {
					goto _loop296;
				}
				
			}
			_loop296:;
			} // ( ... )*
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp274_AST = astFactory->create(_t);
		tmp274_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp274_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST292;
		_t = __t292;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t297 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp275_AST = astFactory->create(_t);
		tmp275_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp275_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST297 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LAND);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST297;
		_t = __t297;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t298 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp276_AST = astFactory->create(_t);
		tmp276_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp276_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST298 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST298;
		_t = __t298;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t299 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp277_AST = astFactory->create(_t);
		tmp277_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp277_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST299 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LOR);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST299;
		_t = __t299;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t300 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp278_AST = astFactory->create(_t);
		tmp278_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp278_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST300 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_hackExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp279_AST = astFactory->create(_t);
		tmp279_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp279_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST300;
		_t = __t300;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_logicalExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_searchCondition_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_searchCondition_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	sql92_searchCondition_AST = currentAST.root;
	returnAST = sql92_searchCondition_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t302 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp280_AST = astFactory->create(_t);
	tmp280_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp280_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST302 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST302;
	_t = __t302;
	_t = _t->getNextSibling();
	sql92_hackExpression_AST = currentAST.root;
	returnAST = sql92_hackExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t304 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp281_AST = astFactory->create(_t);
	tmp281_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp281_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST304 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ELIST);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EXPR:
	{
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp282_AST = astFactory->create(_t);
				tmp282_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp282_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_queryExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop307;
			}
			
		}
		_loop307:;
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
	currentAST = __currentAST304;
	_t = __t304;
	_t = _t->getNextSibling();
	sql92_elist_AST = currentAST.root;
	returnAST = sql92_elist_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t359 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp283_AST = astFactory->create(_t);
	tmp283_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp283_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST359 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,BUILTIN_TYPE);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_PRECISION:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp284_AST = astFactory->create(_t);
		tmp284_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp284_AST);
		match(_t,TK_PRECISION);
		_t = _t->getNextSibling();
		break;
	}
	case 3:
	case LPAREN:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp285_AST = astFactory->create(_t);
		tmp285_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp285_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp286_AST = astFactory->create(_t);
		tmp286_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp286_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp287_AST = astFactory->create(_t);
			tmp287_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp287_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp288_AST = astFactory->create(_t);
			tmp288_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp288_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
			break;
		}
		case RPAREN:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp289_AST = astFactory->create(_t);
		tmp289_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp289_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
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
	currentAST = __currentAST359;
	_t = __t359;
	_t = _t->getNextSibling();
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t349 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp290_AST = astFactory->create(_t);
	tmp290_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp290_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST349 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp291_AST = astFactory->create(_t);
	tmp291_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp291_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST349;
	_t = __t349;
	_t = _t->getNextSibling();
	sql92_simpleWhenExpression_AST = currentAST.root;
	returnAST = sql92_simpleWhenExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t351 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp292_AST = astFactory->create(_t);
	tmp292_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp292_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST351 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ELSE);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST351;
	_t = __t351;
	_t = _t->getNextSibling();
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t347 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp293_AST = astFactory->create(_t);
	tmp293_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp293_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST347 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp294_AST = astFactory->create(_t);
	tmp294_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp294_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST347;
	_t = __t347;
	_t = _t->getNextSibling();
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::sql92_queryPrimaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryPrimaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryPrimaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t353 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp295_AST = astFactory->create(_t);
		tmp295_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp295_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST353 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ID);
		_t = _t->getFirstChild();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp296_AST = astFactory->create(_t);
			tmp296_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp296_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp297_AST = astFactory->create(_t);
			tmp297_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp297_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
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
		currentAST = __currentAST353;
		_t = __t353;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp298_AST = astFactory->create(_t);
		tmp298_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp298_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp299_AST = astFactory->create(_t);
		tmp299_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp299_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp300_AST = astFactory->create(_t);
		tmp300_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp300_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp301_AST = astFactory->create(_t);
		tmp301_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp301_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp302_AST = astFactory->create(_t);
		tmp302_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp302_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp303_AST = astFactory->create(_t);
		tmp303_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp303_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp304_AST = astFactory->create(_t);
		tmp304_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp304_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 2246 "mtsql_tree.g"
		
		// Create an enum value from the string.  Convert this to an integer literal.
		RuntimeValue strVal = RuntimeValue::createString((sql92_queryPrimaryExpression_AST->getText().c_str()));
		RuntimeValue enumVal;
		RuntimeValueCast::ToEnum(&enumVal, &strVal, getNameID());
		enumVal = enumVal.castToLong();
			  ((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setValue(enumVal); 
		((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setText(enumVal.castToString().getStringPtr());
		((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setType(NUM_INT);
		
#line 10029 "MTSQLTreeParser.cpp"
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t355 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp305_AST = astFactory->create(_t);
		tmp305_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp305_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST355 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp306_AST = astFactory->create(_t);
		tmp306_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp306_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		sql92_elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp307_AST = astFactory->create(_t);
		tmp307_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp307_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST355;
		_t = __t355;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case LOCALVAR:
	{
		lv = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		lv_AST = astFactory->create(lv);
		astFactory->addASTChild(currentAST, lv_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 2258 "mtsql_tree.g"
		
			  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)sql92_queryPrimaryExpression_AST); 
		referenceVariable((RefMTSQLAST)lv_AST);
			  ((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 10085 "MTSQLTreeParser.cpp"
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t356 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp308_AST = astFactory->create(_t);
		tmp308_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp308_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST356 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp309_AST = astFactory->create(_t);
		tmp309_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp309_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST356;
		_t = __t356;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case SCALAR_SUBQUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t357 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp310_AST = astFactory->create(_t);
		tmp310_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp310_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST357 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SCALAR_SUBQUERY);
		_t = _t->getFirstChild();
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp311_AST = astFactory->create(_t);
		tmp311_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp311_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST357;
		_t = __t357;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_queryPrimaryExpression_AST;
	_retTree = _t;
}

void MTSQLTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(246);
}
const char* MTSQLTreeParser::tokenNames[] = {
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

const unsigned long MTSQLTreeParser::_tokenSet_0_data_[] = { 17317888UL, 536870912UL, 9UL, 2147483648UL, 52445184UL, 161UL, 2146435072UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "PRINT" "RETURN" "SELECT" ASSIGN IFTHENELSE 
// QUERY RAISERROR1 RAISERROR2 SLIST WHILE SEQUENCE INTEGER_SETMEM BIGINT_SETMEM 
// DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM WSTRING_SETMEM BOOLEAN_SETMEM 
// DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM BINARY_SETMEM RAISERRORINTEGER 
// RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING RAISERROR2WSTRING 
// STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeParser::_tokenSet_0(_tokenSet_0_data_,16);
const unsigned long MTSQLTreeParser::_tokenSet_1_data_[] = { 0UL, 0UL, 0UL, 4194304UL, 0UL, 0UL, 1048064UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// LOCALVAR INTEGER_GETMEM BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM 
// WSTRING_GETMEM BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM 
// BINARY_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLTreeParser::_tokenSet_1(_tokenSet_1_data_,16);


