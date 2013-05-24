/* $ANTLR 2.7.6 (2005-12-22): "expandedrewrite_query_oracle.g" -> "RewriteOracleTreeParser.cpp"$ */
#include "RewriteOracleTreeParser.hpp"
#include <antlr/Token.hpp>
#include <antlr/AST.hpp>
#include <antlr/NoViableAltException.hpp>
#include <antlr/MismatchedTokenException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "expandedrewrite_query_oracle.g"
#line 11 "RewriteOracleTreeParser.cpp"
RewriteOracleTreeParser::RewriteOracleTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void RewriteOracleTreeParser::sql92_tableSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		currentAST = __currentAST3;
		_t = __t3;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case CROSS_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t6 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp4_AST = astFactory->create(_t);
		tmp4_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp4_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST6 = currentAST;
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
		currentAST = __currentAST6;
		_t = __t6;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case GROUPED_JOIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t7 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp5_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp5_AST = astFactory->create(_t);
		tmp5_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp5_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST7 = currentAST;
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
		currentAST = __currentAST7;
		_t = __t7;
		_t = _t->getNextSibling();
		sql92_tableSpecification_AST = currentAST.root;
		break;
	}
	case DERIVED_TABLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t8 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp7_AST = astFactory->create(_t);
		tmp7_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp7_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST8 = currentAST;
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
#line 377 "expandedrewrite_query_oracle.g"
		
		// Use the current alias and the alias of the derived table to create the
		// join criteria.  This needs to be saved until later processing of the 
		// WHERE clause of the "containing" context.
		std::string innerColumn = tmp9_AST->getText() + "." + "requestid ";
		std::string outerColumn = getCurrentAlias() + "." + "requestid ";
		ANTLR_USE_NAMESPACE(antlr)RefAST ast = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(EQUALS,"= "))->add(astFactory->create(ID,innerColumn))->add(astFactory->create(ID,outerColumn))));
		pushWhereClause(ast);
		
#line 213 "RewriteOracleTreeParser.cpp"
		currentAST = __currentAST8;
		_t = __t8;
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

void RewriteOracleTreeParser::sql92_joinCriteria(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t91 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp10_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp10_AST = astFactory->create(_t);
	tmp10_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp10_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST91 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ON);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST91;
	_t = __t91;
	_t = _t->getNextSibling();
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_tableHint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t77 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp11_AST = astFactory->create(_t);
	tmp11_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp11_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST77 = currentAST;
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
				goto _loop82;
			}
			
		}
		_loop82:;
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
						goto _loop88;
					}
					
				}
				_loop88:;
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
			goto _loop89;
		}
		
	}
	_loop89:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp32_AST = astFactory->create(_t);
	tmp32_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp32_AST);
	match(_t,RPAREN);
	_t = _t->getNextSibling();
	currentAST = __currentAST77;
	_t = __t77;
	_t = _t->getNextSibling();
	sql92_tableHint_AST = currentAST.root;
	returnAST = sql92_tableHint_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp33_AST = astFactory->create(_t);
			tmp33_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp33_AST);
			match(_t,TK_UNION);
			_t = _t->getNextSibling();
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp34_AST = astFactory->create(_t);
				tmp34_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp34_AST);
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
			goto _loop41;
		}
		
	}
	_loop41:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp35_AST = astFactory->create(_t);
		tmp35_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp35_AST);
		match(_t,TK_ORDER);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp36_AST = astFactory->create(_t);
		tmp36_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp36_AST);
		match(_t,TK_BY);
		_t = _t->getNextSibling();
		sql92_orderByExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 438 "expandedrewrite_query_oracle.g"
		throw MTSQLSemanticException("ORDER BY not supported in batch queries", (RefMTSQLAST)sql92_selectStatement_AST);
#line 659 "RewriteOracleTreeParser.cpp"
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

void RewriteOracleTreeParser::oracle_for_update_of_hint(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_for_update_of_hint_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_for_update_of_hint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t10 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp37_AST = astFactory->create(_t);
	tmp37_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp37_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST10 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_FOR);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp38_AST = astFactory->create(_t);
	tmp38_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp38_AST);
	match(_t,TK_UPDATE);
	_t = _t->getNextSibling();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_OF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp39_AST = astFactory->create(_t);
		tmp39_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp39_AST);
		match(_t,TK_OF);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp40_AST = astFactory->create(_t);
		tmp40_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp40_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp41_AST = astFactory->create(_t);
			tmp41_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp41_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp42_AST = astFactory->create(_t);
			tmp42_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp42_AST);
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
	currentAST = __currentAST10;
	_t = __t10;
	_t = _t->getNextSibling();
	oracle_for_update_of_hint_AST = currentAST.root;
	returnAST = oracle_for_update_of_hint_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_fromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t14 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp43_AST = astFactory->create(_t);
	tmp43_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp43_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST14 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp44_AST = astFactory->create(_t);
			tmp44_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp44_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop16;
		}
		
	}
	_loop16:;
	} // ( ... )*
#line 393 "expandedrewrite_query_oracle.g"
	
	std::string alias = getCurrentAlias() + " ";
	std::string table = getFullTempTableName() + " ";
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(COMMA,", ")))));
	astFactory->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(TABLE_REF,table))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ALIAS,alias))->add(sql92_fromClause_AST))))))); 
	
