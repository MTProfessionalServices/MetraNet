/* $ANTLR 2.7.6 (2005-12-22): "generate_query.g" -> "GenerateQueryTreeParser.cpp"$ */
#include "GenerateQueryTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "generate_query.g"
#line 11 "GenerateQueryTreeParser.cpp"
GenerateQueryTreeParser::GenerateQueryTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void GenerateQueryTreeParser::mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t2 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp1_AST = astFactory->create(_t);
	tmp1_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp1_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST2 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERY);
	_t = _t->getFirstChild();
	sql92_selectStatement(_t);
	_t = _retTree;
	mtsql_paramList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	mtsql_intoList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST2;
	_t = __t2;
	_t = _t->getNextSibling();
	mtsql_selectStatement_AST = currentAST.root;
	returnAST = mtsql_selectStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp2_AST = astFactory->create(_t);
			tmp2_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp2_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
#line 181 "generate_query.g"
			printNode(tmp2_AST);
#line 72 "GenerateQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp3_AST = astFactory->create(_t);
				tmp3_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp3_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 181 "generate_query.g"
				printNode(tmp3_AST);
#line 88 "GenerateQueryTreeParser.cpp"
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
			goto _loop26;
		}
		
	}
	_loop26:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp4_AST = astFactory->create(_t);
		tmp4_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp4_AST);
		match(_t,TK_ORDER);
		_t = _t->getNextSibling();
#line 182 "generate_query.g"
		printNode(tmp4_AST);
#line 127 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp5_AST = astFactory->create(_t);
		tmp5_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp5_AST);
		match(_t,TK_BY);
		_t = _t->getNextSibling();
#line 182 "generate_query.g"
		printNode(tmp5_AST);
#line 137 "GenerateQueryTreeParser.cpp"
		sql92_orderByExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		break;
	}
	case RPAREN:
	case ARRAY:
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

void GenerateQueryTreeParser::mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t4 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp6_AST = astFactory->create(_t);
	tmp6_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp6_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST4 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ARRAY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case INTEGER_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp7_AST = astFactory->create(_t);
			tmp7_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp7_AST);
			match(_t,INTEGER_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp8_AST = astFactory->create(_t);
			tmp8_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp8_AST);
			match(_t,DECIMAL_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp9_AST = astFactory->create(_t);
			tmp9_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp9_AST);
			match(_t,DOUBLE_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case STRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp10_AST = astFactory->create(_t);
			tmp10_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp10_AST);
			match(_t,STRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp11_AST = astFactory->create(_t);
			tmp11_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp11_AST);
			match(_t,WSTRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp12_AST = astFactory->create(_t);
			tmp12_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp12_AST);
			match(_t,BOOLEAN_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp13_AST = astFactory->create(_t);
			tmp13_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp13_AST);
			match(_t,DATETIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case TIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp14_AST = astFactory->create(_t);
			tmp14_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp14_AST);
			match(_t,TIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp15_AST = astFactory->create(_t);
			tmp15_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp15_AST);
			match(_t,ENUM_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp16_AST = astFactory->create(_t);
			tmp16_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp16_AST);
			match(_t,BIGINT_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BINARY_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp17_AST = astFactory->create(_t);
			tmp17_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp17_AST);
			match(_t,BINARY_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop6;
		}
		}
	}
	_loop6:;
	} // ( ... )*
	currentAST = __currentAST4;
	_t = __t4;
	_t = _t->getNextSibling();
	mtsql_paramList_AST = currentAST.root;
	returnAST = mtsql_paramList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t8 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp18_AST = astFactory->create(_t);
	tmp18_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp18_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST8 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt10=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= INTEGER_SETMEM_QUERY && _t->getType() <= BINARY_SETMEM_QUERY))) {
			mtsql_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt10>=1 ) { goto _loop10; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt10++;
	}
	_loop10:;
	}  // ( ... )+
	currentAST = __currentAST8;
	_t = __t8;
	_t = _t->getNextSibling();
	mtsql_intoList_AST = currentAST.root;
	returnAST = mtsql_intoList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t12 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp19_AST = astFactory->create(_t);
		tmp19_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp19_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST12 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp20_AST = astFactory->create(_t);
		tmp20_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp20_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST12;
		_t = __t12;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t13 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp21_AST = astFactory->create(_t);
		tmp21_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp21_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST13 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp22_AST = astFactory->create(_t);
		tmp22_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp22_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST13;
		_t = __t13;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t14 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp23_AST = astFactory->create(_t);
		tmp23_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp23_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST14 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp24_AST = astFactory->create(_t);
		tmp24_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp24_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST14;
		_t = __t14;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t15 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp25_AST = astFactory->create(_t);
		tmp25_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp25_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST15 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp26_AST = astFactory->create(_t);
		tmp26_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp26_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST15;
		_t = __t15;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t16 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp27_AST = astFactory->create(_t);
		tmp27_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp27_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST16 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp28_AST = astFactory->create(_t);
		tmp28_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp28_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST16;
		_t = __t16;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t17 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp29_AST = astFactory->create(_t);
		tmp29_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp29_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST17 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp30_AST = astFactory->create(_t);
		tmp30_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp30_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST17;
		_t = __t17;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t18 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp31_AST = astFactory->create(_t);
		tmp31_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp31_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST18 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp32_AST = astFactory->create(_t);
		tmp32_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp32_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST18;
		_t = __t18;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp33_AST = astFactory->create(_t);
		tmp33_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp33_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST19 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp34_AST = astFactory->create(_t);
		tmp34_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp34_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST19;
		_t = __t19;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp35_AST = astFactory->create(_t);
		tmp35_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp35_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST20 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp36_AST = astFactory->create(_t);
		tmp36_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp36_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST20;
		_t = __t20;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t21 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp37_AST = astFactory->create(_t);
		tmp37_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp37_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST21 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp38_AST = astFactory->create(_t);
		tmp38_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp38_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST21;
		_t = __t21;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp39_AST = astFactory->create(_t);
		tmp39_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp39_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST22 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp40_AST = astFactory->create(_t);
		tmp40_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp40_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST22;
		_t = __t22;
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

void GenerateQueryTreeParser::sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t38 = _t;
	s = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	s_AST = astFactory->create(s);
	astFactory->addASTChild(currentAST, s_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST38 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_SELECT);
	_t = _t->getFirstChild();
#line 197 "generate_query.g"
	printNode(s_AST);
#line 685 "GenerateQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp41_AST = astFactory->create(_t);
		tmp41_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp41_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
#line 197 "generate_query.g"
		printNode(tmp41_AST);
#line 701 "GenerateQueryTreeParser.cpp"
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp42_AST = astFactory->create(_t);
		tmp42_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp42_AST);
		match(_t,TK_DISTINCT);
		_t = _t->getNextSibling();
#line 197 "generate_query.g"
		printNode(tmp42_AST);
#line 715 "GenerateQueryTreeParser.cpp"
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
	currentAST = __currentAST38;
	_t = __t38;
	_t = _t->getNextSibling();
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ASC:
	{
		a1 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST a1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		a1_AST = astFactory->create(a1);
		astFactory->addASTChild(currentAST, a1_AST);
		match(_t,TK_ASC);
		_t = _t->getNextSibling();
#line 187 "generate_query.g"
		printNode(a1_AST);
#line 816 "GenerateQueryTreeParser.cpp"
		break;
	}
	case TK_DESC:
	{
		d1 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST d1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		d1_AST = astFactory->create(d1);
		astFactory->addASTChild(currentAST, d1_AST);
		match(_t,TK_DESC);
		_t = _t->getNextSibling();
#line 187 "generate_query.g"
		printNode(d1_AST);
#line 829 "GenerateQueryTreeParser.cpp"
		break;
	}
	case COMMA:
	case RPAREN:
	case ARRAY:
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp43_AST = astFactory->create(_t);
			tmp43_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp43_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 187 "generate_query.g"
			printNode(tmp43_AST);
#line 858 "GenerateQueryTreeParser.cpp"
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ASC:
			{
				a2 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST a2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				a2_AST = astFactory->create(a2);
				astFactory->addASTChild(currentAST, a2_AST);
				match(_t,TK_ASC);
				_t = _t->getNextSibling();
#line 187 "generate_query.g"
				printNode(a2_AST);
#line 876 "GenerateQueryTreeParser.cpp"
				break;
			}
			case TK_DESC:
			{
				d2 = _t;
				ANTLR_USE_NAMESPACE(antlr)RefAST d2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				d2_AST = astFactory->create(d2);
				astFactory->addASTChild(currentAST, d2_AST);
				match(_t,TK_DESC);
				_t = _t->getNextSibling();
#line 187 "generate_query.g"
				printNode(d2_AST);
#line 889 "GenerateQueryTreeParser.cpp"
				break;
			}
			case COMMA:
			case RPAREN:
			case ARRAY:
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
			goto _loop32;
		}
		
	}
	_loop32:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp44_AST = astFactory->create(_t);
		tmp44_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp44_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST121 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 316 "generate_query.g"
		printNode(tmp44_AST);
