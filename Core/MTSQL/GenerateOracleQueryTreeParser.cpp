/* $ANTLR 2.7.6 (2005-12-22): "expandedgenerate_query_oracle.g" -> "GenerateOracleQueryTreeParser.cpp"$ */
#include "GenerateOracleQueryTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "expandedgenerate_query_oracle.g"
#line 11 "GenerateOracleQueryTreeParser.cpp"
GenerateOracleQueryTreeParser::GenerateOracleQueryTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void GenerateOracleQueryTreeParser::sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableSpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t2 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp1_AST = astFactory->create(_t);
		tmp1_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp1_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST2 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 140 "expandedgenerate_query_oracle.g"
		printNode(tmp1_AST);
#line 43 "GenerateOracleQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_joinCriteria(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST2;
		_t = __t2;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case TABLE_REF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t3 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp2_AST = astFactory->create(_t);
		tmp2_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp2_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST3 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TABLE_REF);
		_t = _t->getFirstChild();
#line 142 "expandedgenerate_query_oracle.g"
		printNode(tmp2_AST);
#line 71 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp3_AST = astFactory->create(_t);
			tmp3_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp3_AST);
			match(_t,ALIAS);
			_t = _t->getNextSibling();
#line 142 "expandedgenerate_query_oracle.g"
			printNode(tmp3_AST);
#line 87 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case 3:
		case TK_WITH:
		case TK_FOR:
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
		case TK_FOR:
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
		case TK_FOR:
		{
			oracle_for_update_of_hint(_t);
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
		currentAST = __currentAST3;
		_t = __t3;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case CROSS_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t7 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp4_AST = astFactory->create(_t);
		tmp4_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp4_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST7 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CROSS_JOIN);
		_t = _t->getFirstChild();
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 144 "expandedgenerate_query_oracle.g"
		printNode(tmp4_AST);
#line 169 "GenerateOracleQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST7;
		_t = __t7;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case GROUPED_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t8 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp5_AST = astFactory->create(_t);
		tmp5_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp5_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST8 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GROUPED_JOIN);
		_t = _t->getFirstChild();
#line 146 "expandedgenerate_query_oracle.g"
		printNode(tmp5_AST);
#line 194 "GenerateOracleQueryTreeParser.cpp"
		sql92_tableSpecification(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp6_AST = astFactory->create(_t);
		tmp6_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp6_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 146 "expandedgenerate_query_oracle.g"
		printNode(tmp6_AST);
#line 207 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST8;
		_t = __t8;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case DERIVED_TABLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t9 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp7_AST = astFactory->create(_t);
		tmp7_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp7_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST9 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DERIVED_TABLE);
		_t = _t->getFirstChild();
#line 148 "expandedgenerate_query_oracle.g"
		printNode(tmp7_AST);
#line 229 "GenerateOracleQueryTreeParser.cpp"
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp8_AST = astFactory->create(_t);
		tmp8_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp8_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 148 "expandedgenerate_query_oracle.g"
		printNode(tmp8_AST);
#line 242 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp9_AST = astFactory->create(_t);
		tmp9_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp9_AST);
		match(_t,ALIAS);
		_t = _t->getNextSibling();
#line 148 "expandedgenerate_query_oracle.g"
		printNode(tmp9_AST);
#line 252 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST9;
		_t = __t9;
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

void GenerateOracleQueryTreeParser::sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp10_AST = astFactory->create(_t);
	tmp10_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp10_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST129 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ON);
	_t = _t->getFirstChild();
#line 370 "expandedgenerate_query_oracle.g"
	printNode(tmp10_AST);
#line 287 "GenerateOracleQueryTreeParser.cpp"
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST129;
	_t = __t129;
	_t = _t->getNextSibling();
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp11_AST = astFactory->create(_t);
	tmp11_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp11_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST115 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WITH);
	_t = _t->getFirstChild();
#line 358 "expandedgenerate_query_oracle.g"
	printNode(tmp11_AST);
#line 318 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp12_AST = astFactory->create(_t);
	tmp12_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp12_AST);
	match(_t,LPAREN);
	_t = _t->getNextSibling();
#line 358 "expandedgenerate_query_oracle.g"
	printNode(tmp12_AST);
#line 328 "GenerateOracleQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp13_AST = astFactory->create(_t);
		tmp13_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp13_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 359 "expandedgenerate_query_oracle.g"
		printNode(tmp13_AST);
#line 344 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case TK_INDEX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp14_AST = astFactory->create(_t);
		tmp14_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp14_AST);
		match(_t,TK_INDEX);
		_t = _t->getNextSibling();
#line 359 "expandedgenerate_query_oracle.g"
		printNode(tmp14_AST);
#line 358 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp15_AST = astFactory->create(_t);
		tmp15_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp15_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 359 "expandedgenerate_query_oracle.g"
		printNode(tmp15_AST);
#line 368 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ID:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp16_AST = astFactory->create(_t);
			tmp16_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp16_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
#line 360 "expandedgenerate_query_oracle.g"
			printNode(tmp16_AST);
#line 384 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case NUM_INT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp17_AST = astFactory->create(_t);
			tmp17_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp17_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 360 "expandedgenerate_query_oracle.g"
			printNode(tmp17_AST);
#line 398 "GenerateOracleQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp18_AST = astFactory->create(_t);
				tmp18_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp18_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 361 "expandedgenerate_query_oracle.g"
				printNode(tmp18_AST);
#line 421 "GenerateOracleQueryTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp19_AST = astFactory->create(_t);
					tmp19_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp19_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
#line 361 "expandedgenerate_query_oracle.g"
					printNode(tmp19_AST);
#line 437 "GenerateOracleQueryTreeParser.cpp"
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp20_AST = astFactory->create(_t);
					tmp20_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp20_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
#line 361 "expandedgenerate_query_oracle.g"
					printNode(tmp20_AST);
#line 451 "GenerateOracleQueryTreeParser.cpp"
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
				goto _loop120;
			}
			
		}
		_loop120:;
		} // ( ... )*
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp21_AST = astFactory->create(_t);
		tmp21_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp21_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 361 "expandedgenerate_query_oracle.g"
		printNode(tmp21_AST);
#line 477 "GenerateOracleQueryTreeParser.cpp"
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp22_AST = astFactory->create(_t);
			tmp22_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp22_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 362 "expandedgenerate_query_oracle.g"
			printNode(tmp22_AST);
#line 500 "GenerateOracleQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case ID:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp23_AST = astFactory->create(_t);
				tmp23_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp23_AST);
				match(_t,ID);
				_t = _t->getNextSibling();
#line 363 "expandedgenerate_query_oracle.g"
				printNode(tmp23_AST);
#line 516 "GenerateOracleQueryTreeParser.cpp"
				break;
			}
			case TK_INDEX:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp24_AST = astFactory->create(_t);
				tmp24_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp24_AST);
				match(_t,TK_INDEX);
				_t = _t->getNextSibling();
#line 363 "expandedgenerate_query_oracle.g"
				printNode(tmp24_AST);
#line 530 "GenerateOracleQueryTreeParser.cpp"
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp25_AST = astFactory->create(_t);
				tmp25_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp25_AST);
				match(_t,LPAREN);
				_t = _t->getNextSibling();
#line 363 "expandedgenerate_query_oracle.g"
				printNode(tmp25_AST);
#line 540 "GenerateOracleQueryTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp26_AST = astFactory->create(_t);
					tmp26_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp26_AST);
					match(_t,ID);
					_t = _t->getNextSibling();
#line 364 "expandedgenerate_query_oracle.g"
					printNode(tmp26_AST);
#line 556 "GenerateOracleQueryTreeParser.cpp"
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp27_AST = astFactory->create(_t);
					tmp27_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp27_AST);
					match(_t,NUM_INT);
					_t = _t->getNextSibling();
#line 364 "expandedgenerate_query_oracle.g"
					printNode(tmp27_AST);
#line 570 "GenerateOracleQueryTreeParser.cpp"
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
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
						tmp28_AST = astFactory->create(_t);
						tmp28_AST_in = _t;
						astFactory->addASTChild(currentAST, tmp28_AST);
						match(_t,COMMA);
						_t = _t->getNextSibling();
#line 365 "expandedgenerate_query_oracle.g"
						printNode(tmp28_AST);
#line 593 "GenerateOracleQueryTreeParser.cpp"
						{
						if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
							_t = ASTNULL;
						switch ( _t->getType()) {
						case ID:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp29_AST = astFactory->create(_t);
							tmp29_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp29_AST);
							match(_t,ID);
							_t = _t->getNextSibling();
#line 365 "expandedgenerate_query_oracle.g"
							printNode(tmp29_AST);
#line 609 "GenerateOracleQueryTreeParser.cpp"
							break;
						}
						case NUM_INT:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
							tmp30_AST = astFactory->create(_t);
							tmp30_AST_in = _t;
							astFactory->addASTChild(currentAST, tmp30_AST);
							match(_t,NUM_INT);
							_t = _t->getNextSibling();
#line 365 "expandedgenerate_query_oracle.g"
							printNode(tmp30_AST);
#line 623 "GenerateOracleQueryTreeParser.cpp"
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
						goto _loop126;
					}
					
				}
				_loop126:;
				} // ( ... )*
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp31_AST = astFactory->create(_t);
				tmp31_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp31_AST);
				match(_t,RPAREN);
				_t = _t->getNextSibling();
#line 365 "expandedgenerate_query_oracle.g"
				printNode(tmp31_AST);
#line 649 "GenerateOracleQueryTreeParser.cpp"
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
			goto _loop127;
		}
		
	}
	_loop127:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp32_AST = astFactory->create(_t);
	tmp32_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp32_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
#line 366 "expandedgenerate_query_oracle.g"
	printNode(tmp32_AST);
#line 675 "GenerateOracleQueryTreeParser.cpp"
	currentAST = __currentAST115;
	_t = __t115;
	_t = _t->getNextSibling();
	sql92_tableHint_AST = currentAST.root;
	returnAST = sql92_tableHint_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::oracle_for_update_of_hint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_for_update_of_hint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_for_update_of_hint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t11 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp33_AST = astFactory->create(_t);
	tmp33_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp33_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST11 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FOR);
	_t = _t->getFirstChild();
#line 151 "expandedgenerate_query_oracle.g"
	printNode(tmp33_AST);