#line 824 "RewriteOracleTreeParser.cpp"
	currentAST = __currentAST14;
	_t = __t14;
	_t = _t->getNextSibling();
	sql92_fromClause_AST = currentAST.root;
	returnAST = sql92_fromClause_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::mtsql_selectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t18 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp45_AST = astFactory->create(_t);
	tmp45_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp45_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST18 = currentAST;
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
	currentAST = __currentAST18;
	_t = __t18;
	_t = _t->getNextSibling();
	mtsql_selectStatement_AST = currentAST.root;
	returnAST = mtsql_selectStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::mtsql_paramList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_paramList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t20 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp46_AST = astFactory->create(_t);
	tmp46_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp46_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST20 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp47_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp47_AST = astFactory->create(_t);
			tmp47_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp47_AST);
			match(_t,INTEGER_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp48_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp48_AST = astFactory->create(_t);
			tmp48_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp48_AST);
			match(_t,DECIMAL_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp49_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp49_AST = astFactory->create(_t);
			tmp49_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp49_AST);
			match(_t,DOUBLE_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case STRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp50_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp50_AST = astFactory->create(_t);
			tmp50_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp50_AST);
			match(_t,STRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp51_AST = astFactory->create(_t);
			tmp51_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp51_AST);
			match(_t,WSTRING_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp52_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp52_AST = astFactory->create(_t);
			tmp52_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp52_AST);
			match(_t,BOOLEAN_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp53_AST = astFactory->create(_t);
			tmp53_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp53_AST);
			match(_t,DATETIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case TIME_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp54_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp54_AST = astFactory->create(_t);
			tmp54_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp54_AST);
			match(_t,TIME_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp55_AST = astFactory->create(_t);
			tmp55_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp55_AST);
			match(_t,ENUM_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_GETMEM:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp56_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp56_AST = astFactory->create(_t);
			tmp56_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp56_AST);
			match(_t,BIGINT_GETMEM);
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop22;
		}
		}
	}
	_loop22:;
	} // ( ... )*
	currentAST = __currentAST20;
	_t = __t20;
	_t = _t->getNextSibling();
	mtsql_paramList_AST = currentAST.root;
	returnAST = mtsql_paramList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::mtsql_intoList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t24 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp57_AST = astFactory->create(_t);
	tmp57_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp57_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST24 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_INTO);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt26=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= INTEGER_SETMEM_QUERY && _t->getType() <= ENUM_SETMEM_QUERY))) {
			mtsql_intoVarRef(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			if ( _cnt26>=1 ) { goto _loop26; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt26++;
	}
	_loop26:;
	}  // ( ... )+
	currentAST = __currentAST24;
	_t = __t24;
	_t = _t->getNextSibling();
	mtsql_intoList_AST = currentAST.root;
	returnAST = mtsql_intoList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::mtsql_intoVarRef(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST mtsql_intoVarRef_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t28 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp58_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp58_AST = astFactory->create(_t);
		tmp58_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp58_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST28 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp59_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp59_AST = astFactory->create(_t);
		tmp59_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp59_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST28;
		_t = __t28;
		_t = _t->getNextSibling();
#line 415 "expandedrewrite_query_oracle.g"
		pushOutput(tmp59_AST);
#line 1092 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t29 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp60_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp60_AST = astFactory->create(_t);
		tmp60_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp60_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST29 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp61_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp61_AST = astFactory->create(_t);
		tmp61_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp61_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST29;
		_t = __t29;
		_t = _t->getNextSibling();
#line 417 "expandedrewrite_query_oracle.g"
		pushOutput(tmp61_AST);
#line 1121 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM_QUERY:
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
		match(_t,DECIMAL_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp63_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp63_AST = astFactory->create(_t);
		tmp63_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp63_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST30;
		_t = __t30;
		_t = _t->getNextSibling();
#line 419 "expandedrewrite_query_oracle.g"
		pushOutput(tmp63_AST);
#line 1150 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t31 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp64_AST = astFactory->create(_t);
		tmp64_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp64_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST31 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp65_AST = astFactory->create(_t);
		tmp65_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp65_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST31;
		_t = __t31;
		_t = _t->getNextSibling();
#line 421 "expandedrewrite_query_oracle.g"
		pushOutput(tmp65_AST);
#line 1179 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t32 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp66_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp66_AST = astFactory->create(_t);
		tmp66_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp66_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST32 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,STRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp67_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp67_AST = astFactory->create(_t);
		tmp67_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp67_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST32;
		_t = __t32;
		_t = _t->getNextSibling();
#line 423 "expandedrewrite_query_oracle.g"
		pushOutput(tmp67_AST);
#line 1208 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t33 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp68_AST = astFactory->create(_t);
		tmp68_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp68_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST33 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,WSTRING_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp69_AST = astFactory->create(_t);
		tmp69_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp69_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST33;
		_t = __t33;
		_t = _t->getNextSibling();
#line 425 "expandedrewrite_query_oracle.g"
		pushOutput(tmp69_AST);
#line 1237 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t34 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp70_AST = astFactory->create(_t);
		tmp70_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp70_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST34 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOOLEAN_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp71_AST = astFactory->create(_t);
		tmp71_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp71_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST34;
		_t = __t34;
		_t = _t->getNextSibling();
#line 427 "expandedrewrite_query_oracle.g"
		pushOutput(tmp71_AST);
#line 1266 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t35 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp72_AST = astFactory->create(_t);
		tmp72_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp72_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST35 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DATETIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp73_AST = astFactory->create(_t);
		tmp73_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp73_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST35;
		_t = __t35;
		_t = _t->getNextSibling();
#line 429 "expandedrewrite_query_oracle.g"
		pushOutput(tmp73_AST);
#line 1295 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t36 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp74_AST = astFactory->create(_t);
		tmp74_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp74_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST36 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIME_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp75_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp75_AST = astFactory->create(_t);
		tmp75_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp75_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST36;
		_t = __t36;
		_t = _t->getNextSibling();
#line 431 "expandedrewrite_query_oracle.g"
		pushOutput(tmp75_AST);
#line 1324 "RewriteOracleTreeParser.cpp"
		mtsql_intoVarRef_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM_QUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t37 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp76_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp76_AST = astFactory->create(_t);
		tmp76_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp76_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST37 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ENUM_SETMEM_QUERY);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp77_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp77_AST = astFactory->create(_t);
		tmp77_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp77_AST);
		match(_t,LOCALVAR);
		_t = _t->getNextSibling();
		currentAST = __currentAST37;
		_t = __t37;
		_t = _t->getNextSibling();
#line 433 "expandedrewrite_query_oracle.g"
		pushOutput(tmp77_AST);
#line 1353 "RewriteOracleTreeParser.cpp"
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

void RewriteOracleTreeParser::sql92_querySpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
#line 446 "expandedrewrite_query_oracle.g"
	
	bool hasWhere = false;
	bool hasGroupBy = false;
	bool allAggregates = false;
	pushNestingLevel();
	
#line 1381 "RewriteOracleTreeParser.cpp"
	ANTLR_USE_NAMESPACE(antlr)RefAST __t49 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp78_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp78_AST = astFactory->create(_t);
	tmp78_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp78_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST49 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp79_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp79_AST = astFactory->create(_t);
		tmp79_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp79_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp80_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp80_AST = astFactory->create(_t);
		tmp80_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp80_AST);
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
#line 454 "expandedrewrite_query_oracle.g"
	
	if (getAggregateCount() == getSelectListExprCount())
	allAggregates = true;
	
#line 1437 "RewriteOracleTreeParser.cpp"
	sql92_fromClause(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_WHERE:
	{
		w = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
		sql92_whereClause(_t);
		_t = _retTree;
		w_AST = returnAST;
		astFactory->addASTChild( currentAST, returnAST );
#line 459 "expandedrewrite_query_oracle.g"
		hasWhere = true;
#line 1454 "RewriteOracleTreeParser.cpp"
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
#line 460 "expandedrewrite_query_oracle.g"
	
	if(getWhereClause() != ANTLR_USE_NAMESPACE(antlr)RefAST(NULL))
	{
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(TK_WHERE," WHERE "))->add(getWhereClause()))));
	clearWhereClause();
	}
	
#line 1476 "RewriteOracleTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_GROUP:
	{
		sql92_groupByClause(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 467 "expandedrewrite_query_oracle.g"
		hasGroupBy = true;
#line 1488 "RewriteOracleTreeParser.cpp"
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
#line 468 "expandedrewrite_query_oracle.g"
	
	// adds an implicit GROUP BY for queries that don't have their own (CR10840)
	if (!hasGroupBy && allAggregates)
	{
	std::string aliasedColumn = getCurrentAlias() + ".requestid ";
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(TK_GROUP," GROUP "))->add(astFactory->create(TK_BY," BY "))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(ID,aliasedColumn))))))));
	}
	
#line 1510 "RewriteOracleTreeParser.cpp"
	currentAST = __currentAST49;
	_t = __t49;
	_t = _t->getNextSibling();
#line 477 "expandedrewrite_query_oracle.g"
	
	popNestingLevel();
	
#line 1518 "RewriteOracleTreeParser.cpp"
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_orderByExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_ASC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp81_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp81_AST = astFactory->create(_t);
		tmp81_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp81_AST);
		match(_t,TK_ASC);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DESC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp82_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp82_AST = astFactory->create(_t);
		tmp82_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp82_AST);
		match(_t,TK_DESC);
		_t = _t->getNextSibling();
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp83_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp83_AST = astFactory->create(_t);
			tmp83_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp83_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			switch ( _t->getType()) {
			case TK_ASC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp84_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp84_AST = astFactory->create(_t);
				tmp84_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp84_AST);
				match(_t,TK_ASC);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DESC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp85_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp85_AST = astFactory->create(_t);
				tmp85_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp85_AST);
				match(_t,TK_DESC);
				_t = _t->getNextSibling();
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
			goto _loop47;
		}
		
	}
	_loop47:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t139 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp86_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp86_AST = astFactory->create(_t);
		tmp86_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp86_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST139 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BAND);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST139;
		_t = __t139;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t140 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp87_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp87_AST = astFactory->create(_t);
		tmp87_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp87_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST140 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST140;
		_t = __t140;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t141 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp88_AST = astFactory->create(_t);
		tmp88_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp88_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST141 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST141;
		_t = __t141;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t142 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp89_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp89_AST = astFactory->create(_t);
		tmp89_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp89_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST142 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BXOR);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST142;
		_t = __t142;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t143 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp90_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp90_AST = astFactory->create(_t);
		tmp90_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp90_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST143 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MINUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST143;
		_t = __t143;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t144 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp91_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp91_AST = astFactory->create(_t);
		tmp91_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp91_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST144 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,MODULUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST144;
		_t = __t144;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t145 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp92_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp92_AST = astFactory->create(_t);
		tmp92_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp92_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST145 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DIVIDE);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST145;
		_t = __t145;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t146 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp93_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp93_AST = astFactory->create(_t);
		tmp93_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp93_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST146 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,PLUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST146;
		_t = __t146;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t147 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp94_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp94_AST = astFactory->create(_t);
		tmp94_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp94_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST147 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TIMES);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST147;
		_t = __t147;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t148 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp95_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp95_AST = astFactory->create(_t);
		tmp95_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp95_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST148 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_MINUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST148;
		_t = __t148;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case UNARY_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t149 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp96_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp96_AST = astFactory->create(_t);
		tmp96_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp96_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST149 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,UNARY_PLUS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST149;
		_t = __t149;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t150 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp97_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp97_AST = astFactory->create(_t);
		tmp97_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp97_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST150 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_CAST);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp98_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp98_AST = astFactory->create(_t);
		tmp98_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp98_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp99_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp99_AST = astFactory->create(_t);
		tmp99_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp99_AST);
		match(_t,TK_AS);
		_t = _t->getNextSibling();
		sql92_builtInType(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp100_AST = astFactory->create(_t);
		tmp100_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp100_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST150;
		_t = __t150;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	case TK_COUNT:
	case TK_MAX:
	case TK_MIN:
	case TK_SUM:
	{
		sql92_aggregateExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 620 "expandedrewrite_query_oracle.g"
		incrementAggregateCount();
#line 1969 "RewriteOracleTreeParser.cpp"
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SIMPLE_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t151 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp101_AST = astFactory->create(_t);
		tmp101_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp101_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST151 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SIMPLE_CASE);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt153=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == SIMPLE_WHEN)) {
				sql92_simpleWhenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp102_AST = astFactory->create(_t);
		tmp102_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp102_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST151;
		_t = __t151;
		_t = _t->getNextSibling();
		sql92_expr_AST = currentAST.root;
		break;
	}
	case SEARCHED_CASE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t155 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp103_AST = astFactory->create(_t);
		tmp103_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp103_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST155 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SEARCHED_CASE);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )+
		int _cnt157=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == TK_WHEN)) {
				sql92_whenExpression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt157>=1 ) { goto _loop157; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt157++;
		}
		_loop157:;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp104_AST = astFactory->create(_t);
		tmp104_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp104_AST);
		match(_t,TK_END);
		_t = _t->getNextSibling();
		currentAST = __currentAST155;
		_t = __t155;
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
	case INTEGER_GETMEM:
	case BIGINT_GETMEM:
	case DOUBLE_GETMEM:
	case DECIMAL_GETMEM:
	case STRING_GETMEM:
	case WSTRING_GETMEM:
	case BOOLEAN_GETMEM:
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