#line 944 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST121;
		_t = __t121;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t122 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp45_AST = astFactory->create(_t);
		tmp45_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp45_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST122 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
#line 317 "generate_query.g"
		printNode(tmp45_AST);
#line 969 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST122;
		_t = __t122;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp46_AST = astFactory->create(_t);
		tmp46_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp46_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST123 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 318 "generate_query.g"
		printNode(tmp46_AST);
#line 997 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST123;
		_t = __t123;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t124 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp47_AST = astFactory->create(_t);
		tmp47_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp47_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST124 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 319 "generate_query.g"
		printNode(tmp47_AST);
#line 1025 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST124;
		_t = __t124;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp48_AST = astFactory->create(_t);
		tmp48_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp48_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST125 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MINUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 321 "generate_query.g"
		printNode(tmp48_AST);
#line 1053 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST125;
		_t = __t125;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t126 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp49_AST = astFactory->create(_t);
		tmp49_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp49_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST126 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MODULUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 322 "generate_query.g"
		printNode(tmp49_AST);
#line 1081 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST126;
		_t = __t126;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp50_AST = astFactory->create(_t);
		tmp50_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp50_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST127 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DIVIDE);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 323 "generate_query.g"
		printNode(tmp50_AST);
#line 1109 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST127;
		_t = __t127;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t128 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp51_AST = astFactory->create(_t);
		tmp51_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp51_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST128 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,PLUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 324 "generate_query.g"
		printNode(tmp51_AST);
#line 1137 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST128;
		_t = __t128;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp52_AST = astFactory->create(_t);
		tmp52_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp52_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST129 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIMES);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 325 "generate_query.g"
		printNode(tmp52_AST);
#line 1165 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST129;
		_t = __t129;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t130 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp53_AST = astFactory->create(_t);
		tmp53_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp53_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST130 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
#line 326 "generate_query.g"
		printNode(tmp53_AST);
#line 1190 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST130;
		_t = __t130;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t131 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp54_AST = astFactory->create(_t);
		tmp54_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp54_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST131 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_PLUS);
		_t = _t->getFirstChild();
#line 327 "generate_query.g"
		printNode(tmp54_AST);
#line 1215 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST131;
		_t = __t131;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t132 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp55_AST = astFactory->create(_t);
		tmp55_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp55_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST132 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
#line 328 "generate_query.g"
		printNode(tmp55_AST);
#line 1240 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp56_AST = astFactory->create(_t);
		tmp56_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp56_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 328 "generate_query.g"
		printNode(tmp56_AST);
#line 1250 "GenerateQueryTreeParser.cpp"
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp57_AST = astFactory->create(_t);
		tmp57_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp57_AST);
		match(_t,TK_AS);
		_t = _t->getNextSibling();
#line 328 "generate_query.g"
		printNode(tmp57_AST);
#line 1263 "GenerateQueryTreeParser.cpp"
		sql92_builtInType(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp58_AST = astFactory->create(_t);
		tmp58_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp58_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 328 "generate_query.g"
		printNode(tmp58_AST);
#line 1276 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST132;
		_t = __t132;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp59_AST = astFactory->create(_t);
		tmp59_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp59_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST133 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_COUNT);
		_t = _t->getFirstChild();
#line 329 "generate_query.g"
		printNode(tmp59_AST);
#line 1298 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp60_AST = astFactory->create(_t);
		tmp60_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp60_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 329 "generate_query.g"
		printNode(tmp60_AST);
#line 1308 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp61_AST = astFactory->create(_t);
			tmp61_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp61_AST);
			match(_t,STAR);
			_t = _t->getNextSibling();
#line 329 "generate_query.g"
			printNode(tmp61_AST);
#line 1324 "GenerateQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp62_AST = astFactory->create(_t);
				tmp62_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp62_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 329 "generate_query.g"
				printNode(tmp62_AST);
#line 1346 "GenerateQueryTreeParser.cpp"
				break;
			}
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp63_AST = astFactory->create(_t);
				tmp63_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp63_AST);
				match(_t,TK_DISTINCT);
				_t = _t->getNextSibling();
#line 329 "generate_query.g"
				printNode(tmp63_AST);
#line 1360 "GenerateQueryTreeParser.cpp"
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
			sql92_expression(_t);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp64_AST = astFactory->create(_t);
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp64_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 329 "generate_query.g"
		printNode(tmp64_AST);
#line 1393 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST133;
		_t = __t133;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t136 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp65_AST = astFactory->create(_t);
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp65_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST136 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_AVG);
		_t = _t->getFirstChild();
#line 330 "generate_query.g"
		printNode(tmp65_AST);
#line 1415 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp66_AST = astFactory->create(_t);
		tmp66_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp66_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 330 "generate_query.g"
		printNode(tmp66_AST);
#line 1425 "GenerateQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp67_AST = astFactory->create(_t);
			tmp67_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp67_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 330 "generate_query.g"
			printNode(tmp67_AST);
#line 1442 "GenerateQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp68_AST = astFactory->create(_t);
			tmp68_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp68_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 330 "generate_query.g"
			printNode(tmp68_AST);
#line 1456 "GenerateQueryTreeParser.cpp"
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp69_AST = astFactory->create(_t);
		tmp69_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp69_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 330 "generate_query.g"
		printNode(tmp69_AST);
#line 1482 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST136;
		_t = __t136;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp70_AST = astFactory->create(_t);
		tmp70_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp70_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST139 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MAX);
		_t = _t->getFirstChild();
#line 331 "generate_query.g"
		printNode(tmp70_AST);
#line 1504 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp71_AST = astFactory->create(_t);
		tmp71_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp71_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 331 "generate_query.g"
		printNode(tmp71_AST);
#line 1514 "GenerateQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp72_AST = astFactory->create(_t);
			tmp72_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp72_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 331 "generate_query.g"
			printNode(tmp72_AST);
#line 1531 "GenerateQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp73_AST = astFactory->create(_t);
			tmp73_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp73_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 331 "generate_query.g"
			printNode(tmp73_AST);
#line 1545 "GenerateQueryTreeParser.cpp"
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp74_AST = astFactory->create(_t);
		tmp74_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp74_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 331 "generate_query.g"
		printNode(tmp74_AST);
#line 1571 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST139;
		_t = __t139;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t142 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp75_AST = astFactory->create(_t);
		tmp75_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp75_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST142 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MIN);
		_t = _t->getFirstChild();
#line 332 "generate_query.g"
		printNode(tmp75_AST);
#line 1593 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp76_AST = astFactory->create(_t);
		tmp76_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp76_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 332 "generate_query.g"
		printNode(tmp76_AST);
#line 1603 "GenerateQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp77_AST = astFactory->create(_t);
			tmp77_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp77_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 332 "generate_query.g"
			printNode(tmp77_AST);
#line 1620 "GenerateQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp78_AST = astFactory->create(_t);
			tmp78_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp78_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 332 "generate_query.g"
			printNode(tmp78_AST);
#line 1634 "GenerateQueryTreeParser.cpp"
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp79_AST = astFactory->create(_t);
		tmp79_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp79_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 332 "generate_query.g"
		printNode(tmp79_AST);
#line 1660 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST142;
		_t = __t142;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp80_AST = astFactory->create(_t);
		tmp80_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp80_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST145 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_SUM);
		_t = _t->getFirstChild();
#line 333 "generate_query.g"
		printNode(tmp80_AST);
#line 1682 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp81_AST = astFactory->create(_t);
		tmp81_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp81_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 333 "generate_query.g"
		printNode(tmp81_AST);
#line 1692 "GenerateQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp82_AST = astFactory->create(_t);
			tmp82_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp82_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 333 "generate_query.g"
			printNode(tmp82_AST);
#line 1709 "GenerateQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp83_AST = astFactory->create(_t);
			tmp83_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp83_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 333 "generate_query.g"
			printNode(tmp83_AST);
#line 1723 "GenerateQueryTreeParser.cpp"
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp84_AST = astFactory->create(_t);
		tmp84_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp84_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 333 "generate_query.g"
		printNode(tmp84_AST);
#line 1749 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST145;
		_t = __t145;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t148 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp85_AST = astFactory->create(_t);
		tmp85_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp85_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST148 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SIMPLE_CASE);
		_t = _t->getFirstChild();
#line 334 "generate_query.g"
		printNode(tmp85_AST);
#line 1771 "GenerateQueryTreeParser.cpp"
		{ // ( ... )+
		int _cnt150=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == SIMPLE_WHEN)) {
				sql92_simpleWhenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt150>=1 ) { goto _loop150; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt150++;
		}
		_loop150:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp86_AST = astFactory->create(_t);
		tmp86_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp86_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
