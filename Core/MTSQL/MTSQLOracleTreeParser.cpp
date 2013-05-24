/* $ANTLR 2.7.6 (2005-12-22): "expandedmtsql_tree_oracle.g" -> "MTSQLOracleTreeParser.cpp"$ */
#include "MTSQLOracleTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "expandedmtsql_tree_oracle.g"
#line 11 "MTSQLOracleTreeParser.cpp"
MTSQLOracleTreeParser::MTSQLOracleTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void MTSQLOracleTreeParser::sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp8_AST = astFactory->create(_t);
		tmp8_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp8_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp9_AST = astFactory->create(_t);
		tmp9_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp9_AST);
		match(_t,ALIAS);
		_t = _t->getNextSibling();
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

void MTSQLOracleTreeParser::sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t276 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp10_AST = astFactory->create(_t);
	tmp10_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp10_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST276 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ON);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST276;
	_t = __t276;
	_t = _t->getNextSibling();
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t262 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp11_AST = astFactory->create(_t);
	tmp11_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp11_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST262 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WITH);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp12_AST = astFactory->create(_t);
	tmp12_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp12_AST);
	match(_t,LPAREN);
	_t = _t->getNextSibling();
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp15_AST = astFactory->create(_t);
		tmp15_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp15_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
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
				goto _loop267;
			}
			
		}
		_loop267:;
		} // ( ... )*
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp21_AST = astFactory->create(_t);
		tmp21_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp21_AST);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp22_AST = astFactory->create(_t);
			tmp22_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp22_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp25_AST = astFactory->create(_t);
				tmp25_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp25_AST);
				match(_t,LPAREN);
				_t = _t->getNextSibling();
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
						goto _loop273;
					}
					
				}
				_loop273:;
				} // ( ... )*
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp31_AST = astFactory->create(_t);
				tmp31_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp31_AST);
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
			goto _loop274;
		}
		
	}
	_loop274:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp32_AST = astFactory->create(_t);
	tmp32_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp32_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
	currentAST = __currentAST262;
	_t = __t262;
	_t = _t->getNextSibling();
	sql92_tableHint_AST = currentAST.root;
	returnAST = sql92_tableHint_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::oracle_for_update_of_hint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp34_AST = astFactory->create(_t);
	tmp34_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp34_AST);
	match(_t,TK_UPDATE);
	_t = _t->getNextSibling();
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp36_AST = astFactory->create(_t);
		tmp36_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp36_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp38_AST = astFactory->create(_t);
			tmp38_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp38_AST);
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

void MTSQLOracleTreeParser::sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop16;
		}
		
	}
	_loop16:;
	} // ( ... )*
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
			goto _loop19;
		}
		
	}
	_loop19:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp41_AST = astFactory->create(_t);
		tmp41_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp41_AST);
		match(_t,TK_ORDER);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp42_AST = astFactory->create(_t);
		tmp42_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp42_AST);
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
	case TK_LOCK:
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

void MTSQLOracleTreeParser::oracle_lock_statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_lock_statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_lock_statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t22 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp43_AST = astFactory->create(_t);
	tmp43_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp43_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST22 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_LOCK);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp44_AST = astFactory->create(_t);
	tmp44_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp44_AST);
	match(_t,TK_TABLE);
	_t = _t->getNextSibling();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp45_AST = astFactory->create(_t);
	tmp45_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp45_AST);
	match(_t,ID);
	_t = _t->getNextSibling();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case DOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp46_AST = astFactory->create(_t);
		tmp46_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp46_AST);
		match(_t,DOT);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp47_AST = astFactory->create(_t);
		tmp47_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp47_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
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
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp48_AST = astFactory->create(_t);
	tmp48_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp48_AST);
	match(_t,TK_IN);
	_t = _t->getNextSibling();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == ID)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp49_AST = astFactory->create(_t);
			tmp49_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp49_AST);
			match(_t,ID);
			_t = _t->getNextSibling();
		}
		else {
			goto _loop25;
		}
		
	}
	_loop25:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp50_AST = astFactory->create(_t);
	tmp50_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp50_AST);
	match(_t,TK_MODE);
	_t = _t->getNextSibling();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_NOWAIT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp51_AST = astFactory->create(_t);
		tmp51_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp51_AST);
		match(_t,TK_NOWAIT);
		_t = _t->getNextSibling();
		break;
	}
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp52_AST = astFactory->create(_t);
	tmp52_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp52_AST);
	match(_t,SEMI);
	_t = _t->getNextSibling();
	currentAST = __currentAST22;
	_t = __t22;
	_t = _t->getNextSibling();
	oracle_lock_statement_AST = currentAST.root;
	returnAST = oracle_lock_statement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t224 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp53_AST = astFactory->create(_t);
	tmp53_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp53_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST224 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp54_AST = astFactory->create(_t);
		tmp54_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp54_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp55_AST = astFactory->create(_t);
		tmp55_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp55_AST);
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
	currentAST = __currentAST224;
	_t = __t224;
	_t = _t->getNextSibling();
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp56_AST = astFactory->create(_t);
		tmp56_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp56_AST);
		match(_t,TK_ASC);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DESC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp57_AST = astFactory->create(_t);
		tmp57_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp57_AST);
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
	case TK_LOCK:
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp58_AST = astFactory->create(_t);
			tmp58_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp58_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp59_AST = astFactory->create(_t);
				tmp59_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp59_AST);
				match(_t,TK_ASC);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DESC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp60_AST = astFactory->create(_t);
				tmp60_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp60_AST);
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
			case TK_LOCK:
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
			goto _loop222;
		}
		
	}
	_loop222:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
#line 616 "expandedmtsql_tree_oracle.g"
	mReturnType = TYPE_BOOLEAN;
#line 1555 "MTSQLOracleTreeParser.cpp"
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
			goto _loop29;
		}
		
	}
	_loop29:;
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
	ANTLR_USE_NAMESPACE(antlr)RefAST __t31 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp61_AST = astFactory->create(_t);
	tmp61_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp61_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST31 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SCOPE);
	_t = _t->getFirstChild();
#line 616 "expandedmtsql_tree_oracle.g"
	mEnv->beginScope();
#line 1606 "MTSQLOracleTreeParser.cpp"
	statementList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
#line 616 "expandedmtsql_tree_oracle.g"
	mEnv->endScope();
#line 1612 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST31;
	_t = __t31;
	_t = _t->getNextSibling();
	program_AST = currentAST.root;
	returnAST = program_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t39 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp62_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp62_AST = astFactory->create(_t);
	tmp62_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp62_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST39 = currentAST;
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
	currentAST = __currentAST39;
	_t = __t39;
	_t = _t->getNextSibling();
	typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 679 "expandedmtsql_tree_oracle.g"
	
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
			
#line 1705 "MTSQLOracleTreeParser.cpp"
	typeDeclaration_AST = currentAST.root;
	returnAST = typeDeclaration_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::returnsDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t33 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp63_AST = astFactory->create(_t);
	tmp63_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp63_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST33 = currentAST;
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
	currentAST = __currentAST33;
	_t = __t33;
	_t = _t->getNextSibling();
#line 620 "expandedmtsql_tree_oracle.g"
	mReturnType = getType(ty->getText());
#line 1741 "MTSQLOracleTreeParser.cpp"
	returnsDeclaration_AST = currentAST.root;
	returnAST = returnsDeclaration_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop36;
		}
		
	}
	_loop36:;
	} // ( ... )*
	statementList_AST = currentAST.root;
	returnAST = statementList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
	case TK_LOCK:
	{
#line 640 "expandedmtsql_tree_oracle.g"
		
		enterQuery();
		
#line 1849 "MTSQLOracleTreeParser.cpp"
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 644 "expandedmtsql_tree_oracle.g"
		
		statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(4))->add(astFactory->create(QUERY,"QUERY"))->add(statement_AST)->add(getQueryInputs())->add(getInto(statement_AST)))); 
		
#line 1858 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 718 "expandedmtsql_tree_oracle.g"
	
	int r=TYPE_INVALID;
	int e=TYPE_INVALID;
	
#line 2000 "MTSQLOracleTreeParser.cpp"
	
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t44 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp64_AST = astFactory->create(_t);
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp64_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST44 = currentAST;
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
		currentAST = __currentAST44;
		_t = __t44;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 724 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e) || r != TYPE_INTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2040 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t45 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp65_AST = astFactory->create(_t);
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp65_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST45 = currentAST;
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
		currentAST = __currentAST45;
		_t = __t45;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 728 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e) || r != TYPE_BIGINTEGER) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2071 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t46 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp66_AST = astFactory->create(_t);
		tmp66_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp66_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST46 = currentAST;
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
		currentAST = __currentAST46;
		_t = __t46;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 732 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DOUBLE) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2102 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t47 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp67_AST = astFactory->create(_t);
		tmp67_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp67_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST47 = currentAST;
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
		currentAST = __currentAST47;
		_t = __t47;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 736 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DECIMAL) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2133 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t48 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp68_AST = astFactory->create(_t);
		tmp68_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp68_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST48 = currentAST;
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
		currentAST = __currentAST48;
		_t = __t48;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 740 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_BOOLEAN) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2164 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t49 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp69_AST = astFactory->create(_t);
		tmp69_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp69_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST49 = currentAST;
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
		currentAST = __currentAST49;
		_t = __t49;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 744 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_STRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
		
				
#line 2196 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t50 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp70_AST = astFactory->create(_t);
		tmp70_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp70_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST50 = currentAST;
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
		currentAST = __currentAST50;
		_t = __t50;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 749 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_WSTRING) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2227 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t51 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp71_AST = astFactory->create(_t);
		tmp71_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp71_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST51 = currentAST;
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
		currentAST = __currentAST51;
		_t = __t51;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 753 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_DATETIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2258 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t52 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp72_AST = astFactory->create(_t);
		tmp72_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp72_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST52 = currentAST;
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
		currentAST = __currentAST52;
		_t = __t52;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 757 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_TIME) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2289 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t53 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp73_AST = astFactory->create(_t);
		tmp73_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp73_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST53 = currentAST;
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
		currentAST = __currentAST53;
		_t = __t53;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 761 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_ENUM) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2320 "MTSQLOracleTreeParser.cpp"
		setStatement_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t54 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp74_AST = astFactory->create(_t);
		tmp74_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp74_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST54 = currentAST;
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
		currentAST = __currentAST54;
		_t = __t54;
		_t = _t->getNextSibling();
		setStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 765 "expandedmtsql_tree_oracle.g"
		
					if ((e != TYPE_NULL && r != e)  || r != TYPE_BINARY) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)setStatement_AST); 
				