#line 703 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp34_AST = astFactory->create(_t);
	tmp34_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp34_AST);
	match(_t,TK_UPDATE);
	_t = _t->getNextSibling();
#line 151 "expandedgenerate_query_oracle.g"
	printNode(tmp34_AST);
#line 713 "GenerateOracleQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_OF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp35_AST = astFactory->create(_t);
		tmp35_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp35_AST);
		match(_t,TK_OF);
		_t = _t->getNextSibling();
#line 152 "expandedgenerate_query_oracle.g"
		printNode(tmp35_AST);
#line 729 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp36_AST = astFactory->create(_t);
		tmp36_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp36_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 152 "expandedgenerate_query_oracle.g"
		printNode(tmp36_AST);
#line 739 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp37_AST = astFactory->create(_t);
			tmp37_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp37_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
#line 153 "expandedgenerate_query_oracle.g"
			printNode(tmp37_AST);
#line 755 "GenerateOracleQueryTreeParser.cpp"
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp38_AST = astFactory->create(_t);
			tmp38_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp38_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
#line 153 "expandedgenerate_query_oracle.g"
			printNode(tmp38_AST);
#line 765 "GenerateOracleQueryTreeParser.cpp"
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
	currentAST = __currentAST11;
	_t = __t11;
	_t = _t->getNextSibling();
	oracle_for_update_of_hint_AST = currentAST.root;
	returnAST = oracle_for_update_of_hint_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp39_AST = astFactory->create(_t);
			tmp39_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp39_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
#line 346 "expandedgenerate_query_oracle.g"
			printNode(tmp39_AST);
#line 821 "GenerateOracleQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp40_AST = astFactory->create(_t);
				tmp40_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp40_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 346 "expandedgenerate_query_oracle.g"
				printNode(tmp40_AST);
#line 837 "GenerateOracleQueryTreeParser.cpp"
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
			goto _loop102;
		}
		
	}
	_loop102:;
	} // ( ... )*
	sql92_nestedSelectStatement_AST = currentAST.root;
	returnAST = sql92_nestedSelectStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t15 = _t;
	s = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	s_AST = astFactory->create(s);
	astFactory->addASTChild(currentAST, s_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST15 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_SELECT);
	_t = _t->getFirstChild();
#line 157 "expandedgenerate_query_oracle.g"
	
	printNode(s_AST); 
	//try to find ML_COMMENT (94) in hidden stream. Insert it into the query if found
	//We need this because Oracle join hints are passed in comments
	ANTLR_USE_NAMESPACE(antlr)RefToken hidden = 
	(ANTLR_USE_NAMESPACE(antlr)RefCommonASTWithHiddenTokens(s_AST))->getHiddenAfter();
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
	
	
#line 905 "GenerateOracleQueryTreeParser.cpp"
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
#line 177 "expandedgenerate_query_oracle.g"
		printNode(tmp41_AST);
#line 921 "GenerateOracleQueryTreeParser.cpp"
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
#line 177 "expandedgenerate_query_oracle.g"
		printNode(tmp42_AST);
#line 935 "GenerateOracleQueryTreeParser.cpp"
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
	currentAST = __currentAST15;
	_t = __t15;
	_t = _t->getNextSibling();
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t104 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp43_AST = astFactory->create(_t);
	tmp43_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp43_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST104 = currentAST;
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
#line 350 "expandedgenerate_query_oracle.g"
		printNode(s_AST);
#line 1042 "GenerateOracleQueryTreeParser.cpp"
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
#line 350 "expandedgenerate_query_oracle.g"
			printNode(a1_AST);
#line 1064 "GenerateOracleQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp44_AST = astFactory->create(_t);
				tmp44_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp44_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 350 "expandedgenerate_query_oracle.g"
				printNode(tmp44_AST);
#line 1092 "GenerateOracleQueryTreeParser.cpp"
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
#line 350 "expandedgenerate_query_oracle.g"
					printNode(a2_AST);
#line 1110 "GenerateOracleQueryTreeParser.cpp"
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
				goto _loop109;
			}
			
		}
		_loop109:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST104;
	_t = __t104;
	_t = _t->getNextSibling();
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp45_AST = astFactory->create(_t);
	tmp45_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp45_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST111 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FROM);
	_t = _t->getFirstChild();
#line 354 "expandedgenerate_query_oracle.g"
	printNode(tmp45_AST);
#line 1167 "GenerateOracleQueryTreeParser.cpp"
	sql92_tableSpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp46_AST = astFactory->create(_t);
			tmp46_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp46_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 354 "expandedgenerate_query_oracle.g"
			printNode(tmp46_AST);
#line 1185 "GenerateOracleQueryTreeParser.cpp"
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop113;
		}
		
	}
	_loop113:;
	} // ( ... )*
	currentAST = __currentAST111;
	_t = __t111;
	_t = _t->getNextSibling();
	sql92_fromClause_AST = currentAST.root;
	returnAST = sql92_fromClause_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t131 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp47_AST = astFactory->create(_t);
	tmp47_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp47_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST131 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHERE);
	_t = _t->getFirstChild();
#line 374 "expandedgenerate_query_oracle.g"
	printNode(tmp47_AST);
#line 1224 "GenerateOracleQueryTreeParser.cpp"
	{ // ( ... )+
	int _cnt133=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_0.member(_t->getType()))) {
			sql92_searchCondition(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt133>=1 ) { goto _loop133; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt133++;
	}
	_loop133:;
	}  // ( ... )+
	currentAST = __currentAST131;
	_t = __t131;
	_t = _t->getNextSibling();
	sql92_whereClause_AST = currentAST.root;
	returnAST = sql92_whereClause_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp48_AST = astFactory->create(_t);
	tmp48_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp48_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST135 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
#line 378 "expandedgenerate_query_oracle.g"
	printNode(tmp48_AST);
#line 1270 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp49_AST = astFactory->create(_t);
	tmp49_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp49_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
#line 378 "expandedgenerate_query_oracle.g"
	printNode(tmp49_AST);
#line 1280 "GenerateOracleQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp50_AST = astFactory->create(_t);
			tmp50_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp50_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 378 "expandedgenerate_query_oracle.g"
			printNode(tmp50_AST);
#line 1298 "GenerateOracleQueryTreeParser.cpp"
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop137;
		}
		
	}
	_loop137:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp51_AST = astFactory->create(_t);
		tmp51_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp51_AST);
		match(_t,TK_HAVING);
		_t = _t->getNextSibling();
#line 378 "expandedgenerate_query_oracle.g"
		printNode(tmp51_AST);
#line 1325 "GenerateOracleQueryTreeParser.cpp"
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
	currentAST = __currentAST135;
	_t = __t135;
	_t = _t->getNextSibling();
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST x_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST x = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST y_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST y = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp52_AST = astFactory->create(_t);
		tmp52_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp52_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST20 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 182 "expandedgenerate_query_oracle.g"
		printNode(tmp52_AST);
#line 1380 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST20;
		_t = __t20;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t21 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp53_AST = astFactory->create(_t);
		tmp53_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp53_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST21 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
#line 183 "expandedgenerate_query_oracle.g"
		printNode(tmp53_AST);
#line 1405 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST21;
		_t = __t21;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp54_AST = astFactory->create(_t);
		tmp54_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp54_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST22 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 184 "expandedgenerate_query_oracle.g"
		printNode(tmp54_AST);
#line 1433 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST22;
		_t = __t22;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t23 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp55_AST = astFactory->create(_t);
		tmp55_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp55_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST23 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 185 "expandedgenerate_query_oracle.g"
		printNode(tmp55_AST);
#line 1461 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST23;
		_t = __t23;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t24 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp56_AST = astFactory->create(_t);
		tmp56_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp56_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST24 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MINUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 187 "expandedgenerate_query_oracle.g"
		printNode(tmp56_AST);
#line 1489 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST24;
		_t = __t24;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t25 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp57_AST = astFactory->create(_t);
		tmp57_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp57_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST25 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MODULUS);
		_t = _t->getFirstChild();
#line 189 "expandedgenerate_query_oracle.g"
		
			    printString(L" MOD"); 
			    printString(L"("); 
			
#line 1517 "GenerateOracleQueryTreeParser.cpp"
		x = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		sql92_expr(_t);
		_t = _retTree;
		x_AST = returnAST;
		astFactory->addASTChild( currentAST, returnAST );
#line 194 "expandedgenerate_query_oracle.g"
		
			    printString(L", ");
			
#line 1527 "GenerateOracleQueryTreeParser.cpp"
		y = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		sql92_expr(_t);
		_t = _retTree;
		y_AST = returnAST;
		astFactory->addASTChild( currentAST, returnAST );
#line 198 "expandedgenerate_query_oracle.g"
		
			    printString(L") ");
			
#line 1537 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST25;
		_t = __t25;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t26 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp58_AST = astFactory->create(_t);
		tmp58_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp58_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST26 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DIVIDE);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 202 "expandedgenerate_query_oracle.g"
		printNode(tmp58_AST);
#line 1562 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST26;
		_t = __t26;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t27 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp59_AST = astFactory->create(_t);
		tmp59_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp59_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST27 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,PLUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 203 "expandedgenerate_query_oracle.g"
		printNode(tmp59_AST);
#line 1590 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST27;
		_t = __t27;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t28 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp60_AST = astFactory->create(_t);
		tmp60_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp60_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST28 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIMES);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 204 "expandedgenerate_query_oracle.g"
		printNode(tmp60_AST);
#line 1618 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST28;
		_t = __t28;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t29 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp61_AST = astFactory->create(_t);
		tmp61_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp61_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST29 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
#line 205 "expandedgenerate_query_oracle.g"
		printNode(tmp61_AST);
#line 1643 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST29;
		_t = __t29;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t30 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp62_AST = astFactory->create(_t);
		tmp62_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp62_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST30 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_PLUS);
		_t = _t->getFirstChild();
#line 206 "expandedgenerate_query_oracle.g"
		printNode(tmp62_AST);
#line 1668 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST30;
		_t = __t30;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t31 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp63_AST = astFactory->create(_t);
		tmp63_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp63_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST31 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
#line 207 "expandedgenerate_query_oracle.g"
		printNode(tmp63_AST);