#line 334 "generate_query.g"
		printNode(tmp86_AST);
#line 1820 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST148;
		_t = __t148;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t152 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp87_AST = astFactory->create(_t);
		tmp87_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp87_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST152 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SEARCHED_CASE);
		_t = _t->getFirstChild();
#line 335 "generate_query.g"
		printNode(tmp87_AST);
#line 1842 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )+
		int _cnt154=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_WHEN)) {
				sql92_whenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt154>=1 ) { goto _loop154; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt154++;
		}
		_loop154:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp88_AST = astFactory->create(_t);
		tmp88_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp88_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
#line 335 "generate_query.g"
		printNode(tmp88_AST);
#line 1894 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST152;
		_t = __t152;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case STRING_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	case METHOD_CALL:
	case SCALAR_SUBQUERY:
	{
		sql92_primaryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_expr_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_querySpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_UNION)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp89_AST = astFactory->create(_t);
			tmp89_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp89_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
#line 192 "generate_query.g"
			printNode(tmp89_AST);
#line 1951 "GenerateQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp90_AST = astFactory->create(_t);
				tmp90_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp90_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 192 "generate_query.g"
				printNode(tmp90_AST);
#line 1967 "GenerateQueryTreeParser.cpp"
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
			goto _loop36;
		}
		
	}
	_loop36:;
	} // ( ... )*
	sql92_nestedSelectStatement_AST = currentAST.root;
	returnAST = sql92_nestedSelectStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t43 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp91_AST = astFactory->create(_t);
	tmp91_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp91_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST43 = currentAST;
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
		s = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST s_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		s_AST = astFactory->create(s);
		astFactory->addASTChild(currentAST, s_AST);
		match(_t,STAR);
		_t = _t->getNextSibling();
#line 202 "generate_query.g"
		printNode(s_AST);
#line 2033 "GenerateQueryTreeParser.cpp"
		break;
	}
	case EXPR:
	{
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			a1 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST a1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			a1_AST = astFactory->create(a1);
			astFactory->addASTChild(currentAST, a1_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
#line 202 "generate_query.g"
			printNode(a1_AST);
#line 2055 "GenerateQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp92_AST = astFactory->create(_t);
				tmp92_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp92_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 202 "generate_query.g"
				printNode(tmp92_AST);
#line 2083 "GenerateQueryTreeParser.cpp"
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ALIAS:
				{
					a2 = _t;
					ANTLR_USE_NAMESPACE(antlr)RefAST a2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					a2_AST = astFactory->create(a2);
					astFactory->addASTChild(currentAST, a2_AST);
					match(_t,ALIAS);
					_t = _t->getNextSibling();
#line 202 "generate_query.g"
					printNode(a2_AST);
#line 2101 "GenerateQueryTreeParser.cpp"
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
				goto _loop48;
			}
			
		}
		_loop48:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST43;
	_t = __t43;
	_t = _t->getNextSibling();
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t50 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp93_AST = astFactory->create(_t);
	tmp93_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp93_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST50 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FROM);
	_t = _t->getFirstChild();
#line 207 "generate_query.g"
	printNode(tmp93_AST);
#line 2158 "GenerateQueryTreeParser.cpp"
	sql92_tableSpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp94_AST = astFactory->create(_t);
			tmp94_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp94_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 207 "generate_query.g"
			printNode(tmp94_AST);
#line 2176 "GenerateQueryTreeParser.cpp"
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop52;
		}
		
	}
	_loop52:;
	} // ( ... )*
	currentAST = __currentAST50;
	_t = __t50;
	_t = _t->getNextSibling();
	sql92_fromClause_AST = currentAST.root;
	returnAST = sql92_fromClause_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t78 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp95_AST = astFactory->create(_t);
	tmp95_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp95_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST78 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHERE);
	_t = _t->getFirstChild();
#line 243 "generate_query.g"
	printNode(tmp95_AST);
#line 2215 "GenerateQueryTreeParser.cpp"
	{ // ( ... )+
	int _cnt80=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_0.member(_t->getType()))) {
			sql92_searchCondition(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt80>=1 ) { goto _loop80; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt80++;
	}
	_loop80:;
	}  // ( ... )+
	currentAST = __currentAST78;
	_t = __t78;
	_t = _t->getNextSibling();
	sql92_whereClause_AST = currentAST.root;
	returnAST = sql92_whereClause_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t82 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp96_AST = astFactory->create(_t);
	tmp96_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp96_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST82 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
#line 248 "generate_query.g"
	printNode(tmp96_AST);
#line 2261 "GenerateQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp97_AST = astFactory->create(_t);
	tmp97_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp97_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
#line 248 "generate_query.g"
	printNode(tmp97_AST);
#line 2271 "GenerateQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp98_AST = astFactory->create(_t);
			tmp98_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp98_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 248 "generate_query.g"
			printNode(tmp98_AST);
#line 2289 "GenerateQueryTreeParser.cpp"
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop84;
		}
		
	}
	_loop84:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp99_AST = astFactory->create(_t);
		tmp99_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp99_AST);
		match(_t,TK_HAVING);
		_t = _t->getNextSibling();
#line 248 "generate_query.g"
		printNode(tmp99_AST);
#line 2316 "GenerateQueryTreeParser.cpp"
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
	currentAST = __currentAST82;
	_t = __t82;
	_t = _t->getNextSibling();
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp100_AST = astFactory->create(_t);
	tmp100_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp100_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST93;
	_t = __t93;
	_t = _t->getNextSibling();
	sql92_expression_AST = currentAST.root;
	returnAST = sql92_expression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t54 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp101_AST = astFactory->create(_t);
		tmp101_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp101_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST54 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 212 "generate_query.g"
		printNode(tmp101_AST);
#line 2395 "GenerateQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_joinCriteria(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST54;
		_t = __t54;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case TABLE_REF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t55 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp102_AST = astFactory->create(_t);
		tmp102_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp102_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST55 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TABLE_REF);
		_t = _t->getFirstChild();
#line 214 "generate_query.g"
		printNode(tmp102_AST);
#line 2423 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp103_AST = astFactory->create(_t);
			tmp103_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp103_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
#line 214 "generate_query.g"
			printNode(tmp103_AST);
#line 2439 "GenerateQueryTreeParser.cpp"
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
		currentAST = __currentAST55;
		_t = __t55;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case CROSS_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t58 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp104_AST = astFactory->create(_t);
		tmp104_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp104_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST58 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CROSS_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 216 "generate_query.g"
		printNode(tmp104_AST);
#line 2498 "GenerateQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST58;
		_t = __t58;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case GROUPED_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t59 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp105_AST = astFactory->create(_t);
		tmp105_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp105_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST59 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GROUPED_JOIN);
		_t = _t->getFirstChild();
#line 218 "generate_query.g"
		printNode(tmp105_AST);
#line 2523 "GenerateQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp106_AST = astFactory->create(_t);
		tmp106_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp106_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 218 "generate_query.g"
		printNode(tmp106_AST);
#line 2536 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST59;
		_t = __t59;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case DERIVED_TABLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t60 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp107_AST = astFactory->create(_t);
		tmp107_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp107_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST60 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DERIVED_TABLE);
		_t = _t->getFirstChild();
#line 220 "generate_query.g"
		printNode(tmp107_AST);
#line 2558 "GenerateQueryTreeParser.cpp"
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp108_AST = astFactory->create(_t);
		tmp108_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp108_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 220 "generate_query.g"
		printNode(tmp108_AST);
#line 2571 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp109_AST = astFactory->create(_t);
		tmp109_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp109_AST);
		match(_t,ALIAS);
		_t = _t->getNextSibling();
#line 220 "generate_query.g"
		printNode(tmp109_AST);
#line 2581 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST60;
		_t = __t60;
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

void GenerateQueryTreeParser::sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t76 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp110_AST = astFactory->create(_t);
	tmp110_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp110_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST76 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ON);
	_t = _t->getFirstChild();
#line 238 "generate_query.g"
	printNode(tmp110_AST);
#line 2616 "GenerateQueryTreeParser.cpp"
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST76;
	_t = __t76;
	_t = _t->getNextSibling();
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t62 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp111_AST = astFactory->create(_t);
	tmp111_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp111_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST62 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WITH);
	_t = _t->getFirstChild();
#line 225 "generate_query.g"
	printNode(tmp111_AST);
#line 2647 "GenerateQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp112_AST = astFactory->create(_t);
	tmp112_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp112_AST);
	match(_t,LPAREN);
	_t = _t->getNextSibling();
#line 225 "generate_query.g"
	printNode(tmp112_AST);
#line 2657 "GenerateQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp113_AST = astFactory->create(_t);
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp113_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 226 "generate_query.g"
		printNode(tmp113_AST);