#line 2351 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::printStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 771 "expandedmtsql_tree_oracle.g"
	
		int e = TYPE_INVALID;
	
#line 2373 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t56 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp75_AST = astFactory->create(_t);
	tmp75_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp75_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST56 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST56;
	_t = __t56;
	_t = _t->getNextSibling();
	printStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 775 "expandedmtsql_tree_oracle.g"
	
		  if (e != TYPE_STRING && e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)printStatement_AST);
	printStatement_AST->setType(e==TYPE_STRING ? STRING_PRINT : WSTRING_PRINT);
	
#line 2398 "MTSQLOracleTreeParser.cpp"
	printStatement_AST = currentAST.root;
	returnAST = printStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 782 "expandedmtsql_tree_oracle.g"
	
		int e = TYPE_INVALID;
	
#line 2413 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t58 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp76_AST = astFactory->create(_t);
	tmp76_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp76_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST58 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,STRING_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST58;
	_t = __t58;
	_t = _t->getNextSibling();
	stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 786 "expandedmtsql_tree_oracle.g"
	
		  if (e != TYPE_STRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)stringPrintStatement_AST);
	
#line 2437 "MTSQLOracleTreeParser.cpp"
	stringPrintStatement_AST = currentAST.root;
	returnAST = stringPrintStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 792 "expandedmtsql_tree_oracle.g"
	
		int e = TYPE_INVALID;
	
#line 2452 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t60 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp77_AST = astFactory->create(_t);
	tmp77_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp77_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST60 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WSTRING_PRINT);
	_t = _t->getFirstChild();
	e=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST60;
	_t = __t60;
	_t = _t->getNextSibling();
	wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 796 "expandedmtsql_tree_oracle.g"
	
		  if (e != TYPE_WSTRING) throw MTSQLSemanticException("PRINT requires string argument", (RefMTSQLAST)wstringPrintStatement_AST);
	
#line 2476 "MTSQLOracleTreeParser.cpp"
	wstringPrintStatement_AST = currentAST.root;
	returnAST = wstringPrintStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t62 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp78_AST = astFactory->create(_t);
	tmp78_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp78_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST62 = currentAST;
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
	currentAST = __currentAST62;
	_t = __t62;
	_t = _t->getNextSibling();
	seq_AST = currentAST.root;
	returnAST = seq_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t195 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp79_AST = astFactory->create(_t);
	tmp79_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp79_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST195 = currentAST;
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
	currentAST = __currentAST195;
	_t = __t195;
	_t = _t->getNextSibling();
	mtsql_selectStatement_AST = currentAST.root;
	returnAST = mtsql_selectStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 819 "expandedmtsql_tree_oracle.g"
	
		int e = TYPE_INVALID;
	
#line 2556 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t65 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp80_AST = astFactory->create(_t);
	tmp80_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp80_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST65 = currentAST;
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
	currentAST = __currentAST65;
	_t = __t65;
	_t = _t->getNextSibling();
	ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 823 "expandedmtsql_tree_oracle.g"
	
				if (e != TYPE_BOOLEAN) throw MTSQLSemanticException("IF expression must be BOOLEAN type", (RefMTSQLAST)ifStatement_AST); 
			
#line 2604 "MTSQLOracleTreeParser.cpp"
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t68 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp81_AST = astFactory->create(_t);
	tmp81_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp81_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST68 = currentAST;
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
			goto _loop70;
		}
		
	}
	_loop70:;
	} // ( ... )*
	currentAST = __currentAST68;
	_t = __t68;
	_t = _t->getNextSibling();
	listOfStatements_AST = currentAST.root;
	returnAST = listOfStatements_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 837 "expandedmtsql_tree_oracle.g"
	
	int ty;
	bool hasValue = false;
	
#line 2663 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t74 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp82_AST = astFactory->create(_t);
	tmp82_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST74 = currentAST;
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
#line 843 "expandedmtsql_tree_oracle.g"
		
		if (!canImplicitCast(ty,mReturnType)) throw MTSQLSemanticException("RETURN type mismatch", (RefMTSQLAST)returnStatement_AST); 
		if (ty != mReturnType)
		e_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(mReturnType)))->add(e_AST))))));
		
		hasValue = true;
		
#line 2694 "MTSQLOracleTreeParser.cpp"
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
	currentAST = __currentAST74;
	_t = __t74;
	_t = _t->getNextSibling();
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 851 "expandedmtsql_tree_oracle.g"
	
	if(hasValue)
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(tmp82_AST))->add(e_AST)));
	else
	returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(tmp82_AST))));
	
#line 2725 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp83_AST = astFactory->create(_t);
	tmp83_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp83_AST);
	match(_t,TK_BREAK);
	_t = _t->getNextSibling();
	breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 861 "expandedmtsql_tree_oracle.g"
	
		  // Verify that we are inside a while statement
		  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("BREAK can only appear in WHILE loop", (RefMTSQLAST)breakStatement_AST);
		
#line 2756 "MTSQLOracleTreeParser.cpp"
	breakStatement_AST = currentAST.root;
	returnAST = breakStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp84_AST = astFactory->create(_t);
	tmp84_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp84_AST);
	match(_t,TK_CONTINUE);
	_t = _t->getNextSibling();
	continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 869 "expandedmtsql_tree_oracle.g"
	
		  // Verify that we are inside a while statement
		  if (!mWhileContext.isAnalyzingWhile()) throw MTSQLSemanticException("CONTINUE can only appear in WHILE loop", (RefMTSQLAST)continueStatement_AST);
		
#line 2781 "MTSQLOracleTreeParser.cpp"
	continueStatement_AST = currentAST.root;
	returnAST = continueStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 876 "expandedmtsql_tree_oracle.g"
	
	int ty;
	
#line 2796 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t79 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp85_AST = astFactory->create(_t);
	tmp85_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp85_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST79 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WHILE);
	_t = _t->getFirstChild();
#line 880 "expandedmtsql_tree_oracle.g"
	
			mWhileContext.pushAnalyzingWhile(); 
		
#line 2813 "MTSQLOracleTreeParser.cpp"
	ty=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	delayedStatement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST79;
	_t = __t79;
	_t = _t->getNextSibling();
	whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 885 "expandedmtsql_tree_oracle.g"
	
		  mWhileContext.popAnalyzingWhile(); 
		  if (ty != TYPE_BOOLEAN) throw MTSQLSemanticException("WHILE expression must be BOOLEAN", (RefMTSQLAST)whileStatement_AST);
		
#line 2829 "MTSQLOracleTreeParser.cpp"
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserror1Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror1Statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror1Statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 892 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	
#line 2844 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t81 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp86_AST = astFactory->create(_t);
	tmp86_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp86_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST81 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR1);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror1Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 897 "expandedmtsql_tree_oracle.g"
	
			  if(ty1 != TYPE_INTEGER && ty1 != TYPE_STRING && ty1 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes integer or string argument", (RefMTSQLAST)raiserror1Statement_AST); 
	raiserror1Statement_AST->setType(ty1 == TYPE_INTEGER ? RAISERRORINTEGER : ty1==TYPE_STRING ? RAISERRORSTRING : RAISERRORWSTRING);
	
#line 2867 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST81;
	_t = __t81;
	_t = _t->getNextSibling();
	raiserror1Statement_AST = currentAST.root;
	returnAST = raiserror1Statement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 906 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	
#line 2885 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t83 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp87_AST = astFactory->create(_t);
	tmp87_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp87_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST83 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORINTEGER);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 911 "expandedmtsql_tree_oracle.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserrorIntegerStatement_AST); 
	
#line 2907 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST83;
	_t = __t83;
	_t = _t->getNextSibling();
	raiserrorIntegerStatement_AST = currentAST.root;
	returnAST = raiserrorIntegerStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 919 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	
#line 2925 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t85 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp88_AST = astFactory->create(_t);
	tmp88_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp88_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST85 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 924 "expandedmtsql_tree_oracle.g"
	
				if(ty1 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserrorStringStatement_AST); 
	
#line 2947 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST85;
	_t = __t85;
	_t = _t->getNextSibling();
	raiserrorStringStatement_AST = currentAST.root;
	returnAST = raiserrorStringStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 932 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	
#line 2965 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t87 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp89_AST = astFactory->create(_t);
	tmp89_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp89_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST87 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORWSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 937 "expandedmtsql_tree_oracle.g"
	
				if(ty1 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserrorWStringStatement_AST); 
	
#line 2987 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST87;
	_t = __t87;
	_t = _t->getNextSibling();
	raiserrorWStringStatement_AST = currentAST.root;
	returnAST = raiserrorWStringStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserror2Statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2Statement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 945 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	int ty2;
	
#line 3006 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t89 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp90_AST = astFactory->create(_t);
	tmp90_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp90_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST89 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 951 "expandedmtsql_tree_oracle.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2Statement_AST); 
	
#line 3028 "MTSQLOracleTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 956 "expandedmtsql_tree_oracle.g"
	
	if(ty2 != TYPE_WSTRING && ty2 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2Statement_AST);
	
#line 3038 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST89;
	_t = __t89;
	_t = _t->getNextSibling();
	raiserror2Statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 961 "expandedmtsql_tree_oracle.g"
	
	((RefMTSQLAST)raiserror2Statement_AST)->setType(ty2==TYPE_STRING ? RAISERROR2STRING : RAISERROR2WSTRING);
	
#line 3047 "MTSQLOracleTreeParser.cpp"
	raiserror2Statement_AST = currentAST.root;
	returnAST = raiserror2Statement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 967 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	int ty2;
	
#line 3063 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp91_AST = astFactory->create(_t);
	tmp91_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp91_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST91 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2STRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 973 "expandedmtsql_tree_oracle.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2StringStatement_AST); 
	
#line 3085 "MTSQLOracleTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 978 "expandedmtsql_tree_oracle.g"
	
	if(ty2 != TYPE_STRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2StringStatement_AST);
	
#line 3095 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST91;
	_t = __t91;
	_t = _t->getNextSibling();
	raiserror2StringStatement_AST = currentAST.root;
	returnAST = raiserror2StringStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 986 "expandedmtsql_tree_oracle.g"
	
	int ty1;
	int ty2;
	
#line 3114 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp92_AST = astFactory->create(_t);
	tmp92_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp92_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERROR2WSTRING);
	_t = _t->getFirstChild();
	ty1=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 992 "expandedmtsql_tree_oracle.g"
	
	if(ty1 != TYPE_INTEGER) 
	throw MTSQLSemanticException("RAISERROR takes integer argument", (RefMTSQLAST)raiserror2WStringStatement_AST); 
	