#line 1693 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp64_AST = astFactory->create(_t);
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp64_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 207 "expandedgenerate_query_oracle.g"
		printNode(tmp64_AST);
#line 1703 "GenerateOracleQueryTreeParser.cpp"
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp65_AST = astFactory->create(_t);
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp65_AST);
		match(_t,TK_AS);
		_t = _t->getNextSibling();
#line 207 "expandedgenerate_query_oracle.g"
		printNode(tmp65_AST);
#line 1716 "GenerateOracleQueryTreeParser.cpp"
		sql92_builtInType(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp66_AST = astFactory->create(_t);
		tmp66_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp66_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 207 "expandedgenerate_query_oracle.g"
		printNode(tmp66_AST);
#line 1729 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST31;
		_t = __t31;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t32 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp67_AST = astFactory->create(_t);
		tmp67_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp67_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST32 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_COUNT);
		_t = _t->getFirstChild();
#line 208 "expandedgenerate_query_oracle.g"
		printNode(tmp67_AST);
#line 1751 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp68_AST = astFactory->create(_t);
		tmp68_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp68_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 208 "expandedgenerate_query_oracle.g"
		printNode(tmp68_AST);
#line 1761 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp69_AST = astFactory->create(_t);
			tmp69_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp69_AST);
			match(_t,STAR);
			_t = _t->getNextSibling();
#line 208 "expandedgenerate_query_oracle.g"
			printNode(tmp69_AST);
#line 1777 "GenerateOracleQueryTreeParser.cpp"
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp70_AST = astFactory->create(_t);
				tmp70_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp70_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 208 "expandedgenerate_query_oracle.g"
				printNode(tmp70_AST);
#line 1799 "GenerateOracleQueryTreeParser.cpp"
				break;
			}
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp71_AST = astFactory->create(_t);
				tmp71_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp71_AST);
				match(_t,TK_DISTINCT);
				_t = _t->getNextSibling();
#line 208 "expandedgenerate_query_oracle.g"
				printNode(tmp71_AST);
#line 1813 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp72_AST = astFactory->create(_t);
		tmp72_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp72_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 208 "expandedgenerate_query_oracle.g"
		printNode(tmp72_AST);
#line 1846 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST32;
		_t = __t32;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t35 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp73_AST = astFactory->create(_t);
		tmp73_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp73_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST35 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_AVG);
		_t = _t->getFirstChild();
#line 209 "expandedgenerate_query_oracle.g"
		printNode(tmp73_AST);
#line 1868 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp74_AST = astFactory->create(_t);
		tmp74_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp74_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 209 "expandedgenerate_query_oracle.g"
		printNode(tmp74_AST);
#line 1878 "GenerateOracleQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp75_AST = astFactory->create(_t);
			tmp75_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp75_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 209 "expandedgenerate_query_oracle.g"
			printNode(tmp75_AST);
#line 1895 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp76_AST = astFactory->create(_t);
			tmp76_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp76_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 209 "expandedgenerate_query_oracle.g"
			printNode(tmp76_AST);
#line 1909 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp77_AST = astFactory->create(_t);
		tmp77_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp77_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 209 "expandedgenerate_query_oracle.g"
		printNode(tmp77_AST);
#line 1935 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST35;
		_t = __t35;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t38 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp78_AST = astFactory->create(_t);
		tmp78_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp78_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST38 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MAX);
		_t = _t->getFirstChild();
#line 210 "expandedgenerate_query_oracle.g"
		printNode(tmp78_AST);
#line 1957 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp79_AST = astFactory->create(_t);
		tmp79_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp79_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 210 "expandedgenerate_query_oracle.g"
		printNode(tmp79_AST);
#line 1967 "GenerateOracleQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp80_AST = astFactory->create(_t);
			tmp80_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp80_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 210 "expandedgenerate_query_oracle.g"
			printNode(tmp80_AST);
#line 1984 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp81_AST = astFactory->create(_t);
			tmp81_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp81_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 210 "expandedgenerate_query_oracle.g"
			printNode(tmp81_AST);
#line 1998 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp82_AST = astFactory->create(_t);
		tmp82_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp82_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 210 "expandedgenerate_query_oracle.g"
		printNode(tmp82_AST);
#line 2024 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST38;
		_t = __t38;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t41 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp83_AST = astFactory->create(_t);
		tmp83_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp83_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST41 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MIN);
		_t = _t->getFirstChild();
#line 211 "expandedgenerate_query_oracle.g"
		printNode(tmp83_AST);
#line 2046 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp84_AST = astFactory->create(_t);
		tmp84_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp84_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 211 "expandedgenerate_query_oracle.g"
		printNode(tmp84_AST);
#line 2056 "GenerateOracleQueryTreeParser.cpp"
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp85_AST = astFactory->create(_t);
			tmp85_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp85_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
#line 211 "expandedgenerate_query_oracle.g"
			printNode(tmp85_AST);
#line 2073 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp86_AST = astFactory->create(_t);
			tmp86_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp86_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 211 "expandedgenerate_query_oracle.g"
			printNode(tmp86_AST);
#line 2087 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp87_AST = astFactory->create(_t);
		tmp87_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp87_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 211 "expandedgenerate_query_oracle.g"
		printNode(tmp87_AST);
#line 2113 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST41;
		_t = __t41;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t44 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp88_AST = astFactory->create(_t);
		tmp88_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp88_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST44 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_SUM);
		_t = _t->getFirstChild();
#line 212 "expandedgenerate_query_oracle.g"
		printNode(tmp88_AST);
#line 2135 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp89_AST = astFactory->create(_t);
		tmp89_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp89_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 212 "expandedgenerate_query_oracle.g"
		printNode(tmp89_AST);
#line 2145 "GenerateOracleQueryTreeParser.cpp"
		{
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
#line 212 "expandedgenerate_query_oracle.g"
			printNode(tmp90_AST);
#line 2162 "GenerateOracleQueryTreeParser.cpp"
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp91_AST = astFactory->create(_t);
			tmp91_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp91_AST);
			match(_t,TK_DISTINCT);
			_t = _t->getNextSibling();
#line 212 "expandedgenerate_query_oracle.g"
			printNode(tmp91_AST);
#line 2176 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp92_AST = astFactory->create(_t);
		tmp92_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp92_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 212 "expandedgenerate_query_oracle.g"
		printNode(tmp92_AST);
#line 2202 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST44;
		_t = __t44;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t47 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp93_AST = astFactory->create(_t);
		tmp93_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp93_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST47 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SIMPLE_CASE);
		_t = _t->getFirstChild();
#line 213 "expandedgenerate_query_oracle.g"
		printNode(tmp93_AST);
#line 2224 "GenerateOracleQueryTreeParser.cpp"
		{ // ( ... )+
		int _cnt49=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == SIMPLE_WHEN)) {
				sql92_simpleWhenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt49>=1 ) { goto _loop49; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt49++;
		}
		_loop49:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp94_AST = astFactory->create(_t);
		tmp94_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp94_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
#line 213 "expandedgenerate_query_oracle.g"
		printNode(tmp94_AST);
#line 2273 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST47;
		_t = __t47;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t51 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp95_AST = astFactory->create(_t);
		tmp95_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp95_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST51 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SEARCHED_CASE);
		_t = _t->getFirstChild();
#line 214 "expandedgenerate_query_oracle.g"
		printNode(tmp95_AST);
#line 2295 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )+
		int _cnt53=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_WHEN)) {
				sql92_whenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt53>=1 ) { goto _loop53; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt53++;
		}
		_loop53:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp96_AST = astFactory->create(_t);
		tmp96_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp96_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
#line 214 "expandedgenerate_query_oracle.g"
		printNode(tmp96_AST);
#line 2347 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST51;
		_t = __t51;
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

void GenerateOracleQueryTreeParser::sql92_expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t146 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp97_AST = astFactory->create(_t);
	tmp97_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp97_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST146 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST146;
	_t = __t146;
	_t = _t->getNextSibling();
	sql92_expression_AST = currentAST.root;
	returnAST = sql92_expression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST n2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t180 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp98_AST = astFactory->create(_t);
	tmp98_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp98_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST180 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,BUILTIN_TYPE);
	_t = _t->getFirstChild();
#line 449 "expandedgenerate_query_oracle.g"
	printNode(tmp98_AST);
#line 2432 "GenerateOracleQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_PRECISION:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp99_AST = astFactory->create(_t);
		tmp99_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp99_AST);
		match(_t,TK_PRECISION);
		_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
		printNode(tmp99_AST);
#line 2448 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp100_AST = astFactory->create(_t);
		tmp100_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp100_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
		printNode(tmp100_AST);
#line 2477 "GenerateOracleQueryTreeParser.cpp"
		n1 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST n1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		n1_AST = astFactory->create(n1);
		astFactory->addASTChild(currentAST, n1_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
		printNode(n1_AST);
#line 2486 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp101_AST = astFactory->create(_t);
			tmp101_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp101_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
			printNode(tmp101_AST);
#line 2502 "GenerateOracleQueryTreeParser.cpp"
			n2 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST n2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			n2_AST = astFactory->create(n2);
			astFactory->addASTChild(currentAST, n2_AST);
			match(_t,NUM_INT);
			_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
			printNode(n2_AST);
#line 2511 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp102_AST = astFactory->create(_t);
		tmp102_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp102_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 449 "expandedgenerate_query_oracle.g"
		printNode(tmp102_AST);
#line 2533 "GenerateOracleQueryTreeParser.cpp"
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
	currentAST = __currentAST180;
	_t = __t180;
	_t = _t->getNextSibling();
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t176 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp103_AST = astFactory->create(_t);
	tmp103_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp103_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST176 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
#line 441 "expandedgenerate_query_oracle.g"
	printNode(tmp103_AST);
#line 2573 "GenerateOracleQueryTreeParser.cpp"
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp104_AST = astFactory->create(_t);
	tmp104_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp104_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
#line 441 "expandedgenerate_query_oracle.g"
	printNode(tmp104_AST);
#line 2586 "GenerateOracleQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST176;
	_t = __t176;
	_t = _t->getNextSibling();
	sql92_simpleWhenExpression_AST = currentAST.root;
	returnAST = sql92_simpleWhenExpression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t178 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp105_AST = astFactory->create(_t);
	tmp105_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp105_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST178 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ELSE);
	_t = _t->getFirstChild();