void RewriteOracleTreeParser::sql92_selectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t54 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp105_AST = astFactory->create(_t);
	tmp105_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp105_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST54 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp106_AST = astFactory->create(_t);
		tmp106_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp106_AST);
		match(_t,STAR);
		_t = _t->getNextSibling();
#line 485 "expandedrewrite_query_oracle.g"
		incrementSelectListExprCount();
#line 2172 "RewriteOracleTreeParser.cpp"
		break;
	}
	case EXPR:
	{
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 487 "expandedrewrite_query_oracle.g"
		incrementSelectListExprCount();
#line 2182 "RewriteOracleTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp107_AST = astFactory->create(_t);
			tmp107_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp107_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp108_AST = astFactory->create(_t);
				tmp108_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp108_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 488 "expandedrewrite_query_oracle.g"
				incrementSelectListExprCount();
#line 2226 "RewriteOracleTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ALIAS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp109_AST = astFactory->create(_t);
					tmp109_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp109_AST);
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
				goto _loop59;
			}
			
		}
		_loop59:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
#line 490 "expandedrewrite_query_oracle.g"
	
	std::string aliasedColumn = getCurrentAlias() + ".requestid ";
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(COMMA,", ")))));
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ID,aliasedColumn))->add(sql92_selectList_AST)))))));
	
#line 2275 "RewriteOracleTreeParser.cpp"
	currentAST = __currentAST54;
	_t = __t54;
	_t = _t->getNextSibling();
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_whereClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST s = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t93 = _t;
	w = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	w_AST = astFactory->create(w);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST93 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHERE);
	_t = _t->getFirstChild();
	s = (_t == ASTNULL) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	sql92_searchCondition(_t);
	_t = _retTree;
	s_AST = returnAST;
	currentAST = __currentAST93;
	_t = __t93;
	_t = _t->getNextSibling();
	sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 529 "expandedrewrite_query_oracle.g"
	
	if(getWhereClause() != ANTLR_USE_NAMESPACE(antlr)RefAST(NULL))
	{
	sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(w_AST)->add(ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(3))->add(astFactory->create(LAND," AND "))->add(getWhereClause())->add(s_AST))))));
	clearWhereClause();
	}
	else
	{
	sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(w_AST)->add(s_AST)));
	}
	
#line 2323 "RewriteOracleTreeParser.cpp"
	currentAST.root = sql92_whereClause_AST;
	if ( sql92_whereClause_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
		sql92_whereClause_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
		  currentAST.child = sql92_whereClause_AST->getFirstChild();
	else
		currentAST.child = sql92_whereClause_AST;
	currentAST.advanceChildToEnd();
	returnAST = sql92_whereClause_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_groupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t95 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp110_AST = astFactory->create(_t);
	tmp110_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp110_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST95 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp111_AST = astFactory->create(_t);
	tmp111_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp111_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp112_AST = astFactory->create(_t);
			tmp112_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp112_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop97;
		}
		
	}
	_loop97:;
	} // ( ... )*
#line 544 "expandedrewrite_query_oracle.g"
	
	std::string aliasedColumn = getCurrentAlias() + ".requestid ";
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(COMMA,", ")))));
	getASTFactory()->addASTChild(currentAST, ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(1))->add(astFactory->create(ID,aliasedColumn)))));
	
#line 2391 "RewriteOracleTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp113_AST = astFactory->create(_t);
		tmp113_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp113_AST);
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
	currentAST = __currentAST95;
	_t = __t95;
	_t = _t->getNextSibling();
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t111 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp114_AST = astFactory->create(_t);
	tmp114_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp114_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST111 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST111;
	_t = __t111;
	_t = _t->getNextSibling();
	sql92_expression_AST = currentAST.root;
	returnAST = sql92_expression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_nestedSelectStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t61 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp115_AST = astFactory->create(_t);
	tmp115_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp115_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST61 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp116_AST = astFactory->create(_t);
		tmp116_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp116_AST);
		match(_t,TK_ALL);
		_t = _t->getNextSibling();
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp117_AST = astFactory->create(_t);
		tmp117_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp117_AST);
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
	currentAST = __currentAST61;
	_t = __t61;
	_t = _t->getNextSibling();
	sql92_nestedSelectStatement_AST = currentAST.root;
	returnAST = sql92_nestedSelectStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_nestedSelectList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedSelectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t66 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp118_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp118_AST = astFactory->create(_t);
	tmp118_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp118_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST66 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp119_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp119_AST = astFactory->create(_t);
		tmp119_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp119_AST);
		match(_t,STAR);
		_t = _t->getNextSibling();
#line 505 "expandedrewrite_query_oracle.g"
		incrementSelectListExprCount();