#line 3136 "MTSQLOracleTreeParser.cpp"
	ty2=expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 997 "expandedmtsql_tree_oracle.g"
	
	if(ty2 != TYPE_WSTRING) 
	throw MTSQLSemanticException("RAISERROR takes string argument", (RefMTSQLAST)raiserror2WStringStatement_AST);
	
#line 3146 "MTSQLOracleTreeParser.cpp"
	currentAST = __currentAST93;
	_t = __t93;
	_t = _t->getNextSibling();
	raiserror2WStringStatement_AST = currentAST.root;
	returnAST = raiserror2WStringStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::genericSetStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 702 "expandedmtsql_tree_oracle.g"
	
	int r=TYPE_INVALID;
	int e=TYPE_INVALID;
	
#line 3171 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t42 = _t;
	a = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST a_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	a_AST = astFactory->create(a);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST42 = currentAST;
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
	currentAST = __currentAST42;
	_t = __t42;
	_t = _t->getNextSibling();
	genericSetStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 708 "expandedmtsql_tree_oracle.g"
	
		  if (e != TYPE_NULL && !canImplicitCast(e, r)) throw MTSQLSemanticException("Type mismatch in SET", (RefMTSQLAST)a_AST);
	if (e != TYPE_NULL && e != r)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(right_AST))))));
	
	genericSetStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getAssignmentToken(r)))->add(left_AST)->add(right_AST)));
		
#line 3202 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::varLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 806 "expandedmtsql_tree_oracle.g"
	int r;
#line 3217 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST varLValue_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST varLValue_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 806 "expandedmtsql_tree_oracle.g"
	
	r = TYPE_INVALID;
	
#line 3228 "MTSQLOracleTreeParser.cpp"
	
	lv = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	lv_AST = astFactory->create(lv);
	astFactory->addASTChild(currentAST, lv_AST);
	match(_t,LOCALVAR);
	_t = _t->getNextSibling();
	varLValue_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 810 "expandedmtsql_tree_oracle.g"
	
		  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
		  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)varLValue_AST); 
		  r = var->getType(); 
		  ((RefMTSQLAST)varLValue_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 3244 "MTSQLOracleTreeParser.cpp"
	varLValue_AST = currentAST.root;
	returnAST = varLValue_AST;
	_retTree = _t;
	return r;
}

int  MTSQLOracleTreeParser::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1012 "expandedmtsql_tree_oracle.g"
	int r;
#line 3254 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1012 "expandedmtsql_tree_oracle.g"
	
	r = TYPE_INVALID;
	
#line 3263 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp93_AST = astFactory->create(_t);
	tmp93_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp93_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST100 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	r=expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST100;
	_t = __t100;
	_t = _t->getNextSibling();
	expression_AST = currentAST.root;
	returnAST = expression_AST;
	_retTree = _t;
	return r;
}

void MTSQLOracleTreeParser::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t72 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp94_AST = astFactory->create(_t);
	tmp94_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp94_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST72 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DELAYED_STMT);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST72;
	_t = __t72;
	_t = _t->getNextSibling();
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
	_retTree = _t;
}

std::vector<int>  MTSQLOracleTreeParser::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1005 "expandedmtsql_tree_oracle.g"
	std::vector<int> v;
#line 3319 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1005 "expandedmtsql_tree_oracle.g"
	
		int ty;
	
#line 3328 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp95_AST = astFactory->create(_t);
	tmp95_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp95_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST95 = currentAST;
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
#line 1008 "expandedmtsql_tree_oracle.g"
		v.push_back(ty);
#line 3352 "MTSQLOracleTreeParser.cpp"
		{ // ( ... )*
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp96_AST = astFactory->create(_t);
				tmp96_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp96_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				ty=expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 1008 "expandedmtsql_tree_oracle.g"
				v.push_back(ty);
#line 3370 "MTSQLOracleTreeParser.cpp"
			}
			else {
				goto _loop98;
			}
			
		}
		_loop98:;
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
	currentAST = __currentAST95;
	_t = __t95;
	_t = _t->getNextSibling();
	elist_AST = currentAST.root;
	returnAST = elist_AST;
	_retTree = _t;
	return v;
}

int  MTSQLOracleTreeParser::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1019 "expandedmtsql_tree_oracle.g"
	int r;
#line 3403 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST cast = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST cast_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1019 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID, e=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 3417 "MTSQLOracleTreeParser.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t102 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp97_AST = astFactory->create(_t);
		tmp97_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp97_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST102 = currentAST;
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
		currentAST = __currentAST102;
		_t = __t102;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1024 "expandedmtsql_tree_oracle.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 3447 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t103 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp98_AST = astFactory->create(_t);
		tmp98_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp98_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST103 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST103;
		_t = __t103;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1025 "expandedmtsql_tree_oracle.g"
		r = checkUnaryIntegerOperator(lhs, (RefMTSQLAST)expr_AST);
#line 3473 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t104 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp99_AST = astFactory->create(_t);
		tmp99_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp99_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST104 = currentAST;
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
		currentAST = __currentAST104;
		_t = __t104;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1026 "expandedmtsql_tree_oracle.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 3502 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t105 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp100_AST = astFactory->create(_t);
		tmp100_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp100_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST105 = currentAST;
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
		currentAST = __currentAST105;
		_t = __t105;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1027 "expandedmtsql_tree_oracle.g"
		r = checkBinaryIntegerOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 3531 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t106 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp101_AST = astFactory->create(_t);
		tmp101_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp101_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST106 = currentAST;
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
		currentAST = __currentAST106;
		_t = __t106;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1029 "expandedmtsql_tree_oracle.g"
		r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 3560 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t107 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp102_AST = astFactory->create(_t);
		tmp102_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp102_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST107 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST107;
		_t = __t107;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1030 "expandedmtsql_tree_oracle.g"
		r = checkUnaryLogicalOperator(lhs, (RefMTSQLAST)expr_AST);
#line 3586 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t108 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp103_AST = astFactory->create(_t);
		tmp103_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp103_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST108 = currentAST;
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
		currentAST = __currentAST108;
		_t = __t108;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1031 "expandedmtsql_tree_oracle.g"
		r = checkBinaryLogicalOperator(lhs, rhs, (RefMTSQLAST)expr_AST);
#line 3615 "MTSQLOracleTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t109 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp104_AST = astFactory->create(_t);
		tmp104_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp104_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST109 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ISNULL);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST109;
		_t = __t109;
		_t = _t->getNextSibling();
#line 1040 "expandedmtsql_tree_oracle.g"
		r = TYPE_BOOLEAN;
#line 3688 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case STRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t110 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp105_AST = astFactory->create(_t);
		tmp105_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp105_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST110 = currentAST;
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
		currentAST = __currentAST110;
		_t = __t110;
		_t = _t->getNextSibling();
#line 1042 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_STRING || rhs != TYPE_STRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_STRING;
#line 3716 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp106_AST = astFactory->create(_t);
		tmp106_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp106_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST111 = currentAST;
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
		currentAST = __currentAST111;
		_t = __t111;
		_t = _t->getNextSibling();
#line 1043 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_WSTRING || rhs != TYPE_WSTRING) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non string argument to internal string operation"); r = TYPE_WSTRING;
#line 3744 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t112 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp107_AST = astFactory->create(_t);
		tmp107_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp107_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST112 = currentAST;
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
		currentAST = __currentAST112;
		_t = __t112;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1045 "expandedmtsql_tree_oracle.g"
		
		if (lhs != TYPE_STRING && lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_STRING && rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		expr_AST->setType(rhs == TYPE_STRING ? STRING_LIKE : WSTRING_LIKE);
		r = TYPE_BOOLEAN;
		
#line 3779 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case STRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t113 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp108_AST = astFactory->create(_t);
		tmp108_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp108_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST113 = currentAST;
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
		currentAST = __currentAST113;
		_t = __t113;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1053 "expandedmtsql_tree_oracle.g"
		
		if (lhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_STRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		r = TYPE_BOOLEAN;
		
#line 3813 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp109_AST = astFactory->create(_t);
		tmp109_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp109_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST114 = currentAST;
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
		currentAST = __currentAST114;
		_t = __t114;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1060 "expandedmtsql_tree_oracle.g"
		
		if (lhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE", (RefMTSQLAST)expr_AST);
		if (rhs != TYPE_WSTRING) throw MTSQLSemanticException("String required for LIKE pattern", (RefMTSQLAST)expr_AST);
		if (lhs != rhs) throw MTSQLSemanticException("String mismatch for LIKE", (RefMTSQLAST)expr_AST);
		r = TYPE_BOOLEAN;
		
#line 3847 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp110_AST = astFactory->create(_t);
		tmp110_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp110_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST115 = currentAST;
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
		currentAST = __currentAST115;
		_t = __t115;
		_t = _t->getNextSibling();
#line 1067 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 3875 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t116 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp111_AST = astFactory->create(_t);
		tmp111_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp111_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST116 = currentAST;
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
		currentAST = __currentAST116;
		_t = __t116;
		_t = _t->getNextSibling();
#line 1068 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 3903 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp112_AST = astFactory->create(_t);
		tmp112_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp112_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST117 = currentAST;
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
		currentAST = __currentAST117;
		_t = __t117;
		_t = _t->getNextSibling();
#line 1069 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 3931 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t118 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp113_AST = astFactory->create(_t);
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp113_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST118 = currentAST;
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
		currentAST = __currentAST118;
		_t = __t118;
		_t = _t->getNextSibling();
#line 1070 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 3959 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp114_AST = astFactory->create(_t);
		tmp114_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp114_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST119 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST119;
		_t = __t119;
		_t = _t->getNextSibling();
#line 1071 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_INTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation"); r = TYPE_INTEGER;
#line 3984 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t120 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp115_AST = astFactory->create(_t);
		tmp115_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp115_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST120 = currentAST;
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
		currentAST = __currentAST120;
		_t = __t120;
		_t = _t->getNextSibling();
#line 1072 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 4012 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp116_AST = astFactory->create(_t);
		tmp116_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp116_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST121 = currentAST;
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
		currentAST = __currentAST121;
		_t = __t121;
		_t = _t->getNextSibling();
#line 1073 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 4040 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t122 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp117_AST = astFactory->create(_t);
		tmp117_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp117_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST122 = currentAST;
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
		currentAST = __currentAST122;
		_t = __t122;
		_t = _t->getNextSibling();
#line 1074 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 4068 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp118_AST = astFactory->create(_t);
		tmp118_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp118_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST123 = currentAST;
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
		currentAST = __currentAST123;
		_t = __t123;
		_t = _t->getNextSibling();
#line 1075 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 4096 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t124 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp119_AST = astFactory->create(_t);
		tmp119_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp119_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST124 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST124;
		_t = __t124;
		_t = _t->getNextSibling();
#line 1076 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_BIGINTEGER) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non bigint argument to bigint operation"); r = TYPE_BIGINTEGER;
#line 4121 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp120_AST = astFactory->create(_t);
		tmp120_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp120_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST125 = currentAST;
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
		currentAST = __currentAST125;
		_t = __t125;
		_t = _t->getNextSibling();
#line 1077 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 4149 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t126 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp121_AST = astFactory->create(_t);
		tmp121_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp121_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST126 = currentAST;
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
		currentAST = __currentAST126;
		_t = __t126;
		_t = _t->getNextSibling();
#line 1078 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 4177 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp122_AST = astFactory->create(_t);
		tmp122_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp122_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST127 = currentAST;
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
		currentAST = __currentAST127;
		_t = __t127;
		_t = _t->getNextSibling();
#line 1079 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 4205 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t128 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp123_AST = astFactory->create(_t);
		tmp123_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp123_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST128 = currentAST;
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
		currentAST = __currentAST128;
		_t = __t128;
		_t = _t->getNextSibling();
#line 1080 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DOUBLE || rhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 4233 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t129 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp124_AST = astFactory->create(_t);
		tmp124_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp124_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST129 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST129;
		_t = __t129;
		_t = _t->getNextSibling();
#line 1081 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DOUBLE) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non double argument to double operation"); r = TYPE_DOUBLE;
#line 4258 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t130 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp125_AST = astFactory->create(_t);
		tmp125_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp125_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST130 = currentAST;
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
		currentAST = __currentAST130;
		_t = __t130;
		_t = _t->getNextSibling();
#line 1082 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 4286 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t131 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp126_AST = astFactory->create(_t);
		tmp126_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp126_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST131 = currentAST;
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
		currentAST = __currentAST131;
		_t = __t131;
		_t = _t->getNextSibling();
#line 1083 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 4314 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t132 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp127_AST = astFactory->create(_t);
		tmp127_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp127_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST132 = currentAST;
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
		currentAST = __currentAST132;
		_t = __t132;
		_t = _t->getNextSibling();
#line 1085 "expandedmtsql_tree_oracle.g"
		
			  if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) 
			  {
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); 
			  }
			  r = TYPE_DECIMAL; 
			
#line 4348 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp128_AST = astFactory->create(_t);
		tmp128_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp128_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST133 = currentAST;
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
		currentAST = __currentAST133;
		_t = __t133;
		_t = _t->getNextSibling();
#line 1092 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DECIMAL || rhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 4376 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t134 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp129_AST = astFactory->create(_t);
		tmp129_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp129_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST134 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_UNARY_MINUS);
		_t = _t->getFirstChild();
		lhs=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST134;
		_t = __t134;
		_t = _t->getNextSibling();