#line 445 "expandedgenerate_query_oracle.g"
	printNode(tmp105_AST);
#line 2617 "GenerateOracleQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST178;
	_t = __t178;
	_t = _t->getNextSibling();
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t174 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp106_AST = astFactory->create(_t);
	tmp106_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp106_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST174 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
#line 437 "expandedgenerate_query_oracle.g"
	printNode(tmp106_AST);
#line 2648 "GenerateOracleQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp107_AST = astFactory->create(_t);
	tmp107_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp107_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
#line 437 "expandedgenerate_query_oracle.g"
	printNode(tmp107_AST);
#line 2661 "GenerateOracleQueryTreeParser.cpp"
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST174;
	_t = __t174;
	_t = _t->getNextSibling();
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t186 = _t;
		id1 = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST id1_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		id1_AST = astFactory->create(id1);
		astFactory->addASTChild(currentAST, id1_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST186 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ID);
		_t = _t->getFirstChild();
#line 454 "expandedgenerate_query_oracle.g"
		printNode(id1_AST);
#line 2701 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp108_AST = astFactory->create(_t);
			tmp108_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp108_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
#line 454 "expandedgenerate_query_oracle.g"
			printNode(tmp108_AST);
#line 2717 "GenerateOracleQueryTreeParser.cpp"
			id2 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST id2_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			id2_AST = astFactory->create(id2);
			astFactory->addASTChild(currentAST, id2_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
#line 454 "expandedgenerate_query_oracle.g"
			printNode(id2_AST);
#line 2726 "GenerateOracleQueryTreeParser.cpp"
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
		currentAST = __currentAST186;
		_t = __t186;
		_t = _t->getNextSibling();
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp109_AST = astFactory->create(_t);
		tmp109_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp109_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
#line 455 "expandedgenerate_query_oracle.g"
		printNode(tmp109_AST);
#line 2755 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp110_AST = astFactory->create(_t);
		tmp110_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp110_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
#line 456 "expandedgenerate_query_oracle.g"
		printNode(tmp110_AST);
#line 2769 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp111_AST = astFactory->create(_t);
		tmp111_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp111_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
#line 457 "expandedgenerate_query_oracle.g"
		printNode(tmp111_AST);
#line 2783 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp112_AST = astFactory->create(_t);
		tmp112_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp112_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
#line 458 "expandedgenerate_query_oracle.g"
		printNode(tmp112_AST);
#line 2797 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp113_AST = astFactory->create(_t);
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp113_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
#line 459 "expandedgenerate_query_oracle.g"
		printNode(tmp113_AST);
#line 2811 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp114_AST = astFactory->create(_t);
		tmp114_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp114_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
#line 460 "expandedgenerate_query_oracle.g"
		printNode(tmp114_AST);
#line 2825 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case LOCALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp115_AST = astFactory->create(_t);
		tmp115_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp115_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
#line 463 "expandedgenerate_query_oracle.g"
		
		printLocalvarNode(tmp115_AST); 
		
#line 2841 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t188 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp116_AST = astFactory->create(_t);
		tmp116_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp116_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST188 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
#line 466 "expandedgenerate_query_oracle.g"
		printNode(tmp116_AST);
#line 2859 "GenerateOracleQueryTreeParser.cpp"
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp117_AST = astFactory->create(_t);
		tmp117_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp117_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 466 "expandedgenerate_query_oracle.g"
		printNode(tmp117_AST);
#line 2872 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST188;
		_t = __t188;
		_t = _t->getNextSibling();
		break;
	}
	case SCALAR_SUBQUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp118_AST = astFactory->create(_t);
		tmp118_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp118_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST189 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SCALAR_SUBQUERY);
		_t = _t->getFirstChild();
#line 467 "expandedgenerate_query_oracle.g"
		printNode(tmp118_AST);
#line 2893 "GenerateOracleQueryTreeParser.cpp"
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp119_AST = astFactory->create(_t);
		tmp119_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp119_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 467 "expandedgenerate_query_oracle.g"
		printNode(tmp119_AST);
#line 2906 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST189;
		_t = __t189;
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

void GenerateOracleQueryTreeParser::sql92_methodCall(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_methodCall_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_methodCall_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST el = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST el_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 219 "expandedgenerate_query_oracle.g"
	
	int trnsfrm=-1;
	
#line 2943 "GenerateOracleQueryTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t56 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp120_AST = astFactory->create(_t);
	tmp120_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp120_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST56 = currentAST;
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
#line 223 "expandedgenerate_query_oracle.g"
	
	if (0 == stricmp("len", id_AST->getText().c_str()))
	{
	id_AST->setText("length");
	}
	else if (0 == stricmp("charindex", id_AST->getText().c_str()))
	{
	id_AST->setText("instr");
	trnsfrm = 0;
	}
	else if (0 == stricmp("substring", id_AST->getText().c_str()))
	{
	id_AST->setText("substr");
	}
	else if (0 == stricmp("isnull", id_AST->getText().c_str()))
	{
	id_AST->setText("nvl");
	}
	else if (0 == stricmp("ceiling", id_AST->getText().c_str()))
	{
	id_AST->setText("ceil");
	}
	else if (0 == stricmp("atn2", id_AST->getText().c_str()))
	{
	id_AST->setText("atan2");
	}
	else if (0 == stricmp("log", id_AST->getText().c_str()))
	{
	id_AST->setText("ln");
	}
	else if (0 == stricmp("log10", id_AST->getText().c_str()))
	{
	id_AST->setText("log");
	trnsfrm = 1;
	}
	printNode(id_AST); 
	printNode(tmp120_AST); 
	
#line 3001 "GenerateOracleQueryTreeParser.cpp"
	el = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST el_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	el_AST = astFactory->create(el);
	astFactory->addASTChild(currentAST, el_AST);
	match(_t,ELIST);
	_t = _t->getNextSibling();
#line 262 "expandedgenerate_query_oracle.g"
	
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
	
#line 3023 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp121_AST = astFactory->create(_t);
	tmp121_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp121_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
#line 277 "expandedgenerate_query_oracle.g"
	
	printNode(tmp121_AST); 
	
#line 3035 "GenerateOracleQueryTreeParser.cpp"
	currentAST = __currentAST56;
	_t = __t56;
	_t = _t->getNextSibling();
	sql92_methodCall_AST = currentAST.root;
	returnAST = sql92_methodCall_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::oracle_CharIndex(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_CharIndex_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_CharIndex_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST a_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST b = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST b_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST c = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST c_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST d_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t58 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp122_AST = astFactory->create(_t);
	tmp122_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp122_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST58 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ELIST);
	_t = _t->getFirstChild();
	a = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST a_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	a_AST = astFactory->create(a);
	astFactory->addASTChild(currentAST, a_AST);
	match(_t,EXPR);
	_t = _t->getNextSibling();
	b = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST b_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	b_AST = astFactory->create(b);
	astFactory->addASTChild(currentAST, b_AST);
	match(_t,COMMA);
	_t = _t->getNextSibling();
	c = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST c_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	c_AST = astFactory->create(c);
	astFactory->addASTChild(currentAST, c_AST);
	match(_t,EXPR);
	_t = _t->getNextSibling();
#line 283 "expandedgenerate_query_oracle.g"
	sql92_expression(c); printNode(b_AST); sql92_expression(a);
#line 3089 "GenerateOracleQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case COMMA:
	{
		d = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST d_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		d_AST = astFactory->create(d);
		astFactory->addASTChild(currentAST, d_AST);
		match(_t,COMMA);
		_t = _t->getNextSibling();
#line 283 "expandedgenerate_query_oracle.g"
		printNode(d_AST);
#line 3104 "GenerateOracleQueryTreeParser.cpp"
		sql92_expression(_t);
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
	currentAST = __currentAST58;
	_t = __t58;
	_t = _t->getNextSibling();
	oracle_CharIndex_AST = currentAST.root;
	returnAST = oracle_CharIndex_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::oracle_Log(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_Log_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_Log_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t61 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp123_AST = astFactory->create(_t);
	tmp123_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp123_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST61 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ELIST);
	_t = _t->getFirstChild();
#line 286 "expandedgenerate_query_oracle.g"
	printString(L"10, ");
#line 3147 "GenerateOracleQueryTreeParser.cpp"
	sql92_expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST61;
	_t = __t61;
	_t = _t->getNextSibling();
	oracle_Log_AST = currentAST.root;
	returnAST = oracle_Log_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_LOCK)) {
			oracle_lock_statement(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop64;
		}
		
	}
	_loop64:;
	} // ( ... )*
	sql92_querySpecification(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_UNION)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp124_AST = astFactory->create(_t);
			tmp124_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp124_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
#line 289 "expandedgenerate_query_oracle.g"
			printNode(tmp124_AST);
#line 3198 "GenerateOracleQueryTreeParser.cpp"
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp125_AST = astFactory->create(_t);
				tmp125_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp125_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
#line 289 "expandedgenerate_query_oracle.g"
				printNode(tmp125_AST);
#line 3214 "GenerateOracleQueryTreeParser.cpp"
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
			goto _loop67;
		}
		
	}
	_loop67:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp126_AST = astFactory->create(_t);
		tmp126_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp126_AST);
		match(_t,TK_ORDER);
		_t = _t->getNextSibling();
#line 290 "expandedgenerate_query_oracle.g"
		printNode(tmp126_AST);
#line 3253 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp127_AST = astFactory->create(_t);
		tmp127_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp127_AST);
		match(_t,TK_BY);
		_t = _t->getNextSibling();
#line 290 "expandedgenerate_query_oracle.g"
		printNode(tmp127_AST);
#line 3263 "GenerateOracleQueryTreeParser.cpp"
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

void GenerateOracleQueryTreeParser::oracle_lock_statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_lock_statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_lock_statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST schema = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST schema_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tname = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tname_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST modetype = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST modetype_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t70 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp128_AST = astFactory->create(_t);
	tmp128_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST70 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_LOCK);
	_t = _t->getFirstChild();
#line 294 "expandedgenerate_query_oracle.g"
	printNode(tmp128_AST);
#line 3309 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp129_AST = astFactory->create(_t);
	tmp129_AST_in = _t;
	match(_t,TK_TABLE);
	_t = _t->getNextSibling();