#line 2673 "GenerateQueryTreeParser.cpp"
		break;
	}
	case TK_INDEX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp114_AST = astFactory->create(_t);
		tmp114_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp114_AST);
		match(_t,TK_INDEX);
		_t = _t->getNextSibling();
#line 226 "generate_query.g"
		printNode(tmp114_AST);
#line 2687 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp115_AST = astFactory->create(_t);
		tmp115_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp115_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 226 "generate_query.g"
		printNode(tmp115_AST);
#line 2697 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ID:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp116_AST = astFactory->create(_t);
			tmp116_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp116_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
#line 227 "generate_query.g"
			printNode(tmp116_AST);
#line 2713 "GenerateQueryTreeParser.cpp"
			break;
		}
		case NUM_INT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp117_AST = astFactory->create(_t);
			tmp117_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp117_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 227 "generate_query.g"
			printNode(tmp117_AST);
#line 2727 "GenerateQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp118_AST = astFactory->create(_t);
				tmp118_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp118_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 228 "generate_query.g"
				printNode(tmp118_AST);
#line 2750 "GenerateQueryTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp119_AST = astFactory->create(_t);
					tmp119_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp119_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
#line 228 "generate_query.g"
					printNode(tmp119_AST);
#line 2766 "GenerateQueryTreeParser.cpp"
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp120_AST = astFactory->create(_t);
					tmp120_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp120_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
#line 228 "generate_query.g"
					printNode(tmp120_AST);
#line 2780 "GenerateQueryTreeParser.cpp"
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
				goto _loop67;
			}
			
		}
		_loop67:;
		} // ( ... )*
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp121_AST = astFactory->create(_t);
		tmp121_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp121_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 228 "generate_query.g"
		printNode(tmp121_AST);
#line 2806 "GenerateQueryTreeParser.cpp"
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp122_AST = astFactory->create(_t);
			tmp122_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp122_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 229 "generate_query.g"
			printNode(tmp122_AST);
#line 2829 "GenerateQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case ID:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp123_AST = astFactory->create(_t);
				tmp123_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp123_AST);
				match(_t,ID);
				_t = _t->getNextSibling();
#line 230 "generate_query.g"
				printNode(tmp123_AST);
#line 2845 "GenerateQueryTreeParser.cpp"
				break;
			}
			case TK_INDEX:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp124_AST = astFactory->create(_t);
				tmp124_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp124_AST);
				match(_t,TK_INDEX);
				_t = _t->getNextSibling();
#line 230 "generate_query.g"
				printNode(tmp124_AST);
#line 2859 "GenerateQueryTreeParser.cpp"
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp125_AST = astFactory->create(_t);
				tmp125_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp125_AST);
				match(_t,LPAREN);
				_t = _t->getNextSibling();
#line 230 "generate_query.g"
				printNode(tmp125_AST);
#line 2869 "GenerateQueryTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp126_AST = astFactory->create(_t);
					tmp126_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp126_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
#line 231 "generate_query.g"
					printNode(tmp126_AST);
#line 2885 "GenerateQueryTreeParser.cpp"
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp127_AST = astFactory->create(_t);
					tmp127_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp127_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
#line 231 "generate_query.g"
					printNode(tmp127_AST);
#line 2899 "GenerateQueryTreeParser.cpp"
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
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
						tmp128_AST = astFactory->create(_t);
						tmp128_AST_in = _t;
						astFactory->addASTChild(currentAST, tmp128_AST);
						match(_t,COMMA);
						_t = _t->getNextSibling();
#line 232 "generate_query.g"
						printNode(tmp128_AST);
#line 2922 "GenerateQueryTreeParser.cpp"
						{
						if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
							_t = ASTNULL;
						switch ( _t->getType()) {
						case ID:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp129_AST = astFactory->create(_t);
							tmp129_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp129_AST);
							match(_t,ID);
							_t = _t->getNextSibling();
#line 232 "generate_query.g"
							printNode(tmp129_AST);
#line 2938 "GenerateQueryTreeParser.cpp"
							break;
						}
						case NUM_INT:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp130_AST = astFactory->create(_t);
							tmp130_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp130_AST);
							match(_t,NUM_INT);
							_t = _t->getNextSibling();
#line 232 "generate_query.g"
							printNode(tmp130_AST);
#line 2952 "GenerateQueryTreeParser.cpp"
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
						goto _loop73;
					}
					
				}
				_loop73:;
				} // ( ... )*
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp131_AST = astFactory->create(_t);
				tmp131_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp131_AST);
				match(_t,RPAREN);
				_t = _t->getNextSibling();
#line 232 "generate_query.g"
				printNode(tmp131_AST);
#line 2978 "GenerateQueryTreeParser.cpp"
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
			goto _loop74;
		}
		
	}
	_loop74:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp132_AST = astFactory->create(_t);
	tmp132_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp132_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
#line 233 "generate_query.g"
	printNode(tmp132_AST);
#line 3004 "GenerateQueryTreeParser.cpp"
	currentAST = __currentAST62;
	_t = __t62;
	_t = _t->getNextSibling();
	sql92_tableHint_AST = currentAST.root;
	returnAST = sql92_tableHint_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp133_AST = astFactory->create(_t);
		tmp133_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp133_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST95 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,EQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 269 "generate_query.g"
		printNode(tmp133_AST);
#line 3040 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST95;
		_t = __t95;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t96 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp134_AST = astFactory->create(_t);
		tmp134_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp134_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST96 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GT);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 270 "generate_query.g"
		printNode(tmp134_AST);
#line 3068 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST96;
		_t = __t96;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t97 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp135_AST = astFactory->create(_t);
		tmp135_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp135_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST97 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 271 "generate_query.g"
		printNode(tmp135_AST);
#line 3096 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST97;
		_t = __t97;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t98 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp136_AST = astFactory->create(_t);
		tmp136_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp136_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST98 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTN);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 272 "generate_query.g"
		printNode(tmp136_AST);
#line 3124 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST98;
		_t = __t98;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t99 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp137_AST = astFactory->create(_t);
		tmp137_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp137_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST99 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 273 "generate_query.g"
		printNode(tmp137_AST);
#line 3152 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST99;
		_t = __t99;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp138_AST = astFactory->create(_t);
		tmp138_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp138_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST100 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,NOTEQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 274 "generate_query.g"
		printNode(tmp138_AST);
#line 3180 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST100;
		_t = __t100;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t101 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp139_AST = astFactory->create(_t);
		tmp139_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp139_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST101 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_LIKE);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp140_AST = astFactory->create(_t);
			tmp140_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp140_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 276 "generate_query.g"
			printNode(tmp140_AST);
#line 3221 "GenerateQueryTreeParser.cpp"
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
#line 276 "generate_query.g"
		printNode(tmp139_AST);
#line 3265 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST101;
		_t = __t101;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp141_AST = astFactory->create(_t);
		tmp141_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp141_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST103 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 278 "generate_query.g"
		printNode(tmp141_AST);
#line 3293 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp142_AST = astFactory->create(_t);
			tmp142_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp142_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 278 "generate_query.g"
			printNode(tmp142_AST);
#line 3309 "GenerateQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp143_AST = astFactory->create(_t);
		tmp143_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp143_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
#line 278 "generate_query.g"
		printNode(tmp143_AST);
#line 3331 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST103;
		_t = __t103;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_BETWEEN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp144_AST = astFactory->create(_t);
		tmp144_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp144_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST105 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_BETWEEN);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp145_AST = astFactory->create(_t);
			tmp145_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp145_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 280 "generate_query.g"
			printNode(tmp145_AST);
#line 3369 "GenerateQueryTreeParser.cpp"
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
#line 280 "generate_query.g"
		printNode(tmp144_AST);
#line 3413 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp146_AST = astFactory->create(_t);
		tmp146_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp146_AST);
		match(_t,TK_AND);
		_t = _t->getNextSibling();
#line 280 "generate_query.g"
		printNode(tmp146_AST);
#line 3426 "GenerateQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST105;
		_t = __t105;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t107 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp147_AST = astFactory->create(_t);
		tmp147_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp147_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST107 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp148_AST = astFactory->create(_t);
			tmp148_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp148_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 282 "generate_query.g"
			printNode(tmp148_AST);
#line 3464 "GenerateQueryTreeParser.cpp"
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
#line 282 "generate_query.g"
		printNode(tmp147_AST);
#line 3479 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp149_AST = astFactory->create(_t);
		tmp149_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp149_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 283 "generate_query.g"
		printNode(tmp149_AST);
#line 3489 "GenerateQueryTreeParser.cpp"
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp150_AST = astFactory->create(_t);
		tmp150_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp150_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 285 "generate_query.g"
		printNode(tmp150_AST);