#line 2598 "RewriteOracleTreeParser.cpp"
		break;
	}
	case EXPR:
	{
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
#line 507 "expandedrewrite_query_oracle.g"
		incrementSelectListExprCount();
#line 2608 "RewriteOracleTreeParser.cpp"
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case ALIAS:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp120_AST = astFactory->create(_t);
			tmp120_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp120_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp121_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp121_AST = astFactory->create(_t);
				tmp121_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp121_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
#line 508 "expandedrewrite_query_oracle.g"
				incrementSelectListExprCount();
#line 2652 "RewriteOracleTreeParser.cpp"
				{
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				switch ( _t->getType()) {
				case ALIAS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp122_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp122_AST = astFactory->create(_t);
					tmp122_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp122_AST);
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
				goto _loop71;
			}
			
		}
		_loop71:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	currentAST = __currentAST66;
	_t = __t66;
	_t = _t->getNextSibling();
	sql92_nestedSelectList_AST = currentAST.root;
	returnAST = sql92_nestedSelectList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_nestedFromClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedFromClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t73 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp123_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp123_AST = astFactory->create(_t);
	tmp123_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp123_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST73 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp124_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp124_AST = astFactory->create(_t);
			tmp124_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp124_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_tableSpecification(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop75;
		}
		
	}
	_loop75:;
	} // ( ... )*
	currentAST = __currentAST73;
	_t = __t73;
	_t = _t->getNextSibling();
	sql92_nestedFromClause_AST = currentAST.root;
	returnAST = sql92_nestedFromClause_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_nestedGroupByClause(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_nestedGroupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t100 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp125_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp125_AST = astFactory->create(_t);
	tmp125_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp125_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST100 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_GROUP);
	_t = _t->getFirstChild();
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp126_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp126_AST = astFactory->create(_t);
	tmp126_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp126_AST);
	match(_t,TK_BY);
	_t = _t->getNextSibling();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp127_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp127_AST = astFactory->create(_t);
			tmp127_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp127_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop102;
		}
		
	}
	_loop102:;
	} // ( ... )*
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp128_AST = astFactory->create(_t);
		tmp128_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp128_AST);
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
	currentAST = __currentAST100;
	_t = __t100;
	_t = _t->getNextSibling();
	sql92_nestedGroupByClause_AST = currentAST.root;
	returnAST = sql92_nestedGroupByClause_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_logicalExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_logicalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t113 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp129_AST = astFactory->create(_t);
		tmp129_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp129_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST113 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,EQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST113;
		_t = __t113;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t114 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp130_AST = astFactory->create(_t);
		tmp130_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp130_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST114 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GT);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST114;
		_t = __t114;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t115 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp131_AST = astFactory->create(_t);
		tmp131_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp131_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST115 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,GTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST115;
		_t = __t115;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t116 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp132_AST = astFactory->create(_t);
		tmp132_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp132_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST116 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTN);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST116;
		_t = __t116;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t117 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp133_AST = astFactory->create(_t);
		tmp133_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp133_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST117 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LTEQ);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST117;
		_t = __t117;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t118 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp134_AST = astFactory->create(_t);
		tmp134_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp134_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST118 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,NOTEQUALS);
		_t = _t->getFirstChild();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST118;
		_t = __t118;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t119 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp135_AST = astFactory->create(_t);
		tmp135_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp135_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST119 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp136_AST = astFactory->create(_t);
			tmp136_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp136_AST);
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
		case INTEGER_GETMEM:
		case BIGINT_GETMEM:
		case DOUBLE_GETMEM:
		case DECIMAL_GETMEM:
		case STRING_GETMEM:
		case WSTRING_GETMEM:
		case BOOLEAN_GETMEM:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST119;
		_t = __t119;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t121 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp137_AST = astFactory->create(_t);
		tmp137_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp137_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST121 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_IS);
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp138_AST = astFactory->create(_t);
			tmp138_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp138_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp139_AST = astFactory->create(_t);
		tmp139_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp139_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		currentAST = __currentAST121;
		_t = __t121;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_BETWEEN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t123 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp140_AST = astFactory->create(_t);
		tmp140_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp140_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST123 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp141_AST = astFactory->create(_t);
			tmp141_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp141_AST);
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
		case INTEGER_GETMEM:
		case BIGINT_GETMEM:
		case DOUBLE_GETMEM:
		case DECIMAL_GETMEM:
		case STRING_GETMEM:
		case WSTRING_GETMEM:
		case BOOLEAN_GETMEM:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp142_AST = astFactory->create(_t);
		tmp142_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp142_AST);
		match(_t,TK_AND);
		_t = _t->getNextSibling();
		sql92_expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST123;
		_t = __t123;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t125 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp143_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp143_AST = astFactory->create(_t);
		tmp143_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp143_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST125 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp144_AST = astFactory->create(_t);
			tmp144_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp144_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp145_AST = astFactory->create(_t);
		tmp145_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp145_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp146_AST = astFactory->create(_t);
		tmp146_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp146_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST125;
		_t = __t125;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case TK_IN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t127 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp147_AST = astFactory->create(_t);
		tmp147_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp147_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST127 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp148_AST = astFactory->create(_t);
			tmp148_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp148_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp149_AST = astFactory->create(_t);
		tmp149_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp149_AST);
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
		case INTEGER_GETMEM:
		case BIGINT_GETMEM:
		case DOUBLE_GETMEM:
		case DECIMAL_GETMEM:
		case STRING_GETMEM:
		case WSTRING_GETMEM:
		case BOOLEAN_GETMEM:
		{
			sql92_expr(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			{ // ( ... )*
			for (;;) {
				if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
					_t = ASTNULL;
				if ((_t->getType() == COMMA)) {
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
					tmp150_AST = astFactory->create(_t);
					tmp150_AST_in = _t;
					astFactory->addASTChild(currentAST, tmp150_AST);
					match(_t,COMMA);
					_t = _t->getNextSibling();
					sql92_expr(_t);
					_t = _retTree;
					astFactory->addASTChild( currentAST, returnAST );
				}
				else {
					goto _loop131;
				}
				
			}
			_loop131:;
			} // ( ... )*
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp151_AST = astFactory->create(_t);
		tmp151_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp151_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST127;
		_t = __t127;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t132 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp152_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp152_AST = astFactory->create(_t);
		tmp152_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp152_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST132 = currentAST;
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
		currentAST = __currentAST132;
		_t = __t132;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t133 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp153_AST = astFactory->create(_t);
		tmp153_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp153_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST133 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		sql92_logicalExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST133;
		_t = __t133;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t134 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp154_AST = astFactory->create(_t);
		tmp154_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp154_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST134 = currentAST;
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
		currentAST = __currentAST134;
		_t = __t134;
		_t = _t->getNextSibling();
		sql92_logicalExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t135 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp155_AST = astFactory->create(_t);
		tmp155_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp155_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST135 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_hackExpression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp156_AST = astFactory->create(_t);
		tmp156_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp156_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST135;
		_t = __t135;
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

void RewriteOracleTreeParser::sql92_searchCondition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void RewriteOracleTreeParser::sql92_elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t106 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp157_AST = astFactory->create(_t);
	tmp157_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp157_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST106 = currentAST;
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp158_AST = astFactory->create(_t);
				tmp158_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp158_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				sql92_expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop109;
			}
			
		}
		_loop109:;
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
	currentAST = __currentAST106;
	_t = __t106;
	_t = _t->getNextSibling();
	sql92_elist_AST = currentAST.root;
	returnAST = sql92_elist_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_hackExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_hackExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t137 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp159_AST = astFactory->create(_t);
	tmp159_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp159_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST137 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST137;
	_t = __t137;
	_t = _t->getNextSibling();
	sql92_hackExpression_AST = currentAST.root;
	returnAST = sql92_hackExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_builtInType(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t182 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp160_AST = astFactory->create(_t);
	tmp160_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp160_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST182 = currentAST;
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp161_AST = astFactory->create(_t);
		tmp161_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp161_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp162_AST = astFactory->create(_t);
		tmp162_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp162_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp163_AST = astFactory->create(_t);
		tmp163_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp163_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp164_AST = astFactory->create(_t);
			tmp164_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp164_AST);
			match(_t,COMMA);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp165_AST = astFactory->create(_t);
			tmp165_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp165_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp166_AST = astFactory->create(_t);
		tmp166_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp166_AST);
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
	currentAST = __currentAST182;
	_t = __t182;
	_t = _t->getNextSibling();
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_aggregateExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_aggregateExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_aggregateExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t160 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp167_AST = astFactory->create(_t);
		tmp167_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp167_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST160 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_COUNT);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp168_AST = astFactory->create(_t);
		tmp168_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp168_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp169_AST = astFactory->create(_t);
			tmp169_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp169_AST);
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp170_AST = astFactory->create(_t);
				tmp170_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp170_AST);
				match(_t,TK_ALL);
				_t = _t->getNextSibling();
				break;
			}
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp171_AST = astFactory->create(_t);
				tmp171_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp171_AST);
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
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp172_AST = astFactory->create(_t);
		tmp172_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp172_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST160;
		_t = __t160;
		_t = _t->getNextSibling();
		sql92_aggregateExpression_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t163 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp173_AST = astFactory->create(_t);
		tmp173_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp173_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST163 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_AVG);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp174_AST = astFactory->create(_t);
		tmp174_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp174_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp175_AST = astFactory->create(_t);
			tmp175_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp175_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp176_AST = astFactory->create(_t);
			tmp176_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp176_AST);
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp177_AST = astFactory->create(_t);
		tmp177_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp177_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST163;
		_t = __t163;
		_t = _t->getNextSibling();
		sql92_aggregateExpression_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t166 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp178_AST = astFactory->create(_t);
		tmp178_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp178_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST166 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MAX);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp179_AST = astFactory->create(_t);
		tmp179_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp179_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp180_AST = astFactory->create(_t);
			tmp180_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp180_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp181_AST = astFactory->create(_t);
			tmp181_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp181_AST);
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp182_AST = astFactory->create(_t);
		tmp182_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp182_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST166;
		_t = __t166;
		_t = _t->getNextSibling();
		sql92_aggregateExpression_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t169 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp183_AST = astFactory->create(_t);
		tmp183_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp183_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST169 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_MIN);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp184_AST = astFactory->create(_t);
		tmp184_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp184_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp185_AST = astFactory->create(_t);
			tmp185_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp185_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp186_AST = astFactory->create(_t);
			tmp186_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp186_AST);
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp187_AST = astFactory->create(_t);
		tmp187_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp187_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST169;
		_t = __t169;
		_t = _t->getNextSibling();
		sql92_aggregateExpression_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t172 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp188_AST = astFactory->create(_t);
		tmp188_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp188_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST172 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,TK_SUM);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp189_AST = astFactory->create(_t);
		tmp189_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp189_AST);
		match(_t,LPAREN);
		_t = _t->getNextSibling();
		{
		{
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		switch ( _t->getType()) {
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp190_AST = astFactory->create(_t);
			tmp190_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp190_AST);
			match(_t,TK_ALL);
			_t = _t->getNextSibling();
			break;
		}
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp191_AST = astFactory->create(_t);
			tmp191_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp191_AST);
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
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp192_AST = astFactory->create(_t);
		tmp192_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp192_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST172;
		_t = __t172;
		_t = _t->getNextSibling();
		sql92_aggregateExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_aggregateExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_simpleWhenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_simpleWhenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t178 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp193_AST = astFactory->create(_t);
	tmp193_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp193_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST178 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SIMPLE_WHEN);
	_t = _t->getFirstChild();
	sql92_logicalExpression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp194_AST = astFactory->create(_t);
	tmp194_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp194_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST178;
	_t = __t178;
	_t = _t->getNextSibling();
	sql92_simpleWhenExpression_AST = currentAST.root;
	returnAST = sql92_simpleWhenExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_elseExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t180 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp195_AST = astFactory->create(_t);
	tmp195_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp195_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST180 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_ELSE);
	_t = _t->getFirstChild();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST180;
	_t = __t180;
	_t = _t->getNextSibling();
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_whenExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t176 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp196_AST = astFactory->create(_t);
	tmp196_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp196_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST176 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,TK_WHEN);
	_t = _t->getFirstChild();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp197_AST = astFactory->create(_t);
	tmp197_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp197_AST);
	match(_t,TK_THEN);
	_t = _t->getNextSibling();
	sql92_expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST176;
	_t = __t176;
	_t = _t->getNextSibling();
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::sql92_primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t187 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp198_AST = astFactory->create(_t);
		tmp198_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp198_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST187 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp199_AST = astFactory->create(_t);
			tmp199_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp199_AST);
			match(_t,DOT);
			_t = _t->getNextSibling();
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp200_AST = astFactory->create(_t);
			tmp200_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp200_AST);
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
		currentAST = __currentAST187;
		_t = __t187;
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp201_AST = astFactory->create(_t);
		tmp201_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp201_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp202_AST = astFactory->create(_t);
		tmp202_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp202_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp203_AST = astFactory->create(_t);
		tmp203_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp203_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp204_AST = astFactory->create(_t);
		tmp204_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp204_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp205_AST = astFactory->create(_t);
		tmp205_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp205_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp206_AST = astFactory->create(_t);
		tmp206_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp206_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t189 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp207_AST = astFactory->create(_t);
		tmp207_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp207_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST189 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp208_AST = astFactory->create(_t);
		tmp208_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp208_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		sql92_elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp209_AST = astFactory->create(_t);
		tmp209_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp209_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST189;
		_t = __t189;
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
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
#line 661 "expandedrewrite_query_oracle.g"
		
		referenceVariable((RefMTSQLAST) lv_AST);
		lv_AST->setType(ID);
		lv_AST->setText(getCurrentAlias() + "." + getTempColumn(lv_AST->getText()));
		