#line 295 "expandedgenerate_query_oracle.g"
	printNode(tmp129_AST);
#line 3318 "GenerateOracleQueryTreeParser.cpp"
	schema = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST schema_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	schema_AST = astFactory->create(schema);
	match(_t,ID);
	_t = _t->getNextSibling();
#line 296 "expandedgenerate_query_oracle.g"
	printNode(schema_AST);
#line 3326 "GenerateOracleQueryTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case DOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp130_AST = astFactory->create(_t);
		tmp130_AST_in = _t;
		match(_t,DOT);
		_t = _t->getNextSibling();
#line 297 "expandedgenerate_query_oracle.g"
		printNode(tmp130_AST);
#line 3341 "GenerateOracleQueryTreeParser.cpp"
		tname = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tname_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tname_AST = astFactory->create(tname);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 297 "expandedgenerate_query_oracle.g"
		printNode(tname_AST);
#line 3349 "GenerateOracleQueryTreeParser.cpp"
		break;
	}
	case TK_IN:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp131_AST = astFactory->create(_t);
	tmp131_AST_in = _t;
	match(_t,TK_IN);
	_t = _t->getNextSibling();
#line 298 "expandedgenerate_query_oracle.g"
	printNode(tmp131_AST);
#line 3370 "GenerateOracleQueryTreeParser.cpp"
	modetype = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST modetype_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	modetype_AST = astFactory->create(modetype);
	match(_t,ID);
	_t = _t->getNextSibling();
#line 299 "expandedgenerate_query_oracle.g"
	printNode(modetype_AST);
#line 3378 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp132_AST = astFactory->create(_t);
	tmp132_AST_in = _t;
	match(_t,TK_MODE);
	_t = _t->getNextSibling();
#line 300 "expandedgenerate_query_oracle.g"
	printNode(tmp132_AST);
#line 3387 "GenerateOracleQueryTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp133_AST = astFactory->create(_t);
	tmp133_AST_in = _t;
	match(_t,SEMI);
	_t = _t->getNextSibling();
#line 301 "expandedgenerate_query_oracle.g"
	printNode(tmp133_AST);
#line 3396 "GenerateOracleQueryTreeParser.cpp"
	currentAST = __currentAST70;
	_t = __t70;
	_t = _t->getNextSibling();
	returnAST = oracle_lock_statement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 342 "expandedgenerate_query_oracle.g"
		printNode(a1_AST);
#line 3435 "GenerateOracleQueryTreeParser.cpp"
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
#line 342 "expandedgenerate_query_oracle.g"
		printNode(d1_AST);
#line 3448 "GenerateOracleQueryTreeParser.cpp"
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp134_AST = astFactory->create(_t);
			tmp134_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp134_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
#line 342 "expandedgenerate_query_oracle.g"
			printNode(tmp134_AST);
#line 3477 "GenerateOracleQueryTreeParser.cpp"
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
#line 342 "expandedgenerate_query_oracle.g"
				printNode(a2_AST);
#line 3495 "GenerateOracleQueryTreeParser.cpp"
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
#line 342 "expandedgenerate_query_oracle.g"
				printNode(d2_AST);
#line 3508 "GenerateOracleQueryTreeParser.cpp"
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
			goto _loop98;
		}
		
	}
	_loop98:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t73 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp135_AST = astFactory->create(_t);
	tmp135_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp135_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST73 = currentAST;
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
	currentAST = __currentAST73;
	_t = __t73;
	_t = _t->getNextSibling();
	mtsql_selectStatement_AST = currentAST.root;
	returnAST = mtsql_selectStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t75 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp136_AST = astFactory->create(_t);
	tmp136_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp136_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST75 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp137_AST = astFactory->create(_t);
			tmp137_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp137_AST);
			match(_t,INTEGER_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp138_AST = astFactory->create(_t);
			tmp138_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp138_AST);
			match(_t,DECIMAL_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp139_AST = astFactory->create(_t);
			tmp139_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp139_AST);
			match(_t,DOUBLE_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case STRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp140_AST = astFactory->create(_t);
			tmp140_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp140_AST);
			match(_t,STRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp141_AST = astFactory->create(_t);
			tmp141_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp141_AST);
			match(_t,WSTRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp142_AST = astFactory->create(_t);
			tmp142_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp142_AST);
			match(_t,BOOLEAN_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp143_AST = astFactory->create(_t);
			tmp143_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp143_AST);
			match(_t,DATETIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case TIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp144_AST = astFactory->create(_t);
			tmp144_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp144_AST);
			match(_t,TIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp145_AST = astFactory->create(_t);
			tmp145_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp145_AST);
			match(_t,ENUM_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp146_AST = astFactory->create(_t);
			tmp146_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp146_AST);
			match(_t,BIGINT_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BINARY_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp147_AST = astFactory->create(_t);
			tmp147_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp147_AST);
			match(_t,BINARY_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop77;
		}
		}
	}
	_loop77:;
	} // ( ... )*
	currentAST = __currentAST75;
	_t = __t75;
	_t = _t->getNextSibling();
	mtsql_paramList_AST = currentAST.root;
	returnAST = mtsql_paramList_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t79 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp148_AST = astFactory->create(_t);
	tmp148_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp148_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST79 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt81=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= INTEGER_SETMEM_QUERY && _t->getType() <= BINARY_SETMEM_QUERY))) {
			mtsql_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt81>=1 ) { goto _loop81; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt81++;
	}
	_loop81:;
	}  // ( ... )+
	currentAST = __currentAST79;
	_t = __t79;
	_t = _t->getNextSibling();
	mtsql_intoList_AST = currentAST.root;
	returnAST = mtsql_intoList_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t83 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp149_AST = astFactory->create(_t);
		tmp149_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp149_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST83 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp150_AST = astFactory->create(_t);
		tmp150_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp150_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST83;
		_t = __t83;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t84 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp151_AST = astFactory->create(_t);
		tmp151_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp151_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST84 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp152_AST = astFactory->create(_t);
		tmp152_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp152_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST84;
		_t = __t84;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t85 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp153_AST = astFactory->create(_t);
		tmp153_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp153_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST85 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp154_AST = astFactory->create(_t);
		tmp154_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp154_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST85;
		_t = __t85;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t86 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp155_AST = astFactory->create(_t);
		tmp155_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp155_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST86 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp156_AST = astFactory->create(_t);
		tmp156_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp156_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST86;
		_t = __t86;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t87 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp157_AST = astFactory->create(_t);
		tmp157_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp157_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST87 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp158_AST = astFactory->create(_t);
		tmp158_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp158_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST87;
		_t = __t87;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t88 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp159_AST = astFactory->create(_t);
		tmp159_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp159_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST88 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp160_AST = astFactory->create(_t);
		tmp160_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp160_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST88;
		_t = __t88;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t89 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp161_AST = astFactory->create(_t);
		tmp161_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp161_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST89 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp162_AST = astFactory->create(_t);
		tmp162_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp162_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST89;
		_t = __t89;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t90 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp163_AST = astFactory->create(_t);
		tmp163_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp163_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST90 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp164_AST = astFactory->create(_t);
		tmp164_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp164_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST90;
		_t = __t90;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp165_AST = astFactory->create(_t);
		tmp165_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp165_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST91 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp166_AST = astFactory->create(_t);
		tmp166_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp166_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST91;
		_t = __t91;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t92 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp167_AST = astFactory->create(_t);
		tmp167_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp167_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST92 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp168_AST = astFactory->create(_t);
		tmp168_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp168_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST92;
		_t = __t92;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp169_AST = astFactory->create(_t);
		tmp169_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp169_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp170_AST = astFactory->create(_t);
		tmp170_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp170_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST93;
		_t = __t93;
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

void GenerateOracleQueryTreeParser::sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t148 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp171_AST = astFactory->create(_t);
		tmp171_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp171_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST148 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,EQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 395 "expandedgenerate_query_oracle.g"
		printNode(tmp171_AST);
#line 4102 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST148;
		_t = __t148;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t149 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp172_AST = astFactory->create(_t);
		tmp172_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp172_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST149 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GT);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 396 "expandedgenerate_query_oracle.g"
		printNode(tmp172_AST);
#line 4130 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST149;
		_t = __t149;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t150 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp173_AST = astFactory->create(_t);
		tmp173_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp173_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST150 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 397 "expandedgenerate_query_oracle.g"
		printNode(tmp173_AST);
#line 4158 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST150;
		_t = __t150;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t151 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp174_AST = astFactory->create(_t);
		tmp174_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp174_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST151 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTN);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 398 "expandedgenerate_query_oracle.g"
		printNode(tmp174_AST);
#line 4186 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST151;
		_t = __t151;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t152 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp175_AST = astFactory->create(_t);
		tmp175_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp175_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST152 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 399 "expandedgenerate_query_oracle.g"
		printNode(tmp175_AST);
#line 4214 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST152;
		_t = __t152;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t153 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp176_AST = astFactory->create(_t);
		tmp176_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp176_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST153 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,NOTEQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 400 "expandedgenerate_query_oracle.g"
		printNode(tmp176_AST);
#line 4242 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST153;
		_t = __t153;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t154 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp177_AST = astFactory->create(_t);
		tmp177_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp177_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST154 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp178_AST = astFactory->create(_t);
			tmp178_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp178_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 402 "expandedgenerate_query_oracle.g"
			printNode(tmp178_AST);
#line 4283 "GenerateOracleQueryTreeParser.cpp"
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
#line 402 "expandedgenerate_query_oracle.g"
		printNode(tmp177_AST);
#line 4327 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST154;
		_t = __t154;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t156 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp179_AST = astFactory->create(_t);
		tmp179_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp179_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST156 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 404 "expandedgenerate_query_oracle.g"
		printNode(tmp179_AST);
#line 4355 "GenerateOracleQueryTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp180_AST = astFactory->create(_t);
			tmp180_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp180_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 404 "expandedgenerate_query_oracle.g"
			printNode(tmp180_AST);
#line 4371 "GenerateOracleQueryTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp181_AST = astFactory->create(_t);
		tmp181_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp181_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
#line 404 "expandedgenerate_query_oracle.g"
		printNode(tmp181_AST);