#line 1093 "expandedmtsql_tree_oracle.g"
		if(lhs != TYPE_DECIMAL) throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non decimal argument to decimal operation"); r = TYPE_DECIMAL;
#line 4401 "MTSQLOracleTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp130_AST = astFactory->create(_t);
		tmp130_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp130_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST135 = currentAST;
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
		currentAST = __currentAST135;
		_t = __t135;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1097 "expandedmtsql_tree_oracle.g"
		
			  if (!(lhs == TYPE_INTEGER && rhs == TYPE_INTEGER) &&
		!(lhs == TYPE_BIGINTEGER && rhs == TYPE_BIGINTEGER))
		{
				throw MTSQLSemanticException("Non integer argument to %", (RefMTSQLAST)expr_AST);
			  }
			  r = lhs; 
		expr_AST->setType(r == TYPE_INTEGER ? INTEGER_MODULUS : BIGINT_MODULUS);
			
#line 4446 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t136 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp131_AST = astFactory->create(_t);
		tmp131_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp131_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST136 = currentAST;
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
		currentAST = __currentAST136;
		_t = __t136;
		_t = _t->getNextSibling();
#line 1107 "expandedmtsql_tree_oracle.g"
		
			  if (lhs != TYPE_INTEGER || rhs != TYPE_INTEGER) 
		{
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
			  }
			  r = TYPE_INTEGER; 
			
#line 4480 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t137 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp132_AST = astFactory->create(_t);
		tmp132_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp132_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST137 = currentAST;
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
		currentAST = __currentAST137;
		_t = __t137;
		_t = _t->getNextSibling();
#line 1115 "expandedmtsql_tree_oracle.g"
		
			  if (lhs != TYPE_BIGINTEGER || rhs != TYPE_BIGINTEGER) 
		{
				throw MTSQLInternalErrorException(__FILE__, __LINE__, "Non integer argument to integer operation");
			  }
			  r = TYPE_BIGINTEGER; 
			
#line 4514 "MTSQLOracleTreeParser.cpp"
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t138 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp133_AST = astFactory->create(_t);
		tmp133_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp133_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST138 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
		e=expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST138;
		_t = __t138;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1126 "expandedmtsql_tree_oracle.g"
		
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
			
#line 4578 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case ESEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp134_AST = astFactory->create(_t);
		tmp134_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp134_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST139 = currentAST;
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
		currentAST = __currentAST139;
		_t = __t139;
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
#line 1146 "expandedmtsql_tree_oracle.g"
		
			  std::vector<int> consTypes;
		
#line 4629 "MTSQLOracleTreeParser.cpp"
		ANTLR_USE_NAMESPACE(antlr)RefAST __t140 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp135_AST = astFactory->create(_t);
		tmp135_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp135_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST140 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFBLOCK);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt142=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == IFEXPR)) {
				rhs=ifThenElse(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 1149 "expandedmtsql_tree_oracle.g"
				consTypes.push_back(rhs);
#line 4652 "MTSQLOracleTreeParser.cpp"
			}
			else {
				if ( _cnt142>=1 ) { goto _loop142; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt142++;
		}
		_loop142:;
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
#line 1149 "expandedmtsql_tree_oracle.g"
			consTypes.push_back(rhs);
#line 4673 "MTSQLOracleTreeParser.cpp"
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
		currentAST = __currentAST140;
		_t = __t140;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1150 "expandedmtsql_tree_oracle.g"
		
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
			
#line 4705 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t144 = _t;
		cast = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST cast_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		cast_AST = astFactory->create(cast);
		astFactory->addASTChild(currentAST, cast_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST144 = currentAST;
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
		currentAST = __currentAST144;
		_t = __t144;
		_t = _t->getNextSibling();
		expr_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1165 "expandedmtsql_tree_oracle.g"
		
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
				
#line 4777 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_STRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp136_AST = astFactory->create(_t);
		tmp136_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp136_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST145 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_STRING);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST145;
		_t = __t145;
		_t = _t->getNextSibling();
#line 1208 "expandedmtsql_tree_oracle.g"
		r = TYPE_STRING;
#line 4802 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_WSTRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t146 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp137_AST = astFactory->create(_t);
		tmp137_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp137_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST146 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_WSTRING);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST146;
		_t = __t146;
		_t = _t->getNextSibling();
#line 1209 "expandedmtsql_tree_oracle.g"
		r = TYPE_WSTRING;
#line 4827 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_INTEGER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t147 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp138_AST = astFactory->create(_t);
		tmp138_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp138_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST147 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_INTEGER);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST147;
		_t = __t147;
		_t = _t->getNextSibling();
#line 1210 "expandedmtsql_tree_oracle.g"
		r = TYPE_INTEGER;
#line 4852 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t148 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp139_AST = astFactory->create(_t);
		tmp139_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp139_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST148 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BIGINT);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST148;
		_t = __t148;
		_t = _t->getNextSibling();
#line 1211 "expandedmtsql_tree_oracle.g"
		r = TYPE_BIGINTEGER;
#line 4877 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t149 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp140_AST = astFactory->create(_t);
		tmp140_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp140_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST149 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DECIMAL);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST149;
		_t = __t149;
		_t = _t->getNextSibling();
#line 1212 "expandedmtsql_tree_oracle.g"
		r = TYPE_DECIMAL;
#line 4902 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DOUBLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t150 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp141_AST = astFactory->create(_t);
		tmp141_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp141_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST150 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DOUBLE);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST150;
		_t = __t150;
		_t = _t->getNextSibling();
#line 1213 "expandedmtsql_tree_oracle.g"
		r = TYPE_DOUBLE;
#line 4927 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BOOLEAN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t151 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp142_AST = astFactory->create(_t);
		tmp142_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp142_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST151 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BOOLEAN);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST151;
		_t = __t151;
		_t = _t->getNextSibling();
#line 1214 "expandedmtsql_tree_oracle.g"
		r = TYPE_BOOLEAN;
#line 4952 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DATETIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t152 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp143_AST = astFactory->create(_t);
		tmp143_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp143_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST152 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DATETIME);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST152;
		_t = __t152;
		_t = _t->getNextSibling();
#line 1215 "expandedmtsql_tree_oracle.g"
		r = TYPE_DATETIME;
#line 4977 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_TIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t153 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp144_AST = astFactory->create(_t);
		tmp144_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp144_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST153 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_TIME);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST153;
		_t = __t153;
		_t = _t->getNextSibling();
#line 1216 "expandedmtsql_tree_oracle.g"
		r = TYPE_TIME;
#line 5002 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_ENUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t154 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp145_AST = astFactory->create(_t);
		tmp145_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp145_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST154 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_ENUM);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST154;
		_t = __t154;
		_t = _t->getNextSibling();
#line 1217 "expandedmtsql_tree_oracle.g"
		r = TYPE_ENUM;
#line 5027 "MTSQLOracleTreeParser.cpp"
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BINARY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t155 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp146_AST = astFactory->create(_t);
		tmp146_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp146_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST155 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BINARY);
		_t = _t->getFirstChild();
		lhs=expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST155;
		_t = __t155;
		_t = _t->getNextSibling();
#line 1218 "expandedmtsql_tree_oracle.g"
		r = TYPE_BINARY;
#line 5052 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::equalsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1223 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5102 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST equalsExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1223 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5118 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t157 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp147_AST = astFactory->create(_t);
	tmp147_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST157 = currentAST;
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
	currentAST = __currentAST157;
	_t = __t157;
	_t = _t->getNextSibling();
	equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1231 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)equalsExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	equalsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp147_AST))->add(left_AST)->add(right_AST)));
	