#line 3502 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST107;
		_t = __t107;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp151_AST = astFactory->create(_t);
		tmp151_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp151_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST109 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IN);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp152_AST = astFactory->create(_t);
			tmp152_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp152_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 287 "generate_query.g"
			printNode(tmp152_AST);
#line 3540 "GenerateQueryTreeParser.cpp"
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
#line 287 "generate_query.g"
		printNode(tmp151_AST);
#line 3555 "GenerateQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp153_AST = astFactory->create(_t);
		tmp153_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp153_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 288 "generate_query.g"
		printNode(tmp153_AST);
#line 3565 "GenerateQueryTreeParser.cpp"
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
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{ // ( ... )*
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == COMMA)) {
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp154_AST = astFactory->create(_t);
					tmp154_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp154_AST);
					match(_t,COMMA);
					_t = _t->getNextSibling();
#line 290 "generate_query.g"
					printNode(tmp154_AST);
#line 3625 "GenerateQueryTreeParser.cpp"
					sql92_expr(_t);
					_t = _retTree;
					astFactory->addASTChild( currentAST, returnAST );
				}
				else {
					goto _loop113;
				}
				
			}
			_loop113:;
			} // ( ... )*
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp155_AST = astFactory->create(_t);
		tmp155_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp155_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 291 "generate_query.g"
		printNode(tmp155_AST);
#line 3654 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST109;
		_t = __t109;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp156_AST = astFactory->create(_t);
		tmp156_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp156_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST114 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LAND);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 293 "generate_query.g"
		printNode(tmp156_AST);
#line 3679 "GenerateQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST114;
		_t = __t114;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp157_AST = astFactory->create(_t);
		tmp157_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp157_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST115 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
#line 294 "generate_query.g"
		printNode(tmp157_AST);
#line 3704 "GenerateQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST115;
		_t = __t115;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t116 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp158_AST = astFactory->create(_t);
		tmp158_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp158_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST116 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LOR);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 295 "generate_query.g"
		printNode(tmp158_AST);
#line 3732 "GenerateQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST116;
		_t = __t116;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp159_AST = astFactory->create(_t);
		tmp159_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp159_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST117 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
#line 296 "generate_query.g"
		printNode(tmp159_AST);
#line 3757 "GenerateQueryTreeParser.cpp"
		sql92_hackExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp160_AST = astFactory->create(_t);
		tmp160_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp160_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 296 "generate_query.g"
		printNode(tmp160_AST);
#line 3770 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST117;
		_t = __t117;
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

void GenerateQueryTreeParser::sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void GenerateQueryTreeParser::sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t88 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp161_AST = astFactory->create(_t);
	tmp161_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp161_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST88 = currentAST;
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp162_AST = astFactory->create(_t);
				tmp162_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp162_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 258 "generate_query.g"
				printNode(tmp162_AST);
#line 3840 "GenerateQueryTreeParser.cpp"
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop91;
			}
			
		}
		_loop91:;
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
	currentAST = __currentAST88;
	_t = __t88;
	_t = _t->getNextSibling();
	sql92_elist_AST = currentAST.root;
	returnAST = sql92_elist_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp163_AST = astFactory->create(_t);
	tmp163_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp163_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST119 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST119;
	_t = __t119;
	_t = _t->getNextSibling();
	sql92_hackExpression_AST = currentAST.root;
	returnAST = sql92_hackExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t163 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp164_AST = astFactory->create(_t);
	tmp164_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp164_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST163 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,BUILTIN_TYPE);
	_t = _t->getFirstChild();
#line 360 "generate_query.g"
	printNode(tmp164_AST);
#line 3923 "GenerateQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_PRECISION:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp165_AST = astFactory->create(_t);
		tmp165_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp165_AST);
		match(_t,TK_PRECISION);
		_t = _t->getNextSibling();
#line 360 "generate_query.g"
		printNode(tmp165_AST);
#line 3939 "GenerateQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp166_AST = astFactory->create(_t);
		tmp166_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp166_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 360 "generate_query.g"
		printNode(tmp166_AST);
#line 3968 "GenerateQueryTreeParser.cpp"
		n1 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST n1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		n1_AST = astFactory->create(n1);
		astFactory->addASTChild(currentAST, n1_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
#line 360 "generate_query.g"
		printNode(n1_AST);
#line 3977 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp167_AST = astFactory->create(_t);
			tmp167_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp167_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 360 "generate_query.g"
			printNode(tmp167_AST);
#line 3993 "GenerateQueryTreeParser.cpp"
			n2 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST n2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			n2_AST = astFactory->create(n2);
			astFactory->addASTChild(currentAST, n2_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 360 "generate_query.g"
			printNode(n2_AST);
#line 4002 "GenerateQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp168_AST = astFactory->create(_t);
		tmp168_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp168_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 360 "generate_query.g"
		printNode(tmp168_AST);
#line 4024 "GenerateQueryTreeParser.cpp"
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
	currentAST = __currentAST163;
	_t = __t163;
	_t = _t->getNextSibling();
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t159 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp169_AST = astFactory->create(_t);
	tmp169_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp169_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST159 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
#line 349 "generate_query.g"
	printNode(tmp169_AST);
#line 4064 "GenerateQueryTreeParser.cpp"
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp170_AST = astFactory->create(_t);
	tmp170_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp170_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
#line 349 "generate_query.g"
	printNode(tmp170_AST);
#line 4077 "GenerateQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST159;
	_t = __t159;
	_t = _t->getNextSibling();
	sql92_simpleWhenExpression_AST = currentAST.root;
	returnAST = sql92_simpleWhenExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t161 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp171_AST = astFactory->create(_t);
	tmp171_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp171_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST161 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ELSE);
	_t = _t->getFirstChild();
#line 355 "generate_query.g"
	printNode(tmp171_AST);
#line 4108 "GenerateQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST161;
	_t = __t161;
	_t = _t->getNextSibling();
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t157 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp172_AST = astFactory->create(_t);
	tmp172_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp172_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST157 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
#line 343 "generate_query.g"
	printNode(tmp172_AST);
#line 4139 "GenerateQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp173_AST = astFactory->create(_t);
	tmp173_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp173_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
#line 343 "generate_query.g"
	printNode(tmp173_AST);
#line 4152 "GenerateQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST157;
	_t = __t157;
	_t = _t->getNextSibling();
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
		id1 = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST id1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		id1_AST = astFactory->create(id1);
		astFactory->addASTChild(currentAST, id1_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST169 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ID);
		_t = _t->getFirstChild();
#line 366 "generate_query.g"
		printNode(id1_AST);
#line 4192 "GenerateQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp174_AST = astFactory->create(_t);
			tmp174_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp174_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
#line 366 "generate_query.g"
			printNode(tmp174_AST);
#line 4208 "GenerateQueryTreeParser.cpp"
			id2 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST id2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			id2_AST = astFactory->create(id2);
			astFactory->addASTChild(currentAST, id2_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
#line 366 "generate_query.g"
			printNode(id2_AST);
#line 4217 "GenerateQueryTreeParser.cpp"
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
		currentAST = __currentAST169;
		_t = __t169;
		_t = _t->getNextSibling();
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp175_AST = astFactory->create(_t);
		tmp175_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp175_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
#line 367 "generate_query.g"
		printNode(tmp175_AST);
#line 4246 "GenerateQueryTreeParser.cpp"
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp176_AST = astFactory->create(_t);
		tmp176_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp176_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
#line 368 "generate_query.g"
		printNode(tmp176_AST);
#line 4260 "GenerateQueryTreeParser.cpp"
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp177_AST = astFactory->create(_t);
		tmp177_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp177_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
#line 369 "generate_query.g"
		printNode(tmp177_AST);
#line 4274 "GenerateQueryTreeParser.cpp"
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp178_AST = astFactory->create(_t);
		tmp178_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp178_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
#line 370 "generate_query.g"
		printNode(tmp178_AST);
#line 4288 "GenerateQueryTreeParser.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp179_AST = astFactory->create(_t);
		tmp179_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp179_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
#line 371 "generate_query.g"
		printNode(tmp179_AST);
#line 4302 "GenerateQueryTreeParser.cpp"
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp180_AST = astFactory->create(_t);
		tmp180_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp180_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
#line 372 "generate_query.g"
		printNode(tmp180_AST);
#line 4316 "GenerateQueryTreeParser.cpp"
		break;
	}
	case LOCALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp181_AST = astFactory->create(_t);
		tmp181_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp181_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
#line 375 "generate_query.g"
		
		printLocalvarNode(tmp181_AST); 
		
#line 4332 "GenerateQueryTreeParser.cpp"
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t171 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp182_AST = astFactory->create(_t);
		tmp182_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp182_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST171 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
#line 378 "generate_query.g"
		printNode(tmp182_AST);
#line 4350 "GenerateQueryTreeParser.cpp"
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp183_AST = astFactory->create(_t);
		tmp183_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp183_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 378 "generate_query.g"
		printNode(tmp183_AST);
#line 4363 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST171;
		_t = __t171;
		_t = _t->getNextSibling();
		break;
	}
	case SCALAR_SUBQUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t172 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp184_AST = astFactory->create(_t);
		tmp184_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp184_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST172 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SCALAR_SUBQUERY);
		_t = _t->getFirstChild();