#line 4484 "RewriteOracleTreeParser.cpp"
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp210_AST = astFactory->create(_t);
		tmp210_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp210_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp211_AST = astFactory->create(_t);
		tmp211_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp211_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp212_AST = astFactory->create(_t);
		tmp212_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp212_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp213_AST = astFactory->create(_t);
		tmp213_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp213_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp214_AST = astFactory->create(_t);
		tmp214_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp214_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp215_AST = astFactory->create(_t);
		tmp215_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp215_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp216_AST = astFactory->create(_t);
		tmp216_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp216_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case LPAREN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t190 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp217_AST = astFactory->create(_t);
		tmp217_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp217_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST190 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LPAREN);
		_t = _t->getFirstChild();
		sql92_expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp218_AST = astFactory->create(_t);
		tmp218_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp218_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST190;
		_t = __t190;
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	case SCALAR_SUBQUERY:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t191 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp219_AST = astFactory->create(_t);
		tmp219_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp219_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST191 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,SCALAR_SUBQUERY);
		_t = _t->getFirstChild();
		sql92_nestedSelectStatement(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp220_AST = astFactory->create(_t);
		tmp220_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp220_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST191;
		_t = __t191;
		_t = _t->getNextSibling();
		sql92_primaryExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	returnAST = sql92_primaryExpression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop194;
		}
		
	}
	_loop194:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST __t195 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp221_AST = astFactory->create(_t);
	tmp221_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp221_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST195 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,SCOPE);
	_t = _t->getFirstChild();
#line 679 "expandedrewrite_query_oracle.g"
	mEnv->beginScope();
#line 4674 "RewriteOracleTreeParser.cpp"
	statementList(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
#line 680 "expandedrewrite_query_oracle.g"
	mEnv->endScope();
#line 4680 "RewriteOracleTreeParser.cpp"
	currentAST = __currentAST195;
	_t = __t195;
	_t = _t->getNextSibling();
	program_AST = currentAST.root;
	returnAST = program_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::typeDeclaration(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST var_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ty_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t201 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp222_AST = astFactory->create(_t);
	tmp222_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp222_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST201 = currentAST;
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
	currentAST = __currentAST201;
	_t = __t201;
	_t = _t->getNextSibling();
#line 726 "expandedrewrite_query_oracle.g"
	
				
			mEnv->insertVar(
			var->getText(), 
			VarEntry::create(getType(ty->getText()), mEnv->allocateVariable(var->getText(), getType(ty->getText())), mEnv->getCurrentLevel())); 
		
#line 4732 "RewriteOracleTreeParser.cpp"
	typeDeclaration_AST = currentAST.root;
	returnAST = typeDeclaration_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::statementList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
			goto _loop198;
		}
		
	}
	_loop198:;
	} // ( ... )*
	statementList_AST = currentAST.root;
	returnAST = statementList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::statement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
		mtsql_selectStatement(_t);
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

void RewriteOracleTreeParser::setStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case INTEGER_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t203 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp223_AST = astFactory->create(_t);
		tmp223_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp223_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST203 = currentAST;
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
		currentAST = __currentAST203;
		_t = __t203;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BIGINT_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t204 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp224_AST = astFactory->create(_t);
		tmp224_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp224_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST204 = currentAST;
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
		currentAST = __currentAST204;
		_t = __t204;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DOUBLE_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t205 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp225_AST = astFactory->create(_t);
		tmp225_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp225_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST205 = currentAST;
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
		currentAST = __currentAST205;
		_t = __t205;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DECIMAL_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t206 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp226_AST = astFactory->create(_t);
		tmp226_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp226_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST206 = currentAST;
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
		currentAST = __currentAST206;
		_t = __t206;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case BOOLEAN_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t207 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp227_AST = astFactory->create(_t);
		tmp227_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp227_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST207 = currentAST;
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
		currentAST = __currentAST207;
		_t = __t207;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case STRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t208 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp228_AST = astFactory->create(_t);
		tmp228_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp228_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST208 = currentAST;
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
		currentAST = __currentAST208;
		_t = __t208;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case WSTRING_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t209 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp229_AST = astFactory->create(_t);
		tmp229_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp229_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST209 = currentAST;
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
		currentAST = __currentAST209;
		_t = __t209;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case DATETIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t210 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp230_AST = astFactory->create(_t);
		tmp230_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp230_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST210 = currentAST;
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
		currentAST = __currentAST210;
		_t = __t210;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case TIME_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t211 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp231_AST = astFactory->create(_t);
		tmp231_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp231_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST211 = currentAST;
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
		currentAST = __currentAST211;
		_t = __t211;
		_t = _t->getNextSibling();
		setStatement_AST = currentAST.root;
		break;
	}
	case ENUM_SETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t212 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp232_AST = astFactory->create(_t);
		tmp232_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp232_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST212 = currentAST;
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
		currentAST = __currentAST212;
		_t = __t212;
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