#line 5151 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::gtExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1242 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5167 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST gtExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1242 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5183 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t159 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp148_AST = astFactory->create(_t);
	tmp148_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST159 = currentAST;
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
	currentAST = __currentAST159;
	_t = __t159;
	_t = _t->getNextSibling();
	gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1250 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)gtExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	gtExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp148_AST))->add(left_AST)->add(right_AST)));
	
#line 5216 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::gteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1261 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5232 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST gteqExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1261 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5248 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t161 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp149_AST = astFactory->create(_t);
	tmp149_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST161 = currentAST;
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
	currentAST = __currentAST161;
	_t = __t161;
	_t = _t->getNextSibling();
	gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1269 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)gteqExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	gteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp149_AST))->add(left_AST)->add(right_AST)));
	
#line 5281 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::ltExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1280 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5297 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST ltExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1280 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5313 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t163 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp150_AST = astFactory->create(_t);
	tmp150_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST163 = currentAST;
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
	currentAST = __currentAST163;
	_t = __t163;
	_t = _t->getNextSibling();
	ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1288 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)ltExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	ltExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp150_AST))->add(left_AST)->add(right_AST)));
	
#line 5346 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::lteqExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1299 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5362 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST lteqExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1299 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5378 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t165 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp151_AST = astFactory->create(_t);
	tmp151_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST165 = currentAST;
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
	currentAST = __currentAST165;
	_t = __t165;
	_t = _t->getNextSibling();
	lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1307 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)lteqExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	lteqExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp151_AST))->add(left_AST)->add(right_AST)));
	
#line 5411 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::notEqualsExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1318 "expandedmtsql_tree_oracle.g"
	int ty;
#line 5427 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST notEqualsExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1318 "expandedmtsql_tree_oracle.g"
	
	ty = TYPE_BOOLEAN;
	int r = TYPE_INVALID;
	int lhs = TYPE_INVALID;
	int rhs = TYPE_INVALID;
	
#line 5443 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t167 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp152_AST = astFactory->create(_t);
	tmp152_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST167 = currentAST;
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
	currentAST = __currentAST167;
	_t = __t167;
	_t = _t->getNextSibling();
	notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1326 "expandedmtsql_tree_oracle.g"
	
	r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)notEqualsExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	notEqualsExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(tmp152_AST))->add(left_AST)->add(right_AST)));
	
#line 5476 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::minusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1357 "expandedmtsql_tree_oracle.g"
	int r;
#line 5492 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST minusExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1357 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 5506 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t171 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp153_AST = astFactory->create(_t);
	tmp153_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST171 = currentAST;
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
	currentAST = __currentAST171;
	_t = __t171;
	_t = _t->getNextSibling();
	minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1363 "expandedmtsql_tree_oracle.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)minusExpression_AST); 
		  checkAdditiveType(lhs, (RefMTSQLAST)minusExpression_AST); 
		  checkAdditiveType(rhs, (RefMTSQLAST)minusExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	minusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getMinus(r)))->add(left_AST)->add(right_AST)));
	
#line 5542 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::divideExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1397 "expandedmtsql_tree_oracle.g"
	int r;
#line 5558 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST divideExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1397 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 5572 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t175 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp154_AST = astFactory->create(_t);
	tmp154_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST175 = currentAST;
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
	currentAST = __currentAST175;
	_t = __t175;
	_t = _t->getNextSibling();
	divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1403 "expandedmtsql_tree_oracle.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)divideExpression_AST); 
		  checkMultiplicativeType(lhs, (RefMTSQLAST)divideExpression_AST); 
		  checkMultiplicativeType(rhs, (RefMTSQLAST)divideExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	divideExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getDivide(r)))->add(left_AST)->add(right_AST)));
	
#line 5608 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::plusExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1337 "expandedmtsql_tree_oracle.g"
	int r;
#line 5624 "MTSQLOracleTreeParser.cpp"
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
#line 1337 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 5640 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
	p = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST p_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	p_AST = astFactory->create(p);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST169 = currentAST;
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
	currentAST = __currentAST169;
	_t = __t169;
	_t = _t->getNextSibling();
	plusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1343 "expandedmtsql_tree_oracle.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)p_AST); 
		  checkAdditiveTypeWithString(lhs, (RefMTSQLAST)p_AST); 
		  checkAdditiveTypeWithString(rhs, (RefMTSQLAST)p_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	plusExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getPlus(r)))->add(left_AST)->add(right_AST)));
	
#line 5675 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::timesExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1377 "expandedmtsql_tree_oracle.g"
	int r;
#line 5691 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST timesExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST left = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST right = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1377 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r=TYPE_INVALID;
	
#line 5705 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t173 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp155_AST = astFactory->create(_t);
	tmp155_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST173 = currentAST;
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
	currentAST = __currentAST173;
	_t = __t173;
	_t = _t->getNextSibling();
	timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1383 "expandedmtsql_tree_oracle.g"
	
		  r = checkBinaryOperator(lhs, rhs, (RefMTSQLAST)timesExpression_AST); 
		  checkMultiplicativeType(lhs, (RefMTSQLAST)timesExpression_AST); 
		  checkMultiplicativeType(rhs, (RefMTSQLAST)timesExpression_AST); 
	if (lhs != TYPE_NULL && r != lhs)
	left_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(left_AST))))));
	if (rhs != TYPE_NULL && r != rhs)
	right_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(getCastTo(r)))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR))->add(right_AST))))));
	
	timesExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(getTimes(r)))->add(left_AST)->add(right_AST)));
	
#line 5741 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::searchedCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1417 "expandedmtsql_tree_oracle.g"
	int r;
#line 5757 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST searchedCaseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST searchedCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST search = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wk_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wk = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1417 "expandedmtsql_tree_oracle.g"
	
	std::vector<int> condTypes;
	std::vector<int> consTypes;
	std::vector<int> typePair;
	std::string tmp = mTempGen.getNextTemp();
	int rhs=TYPE_INVALID;
	int e = TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 5776 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t177 = _t;
	search = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	search_AST = astFactory->create(search);
	astFactory->addASTChild(currentAST, search_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST177 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SEARCHED_CASE);
	_t = _t->getFirstChild();
#line 1428 "expandedmtsql_tree_oracle.g"
	
			// We are converting the searched case into a simple case
			// We are doing this in the semantic analysis since we need to
			// know the type of the search expression in order to declare a
			// local temporary variable to store the search value
			search_AST->setType(IFBLOCK); 
		
#line 5796 "MTSQLOracleTreeParser.cpp"
	wk = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	e=expr(_t);
	_t = _retTree;
	wk_AST = returnAST;
	{ // ( ... )+
	int _cnt179=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TK_WHEN)) {
			typePair=whenExpression(_t,tmp);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
#line 1436 "expandedmtsql_tree_oracle.g"
			condTypes.push_back(typePair[0]); consTypes.push_back(typePair[1]);
#line 5812 "MTSQLOracleTreeParser.cpp"
		}
		else {
			if ( _cnt179>=1 ) { goto _loop179; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt179++;
	}
	_loop179:;
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
#line 1437 "expandedmtsql_tree_oracle.g"
		consTypes.push_back(rhs);
#line 5833 "MTSQLOracleTreeParser.cpp"
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
	currentAST = __currentAST177;
	_t = __t177;
	_t = _t->getNextSibling();
	searchedCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1439 "expandedmtsql_tree_oracle.g"
	
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
		
#line 5879 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::simpleCaseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1470 "expandedmtsql_tree_oracle.g"
	int r;
#line 5896 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleCaseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simpleCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1470 "expandedmtsql_tree_oracle.g"
	
	std::vector<int> consTypes;
	bool simpleCaseHasElse = false;
	int rhs = TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 5910 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t182 = _t;
	simple = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	simple_AST = astFactory->create(simple);
	astFactory->addASTChild(currentAST, simple_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST182 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_CASE);
	_t = _t->getFirstChild();
#line 1478 "expandedmtsql_tree_oracle.g"
	
		  simple_AST->setType(IFBLOCK);
	
#line 5926 "MTSQLOracleTreeParser.cpp"
	{ // ( ... )+
	int _cnt184=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == SIMPLE_WHEN)) {
			rhs=simpleWhenExpression(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
#line 1481 "expandedmtsql_tree_oracle.g"
			consTypes.push_back(rhs);
#line 5938 "MTSQLOracleTreeParser.cpp"
		}
		else {
			if ( _cnt184>=1 ) { goto _loop184; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt184++;
	}
	_loop184:;
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
#line 1482 "expandedmtsql_tree_oracle.g"
		consTypes.push_back(rhs);
#line 5959 "MTSQLOracleTreeParser.cpp"
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
	currentAST = __currentAST182;
	_t = __t182;
	_t = _t->getNextSibling();
	simpleCaseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1484 "expandedmtsql_tree_oracle.g"
	
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
		
#line 6000 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1510 "expandedmtsql_tree_oracle.g"
	int r;
#line 6017 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1510 "expandedmtsql_tree_oracle.g"
	
	r = TYPE_INVALID;
	int condTy=TYPE_INVALID;
	
#line 6027 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t187 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp156_AST = astFactory->create(_t);
	tmp156_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp156_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST187 = currentAST;
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
	currentAST = __currentAST187;
	_t = __t187;
	_t = _t->getNextSibling();
	ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1515 "expandedmtsql_tree_oracle.g"
	
		  if (condTy != TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)ifThenElse_AST);
		
#line 6054 "MTSQLOracleTreeParser.cpp"
	ifThenElse_AST = currentAST.root;
	returnAST = ifThenElse_AST;
	_retTree = _t;
	return r;
}

int  MTSQLOracleTreeParser::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1551 "expandedmtsql_tree_oracle.g"
	int r;
#line 6064 "MTSQLOracleTreeParser.cpp"
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
#line 1551 "expandedmtsql_tree_oracle.g"
	
	r = TYPE_INVALID;
	std::vector<int> v;
	
#line 6102 "MTSQLOracleTreeParser.cpp"
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp157_AST = astFactory->create(_t);
		tmp157_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp157_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
#line 1556 "expandedmtsql_tree_oracle.g"
		
					// ID's are only used for function names;  I suppose we could add a function (or function pointer type)
					// but it isn't really necessary since we are only allowing ID's in method calls
					r = TYPE_INVALID; 
				
#line 6122 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp158_AST = astFactory->create(_t);
		tmp158_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp158_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1562 "expandedmtsql_tree_oracle.g"
		
					long lVal=0;
					sscanf(primaryExpression_AST->getText().c_str(), primaryExpression_AST->getText().size() > 2 && primaryExpression_AST->getText()[1] == 'x' ? "%x" : "%d", &lVal);
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createLong(lVal)); 
			  		r = TYPE_INTEGER;
				