#line 4393 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST156;
		_t = __t156;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_BETWEEN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t158 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp182_AST = astFactory->create(_t);
		tmp182_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp182_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST158 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp183_AST = astFactory->create(_t);
			tmp183_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp183_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 406 "expandedgenerate_query_oracle.g"
			printNode(tmp183_AST);
#line 4431 "GenerateOracleQueryTreeParser.cpp"
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
#line 406 "expandedgenerate_query_oracle.g"
		printNode(tmp182_AST);
#line 4475 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp184_AST = astFactory->create(_t);
		tmp184_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp184_AST);
		match(_t,TK_AND);
		_t = _t->getNextSibling();
#line 406 "expandedgenerate_query_oracle.g"
		printNode(tmp184_AST);
#line 4488 "GenerateOracleQueryTreeParser.cpp"
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST158;
		_t = __t158;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t160 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp185_AST = astFactory->create(_t);
		tmp185_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp185_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST160 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp186_AST = astFactory->create(_t);
			tmp186_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp186_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 408 "expandedgenerate_query_oracle.g"
			printNode(tmp186_AST);
#line 4526 "GenerateOracleQueryTreeParser.cpp"
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
#line 408 "expandedgenerate_query_oracle.g"
		printNode(tmp185_AST);
#line 4541 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp187_AST = astFactory->create(_t);
		tmp187_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp187_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 409 "expandedgenerate_query_oracle.g"
		printNode(tmp187_AST);
#line 4551 "GenerateOracleQueryTreeParser.cpp"
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp188_AST = astFactory->create(_t);
		tmp188_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp188_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 411 "expandedgenerate_query_oracle.g"
		printNode(tmp188_AST);
#line 4564 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST160;
		_t = __t160;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t162 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp189_AST = astFactory->create(_t);
		tmp189_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp189_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST162 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp190_AST = astFactory->create(_t);
			tmp190_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp190_AST);
			match(_t,TK_NOT);
			_t = _t->getNextSibling();
#line 413 "expandedgenerate_query_oracle.g"
			printNode(tmp190_AST);
#line 4602 "GenerateOracleQueryTreeParser.cpp"
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
#line 413 "expandedgenerate_query_oracle.g"
		printNode(tmp189_AST);
#line 4617 "GenerateOracleQueryTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp191_AST = astFactory->create(_t);
		tmp191_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp191_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
#line 414 "expandedgenerate_query_oracle.g"
		printNode(tmp191_AST);
#line 4627 "GenerateOracleQueryTreeParser.cpp"
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
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp192_AST = astFactory->create(_t);
					tmp192_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp192_AST);
					match(_t,COMMA);
					_t = _t->getNextSibling();
#line 416 "expandedgenerate_query_oracle.g"
					printNode(tmp192_AST);
#line 4687 "GenerateOracleQueryTreeParser.cpp"
					sql92_expr(_t);
					_t = _retTree;
					astFactory->addASTChild( currentAST, returnAST );
				}
				else {
					goto _loop166;
				}
				
			}
			_loop166:;
			} // ( ... )*
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp193_AST = astFactory->create(_t);
		tmp193_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp193_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 417 "expandedgenerate_query_oracle.g"
		printNode(tmp193_AST);
#line 4716 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST162;
		_t = __t162;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t167 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp194_AST = astFactory->create(_t);
		tmp194_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp194_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST167 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LAND);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 419 "expandedgenerate_query_oracle.g"
		printNode(tmp194_AST);
#line 4741 "GenerateOracleQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST167;
		_t = __t167;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t168 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp195_AST = astFactory->create(_t);
		tmp195_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp195_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST168 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
#line 420 "expandedgenerate_query_oracle.g"
		printNode(tmp195_AST);
#line 4766 "GenerateOracleQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST168;
		_t = __t168;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp196_AST = astFactory->create(_t);
		tmp196_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp196_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST169 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LOR);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 421 "expandedgenerate_query_oracle.g"
		printNode(tmp196_AST);
#line 4794 "GenerateOracleQueryTreeParser.cpp"
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST169;
		_t = __t169;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t170 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp197_AST = astFactory->create(_t);
		tmp197_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp197_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST170 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
#line 422 "expandedgenerate_query_oracle.g"
		printNode(tmp197_AST);
#line 4819 "GenerateOracleQueryTreeParser.cpp"
		sql92_hackExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp198_AST = astFactory->create(_t);
		tmp198_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp198_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
#line 422 "expandedgenerate_query_oracle.g"
		printNode(tmp198_AST);
#line 4832 "GenerateOracleQueryTreeParser.cpp"
		currentAST = __currentAST170;
		_t = __t170;
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

void GenerateOracleQueryTreeParser::sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void GenerateOracleQueryTreeParser::sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t141 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp199_AST = astFactory->create(_t);
	tmp199_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp199_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST141 = currentAST;
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp200_AST = astFactory->create(_t);
				tmp200_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp200_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
#line 386 "expandedgenerate_query_oracle.g"
				printNode(tmp200_AST);
#line 4902 "GenerateOracleQueryTreeParser.cpp"
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop144;
			}
			
		}
		_loop144:;
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
	currentAST = __currentAST141;
	_t = __t141;
	_t = _t->getNextSibling();
	sql92_elist_AST = currentAST.root;
	returnAST = sql92_elist_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t172 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp201_AST = astFactory->create(_t);
	tmp201_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp201_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST172 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST172;
	_t = __t172;
	_t = _t->getNextSibling();
	sql92_hackExpression_AST = currentAST.root;
	returnAST = sql92_hackExpression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop192;
		}
		
	}
	_loop192:;
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
	ANTLR_USE_NAMESPACE(antlr)RefAST __t194 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp202_AST = astFactory->create(_t);
	tmp202_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp202_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST194 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SCOPE);
	_t = _t->getFirstChild();
#line 475 "expandedgenerate_query_oracle.g"
	mEnv->beginScope();
#line 5018 "GenerateOracleQueryTreeParser.cpp"
	statementList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
#line 476 "expandedgenerate_query_oracle.g"
	mEnv->endScope();
#line 5024 "GenerateOracleQueryTreeParser.cpp"
	currentAST = __currentAST194;
	_t = __t194;
	_t = _t->getNextSibling();
	program_AST = currentAST.root;
	returnAST = program_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t202 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp203_AST = astFactory->create(_t);
	tmp203_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp203_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST202 = currentAST;
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
	currentAST = __currentAST202;
	_t = __t202;
	_t = _t->getNextSibling();
#line 534 "expandedgenerate_query_oracle.g"
	
				
			mEnv->insertVar(
			var->getText(), 
			VarEntry::create(getType(ty->getText()), mEnv->allocateVariable(var->getText(), getType(ty->getText())), mEnv->getCurrentLevel())); 
		
#line 5076 "GenerateOracleQueryTreeParser.cpp"
	typeDeclaration_AST = currentAST.root;
	returnAST = typeDeclaration_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t196 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp204_AST = astFactory->create(_t);
	tmp204_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp204_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST196 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_RETURNS);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp205_AST = astFactory->create(_t);
	tmp205_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp205_AST);
	match(_t,BUILTIN_TYPE);
	_t = _t->getNextSibling();
	currentAST = __currentAST196;
	_t = __t196;
	_t = _t->getNextSibling();
	returnsDeclaration_AST = currentAST.root;
	returnAST = returnsDeclaration_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop199;
		}
		
	}
	_loop199:;
	} // ( ... )*
	statementList_AST = currentAST.root;
	returnAST = statementList_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 521 "expandedgenerate_query_oracle.g"
		
		mQueryString = L"";
		mQueryParameters.clear();
		
#line 5295 "GenerateOracleQueryTreeParser.cpp"
		mtsql_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 526 "expandedgenerate_query_oracle.g"
		
		RefMTSQLAST ast = ((RefMTSQLAST)statement_AST);
		ast->setValue(RuntimeValue::createWString(mQueryString)); 
		
#line 5305 "GenerateOracleQueryTreeParser.cpp"
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

void GenerateOracleQueryTreeParser::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t204 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp206_AST = astFactory->create(_t);
		tmp206_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp206_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST204 = currentAST;
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
		currentAST = __currentAST204;
		_t = __t204;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t205 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp207_AST = astFactory->create(_t);
		tmp207_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp207_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST205 = currentAST;
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
		currentAST = __currentAST205;
		_t = __t205;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t206 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp208_AST = astFactory->create(_t);
		tmp208_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp208_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST206 = currentAST;
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
		currentAST = __currentAST206;
		_t = __t206;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t207 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp209_AST = astFactory->create(_t);
		tmp209_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp209_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST207 = currentAST;
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
		currentAST = __currentAST207;
		_t = __t207;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t208 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp210_AST = astFactory->create(_t);
		tmp210_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp210_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST208 = currentAST;
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
		currentAST = __currentAST208;
		_t = __t208;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t209 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp211_AST = astFactory->create(_t);
		tmp211_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp211_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST209 = currentAST;
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
		currentAST = __currentAST209;
		_t = __t209;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t210 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp212_AST = astFactory->create(_t);
		tmp212_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp212_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST210 = currentAST;
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
		currentAST = __currentAST210;
		_t = __t210;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t211 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp213_AST = astFactory->create(_t);
		tmp213_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp213_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST211 = currentAST;
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
		currentAST = __currentAST211;
		_t = __t211;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t212 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp214_AST = astFactory->create(_t);
		tmp214_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp214_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST212 = currentAST;
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
		currentAST = __currentAST212;
		_t = __t212;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t213 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp215_AST = astFactory->create(_t);
		tmp215_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp215_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST213 = currentAST;
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
		currentAST = __currentAST213;
		_t = __t213;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t214 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp216_AST = astFactory->create(_t);
		tmp216_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp216_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST214 = currentAST;
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
		currentAST = __currentAST214;
		_t = __t214;
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