#line 379 "generate_query.g"
		printNode(tmp184_AST);
#line 4384 "GenerateQueryTreeParser.cpp"
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp185_AST = astFactory->create(_t);
		tmp185_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp185_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 379 "generate_query.g"
		printNode(tmp185_AST);
#line 4397 "GenerateQueryTreeParser.cpp"
		currentAST = __currentAST172;
		_t = __t172;
		_t = _t->getNextSibling();
		break;
	}
	case METHOD_CALL:
	{
		sql92_methodCall(_t);
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
	sql92_primaryExpression_AST = currentAST.root;
	returnAST = sql92_primaryExpression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::sql92_methodCall(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_methodCall_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_methodCall_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t174 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp186_AST = astFactory->create(_t);
	tmp186_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp186_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST174 = currentAST;
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
#line 386 "generate_query.g"
	printNode(id_AST); printNode(tmp186_AST);
#line 4448 "GenerateQueryTreeParser.cpp"
	sql92_elist(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp187_AST = astFactory->create(_t);
	tmp187_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp187_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
#line 386 "generate_query.g"
	printNode(tmp187_AST);
#line 4461 "GenerateQueryTreeParser.cpp"
	currentAST = __currentAST174;
	_t = __t174;
	_t = _t->getNextSibling();
	sql92_methodCall_AST = currentAST.root;
	returnAST = sql92_methodCall_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
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
			goto _loop177;
		}
		
	}
	_loop177:;
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
	ANTLR_USE_NAMESPACE(antlr)RefAST __t179 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp188_AST = astFactory->create(_t);
	tmp188_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp188_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST179 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SCOPE);
	_t = _t->getFirstChild();
#line 393 "generate_query.g"
	mEnv->beginScope();
#line 4526 "GenerateQueryTreeParser.cpp"
	statementList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
#line 394 "generate_query.g"
	mEnv->endScope();
#line 4532 "GenerateQueryTreeParser.cpp"
	currentAST = __currentAST179;
	_t = __t179;
	_t = _t->getNextSibling();
	program_AST = currentAST.root;
	returnAST = program_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t187 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp189_AST = astFactory->create(_t);
	tmp189_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp189_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST187 = currentAST;
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
	currentAST = __currentAST187;
	_t = __t187;
	_t = _t->getNextSibling();
#line 455 "generate_query.g"
	
				
			mEnv->insertVar(
			var->getText(), 
			VarEntry::create(getType(ty->getText()), mEnv->allocateVariable(var->getText(), getType(ty->getText())), mEnv->getCurrentLevel())); 
		