void RewriteOracleTreeParser::stringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST stringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t215 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp233_AST = astFactory->create(_t);
	tmp233_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp233_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST215 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,STRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST215;
	_t = __t215;
	_t = _t->getNextSibling();
	stringPrintStatement_AST = currentAST.root;
	returnAST = stringPrintStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::wstringPrintStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstringPrintStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t217 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp234_AST = astFactory->create(_t);
	tmp234_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp234_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST217 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,WSTRING_PRINT);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST217;
	_t = __t217;
	_t = _t->getNextSibling();
	wstringPrintStatement_AST = currentAST.root;
	returnAST = wstringPrintStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::seq(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST seq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t219 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp235_AST = astFactory->create(_t);
	tmp235_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp235_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST219 = currentAST;
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
	currentAST = __currentAST219;
	_t = __t219;
	_t = _t->getNextSibling();
	seq_AST = currentAST.root;
	returnAST = seq_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::ifStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t246 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp236_AST = astFactory->create(_t);
	tmp236_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp236_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST246 = currentAST;
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
	currentAST = __currentAST246;
	_t = __t246;
	_t = _t->getNextSibling();
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::listOfStatements(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST listOfStatements_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t251 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp237_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp237_AST = astFactory->create(_t);
	tmp237_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp237_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST251 = currentAST;
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
			goto _loop253;
		}
		
	}
	_loop253:;
	} // ( ... )*
	currentAST = __currentAST251;
	_t = __t251;
	_t = _t->getNextSibling();
	listOfStatements_AST = currentAST.root;
	returnAST = listOfStatements_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::returnStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t255 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp238_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp238_AST = astFactory->create(_t);
	tmp238_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp238_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST255 = currentAST;
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
	currentAST = __currentAST255;
	_t = __t255;
	_t = _t->getNextSibling();
	returnStatement_AST = currentAST.root;
	returnAST = returnStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::breakStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST breakStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp239_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp239_AST = astFactory->create(_t);
	tmp239_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp239_AST);
	match(_t,TK_BREAK);
	_t = _t->getNextSibling();
	breakStatement_AST = currentAST.root;
	returnAST = breakStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::continueStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST continueStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp240_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp240_AST = astFactory->create(_t);
	tmp240_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp240_AST);
	match(_t,TK_CONTINUE);
	_t = _t->getNextSibling();
	continueStatement_AST = currentAST.root;
	returnAST = continueStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::whileStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t260 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp241_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp241_AST = astFactory->create(_t);
	tmp241_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp241_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST260 = currentAST;
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
	currentAST = __currentAST260;
	_t = __t260;
	_t = _t->getNextSibling();
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::raiserrorStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t264 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp242_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp242_AST = astFactory->create(_t);
	tmp242_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp242_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST264 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST264;
	_t = __t264;
	_t = _t->getNextSibling();
	raiserrorStringStatement_AST = currentAST.root;
	returnAST = raiserrorStringStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::raiserrorWStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorWStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t266 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp243_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp243_AST = astFactory->create(_t);
	tmp243_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp243_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST266 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORWSTRING);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST266;
	_t = __t266;
	_t = _t->getNextSibling();
	raiserrorWStringStatement_AST = currentAST.root;
	returnAST = raiserrorWStringStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::raiserrorIntegerStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserrorIntegerStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t262 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp244_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp244_AST = astFactory->create(_t);
	tmp244_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp244_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST262 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,RAISERRORINTEGER);
	_t = _t->getFirstChild();
	expression(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST262;
	_t = __t262;
	_t = _t->getNextSibling();
	raiserrorIntegerStatement_AST = currentAST.root;
	returnAST = raiserrorIntegerStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::raiserror2StringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2StringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t268 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp245_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp245_AST = astFactory->create(_t);
	tmp245_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp245_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST268 = currentAST;
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
	currentAST = __currentAST268;
	_t = __t268;
	_t = _t->getNextSibling();
	raiserror2StringStatement_AST = currentAST.root;
	returnAST = raiserror2StringStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::raiserror2WStringStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST raiserror2WStringStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t270 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp246_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp246_AST = astFactory->create(_t);
	tmp246_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp246_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST270 = currentAST;
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
	currentAST = __currentAST270;
	_t = __t270;
	_t = _t->getNextSibling();
	raiserror2WStringStatement_AST = currentAST.root;
	returnAST = raiserror2WStringStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::varAddress(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void RewriteOracleTreeParser::expression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t277 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp247_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp247_AST = astFactory->create(_t);
	tmp247_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp247_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST277 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,EXPR);
	_t = _t->getFirstChild();
	expr(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST277;
	_t = __t277;
	_t = _t->getNextSibling();
	expression_AST = currentAST.root;
	returnAST = expression_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::expr(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case BAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t279 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp248_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp248_AST = astFactory->create(_t);
		tmp248_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp248_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST279 = currentAST;
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
		currentAST = __currentAST279;
		_t = __t279;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t280 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp249_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp249_AST = astFactory->create(_t);
		tmp249_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp249_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST280 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BNOT);
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
	case BOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t281 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp250_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp250_AST = astFactory->create(_t);
		tmp250_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp250_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST281 = currentAST;
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
		currentAST = __currentAST281;
		_t = __t281;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BXOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t282 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp251_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp251_AST = astFactory->create(_t);
		tmp251_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp251_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST282 = currentAST;
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
		currentAST = __currentAST282;
		_t = __t282;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LAND:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t283 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp252_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp252_AST = astFactory->create(_t);
		tmp252_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp252_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST283 = currentAST;
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
		currentAST = __currentAST283;
		_t = __t283;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LOR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t284 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp253_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp253_AST = astFactory->create(_t);
		tmp253_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp253_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST284 = currentAST;
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
		currentAST = __currentAST284;
		_t = __t284;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LNOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t285 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp254_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp254_AST = astFactory->create(_t);
		tmp254_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp254_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST285 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,LNOT);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST285;
		_t = __t285;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case EQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t286 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp255_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp255_AST = astFactory->create(_t);
		tmp255_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp255_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST286 = currentAST;
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
		currentAST = __currentAST286;
		_t = __t286;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t287 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp256_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp256_AST = astFactory->create(_t);
		tmp256_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp256_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST287 = currentAST;
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
		currentAST = __currentAST287;
		_t = __t287;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case GTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t288 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp257_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp257_AST = astFactory->create(_t);
		tmp257_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp257_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST288 = currentAST;
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
		currentAST = __currentAST288;
		_t = __t288;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t289 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp258_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp258_AST = astFactory->create(_t);
		tmp258_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp258_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST289 = currentAST;
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
		currentAST = __currentAST289;
		_t = __t289;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case LTEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t290 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp259_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp259_AST = astFactory->create(_t);
		tmp259_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp259_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST290 = currentAST;
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
		currentAST = __currentAST290;
		_t = __t290;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case NOTEQUALS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t291 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp260_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp260_AST = astFactory->create(_t);
		tmp260_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp260_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST291 = currentAST;
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
		currentAST = __currentAST291;
		_t = __t291;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ISNULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t292 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp261_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp261_AST = astFactory->create(_t);
		tmp261_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp261_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST292 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,ISNULL);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST292;
		_t = __t292;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t293 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp262_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp262_AST = astFactory->create(_t);
		tmp262_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp262_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST293 = currentAST;
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
		currentAST = __currentAST293;
		_t = __t293;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t294 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp263_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp263_AST = astFactory->create(_t);
		tmp263_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp263_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST294 = currentAST;
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
		currentAST = __currentAST294;
		_t = __t294;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case STRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t295 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp264_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp264_AST = astFactory->create(_t);
		tmp264_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp264_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST295 = currentAST;
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
		currentAST = __currentAST295;
		_t = __t295;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case WSTRING_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t296 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp265_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp265_AST = astFactory->create(_t);
		tmp265_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp265_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST296 = currentAST;
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
		currentAST = __currentAST296;
		_t = __t296;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t297 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp266_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp266_AST = astFactory->create(_t);
		tmp266_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp266_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST297 = currentAST;
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
		currentAST = __currentAST297;
		_t = __t297;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t298 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp267_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp267_AST = astFactory->create(_t);
		tmp267_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp267_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST298 = currentAST;
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
		currentAST = __currentAST298;
		_t = __t298;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t299 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp268_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp268_AST = astFactory->create(_t);
		tmp268_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp268_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST299 = currentAST;
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
		currentAST = __currentAST299;
		_t = __t299;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t300 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp269_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp269_AST = astFactory->create(_t);
		tmp269_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp269_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST300 = currentAST;
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
		currentAST = __currentAST300;
		_t = __t300;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t301 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp270_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp270_AST = astFactory->create(_t);
		tmp270_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp270_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST301 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,INTEGER_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST301;
		_t = __t301;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t302 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp271_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp271_AST = astFactory->create(_t);
		tmp271_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp271_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST302 = currentAST;
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
		currentAST = __currentAST302;
		_t = __t302;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t303 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp272_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp272_AST = astFactory->create(_t);
		tmp272_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp272_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST303 = currentAST;
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
		currentAST = __currentAST303;
		_t = __t303;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t304 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp273_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp273_AST = astFactory->create(_t);
		tmp273_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp273_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST304 = currentAST;
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
		currentAST = __currentAST304;
		_t = __t304;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t305 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp274_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp274_AST = astFactory->create(_t);
		tmp274_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp274_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST305 = currentAST;
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
		currentAST = __currentAST305;
		_t = __t305;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t306 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp275_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp275_AST = astFactory->create(_t);
		tmp275_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp275_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST306 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,BIGINT_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST306;
		_t = __t306;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t307 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp276_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp276_AST = astFactory->create(_t);
		tmp276_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp276_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST307 = currentAST;
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
		currentAST = __currentAST307;
		_t = __t307;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t308 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp277_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp277_AST = astFactory->create(_t);
		tmp277_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp277_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST308 = currentAST;
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
		currentAST = __currentAST308;
		_t = __t308;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t309 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp278_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp278_AST = astFactory->create(_t);
		tmp278_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp278_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST309 = currentAST;
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
		currentAST = __currentAST309;
		_t = __t309;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t310 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp279_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp279_AST = astFactory->create(_t);
		tmp279_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp279_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST310 = currentAST;
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
		currentAST = __currentAST310;
		_t = __t310;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DOUBLE_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t311 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp280_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp280_AST = astFactory->create(_t);
		tmp280_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp280_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST311 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DOUBLE_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST311;
		_t = __t311;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t312 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp281_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp281_AST = astFactory->create(_t);
		tmp281_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp281_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST312 = currentAST;
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
		currentAST = __currentAST312;
		_t = __t312;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_DIVIDE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t313 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp282_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp282_AST = astFactory->create(_t);
		tmp282_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp282_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST313 = currentAST;
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
		currentAST = __currentAST313;
		_t = __t313;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_PLUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t314 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp283_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp283_AST = astFactory->create(_t);
		tmp283_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp283_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST314 = currentAST;
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
		currentAST = __currentAST314;
		_t = __t314;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_TIMES:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t315 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp284_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp284_AST = astFactory->create(_t);
		tmp284_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp284_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST315 = currentAST;
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
		currentAST = __currentAST315;
		_t = __t315;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case DECIMAL_UNARY_MINUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t316 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp285_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp285_AST = astFactory->create(_t);
		tmp285_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp285_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST316 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,DECIMAL_UNARY_MINUS);
		_t = _t->getFirstChild();
		expr(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST316;
		_t = __t316;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case INTEGER_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t317 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp286_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp286_AST = astFactory->create(_t);
		tmp286_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp286_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST317 = currentAST;
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
		currentAST = __currentAST317;
		_t = __t317;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case BIGINT_MODULUS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t318 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp287_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp287_AST = astFactory->create(_t);
		tmp287_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp287_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST318 = currentAST;
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
		currentAST = __currentAST318;
		_t = __t318;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case IFBLOCK:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t319 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp288_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp288_AST = astFactory->create(_t);
		tmp288_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp288_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST319 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFBLOCK);
		_t = _t->getFirstChild();
		{ // ( ... )+
		int _cnt321=0;
		for (;;) {
			if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
				_t = ASTNULL;
			if ((_t->getType() == EXPR || _t->getType() == IFEXPR)) {
				ifThenElse(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				if ( _cnt321>=1 ) { goto _loop321; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
			}
			
			_cnt321++;
		}
		_loop321:;
		}  // ( ... )+
		currentAST = __currentAST319;
		_t = __t319;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case ESEQ:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t322 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp289_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp289_AST = astFactory->create(_t);
		tmp289_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp289_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST322 = currentAST;
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
		currentAST = __currentAST322;
		_t = __t322;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_INTEGER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t323 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp290_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp290_AST = astFactory->create(_t);
		tmp290_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp290_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST323 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_INTEGER);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST323;
		_t = __t323;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t324 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp291_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp291_AST = astFactory->create(_t);
		tmp291_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp291_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST324 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BIGINT);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST324;
		_t = __t324;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DOUBLE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t325 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp292_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp292_AST = astFactory->create(_t);
		tmp292_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp292_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST325 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DOUBLE);
		_t = _t->getFirstChild();
		expression(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST325;
		_t = __t325;
		_t = _t->getNextSibling();
		expr_AST = currentAST.root;
		break;
	}
	case CAST_TO_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t326 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp293_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp293_AST = astFactory->create(_t);
		tmp293_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp293_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST326 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DECIMAL);
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
	case CAST_TO_STRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t327 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp294_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp294_AST = astFactory->create(_t);
		tmp294_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp294_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST327 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_STRING);
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
	case CAST_TO_WSTRING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t328 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp295_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp295_AST = astFactory->create(_t);
		tmp295_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp295_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST328 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_WSTRING);
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
	case CAST_TO_BOOLEAN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t329 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp296_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp296_AST = astFactory->create(_t);
		tmp296_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp296_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST329 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_BOOLEAN);
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
	case CAST_TO_DATETIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t330 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp297_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp297_AST = astFactory->create(_t);
		tmp297_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp297_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST330 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_DATETIME);
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
	case CAST_TO_TIME:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t331 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp298_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp298_AST = astFactory->create(_t);
		tmp298_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp298_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST331 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_TIME);
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
	case CAST_TO_ENUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t332 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp299_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp299_AST = astFactory->create(_t);
		tmp299_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp299_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST332 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,CAST_TO_ENUM);
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