void GenerateOracleQueryTreeParser::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t219 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp217_AST = astFactory->create(_t);
	tmp217_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp217_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST219 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WSTRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST219;
	_t = __t219;
	_t = _t->getNextSibling();
	wstringPrintStatement_AST = currentAST.root;
	returnAST = wstringPrintStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t217 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp218_AST = astFactory->create(_t);
	tmp218_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp218_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST217 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,STRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST217;
	_t = __t217;
	_t = _t->getNextSibling();
	stringPrintStatement_AST = currentAST.root;
	returnAST = stringPrintStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t221 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp219_AST = astFactory->create(_t);
	tmp219_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp219_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST221 = currentAST;
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
	currentAST = __currentAST221;
	_t = __t221;
	_t = _t->getNextSibling();
	seq_AST = currentAST.root;
	returnAST = seq_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t249 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp220_AST = astFactory->create(_t);
	tmp220_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp220_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST249 = currentAST;
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
	currentAST = __currentAST249;
	_t = __t249;
	_t = _t->getNextSibling();
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t254 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp221_AST = astFactory->create(_t);
	tmp221_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp221_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST254 = currentAST;
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
			goto _loop256;
		}
		
	}
	_loop256:;
	} // ( ... )*
	currentAST = __currentAST254;
	_t = __t254;
	_t = _t->getNextSibling();
	listOfStatements_AST = currentAST.root;
	returnAST = listOfStatements_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t258 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp222_AST = astFactory->create(_t);
	tmp222_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp222_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST258 = currentAST;
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
	currentAST = __currentAST258;
	_t = __t258;
	_t = _t->getNextSibling();
	returnStatement_AST = currentAST.root;
	returnAST = returnStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp223_AST = astFactory->create(_t);
	tmp223_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp223_AST);
	match(_t,TK_BREAK);
	_t = _t->getNextSibling();
	breakStatement_AST = currentAST.root;
	returnAST = breakStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp224_AST = astFactory->create(_t);
	tmp224_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp224_AST);
	match(_t,TK_CONTINUE);
	_t = _t->getNextSibling();
	continueStatement_AST = currentAST.root;
	returnAST = continueStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t263 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp225_AST = astFactory->create(_t);
	tmp225_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp225_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST263 = currentAST;
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
	currentAST = __currentAST263;
	_t = __t263;
	_t = _t->getNextSibling();
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t267 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp226_AST = astFactory->create(_t);
	tmp226_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp226_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST267 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST267;
	_t = __t267;
	_t = _t->getNextSibling();
	raiserrorStringStatement_AST = currentAST.root;
	returnAST = raiserrorStringStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t269 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp227_AST = astFactory->create(_t);
	tmp227_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp227_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST269 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORWSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST269;
	_t = __t269;
	_t = _t->getNextSibling();
	raiserrorWStringStatement_AST = currentAST.root;
	returnAST = raiserrorWStringStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t265 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp228_AST = astFactory->create(_t);
	tmp228_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp228_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST265 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORINTEGER);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST265;
	_t = __t265;
	_t = _t->getNextSibling();
	raiserrorIntegerStatement_AST = currentAST.root;
	returnAST = raiserrorIntegerStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t271 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp229_AST = astFactory->create(_t);
	tmp229_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp229_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST271 = currentAST;
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
	currentAST = __currentAST271;
	_t = __t271;
	_t = _t->getNextSibling();
	raiserror2StringStatement_AST = currentAST.root;
	returnAST = raiserror2StringStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t273 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp230_AST = astFactory->create(_t);
	tmp230_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp230_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST273 = currentAST;
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
	currentAST = __currentAST273;
	_t = __t273;
	_t = _t->getNextSibling();
	raiserror2WStringStatement_AST = currentAST.root;
	returnAST = raiserror2WStringStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void GenerateOracleQueryTreeParser::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t280 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp231_AST = astFactory->create(_t);
	tmp231_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp231_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST280 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST280;
	_t = __t280;
	_t = _t->getNextSibling();
	expression_AST = currentAST.root;
	returnAST = expression_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t282 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp232_AST = astFactory->create(_t);
		tmp232_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp232_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST282 = currentAST;
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
		currentAST = __currentAST282;
		_t = __t282;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t283 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp233_AST = astFactory->create(_t);
		tmp233_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp233_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST283 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST283;
		_t = __t283;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t284 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp234_AST = astFactory->create(_t);
		tmp234_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp234_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST284 = currentAST;
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
		currentAST = __currentAST284;
		_t = __t284;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t285 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp235_AST = astFactory->create(_t);
		tmp235_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp235_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST285 = currentAST;
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
		currentAST = __currentAST285;
		_t = __t285;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t286 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp236_AST = astFactory->create(_t);
		tmp236_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp236_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST286 = currentAST;
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
		currentAST = __currentAST286;
		_t = __t286;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t287 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp237_AST = astFactory->create(_t);
		tmp237_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp237_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST287 = currentAST;
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
		currentAST = __currentAST287;
		_t = __t287;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t288 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp238_AST = astFactory->create(_t);
		tmp238_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp238_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST288 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST288;
		_t = __t288;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t289 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp239_AST = astFactory->create(_t);
		tmp239_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp239_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST289 = currentAST;
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
		currentAST = __currentAST289;
		_t = __t289;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t290 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp240_AST = astFactory->create(_t);
		tmp240_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp240_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST290 = currentAST;
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
		currentAST = __currentAST290;
		_t = __t290;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t291 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp241_AST = astFactory->create(_t);
		tmp241_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp241_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST291 = currentAST;
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
		currentAST = __currentAST291;
		_t = __t291;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t292 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp242_AST = astFactory->create(_t);
		tmp242_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp242_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST292 = currentAST;
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
		currentAST = __currentAST292;
		_t = __t292;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t293 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp243_AST = astFactory->create(_t);
		tmp243_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp243_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST293 = currentAST;
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
		currentAST = __currentAST293;
		_t = __t293;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t294 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp244_AST = astFactory->create(_t);
		tmp244_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp244_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST294 = currentAST;
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
		currentAST = __currentAST294;
		_t = __t294;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ISNULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t295 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp245_AST = astFactory->create(_t);
		tmp245_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp245_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST295 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ISNULL);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST295;
		_t = __t295;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t296 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp246_AST = astFactory->create(_t);
		tmp246_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp246_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST296 = currentAST;
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
		currentAST = __currentAST296;
		_t = __t296;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t297 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp247_AST = astFactory->create(_t);
		tmp247_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp247_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST297 = currentAST;
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
		currentAST = __currentAST297;
		_t = __t297;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t298 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp248_AST = astFactory->create(_t);
		tmp248_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp248_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST298 = currentAST;
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
		currentAST = __currentAST298;
		_t = __t298;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t299 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp249_AST = astFactory->create(_t);
		tmp249_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp249_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST299 = currentAST;
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
		currentAST = __currentAST299;
		_t = __t299;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t300 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp250_AST = astFactory->create(_t);
		tmp250_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp250_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST300 = currentAST;
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
		currentAST = __currentAST300;
		_t = __t300;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t301 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp251_AST = astFactory->create(_t);
		tmp251_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp251_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST301 = currentAST;
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
		currentAST = __currentAST301;
		_t = __t301;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t302 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp252_AST = astFactory->create(_t);
		tmp252_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp252_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST302 = currentAST;
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
		currentAST = __currentAST302;
		_t = __t302;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t303 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp253_AST = astFactory->create(_t);
		tmp253_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp253_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST303 = currentAST;
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
		currentAST = __currentAST303;
		_t = __t303;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t304 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp254_AST = astFactory->create(_t);
		tmp254_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp254_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST304 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_UNARY_MINUS);
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
	case BIGINT_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t305 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp255_AST = astFactory->create(_t);
		tmp255_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp255_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST305 = currentAST;
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
		currentAST = __currentAST305;
		_t = __t305;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t306 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp256_AST = astFactory->create(_t);
		tmp256_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp256_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST306 = currentAST;
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
		currentAST = __currentAST306;
		_t = __t306;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t307 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp257_AST = astFactory->create(_t);
		tmp257_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp257_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST307 = currentAST;
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
		currentAST = __currentAST307;
		_t = __t307;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t308 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp258_AST = astFactory->create(_t);
		tmp258_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp258_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST308 = currentAST;
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
		currentAST = __currentAST308;
		_t = __t308;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t309 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp259_AST = astFactory->create(_t);
		tmp259_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp259_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST309 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST309;
		_t = __t309;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t310 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp260_AST = astFactory->create(_t);
		tmp260_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp260_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST310 = currentAST;
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
		currentAST = __currentAST310;
		_t = __t310;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t311 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp261_AST = astFactory->create(_t);
		tmp261_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp261_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST311 = currentAST;
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
		currentAST = __currentAST311;
		_t = __t311;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t312 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp262_AST = astFactory->create(_t);
		tmp262_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp262_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST312 = currentAST;
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
		currentAST = __currentAST312;
		_t = __t312;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t313 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp263_AST = astFactory->create(_t);
		tmp263_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp263_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
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
		currentAST = __currentAST313;
		_t = __t313;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t314 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp264_AST = astFactory->create(_t);
		tmp264_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp264_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST314 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST314;
		_t = __t314;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t315 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp265_AST = astFactory->create(_t);
		tmp265_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp265_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST315 = currentAST;
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
		currentAST = __currentAST315;
		_t = __t315;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t316 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp266_AST = astFactory->create(_t);
		tmp266_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp266_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST316 = currentAST;
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
		currentAST = __currentAST316;
		_t = __t316;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t317 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp267_AST = astFactory->create(_t);
		tmp267_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp267_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST317 = currentAST;
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
		currentAST = __currentAST317;
		_t = __t317;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t318 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp268_AST = astFactory->create(_t);
		tmp268_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp268_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST318 = currentAST;
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
		currentAST = __currentAST318;
		_t = __t318;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t319 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp269_AST = astFactory->create(_t);
		tmp269_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp269_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST319 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST319;
		_t = __t319;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t320 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp270_AST = astFactory->create(_t);
		tmp270_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp270_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST320 = currentAST;
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
		currentAST = __currentAST320;
		_t = __t320;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t321 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp271_AST = astFactory->create(_t);
		tmp271_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp271_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST321 = currentAST;
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
		currentAST = __currentAST321;
		_t = __t321;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case IFBLOCK:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t322 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp272_AST = astFactory->create(_t);
		tmp272_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp272_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST322 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFBLOCK);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt324=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == EXPR || _t->getType() == IFEXPR)) {
				ifThenElse(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt324>=1 ) { goto _loop324; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt324++;
		}
		_loop324:;
		}  // ( ... )+
		currentAST = __currentAST322;
		_t = __t322;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ESEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t325 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp273_AST = astFactory->create(_t);
		tmp273_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp273_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST325 = currentAST;
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
		currentAST = __currentAST325;
		_t = __t325;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_INTEGER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t326 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp274_AST = astFactory->create(_t);
		tmp274_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp274_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST326 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_INTEGER);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST326;
		_t = __t326;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t327 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp275_AST = astFactory->create(_t);
		tmp275_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp275_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST327 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BIGINT);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST327;
		_t = __t327;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DOUBLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t328 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp276_AST = astFactory->create(_t);
		tmp276_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp276_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST328 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DOUBLE);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST328;
		_t = __t328;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t329 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp277_AST = astFactory->create(_t);
		tmp277_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp277_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST329 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DECIMAL);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST329;
		_t = __t329;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_STRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t330 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp278_AST = astFactory->create(_t);
		tmp278_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp278_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST330 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_STRING);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST330;
		_t = __t330;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_WSTRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t331 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp279_AST = astFactory->create(_t);
		tmp279_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp279_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST331 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_WSTRING);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST331;
		_t = __t331;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BOOLEAN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t332 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp280_AST = astFactory->create(_t);
		tmp280_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp280_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST332 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BOOLEAN);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST332;
		_t = __t332;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DATETIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t333 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp281_AST = astFactory->create(_t);
		tmp281_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp281_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST333 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DATETIME);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST333;
		_t = __t333;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_TIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t334 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp282_AST = astFactory->create(_t);
		tmp282_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp282_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST334 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_TIME);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST334;
		_t = __t334;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_ENUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t335 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp283_AST = astFactory->create(_t);
		tmp283_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp283_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST335 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_ENUM);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST335;
		_t = __t335;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BINARY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t336 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp284_AST = astFactory->create(_t);
		tmp284_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp284_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST336 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BINARY);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST336;
		_t = __t336;
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