#line 4584 "GenerateQueryTreeParser.cpp"
	typeDeclaration_AST = currentAST.root;
	returnAST = typeDeclaration_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t181 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp190_AST = astFactory->create(_t);
	tmp190_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp190_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST181 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_RETURNS);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp191_AST = astFactory->create(_t);
	tmp191_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp191_AST);
	match(_t,BUILTIN_TYPE);
	_t = _t->getNextSibling();
	currentAST = __currentAST181;
	_t = __t181;
	_t = _t->getNextSibling();
	returnsDeclaration_AST = currentAST.root;
	returnAST = returnsDeclaration_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_1.member(_t->getType()))) {
			statement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop184;
		}
		
	}
	_loop184:;
	} // ( ... )*
	statementList_AST = currentAST.root;
	returnAST = statementList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
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
	case WSTRING_PRINT:
	{
		wstringPrintStatement(_t);
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
	case SEQUENCE:
	{
		seq(_t);
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
	case RAISERRORINTEGER:
	{
		raiserrorIntegerStatement(_t);
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
	case QUERY:
	{
#line 441 "generate_query.g"
		
		mQueryString = L"";
		mQueryParameters.clear();
		
#line 4803 "GenerateQueryTreeParser.cpp"
		mtsql_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 446 "generate_query.g"
		
		RefMTSQLAST ast = ((RefMTSQLAST)statement_AST);
		ast->setValue(RuntimeValue::createWString(mQueryString)); 
		
#line 4813 "GenerateQueryTreeParser.cpp"
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

void GenerateQueryTreeParser::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp192_AST = astFactory->create(_t);
		tmp192_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp192_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST189 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST189;
		_t = __t189;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t190 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp193_AST = astFactory->create(_t);
		tmp193_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp193_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST190 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST190;
		_t = __t190;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t191 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp194_AST = astFactory->create(_t);
		tmp194_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp194_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST191 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST191;
		_t = __t191;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t192 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp195_AST = astFactory->create(_t);
		tmp195_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp195_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST192 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST192;
		_t = __t192;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t193 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp196_AST = astFactory->create(_t);
		tmp196_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp196_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST193 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST193;
		_t = __t193;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t194 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp197_AST = astFactory->create(_t);
		tmp197_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp197_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST194 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST194;
		_t = __t194;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t195 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp198_AST = astFactory->create(_t);
		tmp198_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp198_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST195 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST195;
		_t = __t195;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t196 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp199_AST = astFactory->create(_t);
		tmp199_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp199_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST196 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST196;
		_t = __t196;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t197 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp200_AST = astFactory->create(_t);
		tmp200_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp200_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST197 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST197;
		_t = __t197;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t198 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp201_AST = astFactory->create(_t);
		tmp201_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp201_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST198 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST198;
		_t = __t198;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t199 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp202_AST = astFactory->create(_t);
		tmp202_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp202_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST199 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM);
		_t = _t->getFirstChild();
		varAddress(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST199;
		_t = __t199;
		_t = _t->getNextSibling();
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

void GenerateQueryTreeParser::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t204 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp203_AST = astFactory->create(_t);
	tmp203_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp203_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST204 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WSTRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST204;
	_t = __t204;
	_t = _t->getNextSibling();
	wstringPrintStatement_AST = currentAST.root;
	returnAST = wstringPrintStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t202 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp204_AST = astFactory->create(_t);
	tmp204_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp204_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST202 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,STRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST202;
	_t = __t202;
	_t = _t->getNextSibling();
	stringPrintStatement_AST = currentAST.root;
	returnAST = stringPrintStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t206 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp205_AST = astFactory->create(_t);
	tmp205_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp205_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST206 = currentAST;
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
	currentAST = __currentAST206;
	_t = __t206;
	_t = _t->getNextSibling();
	seq_AST = currentAST.root;
	returnAST = seq_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t234 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp206_AST = astFactory->create(_t);
	tmp206_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp206_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST234 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,IFTHENELSE);
	_t = _t->getFirstChild();
	expression(_t);
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
	currentAST = __currentAST234;
	_t = __t234;
	_t = _t->getNextSibling();
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t239 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp207_AST = astFactory->create(_t);
	tmp207_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp207_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST239 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SLIST);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_1.member(_t->getType()))) {
			statement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop241;
		}
		
	}
	_loop241:;
	} // ( ... )*
	currentAST = __currentAST239;
	_t = __t239;
	_t = _t->getNextSibling();
	listOfStatements_AST = currentAST.root;
	returnAST = listOfStatements_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t243 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp208_AST = astFactory->create(_t);
	tmp208_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp208_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST243 = currentAST;
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
		expression(_t);
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
	currentAST = __currentAST243;
	_t = __t243;
	_t = _t->getNextSibling();
	returnStatement_AST = currentAST.root;
	returnAST = returnStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp209_AST = astFactory->create(_t);
	tmp209_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp209_AST);
	match(_t,TK_BREAK);
	_t = _t->getNextSibling();
	breakStatement_AST = currentAST.root;
	returnAST = breakStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp210_AST = astFactory->create(_t);
	tmp210_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp210_AST);
	match(_t,TK_CONTINUE);
	_t = _t->getNextSibling();
	continueStatement_AST = currentAST.root;
	returnAST = continueStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t248 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp211_AST = astFactory->create(_t);
	tmp211_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp211_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST248 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WHILE);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	delayedStatement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST248;
	_t = __t248;
	_t = _t->getNextSibling();
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t252 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp212_AST = astFactory->create(_t);
	tmp212_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp212_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST252 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST252;
	_t = __t252;
	_t = _t->getNextSibling();
	raiserrorStringStatement_AST = currentAST.root;
	returnAST = raiserrorStringStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t254 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp213_AST = astFactory->create(_t);
	tmp213_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp213_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST254 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORWSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST254;
	_t = __t254;
	_t = _t->getNextSibling();
	raiserrorWStringStatement_AST = currentAST.root;
	returnAST = raiserrorWStringStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t250 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp214_AST = astFactory->create(_t);
	tmp214_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp214_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST250 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORINTEGER);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST250;
	_t = __t250;
	_t = _t->getNextSibling();
	raiserrorIntegerStatement_AST = currentAST.root;
	returnAST = raiserrorIntegerStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t256 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp215_AST = astFactory->create(_t);
	tmp215_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp215_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST256 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2STRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST256;
	_t = __t256;
	_t = _t->getNextSibling();
	raiserror2StringStatement_AST = currentAST.root;
	returnAST = raiserror2StringStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t258 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp216_AST = astFactory->create(_t);
	tmp216_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp216_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST258 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2WSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST258;
	_t = __t258;
	_t = _t->getNextSibling();
	raiserror2WStringStatement_AST = currentAST.root;
	returnAST = raiserror2WStringStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST varAddress_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST varAddress_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST l = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST l_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	l = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST l_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	l_AST = astFactory->create(l);
	astFactory->addASTChild(currentAST, l_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	varAddress_AST = currentAST.root;
	returnAST = varAddress_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t265 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp217_AST = astFactory->create(_t);
	tmp217_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp217_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST265 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST265;
	_t = __t265;
	_t = _t->getNextSibling();
	expression_AST = currentAST.root;
	returnAST = expression_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t267 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp218_AST = astFactory->create(_t);
		tmp218_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp218_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST267 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST267;
		_t = __t267;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t268 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp219_AST = astFactory->create(_t);
		tmp219_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp219_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST268 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST268;
		_t = __t268;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t269 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp220_AST = astFactory->create(_t);
		tmp220_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp220_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST269 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST269;
		_t = __t269;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t270 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp221_AST = astFactory->create(_t);
		tmp221_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp221_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST270 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST270;
		_t = __t270;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t271 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp222_AST = astFactory->create(_t);
		tmp222_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp222_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST271 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LAND);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST271;
		_t = __t271;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t272 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp223_AST = astFactory->create(_t);
		tmp223_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp223_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST272 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LOR);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST272;
		_t = __t272;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t273 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp224_AST = astFactory->create(_t);
		tmp224_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp224_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST273 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST273;
		_t = __t273;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t274 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp225_AST = astFactory->create(_t);
		tmp225_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp225_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST274 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,EQUALS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST274;
		_t = __t274;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t275 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp226_AST = astFactory->create(_t);
		tmp226_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp226_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST275 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST275;
		_t = __t275;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t276 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp227_AST = astFactory->create(_t);
		tmp227_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp227_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST276 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GTEQ);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST276;
		_t = __t276;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t277 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp228_AST = astFactory->create(_t);
		tmp228_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp228_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST277 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTN);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST277;
		_t = __t277;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t278 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp229_AST = astFactory->create(_t);
		tmp229_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp229_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST278 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTEQ);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST278;
		_t = __t278;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t279 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp230_AST = astFactory->create(_t);
		tmp230_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp230_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST279 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,NOTEQUALS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST279;
		_t = __t279;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ISNULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t280 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp231_AST = astFactory->create(_t);
		tmp231_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp231_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST280 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ISNULL);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST280;
		_t = __t280;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t281 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp232_AST = astFactory->create(_t);
		tmp232_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp232_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST281 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST281;
		_t = __t281;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t282 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp233_AST = astFactory->create(_t);
		tmp233_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp233_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST282 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST282;
		_t = __t282;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t283 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp234_AST = astFactory->create(_t);
		tmp234_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp234_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST283 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_LIKE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST283;
		_t = __t283;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t284 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp235_AST = astFactory->create(_t);
		tmp235_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp235_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST284 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_LIKE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST284;
		_t = __t284;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t285 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp236_AST = astFactory->create(_t);
		tmp236_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp236_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST285 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST285;
		_t = __t285;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t286 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp237_AST = astFactory->create(_t);
		tmp237_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp237_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST286 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_DIVIDE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST286;
		_t = __t286;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t287 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp238_AST = astFactory->create(_t);
		tmp238_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp238_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST287 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST287;
		_t = __t287;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t288 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp239_AST = astFactory->create(_t);
		tmp239_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp239_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST288 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_TIMES);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST288;
		_t = __t288;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t289 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp240_AST = astFactory->create(_t);
		tmp240_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp240_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST289 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST289;
		_t = __t289;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t290 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp241_AST = astFactory->create(_t);
		tmp241_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp241_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST290 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST290;
		_t = __t290;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t291 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp242_AST = astFactory->create(_t);
		tmp242_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp242_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST291 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_DIVIDE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST291;
		_t = __t291;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t292 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp243_AST = astFactory->create(_t);
		tmp243_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp243_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST292 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST292;
		_t = __t292;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t293 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp244_AST = astFactory->create(_t);
		tmp244_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp244_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST293 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_TIMES);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST293;
		_t = __t293;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t294 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp245_AST = astFactory->create(_t);
		tmp245_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp245_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST294 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST294;
		_t = __t294;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t295 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp246_AST = astFactory->create(_t);
		tmp246_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp246_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST295 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST295;
		_t = __t295;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t296 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp247_AST = astFactory->create(_t);
		tmp247_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp247_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST296 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_DIVIDE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST296;
		_t = __t296;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t297 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp248_AST = astFactory->create(_t);
		tmp248_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp248_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST297 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST297;
		_t = __t297;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t298 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp249_AST = astFactory->create(_t);
		tmp249_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp249_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST298 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_TIMES);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST298;
		_t = __t298;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t299 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp250_AST = astFactory->create(_t);
		tmp250_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp250_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST299 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST299;
		_t = __t299;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t300 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp251_AST = astFactory->create(_t);
		tmp251_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp251_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST300 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST300;
		_t = __t300;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t301 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp252_AST = astFactory->create(_t);
		tmp252_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp252_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST301 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_DIVIDE);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST301;
		_t = __t301;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t302 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp253_AST = astFactory->create(_t);
		tmp253_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp253_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST302 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_PLUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST302;
		_t = __t302;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t303 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp254_AST = astFactory->create(_t);
		tmp254_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp254_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST303 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_TIMES);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST303;
		_t = __t303;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t304 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp255_AST = astFactory->create(_t);
		tmp255_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp255_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST304 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST304;
		_t = __t304;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t305 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp256_AST = astFactory->create(_t);
		tmp256_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp256_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST305 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_MODULUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST305;
		_t = __t305;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t306 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp257_AST = astFactory->create(_t);
		tmp257_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp257_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST306 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_MODULUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST306;
		_t = __t306;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case IFBLOCK:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t307 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp258_AST = astFactory->create(_t);
		tmp258_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp258_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST307 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFBLOCK);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt309=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == EXPR || _t->getType() == IFEXPR)) {
				ifThenElse(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt309>=1 ) { goto _loop309; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt309++;
		}
		_loop309:;
		}  // ( ... )+
		currentAST = __currentAST307;
		_t = __t307;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ESEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t310 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp259_AST = astFactory->create(_t);
		tmp259_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp259_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST310 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ESEQ);
		_t = _t->getFirstChild();
		statement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST310;
		_t = __t310;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_INTEGER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t311 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp260_AST = astFactory->create(_t);
		tmp260_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp260_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST311 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_INTEGER);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST311;
		_t = __t311;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t312 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp261_AST = astFactory->create(_t);
		tmp261_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp261_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST312 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BIGINT);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST312;
		_t = __t312;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DOUBLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t313 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp262_AST = astFactory->create(_t);
		tmp262_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp262_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DOUBLE);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST313;
		_t = __t313;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t314 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp263_AST = astFactory->create(_t);
		tmp263_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp263_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST314 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DECIMAL);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST314;
		_t = __t314;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_STRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t315 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp264_AST = astFactory->create(_t);
		tmp264_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp264_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST315 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_STRING);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST315;
		_t = __t315;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_WSTRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t316 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp265_AST = astFactory->create(_t);
		tmp265_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp265_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST316 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_WSTRING);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST316;
		_t = __t316;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BOOLEAN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t317 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp266_AST = astFactory->create(_t);
		tmp266_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp266_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST317 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BOOLEAN);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST317;
		_t = __t317;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DATETIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t318 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp267_AST = astFactory->create(_t);
		tmp267_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp267_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST318 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DATETIME);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST318;
		_t = __t318;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_TIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t319 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp268_AST = astFactory->create(_t);
		tmp268_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp268_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST319 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_TIME);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST319;
		_t = __t319;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_ENUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t320 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp269_AST = astFactory->create(_t);
		tmp269_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp269_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST320 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_ENUM);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST320;
		_t = __t320;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BINARY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t321 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp270_AST = astFactory->create(_t);
		tmp270_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp270_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST321 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BINARY);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST321;
		_t = __t321;
		_t = _t->getNextSibling();
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
		primaryExpression(_t);
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
}