#line 6143 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp159_AST = astFactory->create(_t);
		tmp159_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp159_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1569 "expandedmtsql_tree_oracle.g"
		
					boost::int64_t lVal=0;
		std::stringstream sstr(primaryExpression_AST->getText().c_str());
		if (primaryExpression_AST->getText().size() > 2 && primaryExpression_AST->getText()[1] == 'x')
		{
			                  sstr >> std::hex;
		}
		sstr >> lVal;
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createLongLong(lVal)); 
			  		r = TYPE_BIGINTEGER;
				
#line 6169 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp160_AST = astFactory->create(_t);
		tmp160_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp160_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1581 "expandedmtsql_tree_oracle.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(primaryExpression_AST->getText().c_str()).castToDouble()); 
			  r = TYPE_DOUBLE; 
			
#line 6188 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp161_AST = astFactory->create(_t);
		tmp161_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp161_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1586 "expandedmtsql_tree_oracle.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(primaryExpression_AST->getText().c_str()).castToDec()); 
			  r = TYPE_DECIMAL; 
			
#line 6207 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp162_AST = astFactory->create(_t);
		tmp162_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp162_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1591 "expandedmtsql_tree_oracle.g"
		
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
			
#line 6235 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp163_AST = astFactory->create(_t);
		tmp163_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp163_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1605 "expandedmtsql_tree_oracle.g"
		
		// This UTF-8 unencodes
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createWString((primaryExpression_AST->getText()))); 
			  r = TYPE_WSTRING; 
			
#line 6255 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp164_AST = astFactory->create(_t);
		tmp164_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp164_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1611 "expandedmtsql_tree_oracle.g"
		
		// Create an enum from the string
		RuntimeValue strValue=RuntimeValue::createString((primaryExpression_AST->getText().c_str()));
		RuntimeValue enumValue;
		RuntimeValueCast::ToEnum(&enumValue, &strValue, getNameID());
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(enumValue); 
			  r = TYPE_ENUM; 
			
#line 6278 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp165_AST = astFactory->create(_t);
		tmp165_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp165_AST);
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1620 "expandedmtsql_tree_oracle.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createBool(true)); 
			  r = TYPE_BOOLEAN; 
			
#line 6297 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp166_AST = astFactory->create(_t);
		tmp166_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp166_AST);
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1625 "expandedmtsql_tree_oracle.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createBool(false)); 
			  r = TYPE_BOOLEAN; 
			
#line 6316 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp167_AST = astFactory->create(_t);
		tmp167_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp167_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1630 "expandedmtsql_tree_oracle.g"
		
			  ((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createNull()); 
			  r = TYPE_NULL; 
			
#line 6335 "MTSQLOracleTreeParser.cpp"
		primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t193 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp168_AST = astFactory->create(_t);
		tmp168_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp168_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST193 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp169_AST = astFactory->create(_t);
		tmp169_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp169_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST193;
		_t = __t193;
		_t = _t->getNextSibling();
		primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1635 "expandedmtsql_tree_oracle.g"
		
					FunEntryPtr fe = mEnv->lookupFun(id->getText(), v); 
					if (FunEntryPtr() == fe) 
		{
		throw MTSQLSemanticException("Undefined function: " + id->getText(), (RefMTSQLAST)primaryExpression_AST); 
		}
					r = checkFunctionCall(fe, v, (RefMTSQLAST)primaryExpression_AST); 
					// Save the decorated name as a value
					((RefMTSQLAST)primaryExpression_AST)->setValue(RuntimeValue::createString(fe->getDecoratedName()));
				
#line 6383 "MTSQLOracleTreeParser.cpp"
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
#line 1646 "expandedmtsql_tree_oracle.g"
		
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
			
#line 6445 "MTSQLOracleTreeParser.cpp"
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
#line 1695 "expandedmtsql_tree_oracle.g"
		
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
			
#line 6507 "MTSQLOracleTreeParser.cpp"
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
#line 1744 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(igm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_INTEGER; 
			
#line 6528 "MTSQLOracleTreeParser.cpp"
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
#line 1752 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bigm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BIGINTEGER; 
			
#line 6549 "MTSQLOracleTreeParser.cpp"
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
#line 1760 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BOOLEAN; 
			
#line 6570 "MTSQLOracleTreeParser.cpp"
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
#line 1768 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(dgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DOUBLE; 
			
#line 6591 "MTSQLOracleTreeParser.cpp"
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
#line 1776 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(sgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_STRING; 
			
#line 6612 "MTSQLOracleTreeParser.cpp"
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
#line 1784 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(wsgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_WSTRING; 
			
#line 6633 "MTSQLOracleTreeParser.cpp"
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
#line 1792 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(decgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DECIMAL; 
			
#line 6654 "MTSQLOracleTreeParser.cpp"
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
#line 1800 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(dtgm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_DATETIME; 
			
#line 6675 "MTSQLOracleTreeParser.cpp"
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
#line 1808 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(tm->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_TIME; 
			
#line 6696 "MTSQLOracleTreeParser.cpp"
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
#line 1816 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(en->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_ENUM; 
			
#line 6717 "MTSQLOracleTreeParser.cpp"
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
#line 1824 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(bin->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)primaryExpression_AST); 
			  r = var->getType(); 
			  ((RefMTSQLAST)primaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
			  r = TYPE_BINARY; 
			
#line 6738 "MTSQLOracleTreeParser.cpp"
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

std::vector<int>  MTSQLOracleTreeParser::whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	const std::string& tmp
) {
#line 1521 "expandedmtsql_tree_oracle.g"
	std::vector<int> r;
#line 6765 "MTSQLOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e1 = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST e2 = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 1521 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	
#line 6778 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp170_AST = astFactory->create(_t);
	tmp170_AST_in = _t;
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST189 = currentAST;
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
	currentAST = __currentAST189;
	_t = __t189;
	_t = _t->getNextSibling();
	whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1526 "expandedmtsql_tree_oracle.g"
	
			r.push_back(lhs);
			r.push_back(rhs);
	
		    // Construct the tree
	whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(IFEXPR,"IFEXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(EQUALS,"EQUALS"))->add(astFactory->create(LOCALVAR,tmp))->add(e1_AST)))))))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e2_AST))))));
		
#line 6810 "MTSQLOracleTreeParser.cpp"
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

int  MTSQLOracleTreeParser::simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
#line 1536 "expandedmtsql_tree_oracle.g"
	int r;
#line 6826 "MTSQLOracleTreeParser.cpp"
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
#line 1536 "expandedmtsql_tree_oracle.g"
	
	int lhs=TYPE_INVALID, rhs=TYPE_INVALID;
	r = TYPE_INVALID;
	
#line 6842 "MTSQLOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t191 = _t;
	sw = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST sw_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	sw_AST = astFactory->create(sw);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST191 = currentAST;
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
	currentAST = __currentAST191;
	_t = __t191;
	_t = _t->getNextSibling();
	simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1541 "expandedmtsql_tree_oracle.g"
	
			if(lhs!=TYPE_BOOLEAN) throw MTSQLSemanticException("Non boolean type on CASE condition", (RefMTSQLAST)e1_AST); 
			r = rhs;
	
		    // Construct the tree
		    simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(IFEXPR,"IFEXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e1_AST))))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(e2_AST)))))); 
		
#line 6873 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t197 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp171_AST = astFactory->create(_t);
	tmp171_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp171_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST197 = currentAST;
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
			goto _loop199;
		}
		
	}
	_loop199:;
	} // ( ... )*
	currentAST = __currentAST197;
	_t = __t197;
	_t = _t->getNextSibling();
	mtsql_paramList_AST = currentAST.root;
	returnAST = mtsql_paramList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t202 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp172_AST = astFactory->create(_t);
	tmp172_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp172_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST202 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt204=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= INTEGER_SETMEM_QUERY && _t->getType() <= BINARY_SETMEM_QUERY))) {
			mtsql_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt204>=1 ) { goto _loop204; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt204++;
	}
	_loop204:;
	}  // ( ... )+
	currentAST = __currentAST202;
	_t = __t202;
	_t = _t->getNextSibling();
	mtsql_intoList_AST = currentAST.root;
	returnAST = mtsql_intoList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::mtsql_reference(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_reference_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_reference_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case LOCALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp173_AST = astFactory->create(_t);
		tmp173_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp173_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp174_AST = astFactory->create(_t);
		tmp174_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp174_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp175_AST = astFactory->create(_t);
		tmp175_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp175_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp176_AST = astFactory->create(_t);
		tmp176_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp176_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp177_AST = astFactory->create(_t);
		tmp177_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp177_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp178_AST = astFactory->create(_t);
		tmp178_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp178_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp179_AST = astFactory->create(_t);
		tmp179_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp179_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp180_AST = astFactory->create(_t);
		tmp180_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp180_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp181_AST = astFactory->create(_t);
		tmp181_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp181_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp182_AST = astFactory->create(_t);
		tmp182_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp182_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp183_AST = astFactory->create(_t);
		tmp183_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp183_AST);
		match(_t,ENUM_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = currentAST.root;
		break;
	}
	case BINARY_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp184_AST = astFactory->create(_t);
		tmp184_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp184_AST);
		match(_t,BINARY_GETMEM);
		_t = _t->getNextSibling();
		mtsql_reference_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1855 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(mtsql_reference_AST->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)mtsql_reference_AST); 
			  ((RefMTSQLAST)mtsql_reference_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 7127 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t206 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp185_AST = astFactory->create(_t);
		tmp185_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp185_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST206 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST206;
		_t = __t206;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t207 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp186_AST = astFactory->create(_t);
		tmp186_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp186_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST207 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST207;
		_t = __t207;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t208 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp187_AST = astFactory->create(_t);
		tmp187_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp187_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST208 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST208;
		_t = __t208;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t209 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp188_AST = astFactory->create(_t);
		tmp188_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp188_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST209 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST209;
		_t = __t209;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t210 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp189_AST = astFactory->create(_t);
		tmp189_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp189_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST210 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST210;
		_t = __t210;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t211 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp190_AST = astFactory->create(_t);
		tmp190_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp190_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST211 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST211;
		_t = __t211;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t212 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp191_AST = astFactory->create(_t);
		tmp191_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp191_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST212 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST212;
		_t = __t212;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t213 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp192_AST = astFactory->create(_t);
		tmp192_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp192_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST213 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST213;
		_t = __t213;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t214 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp193_AST = astFactory->create(_t);
		tmp193_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp193_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST214 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST214;
		_t = __t214;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t215 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp194_AST = astFactory->create(_t);
		tmp194_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp194_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST215 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST215;
		_t = __t215;
		_t = _t->getNextSibling();
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BINARY_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t216 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp195_AST = astFactory->create(_t);
		tmp195_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp195_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST216 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BINARY_SETMEM_QUERY);
		_t = _t->getFirstChild();
		mtsql_intoLValue(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST216;
		_t = __t216;
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

void MTSQLOracleTreeParser::mtsql_intoLValue(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 1892 "expandedmtsql_tree_oracle.g"
	
		  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
		  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable: " + lv->getText(), (RefMTSQLAST)mtsql_intoLValue_AST); 
		  ((RefMTSQLAST)mtsql_intoLValue_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 7421 "MTSQLOracleTreeParser.cpp"
	mtsql_intoLValue_AST = currentAST.root;
	returnAST = mtsql_intoLValue_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_queryExpr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t324 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp196_AST = astFactory->create(_t);
		tmp196_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp196_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST324 = currentAST;
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
		currentAST = __currentAST324;
		_t = __t324;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t325 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp197_AST = astFactory->create(_t);
		tmp197_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp197_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST325 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST325;
		_t = __t325;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t326 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp198_AST = astFactory->create(_t);
		tmp198_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp198_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST326 = currentAST;
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
		currentAST = __currentAST326;
		_t = __t326;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t327 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp199_AST = astFactory->create(_t);
		tmp199_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp199_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST327 = currentAST;
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
		currentAST = __currentAST327;
		_t = __t327;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t328 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp200_AST = astFactory->create(_t);
		tmp200_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp200_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST328 = currentAST;
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
		currentAST = __currentAST328;
		_t = __t328;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t329 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp201_AST = astFactory->create(_t);
		tmp201_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp201_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST329 = currentAST;
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
		currentAST = __currentAST329;
		_t = __t329;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t330 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp202_AST = astFactory->create(_t);
		tmp202_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp202_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST330 = currentAST;
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
		currentAST = __currentAST330;
		_t = __t330;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t331 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp203_AST = astFactory->create(_t);
		tmp203_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp203_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST331 = currentAST;
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
		currentAST = __currentAST331;
		_t = __t331;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t332 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp204_AST = astFactory->create(_t);
		tmp204_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp204_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST332 = currentAST;
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
		currentAST = __currentAST332;
		_t = __t332;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t333 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp205_AST = astFactory->create(_t);
		tmp205_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp205_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST333 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST333;
		_t = __t333;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case UNARY_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t334 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp206_AST = astFactory->create(_t);
		tmp206_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp206_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST334 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_PLUS);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST334;
		_t = __t334;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t335 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp207_AST = astFactory->create(_t);
		tmp207_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp207_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST335 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_COUNT);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp208_AST = astFactory->create(_t);
		tmp208_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp208_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp209_AST = astFactory->create(_t);
			tmp209_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp209_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp210_AST = astFactory->create(_t);
				tmp210_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp210_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp211_AST = astFactory->create(_t);
				tmp211_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp211_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp212_AST = astFactory->create(_t);
		tmp212_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp212_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST335;
		_t = __t335;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t338 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp213_AST = astFactory->create(_t);
		tmp213_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp213_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST338 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_AVG);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp214_AST = astFactory->create(_t);
		tmp214_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp214_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp215_AST = astFactory->create(_t);
			tmp215_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp215_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp216_AST = astFactory->create(_t);
			tmp216_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp216_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp217_AST = astFactory->create(_t);
		tmp217_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp217_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST338;
		_t = __t338;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t341 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp218_AST = astFactory->create(_t);
		tmp218_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp218_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST341 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MAX);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp219_AST = astFactory->create(_t);
		tmp219_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp219_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp220_AST = astFactory->create(_t);
			tmp220_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp220_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp221_AST = astFactory->create(_t);
			tmp221_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp221_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp222_AST = astFactory->create(_t);
		tmp222_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp222_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST341;
		_t = __t341;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t344 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp223_AST = astFactory->create(_t);
		tmp223_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp223_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST344 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MIN);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp224_AST = astFactory->create(_t);
		tmp224_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp224_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp225_AST = astFactory->create(_t);
			tmp225_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp225_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp226_AST = astFactory->create(_t);
			tmp226_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp226_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp227_AST = astFactory->create(_t);
		tmp227_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp227_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST344;
		_t = __t344;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t347 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp228_AST = astFactory->create(_t);
		tmp228_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp228_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST347 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_SUM);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp229_AST = astFactory->create(_t);
		tmp229_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp229_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp230_AST = astFactory->create(_t);
			tmp230_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp230_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp231_AST = astFactory->create(_t);
			tmp231_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp231_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp232_AST = astFactory->create(_t);
		tmp232_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp232_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST347;
		_t = __t347;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t350 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp233_AST = astFactory->create(_t);
		tmp233_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp233_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST350 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp234_AST = astFactory->create(_t);
		tmp234_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp234_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp235_AST = astFactory->create(_t);
		tmp235_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp235_AST);
		match(_t,TK_AS);
		_t = _t->getNextSibling();
		sql92_builtInType(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp236_AST = astFactory->create(_t);
		tmp236_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp236_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST350;
		_t = __t350;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t351 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp237_AST = astFactory->create(_t);
		tmp237_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp237_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST351 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SIMPLE_CASE);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt353=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == SIMPLE_WHEN)) {
				sql92_simpleWhenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt353>=1 ) { goto _loop353; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt353++;
		}
		_loop353:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp238_AST = astFactory->create(_t);
		tmp238_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp238_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST351;
		_t = __t351;
		_t = _t->getNextSibling();
		sql92_queryExpr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t355 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp239_AST = astFactory->create(_t);
		tmp239_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp239_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST355 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SEARCHED_CASE);
		_t = _t->getFirstChild();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )+
		int _cnt357=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_WHEN)) {
				sql92_whenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt357>=1 ) { goto _loop357; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt357++;
		}
		_loop357:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp240_AST = astFactory->create(_t);
		tmp240_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp240_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST355;
		_t = __t355;
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