void GenerateOracleQueryTreeParser::queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t223 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp285_AST = astFactory->create(_t);
	tmp285_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp285_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST223 = currentAST;
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
	currentAST = __currentAST223;
	_t = __t223;
	_t = _t->getNextSibling();
	queryStatement_AST = currentAST.root;
	returnAST = queryStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t245 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp286_AST = astFactory->create(_t);
	tmp286_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp286_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST245 = currentAST;
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
			goto _loop247;
		}
		
	}
	_loop247:;
	} // ( ... )*
	currentAST = __currentAST245;
	_t = __t245;
	_t = _t->getNextSibling();
	localParamList_AST = currentAST.root;
	returnAST = localParamList_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 581 "expandedgenerate_query_oracle.g"
	
	
#line 7511 "GenerateOracleQueryTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t225 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp287_AST = astFactory->create(_t);
	tmp287_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp287_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST225 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERYSTRING);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt227=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= TK_AND && _t->getType() <= BIGINT_MODULUS))) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp288_AST = astFactory->create(_t);
			tmp288_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp288_AST);
			if ( _t == ANTLR_USE_NAMESPACE(antlr)nullAST ) throw ANTLR_USE_NAMESPACE(antlr)MismatchedTokenException();
			_t = _t->getNextSibling();
		}
		else {
			if ( _cnt227>=1 ) { goto _loop227; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt227++;
	}
	_loop227:;
	}  // ( ... )+
	currentAST = __currentAST225;
	_t = __t225;
	_t = _t->getNextSibling();
	queryString_AST = currentAST.root;
	returnAST = queryString_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void GenerateOracleQueryTreeParser::setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t230 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp289_AST = astFactory->create(_t);
	tmp289_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp289_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST230 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST __t232 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp290_AST = astFactory->create(_t);
			tmp290_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp290_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST232 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,INTEGER_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST232;
			_t = __t232;
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t233 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp291_AST = astFactory->create(_t);
			tmp291_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp291_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST233 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BIGINT_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST233;
			_t = __t233;
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t234 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp292_AST = astFactory->create(_t);
			tmp292_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp292_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST234 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DOUBLE_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST234;
			_t = __t234;
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t235 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp293_AST = astFactory->create(_t);
			tmp293_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp293_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST235 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DECIMAL_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST235;
			_t = __t235;
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t236 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp294_AST = astFactory->create(_t);
			tmp294_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp294_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST236 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BOOLEAN_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST236;
			_t = __t236;
			_t = _t->getNextSibling();
			break;
		}
		case STRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t237 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp295_AST = astFactory->create(_t);
			tmp295_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp295_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST237 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,STRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST237;
			_t = __t237;
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t238 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp296_AST = astFactory->create(_t);
			tmp296_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp296_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST238 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,WSTRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST238;
			_t = __t238;
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t239 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp297_AST = astFactory->create(_t);
			tmp297_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp297_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST239 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DATETIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST239;
			_t = __t239;
			_t = _t->getNextSibling();
			break;
		}
		case TIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t240 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp298_AST = astFactory->create(_t);
			tmp298_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp298_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST240 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,TIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST240;
			_t = __t240;
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t241 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp299_AST = astFactory->create(_t);
			tmp299_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp299_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST241 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,ENUM_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST241;
			_t = __t241;
			_t = _t->getNextSibling();
			break;
		}
		case BINARY_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t242 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp300_AST = astFactory->create(_t);
			tmp300_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp300_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST242 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BINARY_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST242;
			_t = __t242;
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop243;
		}
		}
	}
	_loop243:;
	} // ( ... )*
	currentAST = __currentAST230;
	_t = __t230;
	_t = _t->getNextSibling();
	setmemQuery_AST = currentAST.root;
	returnAST = setmemQuery_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp301_AST = astFactory->create(_t);
		tmp301_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp301_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp302_AST = astFactory->create(_t);
		tmp302_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp302_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp303_AST = astFactory->create(_t);
		tmp303_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp303_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp304_AST = astFactory->create(_t);
		tmp304_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp304_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp305_AST = astFactory->create(_t);
		tmp305_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp305_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp306_AST = astFactory->create(_t);
		tmp306_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp306_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp307_AST = astFactory->create(_t);
		tmp307_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp307_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp308_AST = astFactory->create(_t);
		tmp308_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp308_AST);
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp309_AST = astFactory->create(_t);
		tmp309_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp309_AST);
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp310_AST = astFactory->create(_t);
		tmp310_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp310_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t341 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp311_AST = astFactory->create(_t);
		tmp311_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp311_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST341 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp312_AST = astFactory->create(_t);
		tmp312_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp312_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp313_AST = astFactory->create(_t);
		tmp313_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp313_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST341;
		_t = __t341;
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp314_AST = astFactory->create(_t);
		tmp314_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp314_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp315_AST = astFactory->create(_t);
		tmp315_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp315_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp316_AST = astFactory->create(_t);
		tmp316_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp316_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp317_AST = astFactory->create(_t);
		tmp317_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp317_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp318_AST = astFactory->create(_t);
		tmp318_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp318_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp319_AST = astFactory->create(_t);
		tmp319_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp319_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp320_AST = astFactory->create(_t);
		tmp320_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp320_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp321_AST = astFactory->create(_t);
		tmp321_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp321_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp322_AST = astFactory->create(_t);
		tmp322_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp322_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp323_AST = astFactory->create(_t);
		tmp323_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp323_AST);
		match(_t,ENUM_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BINARY_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp324_AST = astFactory->create(_t);
		tmp324_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp324_AST);
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

void GenerateOracleQueryTreeParser::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t252 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp325_AST = astFactory->create(_t);
	tmp325_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp325_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST252 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DELAYED_STMT);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST252;
	_t = __t252;
	_t = _t->getNextSibling();
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t275 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp326_AST = astFactory->create(_t);
	tmp326_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp326_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST275 = currentAST;
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp327_AST = astFactory->create(_t);
				tmp327_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp327_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop278;
			}
			
		}
		_loop278:;
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
	currentAST = __currentAST275;
	_t = __t275;
	_t = _t->getNextSibling();
	elist_AST = currentAST.root;
	returnAST = elist_AST;
	_retTree = _t;
}

void GenerateOracleQueryTreeParser::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case IFEXPR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t338 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp328_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp328_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp328_AST = astFactory->create(_t);
		tmp328_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp328_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST338 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFEXPR);
		_t = _t->getFirstChild();
		conditional(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST338;
		_t = __t338;
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

void GenerateOracleQueryTreeParser::conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 739 "expandedgenerate_query_oracle.g"
	
	
#line 8304 "GenerateOracleQueryTreeParser.cpp"
	
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

void GenerateOracleQueryTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(246);
}
const char* GenerateOracleQueryTreeParser::tokenNames[] = {
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

const unsigned long GenerateOracleQueryTreeParser::_tokenSet_0_data_[] = { 2048UL, 139521UL, 3623878656UL, 259UL, 458752UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BETWEEN" "EXISTS" "IN" "IS" "LIKE" EQUALS NOTEQUALS LTN LTEQ GT GTEQ 
// LPAREN LAND LNOT LOR 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateOracleQueryTreeParser::_tokenSet_0(_tokenSet_0_data_,12);
const unsigned long GenerateOracleQueryTreeParser::_tokenSet_1_data_[] = { 17317888UL, 0UL, 1UL, 0UL, 2113536UL, 161UL, 2146435072UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "RETURN" IFTHENELSE QUERY SLIST WHILE SEQUENCE 
// INTEGER_SETMEM BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM 
// WSTRING_SETMEM BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM 
// BINARY_SETMEM RAISERRORINTEGER RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING 
// RAISERROR2WSTRING STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateOracleQueryTreeParser::_tokenSet_1(_tokenSet_1_data_,16);
const unsigned long GenerateOracleQueryTreeParser::_tokenSet_2_data_[] = { 0UL, 2097154UL, 459264UL, 17235968UL, 526336UL, 0UL, 1048064UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "FALSE" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL NUM_INT EXPR METHOD_CALL INTEGER_GETMEM 
// BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM WSTRING_GETMEM 
// BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM BINARY_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet GenerateOracleQueryTreeParser::_tokenSet_2(_tokenSet_2_data_,16);