void RewriteOracleTreeParser::queryStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t221 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp300_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp300_AST = astFactory->create(_t);
	tmp300_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp300_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST221 = currentAST;
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
	currentAST = __currentAST221;
	_t = __t221;
	_t = _t->getNextSibling();
	queryStatement_AST = currentAST.root;
	returnAST = queryStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::localParamList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localParamList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t242 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp301_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp301_AST = astFactory->create(_t);
	tmp301_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp301_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST242 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,ARRAY);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_tokenSet_1.member(_t->getType()))) {
			primaryExpression(_t);
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
	localParamList_AST = currentAST.root;
	returnAST = localParamList_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::queryString(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST queryString_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 772 "expandedrewrite_query_oracle.g"
	
	
#line 7073 "RewriteOracleTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t223 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp302_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp302_AST = astFactory->create(_t);
	tmp302_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp302_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST223 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,QUERYSTRING);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt225=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if (((_t->getType() >= TK_AND && _t->getType() <= BIGINT_MODULUS))) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp303_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp303_AST = astFactory->create(_t);
			tmp303_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp303_AST);
			if ( _t == ANTLR_USE_NAMESPACE(antlr)nullAST ) throw ANTLR_USE_NAMESPACE(antlr)MismatchedTokenException();
			_t = _t->getNextSibling();
		}
		else {
			if ( _cnt225>=1 ) { goto _loop225; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt225++;
	}
	_loop225:;
	}  // ( ... )+
	currentAST = __currentAST223;
	_t = __t223;
	_t = _t->getNextSibling();
	queryString_AST = currentAST.root;
	returnAST = queryString_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::localQueryVarList(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void RewriteOracleTreeParser::setmemQuery(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setmemQuery_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t228 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp304_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp304_AST = astFactory->create(_t);
	tmp304_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp304_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST228 = currentAST;
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
			ANTLR_USE_NAMESPACE(antlr)RefAST __t230 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp305_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp305_AST = astFactory->create(_t);
			tmp305_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp305_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST230 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,INTEGER_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST230;
			_t = __t230;
			_t = _t->getNextSibling();
			break;
		}
		case BIGINT_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t231 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp306_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp306_AST = astFactory->create(_t);
			tmp306_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp306_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST231 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BIGINT_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST231;
			_t = __t231;
			_t = _t->getNextSibling();
			break;
		}
		case DOUBLE_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t232 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp307_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp307_AST = astFactory->create(_t);
			tmp307_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp307_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST232 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DOUBLE_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST232;
			_t = __t232;
			_t = _t->getNextSibling();
			break;
		}
		case DECIMAL_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t233 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp308_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp308_AST = astFactory->create(_t);
			tmp308_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp308_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST233 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DECIMAL_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST233;
			_t = __t233;
			_t = _t->getNextSibling();
			break;
		}
		case BOOLEAN_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t234 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp309_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp309_AST = astFactory->create(_t);
			tmp309_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp309_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST234 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,BOOLEAN_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST234;
			_t = __t234;
			_t = _t->getNextSibling();
			break;
		}
		case STRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t235 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp310_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp310_AST = astFactory->create(_t);
			tmp310_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp310_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST235 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,STRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST235;
			_t = __t235;
			_t = _t->getNextSibling();
			break;
		}
		case WSTRING_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t236 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp311_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp311_AST = astFactory->create(_t);
			tmp311_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp311_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST236 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,WSTRING_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST236;
			_t = __t236;
			_t = _t->getNextSibling();
			break;
		}
		case DATETIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t237 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp312_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp312_AST = astFactory->create(_t);
			tmp312_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp312_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST237 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,DATETIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST237;
			_t = __t237;
			_t = _t->getNextSibling();
			break;
		}
		case TIME_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t238 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp313_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp313_AST = astFactory->create(_t);
			tmp313_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp313_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST238 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,TIME_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST238;
			_t = __t238;
			_t = _t->getNextSibling();
			break;
		}
		case ENUM_SETMEM_QUERY:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST __t239 = _t;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp314_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
			tmp314_AST = astFactory->create(_t);
			tmp314_AST_in = _t;
			astFactory->addASTChild(currentAST, tmp314_AST);
			ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST239 = currentAST;
			currentAST.root = currentAST.child;
			currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
			match(_t,ENUM_SETMEM_QUERY);
			_t = _t->getFirstChild();
			varAddress(_t);
			_t = _retTree;
			astFactory->addASTChild( currentAST, returnAST );
			currentAST = __currentAST239;
			_t = __t239;
			_t = _t->getNextSibling();
			break;
		}
		default:
		{
			goto _loop240;
		}
		}
	}
	_loop240:;
	} // ( ... )*
	currentAST = __currentAST228;
	_t = __t228;
	_t = _t->getNextSibling();
	setmemQuery_AST = currentAST.root;
	returnAST = setmemQuery_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::primaryExpression(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp315_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp315_AST = astFactory->create(_t);
		tmp315_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp315_AST);
		match(_t,NUM_INT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp316_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp316_AST = astFactory->create(_t);
		tmp316_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp316_AST);
		match(_t,NUM_BIGINT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp317_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp317_AST = astFactory->create(_t);
		tmp317_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp317_AST);
		match(_t,NUM_FLOAT);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp318_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp318_AST = astFactory->create(_t);
		tmp318_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp318_AST);
		match(_t,NUM_DECIMAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp319_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp319_AST = astFactory->create(_t);
		tmp319_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp319_AST);
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp320_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp320_AST = astFactory->create(_t);
		tmp320_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp320_AST);
		match(_t,WSTRING_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp321_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp321_AST = astFactory->create(_t);
		tmp321_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp321_AST);
		match(_t,ENUM_LITERAL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp322_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp322_AST = astFactory->create(_t);
		tmp322_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp322_AST);
		match(_t,TK_TRUE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp323_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp323_AST = astFactory->create(_t);
		tmp323_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp323_AST);
		match(_t,TK_FALSE);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp324_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp324_AST = astFactory->create(_t);
		tmp324_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp324_AST);
		match(_t,TK_NULL);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case METHOD_CALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t337 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp325_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp325_AST = astFactory->create(_t);
		tmp325_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp325_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST337 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,METHOD_CALL);
		_t = _t->getFirstChild();
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp326_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp326_AST = astFactory->create(_t);
		tmp326_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp326_AST);
		match(_t,ID);
		_t = _t->getNextSibling();
		elist(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp327_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp327_AST = astFactory->create(_t);
		tmp327_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp327_AST);
		match(_t,RPAREN);
		_t = _t->getNextSibling();
		currentAST = __currentAST337;
		_t = __t337;
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case INTEGER_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp328_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp328_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp328_AST = astFactory->create(_t);
		tmp328_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp328_AST);
		match(_t,INTEGER_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BIGINT_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp329_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp329_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp329_AST = astFactory->create(_t);
		tmp329_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp329_AST);
		match(_t,BIGINT_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DOUBLE_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp330_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp330_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp330_AST = astFactory->create(_t);
		tmp330_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp330_AST);
		match(_t,DOUBLE_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DECIMAL_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp331_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp331_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp331_AST = astFactory->create(_t);
		tmp331_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp331_AST);
		match(_t,DECIMAL_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case BOOLEAN_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp332_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp332_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp332_AST = astFactory->create(_t);
		tmp332_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp332_AST);
		match(_t,BOOLEAN_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case STRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp333_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp333_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp333_AST = astFactory->create(_t);
		tmp333_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp333_AST);
		match(_t,STRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case WSTRING_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp334_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp334_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp334_AST = astFactory->create(_t);
		tmp334_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp334_AST);
		match(_t,WSTRING_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case DATETIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp335_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp335_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp335_AST = astFactory->create(_t);
		tmp335_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp335_AST);
		match(_t,DATETIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case TIME_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp336_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp336_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp336_AST = astFactory->create(_t);
		tmp336_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp336_AST);
		match(_t,TIME_GETMEM);
		_t = _t->getNextSibling();
		primaryExpression_AST = currentAST.root;
		break;
	}
	case ENUM_GETMEM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp337_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp337_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp337_AST = astFactory->create(_t);
		tmp337_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp337_AST);
		match(_t,ENUM_GETMEM);
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