void MTSQLOracleTreeParser::sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t230 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp241_AST = astFactory->create(_t);
	tmp241_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp241_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp242_AST = astFactory->create(_t);
		tmp242_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp242_AST);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp243_AST = astFactory->create(_t);
			tmp243_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp243_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp244_AST = astFactory->create(_t);
				tmp244_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp244_AST);
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
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp245_AST = astFactory->create(_t);
					tmp245_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp245_AST);
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
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t237 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp246_AST = astFactory->create(_t);
	tmp246_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp246_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST237 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
#line 1915 "expandedmtsql_tree_oracle.g"
	enterInto();
#line 8451 "MTSQLOracleTreeParser.cpp"
	{ // ( ... )+
	int _cnt239=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == LOCALVAR)) {
			sql92_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt239>=1 ) { goto _loop239; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt239++;
	}
	_loop239:;
	}  // ( ... )+
	currentAST = __currentAST237;
	_t = __t237;
	_t = _t->getNextSibling();
	sql92_intoList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 1915 "expandedmtsql_tree_oracle.g"
	exitInto(sql92_intoList_AST);
#line 8476 "MTSQLOracleTreeParser.cpp"
	sql92_intoList_AST = currentAST.root;
	returnAST = sql92_intoList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t242 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp247_AST = astFactory->create(_t);
	tmp247_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp247_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST242 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp248_AST = astFactory->create(_t);
			tmp248_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp248_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop244;
		}
		
	}
	_loop244:;
	} // ( ... )*
	currentAST = __currentAST242;
	_t = __t242;
	_t = _t->getNextSibling();
	sql92_fromClause_AST = currentAST.root;
	returnAST = sql92_fromClause_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t278 = _t;
	w = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	w_AST = astFactory->create(w);
	astFactory->addASTChild(currentAST, w_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST278 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHERE);
	_t = _t->getFirstChild();
	sql92_searchCondition(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST278;
	_t = __t278;
	_t = _t->getNextSibling();
	sql92_whereClause_AST = currentAST.root;
	returnAST = sql92_whereClause_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t280 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp249_AST = astFactory->create(_t);
	tmp249_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp249_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST280 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp250_AST = astFactory->create(_t);
	tmp250_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp250_AST);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp251_AST = astFactory->create(_t);
			tmp251_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp251_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop282;
		}
		
	}
	_loop282:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp252_AST = astFactory->create(_t);
		tmp252_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp252_AST);
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
	currentAST = __currentAST280;
	_t = __t280;
	_t = _t->getNextSibling();
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_queryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t322 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp253_AST = astFactory->create(_t);
	tmp253_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp253_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST322 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST322;
	_t = __t322;
	_t = _t->getNextSibling();
	sql92_queryExpression_AST = currentAST.root;
	returnAST = sql92_queryExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 1920 "expandedmtsql_tree_oracle.g"
	
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
	
#line 8733 "MTSQLOracleTreeParser.cpp"
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