void GenerateQueryTreeParser::queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t208 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp271_AST = astFactory->create(_t);
	tmp271_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp271_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST208 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERY);
	_t = _t->getFirstChild();
	localParamList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	queryString(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	localQueryVarList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST208;
	_t = __t208;
	_t = _t->getNextSibling();
	queryStatement_AST = currentAST.root;
	returnAST = queryStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t230 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp272_AST = astFactory->create(_t);
	tmp272_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp272_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST230 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ARRAY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_2.member(_t->getType()))) {
			primaryExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop232;
		}
		
	}
	_loop232:;
	} // ( ... )*
	currentAST = __currentAST230;
	_t = __t230;
	_t = _t->getNextSibling();
	localParamList_AST = currentAST.root;
	returnAST = localParamList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 507 "generate_query.g"
	
	
#line 7019 "GenerateQueryTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t210 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp273_AST = astFactory->create(_t);
	tmp273_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp273_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST210 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERYSTRING);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt212=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= TK_AND && _t->getType() <= BIGINT_MODULUS))) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp274_AST = astFactory->create(_t);
			tmp274_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp274_AST);
			if ( _t == ANTLR_USE_NAMESPACE(antlr)nullAST ) throw ANTLR_USE_NAMESPACE(antlr)MismatchedTokenException();
			_t = _t->getNextSibling();
		}
		else {
			if ( _cnt212>=1 ) { goto _loop212; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt212++;
	}
	_loop212:;
	}  // ( ... )+
	currentAST = __currentAST210;
	_t = __t210;
	_t = _t->getNextSibling();
	queryString_AST = currentAST.root;
	returnAST = queryString_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localQueryVarList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localQueryVarList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	setmemQuery(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	localQueryVarList_AST = currentAST.root;
	returnAST = localQueryVarList_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t215 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp275_AST = astFactory->create(_t);
	tmp275_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp275_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST215 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ARRAY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case INTEGER_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t217 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp276_AST = astFactory->create(_t);
			tmp276_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp276_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST217 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,INTEGER_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST217;
			_t = __t217;
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t218 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp277_AST = astFactory->create(_t);
			tmp277_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp277_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST218 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BIGINT_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST218;
			_t = __t218;
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t219 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp278_AST = astFactory->create(_t);
			tmp278_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp278_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST219 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DOUBLE_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST219;
			_t = __t219;
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t220 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp279_AST = astFactory->create(_t);
			tmp279_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp279_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST220 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DECIMAL_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST220;
			_t = __t220;
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t221 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp280_AST = astFactory->create(_t);
			tmp280_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp280_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST221 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BOOLEAN_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST221;
			_t = __t221;
			_t = _t->getNextSibling();
			break;
		}
		case STRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t222 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp281_AST = astFactory->create(_t);
			tmp281_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp281_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST222 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,STRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST222;
			_t = __t222;
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t223 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp282_AST = astFactory->create(_t);
			tmp282_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp282_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST223 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,WSTRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST223;
			_t = __t223;
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t224 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp283_AST = astFactory->create(_t);
			tmp283_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp283_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST224 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DATETIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST224;
			_t = __t224;
			_t = _t->getNextSibling();
			break;
		}
		case TIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t225 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp284_AST = astFactory->create(_t);
			tmp284_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp284_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST225 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,TIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST225;
			_t = __t225;
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t226 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp285_AST = astFactory->create(_t);
			tmp285_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp285_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST226 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,ENUM_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST226;
			_t = __t226;
			_t = _t->getNextSibling();
			break;
		}
		case BINARY_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t227 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp286_AST = astFactory->create(_t);
			tmp286_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp286_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST227 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BINARY_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST227;
			_t = __t227;
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop228;
		}
		}
	}
	_loop228:;
	} // ( ... )*
	currentAST = __currentAST215;
	_t = __t215;
	_t = _t->getNextSibling();
	setmemQuery_AST = currentAST.root;
	returnAST = setmemQuery_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp287_AST = astFactory->create(_t);
		tmp287_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp287_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp288_AST = astFactory->create(_t);
		tmp288_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp288_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp289_AST = astFactory->create(_t);
		tmp289_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp289_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp290_AST = astFactory->create(_t);
		tmp290_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp290_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp291_AST = astFactory->create(_t);
		tmp291_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp291_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp292_AST = astFactory->create(_t);
		tmp292_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp292_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp293_AST = astFactory->create(_t);
		tmp293_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp293_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp294_AST = astFactory->create(_t);
		tmp294_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp294_AST);
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp295_AST = astFactory->create(_t);
		tmp295_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp295_AST);
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp296_AST = astFactory->create(_t);
		tmp296_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp296_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t326 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp297_AST = astFactory->create(_t);
		tmp297_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp297_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST326 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp298_AST = astFactory->create(_t);
		tmp298_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp298_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp299_AST = astFactory->create(_t);
		tmp299_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp299_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST326;
		_t = __t326;
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp300_AST = astFactory->create(_t);
		tmp300_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp300_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp301_AST = astFactory->create(_t);
		tmp301_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp301_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp302_AST = astFactory->create(_t);
		tmp302_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp302_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp303_AST = astFactory->create(_t);
		tmp303_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp303_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp304_AST = astFactory->create(_t);
		tmp304_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp304_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp305_AST = astFactory->create(_t);
		tmp305_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp305_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp306_AST = astFactory->create(_t);
		tmp306_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp306_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp307_AST = astFactory->create(_t);
		tmp307_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp307_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp308_AST = astFactory->create(_t);
		tmp308_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp308_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp309_AST = astFactory->create(_t);
		tmp309_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp309_AST);
		match(_t,ENUM_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BINARY_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp310_AST = astFactory->create(_t);
		tmp310_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp310_AST);
		match(_t,BINARY_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case EXPR:
	{
		expression(_t);
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
}

void GenerateQueryTreeParser::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t237 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp311_AST = astFactory->create(_t);
	tmp311_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp311_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST237 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DELAYED_STMT);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST237;
	_t = __t237;
	_t = _t->getNextSibling();
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t260 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp312_AST = astFactory->create(_t);
	tmp312_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp312_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST260 = currentAST;
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
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp313_AST = astFactory->create(_t);
				tmp313_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp313_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop263;
			}
			
		}
		_loop263:;
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
	currentAST = __currentAST260;
	_t = __t260;
	_t = _t->getNextSibling();
	elist_AST = currentAST.root;
	returnAST = elist_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case IFEXPR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t323 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp314_AST = astFactory->create(_t);
		tmp314_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp314_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST323 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFEXPR);
		_t = _t->getFirstChild();
		conditional(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST323;
		_t = __t323;
		_t = _t->getNextSibling();
		ifThenElse_AST = currentAST.root;
		break;
	}
	case EXPR:
	{
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ifThenElse_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = ifThenElse_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 685 "generate_query.g"
	
	
#line 7812 "GenerateQueryTreeParser.cpp"
	
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	conditional_AST = currentAST.root;
	returnAST = conditional_AST;
	_retTree = _t;
}

void GenerateQueryTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(246);
}
const char* GenerateQueryTreeParser::tokenNames[] = {
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

const unsigned long GenerateQueryTreeParser::_tokenSet_0_data_[] = { 2048UL, 139521UL, 3623878656UL, 259UL, 458752UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BETWEEN" "EXISTS" "IN" "IS" "LIKE" EQUALS NOTEQUALS LTN LTEQ GT GTEQ 
// LPAREN LAND LNOT LOR 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateQueryTreeParser::_tokenSet_0(_tokenSet_0_data_,12);
const unsigned long GenerateQueryTreeParser::_tokenSet_1_data_[] = { 17317888UL, 0UL, 1UL, 0UL, 2113536UL, 161UL, 2146435072UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "RETURN" IFTHENELSE QUERY SLIST WHILE SEQUENCE 
// INTEGER_SETMEM BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM 
// WSTRING_SETMEM BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM 
// BINARY_SETMEM RAISERRORINTEGER RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING 
// RAISERROR2WSTRING STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateQueryTreeParser::_tokenSet_1(_tokenSet_1_data_,16);
const unsigned long GenerateQueryTreeParser::_tokenSet_2_data_[] = { 0UL, 2097154UL, 459264UL, 17235968UL, 526336UL, 0UL, 1048064UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "FALSE" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL NUM_INT EXPR METHOD_CALL INTEGER_GETMEM 
// BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM WSTRING_GETMEM 
// BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM BINARY_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateQueryTreeParser::_tokenSet_2(_tokenSet_2_data_,16);