void RewriteOracleTreeParser::delayedStatement(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t249 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp338_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp338_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp338_AST = astFactory->create(_t);
	tmp338_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp338_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST249 = currentAST;
	currentAST.root = currentAST.child;
	currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
	match(_t,DELAYED_STMT);
	_t = _t->getFirstChild();
	statement(_t);
	_t = _retTree;
	astFactory->addASTChild( currentAST, returnAST );
	currentAST = __currentAST249;
	_t = __t249;
	_t = _t->getNextSibling();
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::elist(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elist_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t272 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp339_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp339_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp339_AST = astFactory->create(_t);
	tmp339_AST_in = _t;
	astFactory->addASTChild(currentAST, tmp339_AST);
	ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST272 = currentAST;
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
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp340_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp340_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
				tmp340_AST = astFactory->create(_t);
				tmp340_AST_in = _t;
				astFactory->addASTChild(currentAST, tmp340_AST);
				match(_t,COMMA);
				_t = _t->getNextSibling();
				expression(_t);
				_t = _retTree;
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop275;
			}
			
		}
		_loop275:;
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
	currentAST = __currentAST272;
	_t = __t272;
	_t = _t->getNextSibling();
	elist_AST = currentAST.root;
	returnAST = elist_AST;
	_retTree = _t;
}

void RewriteOracleTreeParser::ifThenElse(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifThenElse_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case IFEXPR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST __t334 = _t;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp341_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp341_AST_in = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp341_AST = astFactory->create(_t);
		tmp341_AST_in = _t;
		astFactory->addASTChild(currentAST, tmp341_AST);
		ANTLR_USE_NAMESPACE(antlr)ASTPair __currentAST334 = currentAST;
		currentAST.root = currentAST.child;
		currentAST.child = ANTLR_USE_NAMESPACE(antlr)nullAST;
		match(_t,IFEXPR);
		_t = _t->getFirstChild();
		conditional(_t);
		_t = _retTree;
		astFactory->addASTChild( currentAST, returnAST );
		currentAST = __currentAST334;
		_t = __t334;
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

void RewriteOracleTreeParser::conditional(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conditional_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 928 "expandedrewrite_query_oracle.g"
	
	
#line 7833 "RewriteOracleTreeParser.cpp"
	
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

void RewriteOracleTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(246);
}
const char* RewriteOracleTreeParser::tokenNames[] = {
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

const unsigned long RewriteOracleTreeParser::_tokenSet_0_data_[] = { 17317888UL, 0UL, 1UL, 0UL, 2113536UL, 161UL, 1072693248UL, 1699840UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BREAK" "CONTINUE" "DECLARE" "RETURN" IFTHENELSE QUERY SLIST WHILE SEQUENCE 
// INTEGER_SETMEM BIGINT_SETMEM DOUBLE_SETMEM DECIMAL_SETMEM STRING_SETMEM 
// WSTRING_SETMEM BOOLEAN_SETMEM DATETIME_SETMEM TIME_SETMEM ENUM_SETMEM 
// RAISERRORINTEGER RAISERRORSTRING RAISERRORWSTRING RAISERROR2STRING RAISERROR2WSTRING 
// STRING_PRINT WSTRING_PRINT 
const ANTLR_USE_NAMESPACE(antlr)BitSet RewriteOracleTreeParser::_tokenSet_0(_tokenSet_0_data_,16);
const unsigned long RewriteOracleTreeParser::_tokenSet_1_data_[] = { 0UL, 2097154UL, 459264UL, 17235968UL, 526336UL, 0UL, 523776UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "FALSE" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL NUM_INT EXPR METHOD_CALL INTEGER_GETMEM 
// BIGINT_GETMEM DOUBLE_GETMEM DECIMAL_GETMEM STRING_GETMEM WSTRING_GETMEM 
// BOOLEAN_GETMEM DATETIME_GETMEM TIME_GETMEM ENUM_GETMEM 
const ANTLR_USE_NAMESPACE(antlr)BitSet RewriteOracleTreeParser::_tokenSet_1(_tokenSet_1_data_,16);