void MTSQLOracleTreeParser::sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t246 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp254_AST = astFactory->create(_t);
	tmp254_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp254_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST246 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp255_AST = astFactory->create(_t);
		tmp255_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp255_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp256_AST = astFactory->create(_t);
		tmp256_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp256_AST);
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
	currentAST = __currentAST246;
	_t = __t246;
	_t = _t->getNextSibling();
	sql92_nestedSelectStatement_AST = currentAST.root;
	returnAST = sql92_nestedSelectStatement_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_nestedSelectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t251 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp257_AST = astFactory->create(_t);
	tmp257_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp257_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST251 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp258_AST = astFactory->create(_t);
		tmp258_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp258_AST);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp259_AST = astFactory->create(_t);
			tmp259_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp259_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp260_AST = astFactory->create(_t);
				tmp260_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp260_AST);
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
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp261_AST = astFactory->create(_t);
					tmp261_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp261_AST);
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
				goto _loop256;
			}
			
		}
		_loop256:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST251;
	_t = __t251;
	_t = _t->getNextSibling();
	sql92_nestedSelectList_AST = currentAST.root;
	returnAST = sql92_nestedSelectList_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_nestedFromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t258 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp262_AST = astFactory->create(_t);
	tmp262_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp262_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST258 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp263_AST = astFactory->create(_t);
			tmp263_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp263_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop260;
		}
		
	}
	_loop260:;
	} // ( ... )*
	currentAST = __currentAST258;
	_t = __t258;
	_t = _t->getNextSibling();
	sql92_nestedFromClause_AST = currentAST.root;
	returnAST = sql92_nestedFromClause_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_nestedGroupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t285 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp264_AST = astFactory->create(_t);
	tmp264_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp264_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST285 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp265_AST = astFactory->create(_t);
	tmp265_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp265_AST);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp266_AST = astFactory->create(_t);
			tmp266_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp266_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_queryExpr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop287;
		}
		
	}
	_loop287:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp267_AST = astFactory->create(_t);
		tmp267_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp267_AST);
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
	currentAST = __currentAST285;
	_t = __t285;
	_t = _t->getNextSibling();
	sql92_nestedGroupByClause_AST = currentAST.root;
	returnAST = sql92_nestedGroupByClause_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t291 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp268_AST = astFactory->create(_t);
		tmp268_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp268_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST291 = currentAST;
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
		currentAST = __currentAST291;
		_t = __t291;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t292 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp269_AST = astFactory->create(_t);
		tmp269_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp269_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST292 = currentAST;
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
		currentAST = __currentAST292;
		_t = __t292;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t293 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp270_AST = astFactory->create(_t);
		tmp270_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp270_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST293 = currentAST;
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
		currentAST = __currentAST293;
		_t = __t293;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t294 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp271_AST = astFactory->create(_t);
		tmp271_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp271_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST294 = currentAST;
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
		currentAST = __currentAST294;
		_t = __t294;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t295 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp272_AST = astFactory->create(_t);
		tmp272_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp272_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST295 = currentAST;
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
		currentAST = __currentAST295;
		_t = __t295;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t296 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp273_AST = astFactory->create(_t);
		tmp273_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp273_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST296 = currentAST;
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
		currentAST = __currentAST296;
		_t = __t296;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t297 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp274_AST = astFactory->create(_t);
		tmp274_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp274_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST297 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp275_AST = astFactory->create(_t);
			tmp275_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp275_AST);
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
		currentAST = __currentAST297;
		_t = __t297;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t299 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp276_AST = astFactory->create(_t);
		tmp276_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp276_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST299 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp277_AST = astFactory->create(_t);
			tmp277_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp277_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp278_AST = astFactory->create(_t);
		tmp278_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp278_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		currentAST = __currentAST299;
		_t = __t299;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_BETWEEN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t301 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp279_AST = astFactory->create(_t);
		tmp279_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp279_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST301 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp280_AST = astFactory->create(_t);
			tmp280_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp280_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp281_AST = astFactory->create(_t);
		tmp281_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp281_AST);
		match(_t,TK_AND);
		_t = _t->getNextSibling();
		sql92_queryExpr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST301;
		_t = __t301;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t303 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp282_AST = astFactory->create(_t);
		tmp282_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp282_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST303 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp283_AST = astFactory->create(_t);
			tmp283_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp283_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp284_AST = astFactory->create(_t);
		tmp284_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp284_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp285_AST = astFactory->create(_t);
		tmp285_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp285_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST303;
		_t = __t303;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t305 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp286_AST = astFactory->create(_t);
		tmp286_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp286_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST305 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp287_AST = astFactory->create(_t);
			tmp287_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp287_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp288_AST = astFactory->create(_t);
		tmp288_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp288_AST);
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
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp289_AST = astFactory->create(_t);
					tmp289_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp289_AST);
					match(_t,COMMA);
					_t = _t->getNextSibling();
					sql92_queryExpr(_t);
					_t = _retTree;
					astFactory->addASTChild( currentAST, returnAST );
				}
				else {
					goto _loop309;
				}
				
			}
			_loop309:;
			} // ( ... )*
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp290_AST = astFactory->create(_t);
		tmp290_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp290_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST305;
		_t = __t305;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t310 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp291_AST = astFactory->create(_t);
		tmp291_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp291_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST310 = currentAST;
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
		currentAST = __currentAST310;
		_t = __t310;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t311 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp292_AST = astFactory->create(_t);
		tmp292_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp292_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST311 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST311;
		_t = __t311;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t312 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp293_AST = astFactory->create(_t);
		tmp293_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp293_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST312 = currentAST;
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
		currentAST = __currentAST312;
		_t = __t312;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t313 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp294_AST = astFactory->create(_t);
		tmp294_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp294_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_hackExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp295_AST = astFactory->create(_t);
		tmp295_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp295_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST313;
		_t = __t313;
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

void MTSQLOracleTreeParser::sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void MTSQLOracleTreeParser::sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t315 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp296_AST = astFactory->create(_t);
	tmp296_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp296_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST315 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST315;
	_t = __t315;
	_t = _t->getNextSibling();
	sql92_hackExpression_AST = currentAST.root;
	returnAST = sql92_hackExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t317 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp297_AST = astFactory->create(_t);
	tmp297_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp297_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST317 = currentAST;
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp298_AST = astFactory->create(_t);
				tmp298_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp298_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_queryExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop320;
			}
			
		}
		_loop320:;
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
	currentAST = __currentAST317;
	_t = __t317;
	_t = _t->getNextSibling();
	sql92_elist_AST = currentAST.root;
	returnAST = sql92_elist_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t372 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp299_AST = astFactory->create(_t);
	tmp299_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp299_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST372 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp300_AST = astFactory->create(_t);
		tmp300_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp300_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp301_AST = astFactory->create(_t);
		tmp301_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp301_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp302_AST = astFactory->create(_t);
		tmp302_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp302_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp303_AST = astFactory->create(_t);
			tmp303_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp303_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp304_AST = astFactory->create(_t);
			tmp304_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp304_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp305_AST = astFactory->create(_t);
		tmp305_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp305_AST);
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
	currentAST = __currentAST372;
	_t = __t372;
	_t = _t->getNextSibling();
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t362 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp306_AST = astFactory->create(_t);
	tmp306_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp306_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST362 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp307_AST = astFactory->create(_t);
	tmp307_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp307_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST362;
	_t = __t362;
	_t = _t->getNextSibling();
	sql92_simpleWhenExpression_AST = currentAST.root;
	returnAST = sql92_simpleWhenExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t364 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp308_AST = astFactory->create(_t);
	tmp308_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp308_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST364 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ELSE);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST364;
	_t = __t364;
	_t = _t->getNextSibling();
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t360 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp309_AST = astFactory->create(_t);
	tmp309_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp309_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST360 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp310_AST = astFactory->create(_t);
	tmp310_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp310_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_queryExpr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST360;
	_t = __t360;
	_t = _t->getNextSibling();
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
	_retTree = _t;
}

void MTSQLOracleTreeParser::sql92_queryPrimaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		ANTLR_USE_NAMESPACE(antlr)RefAST __t366 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp311_AST = astFactory->create(_t);
		tmp311_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp311_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST366 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp312_AST = astFactory->create(_t);
			tmp312_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp312_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp313_AST = astFactory->create(_t);
			tmp313_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp313_AST);
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
		currentAST = __currentAST366;
		_t = __t366;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp314_AST = astFactory->create(_t);
		tmp314_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp314_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp315_AST = astFactory->create(_t);
		tmp315_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp315_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp316_AST = astFactory->create(_t);
		tmp316_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp316_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp317_AST = astFactory->create(_t);
		tmp317_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp317_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp318_AST = astFactory->create(_t);
		tmp318_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp318_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp319_AST = astFactory->create(_t);
		tmp319_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp319_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp320_AST = astFactory->create(_t);
		tmp320_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp320_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 2100 "expandedmtsql_tree_oracle.g"
		
		// Create an enum value from the string.  Convert this to an integer literal.
		RuntimeValue strVal = RuntimeValue::createString((sql92_queryPrimaryExpression_AST->getText().c_str()));
		RuntimeValue enumVal;
		RuntimeValueCast::ToEnum(&enumVal, &strVal, getNameID());
		enumVal = enumVal.castToLong();
			  ((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setValue(enumVal); 
		((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setText(enumVal.castToString().getStringPtr());
		((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setType(NUM_INT);
		
#line 10305 "MTSQLOracleTreeParser.cpp"
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t368 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp321_AST = astFactory->create(_t);
		tmp321_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp321_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST368 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp322_AST = astFactory->create(_t);
		tmp322_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp322_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		sql92_elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp323_AST = astFactory->create(_t);
		tmp323_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp323_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST368;
		_t = __t368;
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
#line 2112 "expandedmtsql_tree_oracle.g"
		
			  VarEntryPtr var = mEnv->lookupVar(lv->getText()); 
			  if (VarEntryPtr() == var) throw MTSQLSemanticException("Undefined Variable", (RefMTSQLAST)sql92_queryPrimaryExpression_AST); 
		referenceVariable((RefMTSQLAST)lv_AST);
			  ((RefMTSQLAST)sql92_queryPrimaryExpression_AST)->setAccess(LexicalAddress::create(mEnv->getCurrentLevel()-var->getLevel(), var->getAccess()));
		
#line 10361 "MTSQLOracleTreeParser.cpp"
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t369 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp324_AST = astFactory->create(_t);
		tmp324_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp324_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST369 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_queryExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp325_AST = astFactory->create(_t);
		tmp325_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp325_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST369;
		_t = __t369;
		_t = _t->getNextSibling();
		sql92_queryPrimaryExpression_AST = currentAST.root;
		break;
	}
	case SCALAR_SUBQUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t370 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp326_AST = astFactory->create(_t);
		tmp326_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp326_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST370 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SCALAR_SUBQUERY);
		_t = _t->getFirstChild();
		sql92_selectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp327_AST = astFactory->create(_t);
		tmp327_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp327_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST370;
		_t = __t370;
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

void MTSQLOracleTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(246);
}
const char* MTSQLOracleTreeParser::tokenNames[] = {
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

const unsigned long MTSQLOracleTreeParser::_tokenSet_0_data_[] = { 17317888UL, 536870912UL, 524297UL, 2147483648UL, 52445184UL, 161UL, 2146435072UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "PRINT" "RETURN" "SELECT" "LOCK" ASSIGN 
// IFTHENELSE QUERY RAISERROR1 RAISERROR2 SLIST WHILE SEQUENCE INTEGER_SETMEM 
// BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM WSTRING_SETMEM 
// BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM BINARY_SETMEM 
// RAISERRORINTEGER RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING RAISERROR2WSTRING 
// STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleTreeParser::_tokenSet_0(_tokenSet_0_data_,16);
const unsigned long MTSQLOracleTreeParser::_tokenSet_1_data_[] = { 0UL, 0UL, 0UL, 4194304UL, 0UL, 0UL, 1048064UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// LOCALVAR INTEGER_GETMEM BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM 
// WSTRING_GETMEM BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM 
// BINARY_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleTreeParser::_tokenSet_1(_tokenSet_1_data_,16);


