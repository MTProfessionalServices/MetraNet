/* $ANTLR 2.7.6 (2005-12-22): "expandedmtsql_parser_oracle.g" -> "MTSQLOracleParser.cpp"$ */
#include "MTSQLOracleParser.hpp"
#include <antlr/NoViableAltException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/ASTFactory.hpp>
MTSQLOracleParser::MTSQLOracleParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,k)
{
}

MTSQLOracleParser::MTSQLOracleParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,3)
{
}

MTSQLOracleParser::MTSQLOracleParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,k)
{
}

MTSQLOracleParser::MTSQLOracleParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,3)
{
}

MTSQLOracleParser::MTSQLOracleParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(state,3)
{
}

void MTSQLOracleParser::sql92_joinedTable() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinedTable_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	std::string joinType = "INNER";
	
	
	sql92_tableReference();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		switch ( LA(1)) {
		case TK_FULL:
		case TK_INNER:
		case TK_JOIN:
		case TK_LEFT:
		case TK_RIGHT:
		{
			{
			{
			switch ( LA(1)) {
			case TK_FULL:
			case TK_INNER:
			case TK_LEFT:
			case TK_RIGHT:
			{
				{
				switch ( LA(1)) {
				case TK_INNER:
				{
					match(TK_INNER);
					if ( inputState->guessing==0 ) {
						joinType = "INNER";
					}
					break;
				}
				case TK_FULL:
				case TK_LEFT:
				case TK_RIGHT:
				{
					{
					switch ( LA(1)) {
					case TK_FULL:
					{
						match(TK_FULL);
						if ( inputState->guessing==0 ) {
							joinType = "FULL OUTER";
						}
						break;
					}
					case TK_LEFT:
					{
						match(TK_LEFT);
						if ( inputState->guessing==0 ) {
							joinType = "LEFT OUTER";
						}
						break;
					}
					case TK_RIGHT:
					{
						match(TK_RIGHT);
						if ( inputState->guessing==0 ) {
							joinType = "RIGHT OUTER";
						}
						break;
					}
					default:
					{
						throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
					}
					}
					}
					{
					switch ( LA(1)) {
					case TK_OUTER:
					{
						match(TK_OUTER);
						break;
					}
					case TK_JOIN:
					case ID:
					{
						break;
					}
					default:
					{
						throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
					}
					}
					}
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
				{
				switch ( LA(1)) {
				case ID:
				{
					id = LT(1);
					if ( inputState->guessing == 0 ) {
						id_AST = astFactory->create(id);
					}
					match(ID);
					if ( inputState->guessing==0 ) {
						
						joinType += " ";
						char buf[512];
						sprintf(buf, "SQL Server style join hints are not supported on Oracle, ignoring. (%s)!",  id_AST->getText().c_str());
						reportWarning(string(buf));
						
					}
					break;
				}
				case TK_JOIN:
				{
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
				break;
			}
			case TK_JOIN:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp6_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp6_AST = astFactory->create(LT(1));
				astFactory->makeASTRoot(currentAST, tmp6_AST);
			}
			match(TK_JOIN);
			if ( inputState->guessing==0 ) {
				sql92_joinedTable_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
				sql92_joinedTable_AST->setText(joinType + " JOIN");
			}
			sql92_joinedTable();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			sql92_joinCriteria();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			}
			break;
		}
		case TK_CROSS:
		{
			match(TK_CROSS);
			if ( inputState->guessing==0 ) {
				joinType = "CROSS JOIN";
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp8_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp8_AST = astFactory->create(LT(1));
				astFactory->makeASTRoot(currentAST, tmp8_AST);
			}
			match(TK_JOIN);
			if ( inputState->guessing==0 ) {
				sql92_joinedTable_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
				sql92_joinedTable_AST->setType(CROSS_JOIN); sql92_joinedTable_AST->setText(joinType);
			}
			sql92_tableReference();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		default:
		{
			goto _loop9;
		}
		}
	}
	_loop9:;
	} // ( ... )*
	sql92_joinedTable_AST = currentAST.root;
	returnAST = sql92_joinedTable_AST;
}

void MTSQLOracleParser::sql92_tableReference() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableReference_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  alias = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST alias_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  alias2 = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST alias2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	if ((LA(1) == ID)) {
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp9_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp9_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp9_AST);
		}
		match(ID);
		if ( inputState->guessing==0 ) {
			sql92_tableReference_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			sql92_tableReference_AST->setType(TABLE_REF);
		}
		{
		switch ( LA(1)) {
		case TK_AS:
		case ID:
		{
			{
			switch ( LA(1)) {
			case TK_AS:
			{
				match(TK_AS);
				break;
			}
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			alias = LT(1);
			if ( inputState->guessing == 0 ) {
				alias_AST = astFactory->create(alias);
				astFactory->addASTChild(currentAST, alias_AST);
			}
			match(ID);
			if ( inputState->guessing==0 ) {
				alias_AST->setType(ALIAS);
			}
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_FULL:
		case TK_GROUP:
		case TK_IF:
		case TK_INNER:
		case TK_JOIN:
		case TK_LEFT:
		case TK_ON:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_UNION:
		case TK_WHERE:
		case TK_WHILE:
		case TK_WITH:
		case TK_LOCK:
		case TK_FOR:
		case COMMA:
		case RPAREN:
		case SEMI:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		{
		switch ( LA(1)) {
		case TK_WITH:
		{
			sql92_tableHint();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_FULL:
		case TK_GROUP:
		case TK_IF:
		case TK_INNER:
		case TK_JOIN:
		case TK_LEFT:
		case TK_ON:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_UNION:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case TK_FOR:
		case COMMA:
		case RPAREN:
		case SEMI:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		{
		switch ( LA(1)) {
		case TK_FOR:
		{
			oracle_for_update_of_hint();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_FULL:
		case TK_GROUP:
		case TK_IF:
		case TK_INNER:
		case TK_JOIN:
		case TK_LEFT:
		case TK_ON:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_UNION:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case COMMA:
		case RPAREN:
		case SEMI:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_tableReference_AST = currentAST.root;
	}
	else if ((LA(1) == LPAREN) && (LA(2) == TK_SELECT)) {
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp11_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp11_AST);
		}
		match(LPAREN);
		if ( inputState->guessing==0 ) {
			sql92_tableReference_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			sql92_tableReference_AST->setType(DERIVED_TABLE);
		}
		sql92_selectStatement();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp12_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp12_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp12_AST);
		}
		match(RPAREN);
		{
		switch ( LA(1)) {
		case TK_AS:
		{
			match(TK_AS);
			break;
		}
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		alias2 = LT(1);
		if ( inputState->guessing == 0 ) {
			alias2_AST = astFactory->create(alias2);
			astFactory->addASTChild(currentAST, alias2_AST);
		}
		match(ID);
		if ( inputState->guessing==0 ) {
			alias2_AST->setType(ALIAS);
		}
		sql92_tableReference_AST = currentAST.root;
	}
	else if ((LA(1) == LPAREN) && (LA(2) == LPAREN || LA(2) == ID)) {
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp14_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp14_AST);
		}
		match(LPAREN);
		if ( inputState->guessing==0 ) {
			sql92_tableReference_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			sql92_tableReference_AST->setType(GROUPED_JOIN);
		}
		sql92_joinedTable();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp15_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp15_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp15_AST);
		}
		match(RPAREN);
		sql92_tableReference_AST = currentAST.root;
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	returnAST = sql92_tableReference_AST;
}

void MTSQLOracleParser::sql92_joinCriteria() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_joinCriteria_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp16_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp16_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp16_AST);
	}
	match(TK_ON);
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_joinCriteria_AST = currentAST.root;
	returnAST = sql92_joinCriteria_AST;
}

void MTSQLOracleParser::sql92_tableHint() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableHint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	std::string tableHint = "";
	
	
	id = LT(1);
	if ( inputState->guessing == 0 ) {
		id_AST = astFactory->create(id);
	}
	match(TK_WITH);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp17_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp17_AST = astFactory->create(LT(1));
	}
	match(LPAREN);
	{
	switch ( LA(1)) {
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp18_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp18_AST = astFactory->create(LT(1));
		}
		match(ID);
		break;
	}
	case TK_INDEX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp19_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp19_AST = astFactory->create(LT(1));
		}
		match(TK_INDEX);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp20_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp20_AST = astFactory->create(LT(1));
		}
		match(LPAREN);
		{
		switch ( LA(1)) {
		case ID:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp21_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp21_AST = astFactory->create(LT(1));
			}
			match(ID);
			break;
		}
		case NUM_INT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp22_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp22_AST = astFactory->create(LT(1));
			}
			match(NUM_INT);
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		{ // ( ... )*
		for (;;) {
			if ((LA(1) == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp23_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp23_AST = astFactory->create(LT(1));
				}
				match(COMMA);
				{
				switch ( LA(1)) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp24_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp24_AST = astFactory->create(LT(1));
					}
					match(ID);
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp25_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp25_AST = astFactory->create(LT(1));
					}
					match(NUM_INT);
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
			}
			else {
				goto _loop15;
			}
			
		}
		_loop15:;
		} // ( ... )*
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp26_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp26_AST = astFactory->create(LT(1));
		}
		match(RPAREN);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp27_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp27_AST = astFactory->create(LT(1));
			}
			match(COMMA);
			{
			switch ( LA(1)) {
			case ID:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp28_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp28_AST = astFactory->create(LT(1));
				}
				match(ID);
				break;
			}
			case TK_INDEX:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp29_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp29_AST = astFactory->create(LT(1));
				}
				match(TK_INDEX);
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp30_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp30_AST = astFactory->create(LT(1));
				}
				match(LPAREN);
				{
				switch ( LA(1)) {
				case ID:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp31_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp31_AST = astFactory->create(LT(1));
					}
					match(ID);
					break;
				}
				case NUM_INT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp32_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp32_AST = astFactory->create(LT(1));
					}
					match(NUM_INT);
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
				{ // ( ... )*
				for (;;) {
					if ((LA(1) == COMMA)) {
						ANTLR_USE_NAMESPACE(antlr)RefAST tmp33_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
						if ( inputState->guessing == 0 ) {
							tmp33_AST = astFactory->create(LT(1));
						}
						match(COMMA);
						{
						switch ( LA(1)) {
						case ID:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp34_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							if ( inputState->guessing == 0 ) {
								tmp34_AST = astFactory->create(LT(1));
							}
							match(ID);
							break;
						}
						case NUM_INT:
						{
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp35_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							if ( inputState->guessing == 0 ) {
								tmp35_AST = astFactory->create(LT(1));
							}
							match(NUM_INT);
							break;
						}
						default:
						{
							throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
						}
						}
						}
					}
					else {
						goto _loop21;
					}
					
				}
				_loop21:;
				} // ( ... )*
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp36_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp36_AST = astFactory->create(LT(1));
				}
				match(RPAREN);
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else {
			goto _loop22;
		}
		
	}
	_loop22:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp37_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp37_AST = astFactory->create(LT(1));
	}
	match(RPAREN);
	if ( inputState->guessing==0 ) {
		
		char buf[512];
		sprintf(buf, "SQL Server style locking hints are not supported on Oracle, ignoring!");
		reportWarning(string(buf));
		
	}
	returnAST = sql92_tableHint_AST;
}

void MTSQLOracleParser::oracle_for_update_of_hint() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_for_update_of_hint_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	id = LT(1);
	if ( inputState->guessing == 0 ) {
		id_AST = astFactory->create(id);
		astFactory->makeASTRoot(currentAST, id_AST);
	}
	match(TK_FOR);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp38_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp38_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp38_AST);
	}
	match(TK_UPDATE);
	{
	switch ( LA(1)) {
	case TK_OF:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp39_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp39_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp39_AST);
		}
		match(TK_OF);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp40_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp40_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp40_AST);
		}
		match(ID);
		{
		switch ( LA(1)) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp41_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp41_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp41_AST);
			}
			match(DOT);
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp42_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp42_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp42_AST);
			}
			match(ID);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_FULL:
		case TK_GROUP:
		case TK_IF:
		case TK_INNER:
		case TK_JOIN:
		case TK_LEFT:
		case TK_ON:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_UNION:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case COMMA:
		case RPAREN:
		case SEMI:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_CROSS:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_FULL:
	case TK_GROUP:
	case TK_IF:
	case TK_INNER:
	case TK_JOIN:
	case TK_LEFT:
	case TK_ON:
	case TK_ORDER:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_RIGHT:
	case TK_SELECT:
	case TK_SET:
	case TK_UNION:
	case TK_WHERE:
	case TK_WHILE:
	case TK_LOCK:
	case COMMA:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	if ( inputState->guessing==0 ) {
		
		
		
	}
	oracle_for_update_of_hint_AST = currentAST.root;
	returnAST = oracle_for_update_of_hint_AST;
}

void MTSQLOracleParser::sql92_selectStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_queryExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_UNION)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp43_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp43_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp43_AST);
			}
			match(TK_UNION);
			{
			switch ( LA(1)) {
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp44_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp44_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp44_AST);
				}
				match(TK_ALL);
				break;
			}
			case TK_SELECT:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			sql92_queryExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop142;
		}
		
	}
	_loop142:;
	} // ( ... )*
	{
	switch ( LA(1)) {
	case TK_ORDER:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp45_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp45_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp45_AST);
		}
		match(TK_ORDER);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp46_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp46_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp46_AST);
		}
		match(TK_BY);
		sql92_orderByExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_WHILE:
	case TK_LOCK:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_selectStatement_AST = currentAST.root;
	returnAST = sql92_selectStatement_AST;
}

void MTSQLOracleParser::statement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		{
		switch ( LA(1)) {
		case TK_SET:
		{
			setStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_DECLARE:
		{
			variableDeclaration();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_PRINT:
		{
			printStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_IF:
		{
			ifStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_BEGIN:
		{
			statementBlock();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_RETURN:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp51_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp51_AST = astFactory->create(LT(1));
				astFactory->makeASTRoot(currentAST, tmp51_AST);
			}
			match(TK_RETURN);
			{
			switch ( LA(1)) {
			case TK_CASE:
			case TK_CAST:
			case TK_FALSE:
			case TK_NOT:
			case TK_NULL:
			case TK_TRUE:
			case NUM_DECIMAL:
			case NUM_FLOAT:
			case NUM_BIGINT:
			case LPAREN:
			case MINUS:
			case PLUS:
			case STRING_LITERAL:
			case ENUM_LITERAL:
			case WSTRING_LITERAL:
			case TILDE:
			case ID:
			case LOCALVAR:
			case GLOBALVAR:
			case NUM_INT:
			{
				expression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			case SEMI:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_BREAK:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp53_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp53_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp53_AST);
			}
			match(TK_BREAK);
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_CONTINUE:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp55_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp55_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp55_AST);
			}
			match(TK_CONTINUE);
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_RAISERROR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp57_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp57_AST = astFactory->create(LT(1));
				astFactory->makeASTRoot(currentAST, tmp57_AST);
			}
			match(TK_RAISERROR);
			match(LPAREN);
			expression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			if ( inputState->guessing==0 ) {
				statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
				statement_AST->setType(RAISERROR1);
			}
			{
			switch ( LA(1)) {
			case COMMA:
			{
				match(COMMA);
				expression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				if ( inputState->guessing==0 ) {
					statement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
					statement_AST->setType(RAISERROR2);
				}
				break;
			}
			case RPAREN:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			match(RPAREN);
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_WHILE:
		{
			whileStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_SELECT:
		{
			sql92_selectStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case SEMI:
			{
				match(SEMI);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_LOCK:
		{
			oracle_lock_statement();
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		statement_AST = currentAST.root;
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		if( inputState->guessing == 0 ) {
			reportError(ex);
			recover(ex,_tokenSet_0);
		} else {
			throw;
		}
	}
	returnAST = statement_AST;
}

void MTSQLOracleParser::setStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST setStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  set = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST set_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	set = LT(1);
	if ( inputState->guessing == 0 ) {
		set_AST = astFactory->create(set);
		astFactory->makeASTRoot(currentAST, set_AST);
	}
	match(TK_SET);
	if ( inputState->guessing==0 ) {
		set_AST->setType(ASSIGN);
	}
	variableName();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	match(EQUALS);
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	setStatement_AST = currentAST.root;
	returnAST = setStatement_AST;
}

void MTSQLOracleParser::variableDeclaration() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST variableDeclaration_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp64_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp64_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp64_AST);
	}
	match(TK_DECLARE);
	variableName();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	builtInType();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	variableDeclaration_AST = currentAST.root;
	returnAST = variableDeclaration_AST;
}

void MTSQLOracleParser::printStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST printStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp65_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp65_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp65_AST);
	}
	match(TK_PRINT);
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	printStatement_AST = currentAST.root;
	returnAST = printStatement_AST;
}

void MTSQLOracleParser::ifStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ifStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST i_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	i = LT(1);
	if ( inputState->guessing == 0 ) {
		i_AST = astFactory->create(i);
		astFactory->makeASTRoot(currentAST, i_AST);
	}
	match(TK_IF);
	if ( inputState->guessing==0 ) {
		i_AST->setType(IFTHENELSE);
	}
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	delayedStatement();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	if ((LA(1) == TK_ELSE) && (_tokenSet_1.member(LA(2))) && (_tokenSet_2.member(LA(3)))) {
		match(TK_ELSE);
		delayedStatement();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
	}
	else if ((_tokenSet_0.member(LA(1))) && (_tokenSet_2.member(LA(2))) && (_tokenSet_3.member(LA(3)))) {
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	}
	ifStatement_AST = currentAST.root;
	returnAST = ifStatement_AST;
}

void MTSQLOracleParser::statementBlock() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statementBlock_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  b = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST b_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	b = LT(1);
	if ( inputState->guessing == 0 ) {
		b_AST = astFactory->create(b);
		astFactory->makeASTRoot(currentAST, b_AST);
	}
	match(TK_BEGIN);
	if ( inputState->guessing==0 ) {
		b_AST->setType(SLIST);
	}
	{ // ( ... )*
	for (;;) {
		if ((_tokenSet_1.member(LA(1)))) {
			statement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop85;
		}
		
	}
	_loop85:;
	} // ( ... )*
	match(TK_END);
	statementBlock_AST = currentAST.root;
	returnAST = statementBlock_AST;
}

void MTSQLOracleParser::expression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	}
	if ( inputState->guessing==0 ) {
		expression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		expression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(expression_AST)));
		currentAST.root = expression_AST;
		if ( expression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			expression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = expression_AST->getFirstChild();
		else
			currentAST.child = expression_AST;
		currentAST.advanceChildToEnd();
	}
	expression_AST = currentAST.root;
	returnAST = expression_AST;
}

void MTSQLOracleParser::whileStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whileStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  w = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST w_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	w = LT(1);
	if ( inputState->guessing == 0 ) {
		w_AST = astFactory->create(w);
		astFactory->makeASTRoot(currentAST, w_AST);
	}
	match(TK_WHILE);
	if ( inputState->guessing==0 ) {
		w_AST->setType(WHILE);
	}
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	delayedStatement();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	whileStatement_AST = currentAST.root;
	returnAST = whileStatement_AST;
}

void MTSQLOracleParser::oracle_lock_statement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST oracle_lock_statement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  l = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST l_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  schema = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST schema_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  table = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST table_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	l = LT(1);
	if ( inputState->guessing == 0 ) {
		l_AST = astFactory->create(l);
		astFactory->makeASTRoot(currentAST, l_AST);
	}
	match(TK_LOCK);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp68_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp68_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp68_AST);
	}
	match(TK_TABLE);
	schema = LT(1);
	if ( inputState->guessing == 0 ) {
		schema_AST = astFactory->create(schema);
		astFactory->addASTChild(currentAST, schema_AST);
	}
	match(ID);
	{
	switch ( LA(1)) {
	case DOT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp69_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp69_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp69_AST);
		}
		match(DOT);
		table = LT(1);
		if ( inputState->guessing == 0 ) {
			table_AST = astFactory->create(table);
			astFactory->addASTChild(currentAST, table_AST);
		}
		match(ID);
		break;
	}
	case TK_IN:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp70_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp70_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp70_AST);
	}
	match(TK_IN);
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == ID)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp71_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp71_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp71_AST);
			}
			match(ID);
		}
		else {
			goto _loop48;
		}
		
	}
	_loop48:;
	} // ( ... )*
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp72_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp72_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp72_AST);
	}
	match(TK_MODE);
	{
	switch ( LA(1)) {
	case TK_NOWAIT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp73_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp73_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp73_AST);
		}
		match(TK_NOWAIT);
		break;
	}
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp74_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp74_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp74_AST);
	}
	match(SEMI);
	oracle_lock_statement_AST = currentAST.root;
	returnAST = oracle_lock_statement_AST;
}

void MTSQLOracleParser::program() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		if ((LA(1) == TK_CREATE) && (LA(2) == TK_PROCEDURE)) {
			match(TK_CREATE);
			match(TK_PROCEDURE);
			match(ID);
			programArgList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			match(TK_AS);
			statementList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			match(ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
			program_AST = currentAST.root;
		}
		else if ((LA(1) == TK_CREATE) && (LA(2) == TK_FUNCTION)) {
			match(TK_CREATE);
			match(TK_FUNCTION);
			match(ID);
			match(LPAREN);
			programArgList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			match(RPAREN);
			returnsDecl();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			match(TK_AS);
			statementList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			match(ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE);
			program_AST = currentAST.root;
		}
		else {
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		if( inputState->guessing == 0 ) {
			reportError(ex);
			recover(ex,_tokenSet_4);
		} else {
			throw;
		}
	}
	returnAST = program_AST;
}

void MTSQLOracleParser::programArgList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST programArgList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == ID || LA(1) == LOCALVAR)) {
			programArgDecl();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case COMMA:
			{
				match(COMMA);
				break;
			}
			case TK_AS:
			case RPAREN:
			case ID:
			case LOCALVAR:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else {
			goto _loop55;
		}
		
	}
	_loop55:;
	} // ( ... )*
	programArgList_AST = currentAST.root;
	returnAST = programArgList_AST;
}

void MTSQLOracleParser::statementList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST statementList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		{ // ( ... )*
		for (;;) {
			if ((_tokenSet_1.member(LA(1)))) {
				statement();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				goto _loop60;
			}
			
		}
		_loop60:;
		} // ( ... )*
		if ( inputState->guessing==0 ) {
			statementList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			statementList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(SCOPE,"SCOPE"))->add(statementList_AST)));
			currentAST.root = statementList_AST;
			if ( statementList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
				statementList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
				  currentAST.child = statementList_AST->getFirstChild();
			else
				currentAST.child = statementList_AST;
			currentAST.advanceChildToEnd();
		}
		statementList_AST = currentAST.root;
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		if( inputState->guessing == 0 ) {
			reportError(ex);
			recover(ex,_tokenSet_4);
		} else {
			throw;
		}
	}
	returnAST = statementList_AST;
}

void MTSQLOracleParser::returnsDecl() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST returnsDecl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp88_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp88_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp88_AST);
	}
	match(TK_RETURNS);
	builtInType();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	returnsDecl_AST = currentAST.root;
	returnAST = returnsDecl_AST;
}

void MTSQLOracleParser::builtInType() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST i_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dbl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dbl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  str = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST str_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  wstr = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dec = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dec_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  b = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST b_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dt = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dt_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  tm = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST tm_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  en = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST en_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bi = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bi_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bin = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bin_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case TK_INTEGER:
	{
		i = LT(1);
		if ( inputState->guessing == 0 ) {
			i_AST = astFactory->create(i);
			astFactory->makeASTRoot(currentAST, i_AST);
		}
		match(TK_INTEGER);
		if ( inputState->guessing==0 ) {
			i_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DOUBLE:
	{
		dbl = LT(1);
		if ( inputState->guessing == 0 ) {
			dbl_AST = astFactory->create(dbl);
			astFactory->makeASTRoot(currentAST, dbl_AST);
		}
		match(TK_DOUBLE);
		{
		switch ( LA(1)) {
		case TK_PRECISION:
		{
			match(TK_PRECISION);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_IF:
		case TK_OUTPUT:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_SELECT:
		case TK_SET:
		case TK_WHILE:
		case TK_LOCK:
		case COMMA:
		case RPAREN:
		case SEMI:
		case ID:
		case LOCALVAR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		if ( inputState->guessing==0 ) {
			dbl_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_VARCHAR:
	{
		str = LT(1);
		if ( inputState->guessing == 0 ) {
			str_AST = astFactory->create(str);
			astFactory->makeASTRoot(currentAST, str_AST);
		}
		match(TK_VARCHAR);
		{
		switch ( LA(1)) {
		case LPAREN:
		{
			match(LPAREN);
			match(NUM_INT);
			match(RPAREN);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_IF:
		case TK_OUTPUT:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_SELECT:
		case TK_SET:
		case TK_WHILE:
		case TK_LOCK:
		case COMMA:
		case RPAREN:
		case SEMI:
		case ID:
		case LOCALVAR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		if ( inputState->guessing==0 ) {
			str_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_NVARCHAR:
	{
		wstr = LT(1);
		if ( inputState->guessing == 0 ) {
			wstr_AST = astFactory->create(wstr);
			astFactory->makeASTRoot(currentAST, wstr_AST);
		}
		match(TK_NVARCHAR);
		{
		switch ( LA(1)) {
		case LPAREN:
		{
			match(LPAREN);
			match(NUM_INT);
			match(RPAREN);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_IF:
		case TK_OUTPUT:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_SELECT:
		case TK_SET:
		case TK_WHILE:
		case TK_LOCK:
		case COMMA:
		case RPAREN:
		case SEMI:
		case ID:
		case LOCALVAR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		if ( inputState->guessing==0 ) {
			wstr_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DECIMAL:
	{
		dec = LT(1);
		if ( inputState->guessing == 0 ) {
			dec_AST = astFactory->create(dec);
			astFactory->makeASTRoot(currentAST, dec_AST);
		}
		match(TK_DECIMAL);
		if ( inputState->guessing==0 ) {
			dec_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_BOOLEAN:
	{
		b = LT(1);
		if ( inputState->guessing == 0 ) {
			b_AST = astFactory->create(b);
			astFactory->makeASTRoot(currentAST, b_AST);
		}
		match(TK_BOOLEAN);
		if ( inputState->guessing==0 ) {
			b_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DATETIME:
	{
		dt = LT(1);
		if ( inputState->guessing == 0 ) {
			dt_AST = astFactory->create(dt);
			astFactory->makeASTRoot(currentAST, dt_AST);
		}
		match(TK_DATETIME);
		if ( inputState->guessing==0 ) {
			dt_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_TIME:
	{
		tm = LT(1);
		if ( inputState->guessing == 0 ) {
			tm_AST = astFactory->create(tm);
			astFactory->makeASTRoot(currentAST, tm_AST);
		}
		match(TK_TIME);
		if ( inputState->guessing==0 ) {
			tm_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_ENUM:
	{
		en = LT(1);
		if ( inputState->guessing == 0 ) {
			en_AST = astFactory->create(en);
			astFactory->makeASTRoot(currentAST, en_AST);
		}
		match(TK_ENUM);
		if ( inputState->guessing==0 ) {
			en_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_BIGINT:
	{
		bi = LT(1);
		if ( inputState->guessing == 0 ) {
			bi_AST = astFactory->create(bi);
			astFactory->makeASTRoot(currentAST, bi_AST);
		}
		match(TK_BIGINT);
		if ( inputState->guessing==0 ) {
			bi_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case ID:
	{
		bin = LT(1);
		if ( inputState->guessing == 0 ) {
			bin_AST = astFactory->create(bin);
			astFactory->makeASTRoot(currentAST, bin_AST);
		}
		match(ID);
		if ( inputState->guessing==0 ) {
			
			if (boost::algorithm::iequals(bin_AST->getText(), "binary"))
			{
			bin_AST->setType(BUILTIN_TYPE); 
			}
			else
			{
			throw MTSQLSemanticException((boost::format("Expecting INTEGER, VARCHAR, NVARCHAR, DOUBLE PRECISION, DECIMAL, DATETIME, ENUM, BIGINT, BINARY: found %1%") % bin_AST->getText()).str(),  (RefMTSQLAST) bin_AST); 
			}
			
		}
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	builtInType_AST = currentAST.root;
	returnAST = builtInType_AST;
}

void MTSQLOracleParser::programArgDecl() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST programArgDecl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bit_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  ou = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST ou_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	variableName();
	if (inputState->guessing==0) {
		lv_AST = returnAST;
	}
	builtInType();
	if (inputState->guessing==0) {
		bit_AST = returnAST;
	}
	{
	switch ( LA(1)) {
	case TK_OUTPUT:
	{
		ou = LT(1);
		if ( inputState->guessing == 0 ) {
			ou_AST = astFactory->create(ou);
		}
		match(TK_OUTPUT);
		break;
	}
	case TK_AS:
	case COMMA:
	case RPAREN:
	case ID:
	case LOCALVAR:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	if ( inputState->guessing==0 ) {
		programArgDecl_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		programArgDecl_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(4))->add(astFactory->create(TK_DECLARE,"DECLARE"))->add(lv_AST)->add(bit_AST)->add(ou_AST)));
		currentAST.root = programArgDecl_AST;
		if ( programArgDecl_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			programArgDecl_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = programArgDecl_AST->getFirstChild();
		else
			currentAST.child = programArgDecl_AST;
		currentAST.advanceChildToEnd();
	}
	returnAST = programArgDecl_AST;
}

void MTSQLOracleParser::variableName() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST variableName_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	switch ( LA(1)) {
	case LOCALVAR:
	{
		localvarName();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		variableName_AST = currentAST.root;
		break;
	}
	case ID:
	{
		idName();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		variableName_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	returnAST = variableName_AST;
}

void MTSQLOracleParser::localQueryVarList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localQueryVarList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	localQueryVar();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			localQueryVar();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop63;
		}
		
	}
	_loop63:;
	} // ( ... )*
	if ( inputState->guessing==0 ) {
		localQueryVarList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		localQueryVarList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ARRAY,"ARRAY"))->add(localQueryVarList_AST)));
		currentAST.root = localQueryVarList_AST;
		if ( localQueryVarList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			localQueryVarList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = localQueryVarList_AST->getFirstChild();
		else
			currentAST.child = localQueryVarList_AST;
		currentAST.advanceChildToEnd();
	}
	localQueryVarList_AST = currentAST.root;
	returnAST = localQueryVarList_AST;
}

void MTSQLOracleParser::localQueryVar() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localQueryVar_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	variableName();
	if (inputState->guessing==0) {
		lv_AST = returnAST;
		astFactory->addASTChild( currentAST, returnAST );
	}
	if ( inputState->guessing==0 ) {
		localQueryVar_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		localQueryVar_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ASSIGN_QUERY,"ASSIGN_QUERY"))->add(localQueryVar_AST)));
		currentAST.root = localQueryVar_AST;
		if ( localQueryVar_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			localQueryVar_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = localQueryVar_AST->getFirstChild();
		else
			currentAST.child = localQueryVar_AST;
		currentAST.advanceChildToEnd();
	}
	localQueryVar_AST = currentAST.root;
	returnAST = localQueryVar_AST;
}

void MTSQLOracleParser::localvarName() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST localvarName_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lv = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST i_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	std::string qualifiedName;
	
	
	lv = LT(1);
	if ( inputState->guessing == 0 ) {
		lv_AST = astFactory->create(lv);
		astFactory->addASTChild(currentAST, lv_AST);
	}
	match(LOCALVAR);
	if ( inputState->guessing==0 ) {
		qualifiedName = lv_AST->getText();
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == DOT)) {
			match(DOT);
			i = LT(1);
			if ( inputState->guessing == 0 ) {
				i_AST = astFactory->create(i);
			}
			match(ID);
			if ( inputState->guessing==0 ) {
				qualifiedName += "."; qualifiedName += i_AST->getText();
			}
		}
		else {
			goto _loop74;
		}
		
	}
	_loop74:;
	} // ( ... )*
	if ( inputState->guessing==0 ) {
		localvarName_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		
		localvarName_AST->setText(qualifiedName);
		
	}
	localvarName_AST = currentAST.root;
	returnAST = localvarName_AST;
}

void MTSQLOracleParser::idName() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST idName_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lv = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lv_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST i_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	std::string qualifiedName;
	
	
	lv = LT(1);
	if ( inputState->guessing == 0 ) {
		lv_AST = astFactory->create(lv);
		astFactory->addASTChild(currentAST, lv_AST);
	}
	match(ID);
	if ( inputState->guessing==0 ) {
		qualifiedName = lv_AST->getText();
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == DOT)) {
			match(DOT);
			i = LT(1);
			if ( inputState->guessing == 0 ) {
				i_AST = astFactory->create(i);
			}
			match(ID);
			if ( inputState->guessing==0 ) {
				qualifiedName += "."; qualifiedName += i_AST->getText();
			}
		}
		else {
			goto _loop77;
		}
		
	}
	_loop77:;
	} // ( ... )*
	if ( inputState->guessing==0 ) {
		idName_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		
		idName_AST->setText(qualifiedName);
		idName_AST->setType(LOCALVAR);
		
	}
	idName_AST = currentAST.root;
	returnAST = idName_AST;
}

void MTSQLOracleParser::delayedStatement() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	statement();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	if ( inputState->guessing==0 ) {
		delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		delayedStatement_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(DELAYED_STMT,"DELAYED_STMT"))->add(delayedStatement_AST)));
		currentAST.root = delayedStatement_AST;
		if ( delayedStatement_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			delayedStatement_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = delayedStatement_AST->getFirstChild();
		else
			currentAST.child = delayedStatement_AST;
		currentAST.advanceChildToEnd();
	}
	delayedStatement_AST = currentAST.root;
	returnAST = delayedStatement_AST;
}

void MTSQLOracleParser::weakExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST weakExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conj_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	conjunctiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_OR)) {
			lor = LT(1);
			if ( inputState->guessing == 0 ) {
				lor_AST = astFactory->create(lor);
				astFactory->makeASTRoot(currentAST, lor_AST);
			}
			match(TK_OR);
			if ( inputState->guessing==0 ) {
				
									lor_AST->setType(LOR); 
								
			}
			conjunctiveExpression();
			if (inputState->guessing==0) {
				conj_AST = returnAST;
			}
			if ( inputState->guessing==0 ) {
				
									// Put an EXPR on top of rhs to allow runtime optimization of deferred execution
									// when lhs is true
									conj_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(conj_AST))); 
									getASTFactory()->addASTChild(currentAST, conj_AST);
								
			}
		}
		else {
			goto _loop91;
		}
		
	}
	_loop91:;
	} // ( ... )*
	weakExpression_AST = currentAST.root;
	returnAST = weakExpression_AST;
}

void MTSQLOracleParser::conjunctiveExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conjunctiveExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  land = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST land_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST neg_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	negatedExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_AND)) {
			land = LT(1);
			if ( inputState->guessing == 0 ) {
				land_AST = astFactory->create(land);
				astFactory->makeASTRoot(currentAST, land_AST);
			}
			match(TK_AND);
			if ( inputState->guessing==0 ) {
				land_AST->setType(LAND);
			}
			negatedExpression();
			if (inputState->guessing==0) {
				neg_AST = returnAST;
			}
			if ( inputState->guessing==0 ) {
				
						// Put an EXPR on top of rhs to allow runtime optimization of deferred execution when lhs is false
						neg_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(neg_AST))); 
						getASTFactory()->addASTChild(currentAST, neg_AST); 
					
			}
		}
		else {
			goto _loop94;
		}
		
	}
	_loop94:;
	} // ( ... )*
	conjunctiveExpression_AST = currentAST.root;
	returnAST = conjunctiveExpression_AST;
}

void MTSQLOracleParser::negatedExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST negatedExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lnot = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lnot_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_NOT)) {
			lnot = LT(1);
			if ( inputState->guessing == 0 ) {
				lnot_AST = astFactory->create(lnot);
				astFactory->makeASTRoot(currentAST, lnot_AST);
			}
			match(TK_NOT);
			if ( inputState->guessing==0 ) {
				lnot_AST->setType(LNOT);
			}
		}
		else {
			goto _loop97;
		}
		
	}
	_loop97:;
	} // ( ... )*
	isNullExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	negatedExpression_AST = currentAST.root;
	returnAST = negatedExpression_AST;
}

void MTSQLOracleParser::isNullExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST isNullExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  isnull = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST isnull_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	bitwiseExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_IS:
	{
		isnull = LT(1);
		if ( inputState->guessing == 0 ) {
			isnull_AST = astFactory->create(isnull);
			astFactory->makeASTRoot(currentAST, isnull_AST);
		}
		match(TK_IS);
		if ( inputState->guessing==0 ) {
			isnull_AST->setType(ISNULL);
		}
		match(TK_NULL);
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_AND:
	case TK_AS:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_OR:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_THEN:
	case TK_WHEN:
	case TK_WHILE:
	case TK_LOCK:
	case COMMA:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	isNullExpression_AST = currentAST.root;
	returnAST = isNullExpression_AST;
}

void MTSQLOracleParser::bitwiseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST bitwiseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bxor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bxor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  band = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST band_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	conditionalExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == AMPERSAND || LA(1) == CARET || LA(1) == PIPE)) {
			{
			switch ( LA(1)) {
			case CARET:
			{
				bxor = LT(1);
				if ( inputState->guessing == 0 ) {
					bxor_AST = astFactory->create(bxor);
					astFactory->makeASTRoot(currentAST, bxor_AST);
				}
				match(CARET);
				if ( inputState->guessing==0 ) {
					bxor_AST->setType(BXOR);
				}
				break;
			}
			case PIPE:
			{
				bor = LT(1);
				if ( inputState->guessing == 0 ) {
					bor_AST = astFactory->create(bor);
					astFactory->makeASTRoot(currentAST, bor_AST);
				}
				match(PIPE);
				if ( inputState->guessing==0 ) {
					bor_AST->setType(BOR);
				}
				break;
			}
			case AMPERSAND:
			{
				band = LT(1);
				if ( inputState->guessing == 0 ) {
					band_AST = astFactory->create(band);
					astFactory->makeASTRoot(currentAST, band_AST);
				}
				match(AMPERSAND);
				if ( inputState->guessing==0 ) {
					band_AST->setType(BAND);
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			conditionalExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop103;
		}
		
	}
	_loop103:;
	} // ( ... )*
	bitwiseExpression_AST = currentAST.root;
	returnAST = bitwiseExpression_AST;
}

void MTSQLOracleParser::conditionalExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conditionalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  neq = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST neq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	additiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_AND:
	case TK_AS:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_IS:
	case TK_OR:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_THEN:
	case TK_WHEN:
	case TK_WHILE:
	case TK_LOCK:
	case AMPERSAND:
	case EQUALS:
	case NOTEQUALS:
	case NOTEQUALS2:
	case LTN:
	case LTEQ:
	case GT:
	case GTEQ:
	case CARET:
	case COMMA:
	case RPAREN:
	case PIPE:
	case SEMI:
	{
		{
		switch ( LA(1)) {
		case EQUALS:
		case NOTEQUALS:
		case NOTEQUALS2:
		case LTN:
		case LTEQ:
		case GT:
		case GTEQ:
		{
			{
			switch ( LA(1)) {
			case EQUALS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp100_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp100_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp100_AST);
				}
				match(EQUALS);
				break;
			}
			case GT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp101_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp101_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp101_AST);
				}
				match(GT);
				break;
			}
			case LTN:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp102_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp102_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp102_AST);
				}
				match(LTN);
				break;
			}
			case GTEQ:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp103_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp103_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp103_AST);
				}
				match(GTEQ);
				break;
			}
			case LTEQ:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp104_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp104_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp104_AST);
				}
				match(LTEQ);
				break;
			}
			case NOTEQUALS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp105_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp105_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp105_AST);
				}
				match(NOTEQUALS);
				break;
			}
			case NOTEQUALS2:
			{
				neq = LT(1);
				if ( inputState->guessing == 0 ) {
					neq_AST = astFactory->create(neq);
					astFactory->makeASTRoot(currentAST, neq_AST);
				}
				match(NOTEQUALS2);
				if ( inputState->guessing==0 ) {
					neq_AST->setType(NOTEQUALS);
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			additiveExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AND:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_IF:
		case TK_IS:
		case TK_OR:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_SELECT:
		case TK_SET:
		case TK_THEN:
		case TK_WHEN:
		case TK_WHILE:
		case TK_LOCK:
		case AMPERSAND:
		case CARET:
		case COMMA:
		case RPAREN:
		case PIPE:
		case SEMI:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		break;
	}
	case TK_LIKE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp106_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp106_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp106_AST);
		}
		match(TK_LIKE);
		additiveExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	conditionalExpression_AST = currentAST.root;
	returnAST = conditionalExpression_AST;
}

void MTSQLOracleParser::additiveExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST additiveExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	multiplicativeExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == MINUS || LA(1) == PLUS)) {
			{
			switch ( LA(1)) {
			case PLUS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp107_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp107_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp107_AST);
				}
				match(PLUS);
				break;
			}
			case MINUS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp108_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp108_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp108_AST);
				}
				match(MINUS);
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			multiplicativeExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop111;
		}
		
	}
	_loop111:;
	} // ( ... )*
	additiveExpression_AST = currentAST.root;
	returnAST = additiveExpression_AST;
}

void MTSQLOracleParser::multiplicativeExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST multiplicativeExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  m = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST m_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  d = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST d_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  mod = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST mod_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	unaryExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == MODULO || LA(1) == SLASH || LA(1) == STAR)) {
			{
			switch ( LA(1)) {
			case STAR:
			{
				m = LT(1);
				if ( inputState->guessing == 0 ) {
					m_AST = astFactory->create(m);
					astFactory->makeASTRoot(currentAST, m_AST);
				}
				match(STAR);
				if ( inputState->guessing==0 ) {
					m_AST->setType(TIMES);
				}
				break;
			}
			case SLASH:
			{
				d = LT(1);
				if ( inputState->guessing == 0 ) {
					d_AST = astFactory->create(d);
					astFactory->makeASTRoot(currentAST, d_AST);
				}
				match(SLASH);
				if ( inputState->guessing==0 ) {
					d_AST->setType(DIVIDE);
				}
				break;
			}
			case MODULO:
			{
				mod = LT(1);
				if ( inputState->guessing == 0 ) {
					mod_AST = astFactory->create(mod);
					astFactory->makeASTRoot(currentAST, mod_AST);
				}
				match(MODULO);
				if ( inputState->guessing==0 ) {
					mod_AST->setType(MODULUS);
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			unaryExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop115;
		}
		
	}
	_loop115:;
	} // ( ... )*
	multiplicativeExpression_AST = currentAST.root;
	returnAST = multiplicativeExpression_AST;
}

void MTSQLOracleParser::unaryExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST unaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  up = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST up_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  um = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST um_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bnot = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bnot_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case PLUS:
	{
		up = LT(1);
		if ( inputState->guessing == 0 ) {
			up_AST = astFactory->create(up);
			astFactory->makeASTRoot(currentAST, up_AST);
		}
		match(PLUS);
		if ( inputState->guessing==0 ) {
			up_AST->setType(UNARY_PLUS);
		}
		break;
	}
	case MINUS:
	{
		um = LT(1);
		if ( inputState->guessing == 0 ) {
			um_AST = astFactory->create(um);
			astFactory->makeASTRoot(currentAST, um_AST);
		}
		match(MINUS);
		if ( inputState->guessing==0 ) {
			um_AST->setType(UNARY_MINUS);
		}
		break;
	}
	case TILDE:
	{
		bnot = LT(1);
		if ( inputState->guessing == 0 ) {
			bnot_AST = astFactory->create(bnot);
			astFactory->makeASTRoot(currentAST, bnot_AST);
		}
		match(TILDE);
		if ( inputState->guessing==0 ) {
			bnot_AST->setType(BNOT);
		}
		break;
	}
	case TK_CASE:
	case TK_CAST:
	case TK_FALSE:
	case TK_NULL:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
	case NUM_INT:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	postfixExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	unaryExpression_AST = currentAST.root;
	returnAST = unaryExpression_AST;
}

void MTSQLOracleParser::postfixExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST postfixExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	switch ( LA(1)) {
	case TK_FALSE:
	case TK_NULL:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
	case NUM_INT:
	{
		primaryExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		castExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_CASE:
	{
		caseExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		postfixExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	returnAST = postfixExpression_AST;
}

void MTSQLOracleParser::primaryExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  sl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST sl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  wsl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST wsl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  el = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST el_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lp = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lp_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	bool isFunctionCall = false;
	
	
	{
	switch ( LA(1)) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp109_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp109_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp109_AST);
		}
		match(NUM_INT);
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp110_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp110_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp110_AST);
		}
		match(NUM_BIGINT);
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp111_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp111_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp111_AST);
		}
		match(NUM_FLOAT);
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp112_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp112_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp112_AST);
		}
		match(NUM_DECIMAL);
		break;
	}
	case STRING_LITERAL:
	{
		sl = LT(1);
		if ( inputState->guessing == 0 ) {
			sl_AST = astFactory->create(sl);
			astFactory->addASTChild(currentAST, sl_AST);
		}
		match(STRING_LITERAL);
		if ( inputState->guessing==0 ) {
			
							// Strip of the leading single quote and the trailing single quote
							sl_AST->setText(sl_AST->getText().substr(1, sl_AST->getText().length()-2)); 
						
		}
		break;
	}
	case WSTRING_LITERAL:
	{
		wsl = LT(1);
		if ( inputState->guessing == 0 ) {
			wsl_AST = astFactory->create(wsl);
			astFactory->addASTChild(currentAST, wsl_AST);
		}
		match(WSTRING_LITERAL);
		if ( inputState->guessing==0 ) {
			
							// Strip of the leading single quote and N and the trailing single quote
							wsl_AST->setText(wsl_AST->getText().substr(2, wsl_AST->getText().length()-3)); 
						
		}
		break;
	}
	case ENUM_LITERAL:
	{
		el = LT(1);
		if ( inputState->guessing == 0 ) {
			el_AST = astFactory->create(el);
			astFactory->addASTChild(currentAST, el_AST);
		}
		match(ENUM_LITERAL);
		if ( inputState->guessing==0 ) {
			
							// Strip of the leading and the trailing delimeters
							el_AST->setText(el_AST->getText().substr(1, el_AST->getText().length()-2)); 
						
		}
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp113_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp113_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp113_AST);
		}
		match(TK_TRUE);
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp114_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp114_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp114_AST);
		}
		match(TK_FALSE);
		break;
	}
	case ID:
	{
		id = LT(1);
		if ( inputState->guessing == 0 ) {
			id_AST = astFactory->create(id);
			astFactory->addASTChild(currentAST, id_AST);
		}
		match(ID);
		{
		switch ( LA(1)) {
		case LPAREN:
		{
			lp = LT(1);
			if ( inputState->guessing == 0 ) {
				lp_AST = astFactory->create(lp);
				astFactory->makeASTRoot(currentAST, lp_AST);
			}
			match(LPAREN);
			if ( inputState->guessing==0 ) {
				isFunctionCall = true; lp_AST->setType(METHOD_CALL);
			}
			argList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp115_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp115_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp115_AST);
			}
			match(RPAREN);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AND:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_IF:
		case TK_IS:
		case TK_LIKE:
		case TK_OR:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_SELECT:
		case TK_SET:
		case TK_THEN:
		case TK_WHEN:
		case TK_WHILE:
		case TK_LOCK:
		case AMPERSAND:
		case EQUALS:
		case NOTEQUALS:
		case NOTEQUALS2:
		case LTN:
		case LTEQ:
		case GT:
		case GTEQ:
		case MODULO:
		case CARET:
		case COMMA:
		case RPAREN:
		case MINUS:
		case PIPE:
		case PLUS:
		case SEMI:
		case SLASH:
		case STAR:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		if ( inputState->guessing==0 ) {
			
			if (!isFunctionCall)
			{ 
							  // Convert to LOCALVAR
							  id_AST->setText("@" + id_AST->getText());
			id_AST->setType(LOCALVAR);
			}
						
		}
		break;
	}
	case LOCALVAR:
	{
		localvarName();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case GLOBALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp116_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp116_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp116_AST);
		}
		match(GLOBALVAR);
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp117_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp117_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp117_AST);
		}
		match(TK_NULL);
		break;
	}
	case LPAREN:
	{
		match(LPAREN);
		expression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		match(RPAREN);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	primaryExpression_AST = currentAST.root;
	returnAST = primaryExpression_AST;
}

void MTSQLOracleParser::castExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST castExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp120_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp120_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp120_AST);
	}
	match(TK_CAST);
	match(LPAREN);
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	match(TK_AS);
	builtInType();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	match(RPAREN);
	castExpression_AST = currentAST.root;
	returnAST = castExpression_AST;
}

void MTSQLOracleParser::caseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST caseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  simple = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  search = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	#pragma warning(disable : 4101)
	
	
	bool synPredMatched121 = false;
	if (((LA(1) == TK_CASE) && (LA(2) == TK_WHEN))) {
		int _m121 = mark();
		synPredMatched121 = true;
		inputState->guessing++;
		try {
			{
			match(TK_CASE);
			match(TK_WHEN);
			}
		}
		catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& pe) {
			synPredMatched121 = false;
		}
		rewind(_m121);
		inputState->guessing--;
	}
	if ( synPredMatched121 ) {
		simple = LT(1);
		if ( inputState->guessing == 0 ) {
			simple_AST = astFactory->create(simple);
			astFactory->makeASTRoot(currentAST, simple_AST);
		}
		match(TK_CASE);
		if ( inputState->guessing==0 ) {
			simple_AST->setType(SIMPLE_CASE);
		}
		{ // ( ... )+
		int _cnt123=0;
		for (;;) {
			if ((LA(1) == TK_WHEN)) {
				whenExpression(true);
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				if ( _cnt123>=1 ) { goto _loop123; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());}
			}
			
			_cnt123++;
		}
		_loop123:;
		}  // ( ... )+
		{
		switch ( LA(1)) {
		case TK_ELSE:
		{
			elseExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		match(TK_END);
		caseExpression_AST = currentAST.root;
	}
	else if ((LA(1) == TK_CASE) && (_tokenSet_5.member(LA(2)))) {
		search = LT(1);
		if ( inputState->guessing == 0 ) {
			search_AST = astFactory->create(search);
			astFactory->makeASTRoot(currentAST, search_AST);
		}
		match(TK_CASE);
		if ( inputState->guessing==0 ) {
			search_AST->setType(SEARCHED_CASE);
		}
		weakExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		{ // ( ... )+
		int _cnt126=0;
		for (;;) {
			if ((LA(1) == TK_WHEN)) {
				whenExpression(false);
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				if ( _cnt126>=1 ) { goto _loop126; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());}
			}
			
			_cnt126++;
		}
		_loop126:;
		}  // ( ... )+
		{
		switch ( LA(1)) {
		case TK_ELSE:
		{
			elseExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		match(TK_END);
		caseExpression_AST = currentAST.root;
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	returnAST = caseExpression_AST;
}

void MTSQLOracleParser::whenExpression(
	bool simple
) {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  tkw = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST tkw_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	tkw = LT(1);
	if ( inputState->guessing == 0 ) {
		tkw_AST = astFactory->create(tkw);
		astFactory->makeASTRoot(currentAST, tkw_AST);
	}
	match(TK_WHEN);
	if ( inputState->guessing==0 ) {
		if(simple) tkw_AST->setType(SIMPLE_WHEN);
	}
	weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	match(TK_THEN);
	weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	whenExpression_AST = currentAST.root;
	returnAST = whenExpression_AST;
}

void MTSQLOracleParser::elseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	match(TK_ELSE);
	weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	if ( inputState->guessing==0 ) {
		elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(elseExpression_AST)));
		currentAST.root = elseExpression_AST;
		if ( elseExpression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			elseExpression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = elseExpression_AST->getFirstChild();
		else
			currentAST.child = elseExpression_AST;
		currentAST.advanceChildToEnd();
	}
	elseExpression_AST = currentAST.root;
	returnAST = elseExpression_AST;
}

void MTSQLOracleParser::argList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST argList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case TK_CASE:
	case TK_CAST:
	case TK_FALSE:
	case TK_NOT:
	case TK_NULL:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case TILDE:
	case ID:
	case LOCALVAR:
	case GLOBALVAR:
	case NUM_INT:
	{
		expressionList();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case RPAREN:
	{
		if ( inputState->guessing==0 ) {
			argList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			argList_AST = astFactory->create(ELIST,"ELIST");
			currentAST.root = argList_AST;
			if ( argList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
				argList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
				  currentAST.child = argList_AST->getFirstChild();
			else
				currentAST.child = argList_AST;
			currentAST.advanceChildToEnd();
		}
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	argList_AST = currentAST.root;
	returnAST = argList_AST;
}

void MTSQLOracleParser::expressionList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST expressionList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp128_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp128_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp128_AST);
			}
			match(COMMA);
			expression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop135;
		}
		
	}
	_loop135:;
	} // ( ... )*
	if ( inputState->guessing==0 ) {
		expressionList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		expressionList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ELIST,"ELIST"))->add(expressionList_AST)));
		currentAST.root = expressionList_AST;
		if ( expressionList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			expressionList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = expressionList_AST->getFirstChild();
		else
			currentAST.child = expressionList_AST;
		currentAST.advanceChildToEnd();
	}
	expressionList_AST = currentAST.root;
	returnAST = expressionList_AST;
}

void MTSQLOracleParser::sql92_queryExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_queryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_querySpecification();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_queryExpression_AST = currentAST.root;
	returnAST = sql92_queryExpression_AST;
}

void MTSQLOracleParser::sql92_orderByExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_orderByExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_additiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_ASC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp129_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp129_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp129_AST);
		}
		match(TK_ASC);
		break;
	}
	case TK_DESC:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp130_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp130_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp130_AST);
		}
		match(TK_DESC);
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_WHILE:
	case TK_LOCK:
	case COMMA:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp131_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp131_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp131_AST);
			}
			match(COMMA);
			sql92_additiveExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			{
			switch ( LA(1)) {
			case TK_ASC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp132_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp132_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp132_AST);
				}
				match(TK_ASC);
				break;
			}
			case TK_DESC:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp133_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp133_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp133_AST);
				}
				match(TK_DESC);
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_IF:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_SELECT:
			case TK_SET:
			case TK_WHILE:
			case TK_LOCK:
			case COMMA:
			case RPAREN:
			case SEMI:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
		}
		else {
			goto _loop148;
		}
		
	}
	_loop148:;
	} // ( ... )*
	sql92_orderByExpression_AST = currentAST.root;
	returnAST = sql92_orderByExpression_AST;
}

void MTSQLOracleParser::sql92_additiveExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_additiveExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_multiplicativeExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == MINUS || LA(1) == PLUS)) {
			{
			switch ( LA(1)) {
			case PLUS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp134_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp134_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp134_AST);
				}
				match(PLUS);
				break;
			}
			case MINUS:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp135_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp135_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp135_AST);
				}
				match(MINUS);
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			sql92_multiplicativeExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop207;
		}
		
	}
	_loop207:;
	} // ( ... )*
	sql92_additiveExpression_AST = currentAST.root;
	returnAST = sql92_additiveExpression_AST;
}

void MTSQLOracleParser::sql92_querySpecification() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_querySpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp136_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp136_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp136_AST);
	}
	match(TK_SELECT);
	{
	switch ( LA(1)) {
	case TK_ALL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp137_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp137_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp137_AST);
		}
		match(TK_ALL);
		break;
	}
	case TK_DISTINCT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp138_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp138_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp138_AST);
		}
		match(TK_DISTINCT);
		break;
	}
	case TK_AVG:
	case TK_CASE:
	case TK_CAST:
	case TK_COUNT:
	case TK_EXISTS:
	case TK_FALSE:
	case TK_MAX:
	case TK_MIN:
	case TK_NOT:
	case TK_NULL:
	case TK_SUM:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case MINUS:
	case PLUS:
	case STAR:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case TILDE:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_selectList();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_INTO:
	{
		sql92_intoList();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case TK_FROM:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_fromSpecification();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_WHERE:
	{
		sql92_whereClause();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_GROUP:
	case TK_IF:
	case TK_ORDER:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_UNION:
	case TK_WHILE:
	case TK_LOCK:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	{
	switch ( LA(1)) {
	case TK_GROUP:
	{
		sql92_groupByClause();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_ORDER:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_UNION:
	case TK_WHILE:
	case TK_LOCK:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_querySpecification_AST = currentAST.root;
	returnAST = sql92_querySpecification_AST;
}

void MTSQLOracleParser::sql92_selectList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case STAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp139_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp139_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp139_AST);
		}
		match(STAR);
		break;
	}
	case TK_AVG:
	case TK_CASE:
	case TK_CAST:
	case TK_COUNT:
	case TK_EXISTS:
	case TK_FALSE:
	case TK_MAX:
	case TK_MIN:
	case TK_NOT:
	case TK_NULL:
	case TK_SUM:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case TILDE:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	{
		sql92_aliasedExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		{ // ( ... )*
		for (;;) {
			if ((LA(1) == COMMA)) {
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp140_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp140_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp140_AST);
				}
				match(COMMA);
				sql92_aliasedExpression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				goto _loop165;
			}
			
		}
		_loop165:;
		} // ( ... )*
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	if ( inputState->guessing==0 ) {
		sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		sql92_selectList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(SELECT_LIST,"SELECT_LIST"))->add(sql92_selectList_AST)));
		currentAST.root = sql92_selectList_AST;
		if ( sql92_selectList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			sql92_selectList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = sql92_selectList_AST->getFirstChild();
		else
			currentAST.child = sql92_selectList_AST;
		currentAST.advanceChildToEnd();
	}
	sql92_selectList_AST = currentAST.root;
	returnAST = sql92_selectList_AST;
}

void MTSQLOracleParser::sql92_intoList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_intoList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp141_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp141_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp141_AST);
	}
	match(TK_INTO);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp142_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp142_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp142_AST);
	}
	match(LOCALVAR);
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp144_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp144_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp144_AST);
			}
			match(LOCALVAR);
		}
		else {
			goto _loop161;
		}
		
	}
	_loop161:;
	} // ( ... )*
	sql92_intoList_AST = currentAST.root;
	returnAST = sql92_intoList_AST;
}

void MTSQLOracleParser::sql92_fromSpecification() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_fromSpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp145_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp145_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp145_AST);
	}
	match(TK_FROM);
	sql92_tableReferenceList();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_fromSpecification_AST = currentAST.root;
	returnAST = sql92_fromSpecification_AST;
}

void MTSQLOracleParser::sql92_whereClause() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whereClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp146_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp146_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp146_AST);
	}
	match(TK_WHERE);
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_whereClause_AST = currentAST.root;
	returnAST = sql92_whereClause_AST;
}

void MTSQLOracleParser::sql92_groupByClause() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByClause_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp147_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp147_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp147_AST);
	}
	match(TK_GROUP);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp148_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp148_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp148_AST);
	}
	match(TK_BY);
	sql92_groupByExpressionList();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_HAVING:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp149_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp149_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp149_AST);
		}
		match(TK_HAVING);
		sql92_weakExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_IF:
	case TK_ORDER:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_SELECT:
	case TK_SET:
	case TK_UNION:
	case TK_WHILE:
	case TK_LOCK:
	case RPAREN:
	case SEMI:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_groupByClause_AST = currentAST.root;
	returnAST = sql92_groupByClause_AST;
}

void MTSQLOracleParser::sql92_tableReferenceList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_tableReferenceList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_joinedTable();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp150_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp150_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp150_AST);
			}
			match(COMMA);
			sql92_joinedTable();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop171;
		}
		
	}
	_loop171:;
	} // ( ... )*
	sql92_tableReferenceList_AST = currentAST.root;
	returnAST = sql92_tableReferenceList_AST;
}

void MTSQLOracleParser::sql92_weakExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_weakExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST conj_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_conjunctiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_OR)) {
			lor = LT(1);
			if ( inputState->guessing == 0 ) {
				lor_AST = astFactory->create(lor);
				astFactory->makeASTRoot(currentAST, lor_AST);
			}
			match(TK_OR);
			if ( inputState->guessing==0 ) {
				
									lor_AST->setType(LOR); 
								
			}
			sql92_conjunctiveExpression();
			if (inputState->guessing==0) {
				conj_AST = returnAST;
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop181;
		}
		
	}
	_loop181:;
	} // ( ... )*
	sql92_weakExpression_AST = currentAST.root;
	returnAST = sql92_weakExpression_AST;
}

void MTSQLOracleParser::sql92_groupByExpressionList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_groupByExpressionList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_additiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp151_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp151_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp151_AST);
			}
			match(COMMA);
			sql92_additiveExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop175;
		}
		
	}
	_loop175:;
	} // ( ... )*
	sql92_groupByExpressionList_AST = currentAST.root;
	returnAST = sql92_groupByExpressionList_AST;
}

void MTSQLOracleParser::sql92_aliasedExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_aliasedExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  id = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST id_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_AS:
	case ID:
	{
		{
		switch ( LA(1)) {
		case TK_AS:
		{
			match(TK_AS);
			break;
		}
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		id = LT(1);
		if ( inputState->guessing == 0 ) {
			id_AST = astFactory->create(id);
			astFactory->addASTChild(currentAST, id_AST);
		}
		match(ID);
		if ( inputState->guessing==0 ) {
			id_AST->setType(ALIAS);
		}
		break;
	}
	case TK_FROM:
	case TK_INTO:
	case COMMA:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_aliasedExpression_AST = currentAST.root;
	returnAST = sql92_aliasedExpression_AST;
}

void MTSQLOracleParser::sql92_expression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	}
	if ( inputState->guessing==0 ) {
		sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		sql92_expression_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(EXPR,"EXPR"))->add(sql92_expression_AST)));
		currentAST.root = sql92_expression_AST;
		if ( sql92_expression_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			sql92_expression_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = sql92_expression_AST->getFirstChild();
		else
			currentAST.child = sql92_expression_AST;
		currentAST.advanceChildToEnd();
	}
	sql92_expression_AST = currentAST.root;
	returnAST = sql92_expression_AST;
}

void MTSQLOracleParser::sql92_markedAdditiveExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_markedAdditiveExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_additiveExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_markedAdditiveExpression_AST = currentAST.root;
	returnAST = sql92_markedAdditiveExpression_AST;
}

void MTSQLOracleParser::sql92_conjunctiveExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_conjunctiveExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  land = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST land_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST neg_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_negatedExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_AND)) {
			land = LT(1);
			if ( inputState->guessing == 0 ) {
				land_AST = astFactory->create(land);
				astFactory->makeASTRoot(currentAST, land_AST);
			}
			match(TK_AND);
			if ( inputState->guessing==0 ) {
				land_AST->setType(LAND);
			}
			sql92_negatedExpression();
			if (inputState->guessing==0) {
				neg_AST = returnAST;
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop184;
		}
		
	}
	_loop184:;
	} // ( ... )*
	sql92_conjunctiveExpression_AST = currentAST.root;
	returnAST = sql92_conjunctiveExpression_AST;
}

void MTSQLOracleParser::sql92_negatedExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_negatedExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lnot = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lnot_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == TK_NOT)) {
			lnot = LT(1);
			if ( inputState->guessing == 0 ) {
				lnot_AST = astFactory->create(lnot);
				astFactory->makeASTRoot(currentAST, lnot_AST);
			}
			match(TK_NOT);
			if ( inputState->guessing==0 ) {
				lnot_AST->setType(LNOT);
			}
		}
		else {
			goto _loop187;
		}
		
	}
	_loop187:;
	} // ( ... )*
	sql92_isNullExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_negatedExpression_AST = currentAST.root;
	returnAST = sql92_negatedExpression_AST;
}

void MTSQLOracleParser::sql92_isNullExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_isNullExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  isnull = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST isnull_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_bitwiseExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{
	switch ( LA(1)) {
	case TK_IS:
	{
		isnull = LT(1);
		if ( inputState->guessing == 0 ) {
			isnull_AST = astFactory->create(isnull);
			astFactory->makeASTRoot(currentAST, isnull_AST);
		}
		match(TK_IS);
		{
		switch ( LA(1)) {
		case TK_NOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp153_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp153_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp153_AST);
			}
			match(TK_NOT);
			break;
		}
		case TK_NULL:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp154_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp154_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp154_AST);
		}
		match(TK_NULL);
		break;
	}
	case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
	case TK_AND:
	case TK_AS:
	case TK_BEGIN:
	case TK_BREAK:
	case TK_CONTINUE:
	case TK_CROSS:
	case TK_DECLARE:
	case TK_ELSE:
	case TK_END:
	case TK_FROM:
	case TK_FULL:
	case TK_GROUP:
	case TK_IF:
	case TK_INNER:
	case TK_INTO:
	case TK_JOIN:
	case TK_LEFT:
	case TK_ON:
	case TK_OR:
	case TK_ORDER:
	case TK_PRINT:
	case TK_RAISERROR:
	case TK_RETURN:
	case TK_RIGHT:
	case TK_SELECT:
	case TK_SET:
	case TK_THEN:
	case TK_UNION:
	case TK_WHEN:
	case TK_WHERE:
	case TK_WHILE:
	case TK_LOCK:
	case COMMA:
	case RPAREN:
	case SEMI:
	case ID:
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_isNullExpression_AST = currentAST.root;
	returnAST = sql92_isNullExpression_AST;
}

void MTSQLOracleParser::sql92_bitwiseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_bitwiseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bxor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bxor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bor = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bor_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  band = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST band_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_conditionalExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == AMPERSAND || LA(1) == CARET || LA(1) == PIPE)) {
			{
			switch ( LA(1)) {
			case CARET:
			{
				bxor = LT(1);
				if ( inputState->guessing == 0 ) {
					bxor_AST = astFactory->create(bxor);
					astFactory->makeASTRoot(currentAST, bxor_AST);
				}
				match(CARET);
				if ( inputState->guessing==0 ) {
					bxor_AST->setType(BXOR);
				}
				break;
			}
			case PIPE:
			{
				bor = LT(1);
				if ( inputState->guessing == 0 ) {
					bor_AST = astFactory->create(bor);
					astFactory->makeASTRoot(currentAST, bor_AST);
				}
				match(PIPE);
				if ( inputState->guessing==0 ) {
					bor_AST->setType(BOR);
				}
				break;
			}
			case AMPERSAND:
			{
				band = LT(1);
				if ( inputState->guessing == 0 ) {
					band_AST = astFactory->create(band);
					astFactory->makeASTRoot(currentAST, band_AST);
				}
				match(AMPERSAND);
				if ( inputState->guessing==0 ) {
					band_AST->setType(BAND);
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			sql92_conditionalExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop194;
		}
		
	}
	_loop194:;
	} // ( ... )*
	sql92_bitwiseExpression_AST = currentAST.root;
	returnAST = sql92_bitwiseExpression_AST;
}

void MTSQLOracleParser::sql92_conditionalExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_conditionalExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  neq = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST neq_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	switch ( LA(1)) {
	case TK_AVG:
	case TK_CASE:
	case TK_CAST:
	case TK_COUNT:
	case TK_FALSE:
	case TK_MAX:
	case TK_MIN:
	case TK_NULL:
	case TK_SUM:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case TILDE:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	{
		sql92_additiveExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		{
		switch ( LA(1)) {
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AND:
		case TK_AS:
		case TK_BEGIN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_ELSE:
		case TK_END:
		case TK_FROM:
		case TK_FULL:
		case TK_GROUP:
		case TK_IF:
		case TK_INNER:
		case TK_INTO:
		case TK_IS:
		case TK_JOIN:
		case TK_LEFT:
		case TK_ON:
		case TK_OR:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_THEN:
		case TK_UNION:
		case TK_WHEN:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case AMPERSAND:
		case EQUALS:
		case NOTEQUALS:
		case NOTEQUALS2:
		case LTN:
		case LTEQ:
		case GT:
		case GTEQ:
		case CARET:
		case COMMA:
		case RPAREN:
		case PIPE:
		case SEMI:
		case ID:
		{
			{
			switch ( LA(1)) {
			case EQUALS:
			case NOTEQUALS:
			case NOTEQUALS2:
			case LTN:
			case LTEQ:
			case GT:
			case GTEQ:
			{
				{
				switch ( LA(1)) {
				case EQUALS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp155_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp155_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp155_AST);
					}
					match(EQUALS);
					break;
				}
				case GT:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp156_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp156_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp156_AST);
					}
					match(GT);
					break;
				}
				case LTN:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp157_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp157_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp157_AST);
					}
					match(LTN);
					break;
				}
				case GTEQ:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp158_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp158_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp158_AST);
					}
					match(GTEQ);
					break;
				}
				case LTEQ:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp159_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp159_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp159_AST);
					}
					match(LTEQ);
					break;
				}
				case NOTEQUALS:
				{
					ANTLR_USE_NAMESPACE(antlr)RefAST tmp160_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
					if ( inputState->guessing == 0 ) {
						tmp160_AST = astFactory->create(LT(1));
						astFactory->makeASTRoot(currentAST, tmp160_AST);
					}
					match(NOTEQUALS);
					break;
				}
				case NOTEQUALS2:
				{
					neq = LT(1);
					if ( inputState->guessing == 0 ) {
						neq_AST = astFactory->create(neq);
						astFactory->makeASTRoot(currentAST, neq_AST);
					}
					match(NOTEQUALS2);
					if ( inputState->guessing==0 ) {
						neq_AST->setType(NOTEQUALS);
					}
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
				sql92_additiveExpression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				break;
			}
			case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
			case TK_AND:
			case TK_AS:
			case TK_BEGIN:
			case TK_BREAK:
			case TK_CONTINUE:
			case TK_CROSS:
			case TK_DECLARE:
			case TK_ELSE:
			case TK_END:
			case TK_FROM:
			case TK_FULL:
			case TK_GROUP:
			case TK_IF:
			case TK_INNER:
			case TK_INTO:
			case TK_IS:
			case TK_JOIN:
			case TK_LEFT:
			case TK_ON:
			case TK_OR:
			case TK_ORDER:
			case TK_PRINT:
			case TK_RAISERROR:
			case TK_RETURN:
			case TK_RIGHT:
			case TK_SELECT:
			case TK_SET:
			case TK_THEN:
			case TK_UNION:
			case TK_WHEN:
			case TK_WHERE:
			case TK_WHILE:
			case TK_LOCK:
			case AMPERSAND:
			case CARET:
			case COMMA:
			case RPAREN:
			case PIPE:
			case SEMI:
			case ID:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		case TK_BETWEEN:
		case TK_IN:
		case TK_LIKE:
		case TK_NOT:
		{
			{
			switch ( LA(1)) {
			case TK_NOT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp161_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp161_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp161_AST);
				}
				match(TK_NOT);
				break;
			}
			case TK_BETWEEN:
			case TK_IN:
			case TK_LIKE:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			{
			switch ( LA(1)) {
			case TK_LIKE:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp162_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp162_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp162_AST);
				}
				match(TK_LIKE);
				sql92_additiveExpression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				break;
			}
			case TK_BETWEEN:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp163_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp163_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp163_AST);
				}
				match(TK_BETWEEN);
				sql92_additiveExpression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp164_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp164_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp164_AST);
				}
				match(TK_AND);
				sql92_additiveExpression();
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
				break;
			}
			case TK_IN:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp165_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp165_AST = astFactory->create(LT(1));
					astFactory->makeASTRoot(currentAST, tmp165_AST);
				}
				match(TK_IN);
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp166_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp166_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp166_AST);
				}
				match(LPAREN);
				{
				switch ( LA(1)) {
				case TK_SELECT:
				{
					sql92_selectStatement();
					if (inputState->guessing==0) {
						astFactory->addASTChild( currentAST, returnAST );
					}
					break;
				}
				case TK_AVG:
				case TK_CASE:
				case TK_CAST:
				case TK_COUNT:
				case TK_FALSE:
				case TK_MAX:
				case TK_MIN:
				case TK_NULL:
				case TK_SUM:
				case TK_TRUE:
				case NUM_DECIMAL:
				case NUM_FLOAT:
				case NUM_BIGINT:
				case LPAREN:
				case MINUS:
				case PLUS:
				case STRING_LITERAL:
				case ENUM_LITERAL:
				case WSTRING_LITERAL:
				case TILDE:
				case ID:
				case LOCALVAR:
				case NUM_INT:
				{
					sql92_additiveExpression();
					if (inputState->guessing==0) {
						astFactory->addASTChild( currentAST, returnAST );
					}
					{ // ( ... )*
					for (;;) {
						if ((LA(1) == COMMA)) {
							ANTLR_USE_NAMESPACE(antlr)RefAST tmp167_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
							if ( inputState->guessing == 0 ) {
								tmp167_AST = astFactory->create(LT(1));
								astFactory->addASTChild(currentAST, tmp167_AST);
							}
							match(COMMA);
							sql92_additiveExpression();
							if (inputState->guessing==0) {
								astFactory->addASTChild( currentAST, returnAST );
							}
						}
						else {
							goto _loop203;
						}
						
					}
					_loop203:;
					} // ( ... )*
					break;
				}
				default:
				{
					throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
				}
				}
				}
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp168_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp168_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp168_AST);
				}
				match(RPAREN);
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_conditionalExpression_AST = currentAST.root;
		break;
	}
	case TK_EXISTS:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp169_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp169_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp169_AST);
		}
		match(TK_EXISTS);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp170_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp170_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp170_AST);
		}
		match(LPAREN);
		sql92_selectStatement();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp171_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp171_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp171_AST);
		}
		match(RPAREN);
		sql92_conditionalExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	returnAST = sql92_conditionalExpression_AST;
}

void MTSQLOracleParser::sql92_multiplicativeExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_multiplicativeExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  m = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST m_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  d = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST d_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  mod = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST mod_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_unaryExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == MODULO || LA(1) == SLASH || LA(1) == STAR)) {
			{
			switch ( LA(1)) {
			case STAR:
			{
				m = LT(1);
				if ( inputState->guessing == 0 ) {
					m_AST = astFactory->create(m);
					astFactory->makeASTRoot(currentAST, m_AST);
				}
				match(STAR);
				if ( inputState->guessing==0 ) {
					m_AST->setType(TIMES);
				}
				break;
			}
			case SLASH:
			{
				d = LT(1);
				if ( inputState->guessing == 0 ) {
					d_AST = astFactory->create(d);
					astFactory->makeASTRoot(currentAST, d_AST);
				}
				match(SLASH);
				if ( inputState->guessing==0 ) {
					d_AST->setType(DIVIDE);
				}
				break;
			}
			case MODULO:
			{
				mod = LT(1);
				if ( inputState->guessing == 0 ) {
					mod_AST = astFactory->create(mod);
					astFactory->makeASTRoot(currentAST, mod_AST);
				}
				match(MODULO);
				if ( inputState->guessing==0 ) {
					mod_AST->setType(MODULUS);
				}
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			sql92_unaryExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop211;
		}
		
	}
	_loop211:;
	} // ( ... )*
	sql92_multiplicativeExpression_AST = currentAST.root;
	returnAST = sql92_multiplicativeExpression_AST;
}

void MTSQLOracleParser::sql92_unaryExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_unaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  up = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST up_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  um = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST um_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bnot = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bnot_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case PLUS:
	{
		up = LT(1);
		if ( inputState->guessing == 0 ) {
			up_AST = astFactory->create(up);
			astFactory->makeASTRoot(currentAST, up_AST);
		}
		match(PLUS);
		if ( inputState->guessing==0 ) {
			up_AST->setType(UNARY_PLUS);
		}
		break;
	}
	case MINUS:
	{
		um = LT(1);
		if ( inputState->guessing == 0 ) {
			um_AST = astFactory->create(um);
			astFactory->makeASTRoot(currentAST, um_AST);
		}
		match(MINUS);
		if ( inputState->guessing==0 ) {
			um_AST->setType(UNARY_MINUS);
		}
		break;
	}
	case TILDE:
	{
		bnot = LT(1);
		if ( inputState->guessing == 0 ) {
			bnot_AST = astFactory->create(bnot);
			astFactory->makeASTRoot(currentAST, bnot_AST);
		}
		match(TILDE);
		if ( inputState->guessing==0 ) {
			bnot_AST->setType(BNOT);
		}
		break;
	}
	case TK_AVG:
	case TK_CASE:
	case TK_CAST:
	case TK_COUNT:
	case TK_FALSE:
	case TK_MAX:
	case TK_MIN:
	case TK_NULL:
	case TK_SUM:
	case TK_TRUE:
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
	{
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_postfixExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_unaryExpression_AST = currentAST.root;
	returnAST = sql92_unaryExpression_AST;
}

void MTSQLOracleParser::sql92_postfixExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_postfixExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lp = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lp_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	switch ( LA(1)) {
	case TK_FALSE:
	case TK_NULL:
	case TK_TRUE:
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
	{
		sql92_primaryExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		{
		switch ( LA(1)) {
		case LPAREN:
		{
			lp = LT(1);
			if ( inputState->guessing == 0 ) {
				lp_AST = astFactory->create(lp);
				astFactory->makeASTRoot(currentAST, lp_AST);
			}
			match(LPAREN);
			if ( inputState->guessing==0 ) {
				lp_AST->setType(METHOD_CALL);
			}
			sql92_argList();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp172_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp172_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp172_AST);
			}
			match(RPAREN);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AND:
		case TK_AS:
		case TK_ASC:
		case TK_BEGIN:
		case TK_BETWEEN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_DESC:
		case TK_ELSE:
		case TK_END:
		case TK_FROM:
		case TK_FULL:
		case TK_GROUP:
		case TK_HAVING:
		case TK_IF:
		case TK_IN:
		case TK_INNER:
		case TK_INTO:
		case TK_IS:
		case TK_JOIN:
		case TK_LEFT:
		case TK_LIKE:
		case TK_NOT:
		case TK_ON:
		case TK_OR:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_THEN:
		case TK_UNION:
		case TK_WHEN:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case AMPERSAND:
		case EQUALS:
		case NOTEQUALS:
		case NOTEQUALS2:
		case LTN:
		case LTEQ:
		case GT:
		case GTEQ:
		case MODULO:
		case CARET:
		case COMMA:
		case RPAREN:
		case MINUS:
		case PIPE:
		case PLUS:
		case SEMI:
		case SLASH:
		case STAR:
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_COUNT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp173_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp173_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp173_AST);
		}
		match(TK_COUNT);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp174_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp174_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp174_AST);
		}
		match(LPAREN);
		{
		switch ( LA(1)) {
		case STAR:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp175_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp175_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp175_AST);
			}
			match(STAR);
			break;
		}
		case TK_ALL:
		case TK_AVG:
		case TK_CASE:
		case TK_CAST:
		case TK_COUNT:
		case TK_DISTINCT:
		case TK_EXISTS:
		case TK_FALSE:
		case TK_MAX:
		case TK_MIN:
		case TK_NOT:
		case TK_NULL:
		case TK_SUM:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case TILDE:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		{
			{
			switch ( LA(1)) {
			case TK_DISTINCT:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp176_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp176_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp176_AST);
				}
				match(TK_DISTINCT);
				break;
			}
			case TK_ALL:
			{
				ANTLR_USE_NAMESPACE(antlr)RefAST tmp177_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
				if ( inputState->guessing == 0 ) {
					tmp177_AST = astFactory->create(LT(1));
					astFactory->addASTChild(currentAST, tmp177_AST);
				}
				match(TK_ALL);
				break;
			}
			case TK_AVG:
			case TK_CASE:
			case TK_CAST:
			case TK_COUNT:
			case TK_EXISTS:
			case TK_FALSE:
			case TK_MAX:
			case TK_MIN:
			case TK_NOT:
			case TK_NULL:
			case TK_SUM:
			case TK_TRUE:
			case NUM_DECIMAL:
			case NUM_FLOAT:
			case NUM_BIGINT:
			case LPAREN:
			case MINUS:
			case PLUS:
			case STRING_LITERAL:
			case ENUM_LITERAL:
			case WSTRING_LITERAL:
			case TILDE:
			case ID:
			case LOCALVAR:
			case NUM_INT:
			{
				break;
			}
			default:
			{
				throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
			}
			}
			}
			sql92_expression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp178_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp178_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp178_AST);
		}
		match(RPAREN);
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_AVG:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp179_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp179_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp179_AST);
		}
		match(TK_AVG);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp180_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp180_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp180_AST);
		}
		match(LPAREN);
		{
		{
		switch ( LA(1)) {
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp181_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp181_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp181_AST);
			}
			match(TK_DISTINCT);
			break;
		}
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp182_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp182_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp182_AST);
			}
			match(TK_ALL);
			break;
		}
		case TK_AVG:
		case TK_CASE:
		case TK_CAST:
		case TK_COUNT:
		case TK_EXISTS:
		case TK_FALSE:
		case TK_MAX:
		case TK_MIN:
		case TK_NOT:
		case TK_NULL:
		case TK_SUM:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case TILDE:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_expression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp183_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp183_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp183_AST);
		}
		match(RPAREN);
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_MAX:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp184_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp184_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp184_AST);
		}
		match(TK_MAX);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp185_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp185_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp185_AST);
		}
		match(LPAREN);
		{
		{
		switch ( LA(1)) {
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp186_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp186_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp186_AST);
			}
			match(TK_DISTINCT);
			break;
		}
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp187_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp187_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp187_AST);
			}
			match(TK_ALL);
			break;
		}
		case TK_AVG:
		case TK_CASE:
		case TK_CAST:
		case TK_COUNT:
		case TK_EXISTS:
		case TK_FALSE:
		case TK_MAX:
		case TK_MIN:
		case TK_NOT:
		case TK_NULL:
		case TK_SUM:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case TILDE:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_expression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp188_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp188_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp188_AST);
		}
		match(RPAREN);
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_MIN:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp189_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp189_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp189_AST);
		}
		match(TK_MIN);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp190_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp190_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp190_AST);
		}
		match(LPAREN);
		{
		{
		switch ( LA(1)) {
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp191_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp191_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp191_AST);
			}
			match(TK_DISTINCT);
			break;
		}
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp192_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp192_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp192_AST);
			}
			match(TK_ALL);
			break;
		}
		case TK_AVG:
		case TK_CASE:
		case TK_CAST:
		case TK_COUNT:
		case TK_EXISTS:
		case TK_FALSE:
		case TK_MAX:
		case TK_MIN:
		case TK_NOT:
		case TK_NULL:
		case TK_SUM:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case TILDE:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_expression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp193_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp193_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp193_AST);
		}
		match(RPAREN);
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_SUM:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp194_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp194_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp194_AST);
		}
		match(TK_SUM);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp195_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp195_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp195_AST);
		}
		match(LPAREN);
		{
		{
		switch ( LA(1)) {
		case TK_DISTINCT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp196_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp196_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp196_AST);
			}
			match(TK_DISTINCT);
			break;
		}
		case TK_ALL:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp197_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp197_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp197_AST);
			}
			match(TK_ALL);
			break;
		}
		case TK_AVG:
		case TK_CASE:
		case TK_CAST:
		case TK_COUNT:
		case TK_EXISTS:
		case TK_FALSE:
		case TK_MAX:
		case TK_MIN:
		case TK_NOT:
		case TK_NULL:
		case TK_SUM:
		case TK_TRUE:
		case NUM_DECIMAL:
		case NUM_FLOAT:
		case NUM_BIGINT:
		case LPAREN:
		case MINUS:
		case PLUS:
		case STRING_LITERAL:
		case ENUM_LITERAL:
		case WSTRING_LITERAL:
		case TILDE:
		case ID:
		case LOCALVAR:
		case NUM_INT:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		sql92_expression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp198_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp198_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp198_AST);
		}
		match(RPAREN);
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_CAST:
	{
		sql92_castExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	case TK_CASE:
	{
		sql92_caseExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		sql92_postfixExpression_AST = currentAST.root;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	returnAST = sql92_postfixExpression_AST;
}

void MTSQLOracleParser::sql92_primaryExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_primaryExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  sl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST sl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  el = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST el_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  wsl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST wsl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  lp = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST lp_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case NUM_INT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp199_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp199_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp199_AST);
		}
		match(NUM_INT);
		break;
	}
	case NUM_BIGINT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp200_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp200_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp200_AST);
		}
		match(NUM_BIGINT);
		break;
	}
	case NUM_FLOAT:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp201_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp201_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp201_AST);
		}
		match(NUM_FLOAT);
		break;
	}
	case NUM_DECIMAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp202_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp202_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp202_AST);
		}
		match(NUM_DECIMAL);
		break;
	}
	case STRING_LITERAL:
	{
		sl = LT(1);
		if ( inputState->guessing == 0 ) {
			sl_AST = astFactory->create(sl);
			astFactory->addASTChild(currentAST, sl_AST);
		}
		match(STRING_LITERAL);
		break;
	}
	case ENUM_LITERAL:
	{
		el = LT(1);
		if ( inputState->guessing == 0 ) {
			el_AST = astFactory->create(el);
			astFactory->addASTChild(currentAST, el_AST);
		}
		match(ENUM_LITERAL);
		if ( inputState->guessing==0 ) {
			
							// Strip of the leading and the trailing delimeters.  Store the
			// FQN.  This will be converted to an integer during semantic analysis.
							el_AST->setText(el_AST->getText().substr(1, el_AST->getText().length()-2)); 
						
		}
		break;
	}
	case WSTRING_LITERAL:
	{
		wsl = LT(1);
		if ( inputState->guessing == 0 ) {
			wsl_AST = astFactory->create(wsl);
			astFactory->addASTChild(currentAST, wsl_AST);
		}
		match(WSTRING_LITERAL);
		break;
	}
	case TK_TRUE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp203_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp203_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp203_AST);
		}
		match(TK_TRUE);
		break;
	}
	case TK_FALSE:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp204_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp204_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp204_AST);
		}
		match(TK_FALSE);
		break;
	}
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp205_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp205_AST = astFactory->create(LT(1));
			astFactory->makeASTRoot(currentAST, tmp205_AST);
		}
		match(ID);
		{
		switch ( LA(1)) {
		case DOT:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp206_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp206_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp206_AST);
			}
			match(DOT);
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp207_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp207_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp207_AST);
			}
			match(ID);
			break;
		}
		case ANTLR_USE_NAMESPACE(antlr)Token::EOF_TYPE:
		case TK_AND:
		case TK_AS:
		case TK_ASC:
		case TK_BEGIN:
		case TK_BETWEEN:
		case TK_BREAK:
		case TK_CONTINUE:
		case TK_CROSS:
		case TK_DECLARE:
		case TK_DESC:
		case TK_ELSE:
		case TK_END:
		case TK_FROM:
		case TK_FULL:
		case TK_GROUP:
		case TK_HAVING:
		case TK_IF:
		case TK_IN:
		case TK_INNER:
		case TK_INTO:
		case TK_IS:
		case TK_JOIN:
		case TK_LEFT:
		case TK_LIKE:
		case TK_NOT:
		case TK_ON:
		case TK_OR:
		case TK_ORDER:
		case TK_PRINT:
		case TK_RAISERROR:
		case TK_RETURN:
		case TK_RIGHT:
		case TK_SELECT:
		case TK_SET:
		case TK_THEN:
		case TK_UNION:
		case TK_WHEN:
		case TK_WHERE:
		case TK_WHILE:
		case TK_LOCK:
		case AMPERSAND:
		case EQUALS:
		case NOTEQUALS:
		case NOTEQUALS2:
		case LTN:
		case LTEQ:
		case GT:
		case GTEQ:
		case MODULO:
		case CARET:
		case COMMA:
		case LPAREN:
		case RPAREN:
		case MINUS:
		case PIPE:
		case PLUS:
		case SEMI:
		case SLASH:
		case STAR:
		case ID:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		break;
	}
	case LOCALVAR:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp208_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp208_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp208_AST);
		}
		match(LOCALVAR);
		break;
	}
	case TK_NULL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp209_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp209_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp209_AST);
		}
		match(TK_NULL);
		break;
	}
	default:
		if ((LA(1) == LPAREN) && (_tokenSet_6.member(LA(2)))) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp210_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp210_AST = astFactory->create(LT(1));
				astFactory->makeASTRoot(currentAST, tmp210_AST);
			}
			match(LPAREN);
			sql92_expression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp211_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp211_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp211_AST);
			}
			match(RPAREN);
		}
		else if ((LA(1) == LPAREN) && (LA(2) == TK_SELECT)) {
			lp = LT(1);
			if ( inputState->guessing == 0 ) {
				lp_AST = astFactory->create(lp);
				astFactory->makeASTRoot(currentAST, lp_AST);
			}
			match(LPAREN);
			sql92_selectStatement();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp212_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp212_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp212_AST);
			}
			match(RPAREN);
			if ( inputState->guessing==0 ) {
				lp_AST->setType(SCALAR_SUBQUERY);
			}
		}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_primaryExpression_AST = currentAST.root;
	returnAST = sql92_primaryExpression_AST;
}

void MTSQLOracleParser::sql92_argList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_argList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case TK_AVG:
	case TK_CASE:
	case TK_CAST:
	case TK_COUNT:
	case TK_EXISTS:
	case TK_FALSE:
	case TK_MAX:
	case TK_MIN:
	case TK_NOT:
	case TK_NULL:
	case TK_SUM:
	case TK_TRUE:
	case NUM_DECIMAL:
	case NUM_FLOAT:
	case NUM_BIGINT:
	case LPAREN:
	case MINUS:
	case PLUS:
	case STRING_LITERAL:
	case ENUM_LITERAL:
	case WSTRING_LITERAL:
	case TILDE:
	case ID:
	case LOCALVAR:
	case NUM_INT:
	{
		sql92_expressionList();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		break;
	}
	case RPAREN:
	{
		if ( inputState->guessing==0 ) {
			sql92_argList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
			sql92_argList_AST = astFactory->create(ELIST,"ELIST");
			currentAST.root = sql92_argList_AST;
			if ( sql92_argList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
				sql92_argList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
				  currentAST.child = sql92_argList_AST->getFirstChild();
			else
				currentAST.child = sql92_argList_AST;
			currentAST.advanceChildToEnd();
		}
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_argList_AST = currentAST.root;
	returnAST = sql92_argList_AST;
}

void MTSQLOracleParser::sql92_castExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_castExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp213_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp213_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp213_AST);
	}
	match(TK_CAST);
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp214_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp214_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp214_AST);
	}
	match(LPAREN);
	sql92_expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp215_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp215_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp215_AST);
	}
	match(TK_AS);
	sql92_builtInType();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp216_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp216_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp216_AST);
	}
	match(RPAREN);
	sql92_castExpression_AST = currentAST.root;
	returnAST = sql92_castExpression_AST;
}

void MTSQLOracleParser::sql92_caseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_caseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  simple = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST simple_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  search = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST search_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	#pragma warning(disable : 4101)
	
	
	bool synPredMatched228 = false;
	if (((LA(1) == TK_CASE) && (LA(2) == TK_WHEN))) {
		int _m228 = mark();
		synPredMatched228 = true;
		inputState->guessing++;
		try {
			{
			match(TK_CASE);
			match(TK_WHEN);
			}
		}
		catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& pe) {
			synPredMatched228 = false;
		}
		rewind(_m228);
		inputState->guessing--;
	}
	if ( synPredMatched228 ) {
		simple = LT(1);
		if ( inputState->guessing == 0 ) {
			simple_AST = astFactory->create(simple);
			astFactory->makeASTRoot(currentAST, simple_AST);
		}
		match(TK_CASE);
		if ( inputState->guessing==0 ) {
			simple_AST->setType(SIMPLE_CASE);
		}
		{ // ( ... )+
		int _cnt230=0;
		for (;;) {
			if ((LA(1) == TK_WHEN)) {
				sql92_whenExpression(true);
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				if ( _cnt230>=1 ) { goto _loop230; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());}
			}
			
			_cnt230++;
		}
		_loop230:;
		}  // ( ... )+
		{
		switch ( LA(1)) {
		case TK_ELSE:
		{
			sql92_elseExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp217_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp217_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp217_AST);
		}
		match(TK_END);
		sql92_caseExpression_AST = currentAST.root;
	}
	else if ((LA(1) == TK_CASE) && (_tokenSet_6.member(LA(2)))) {
		search = LT(1);
		if ( inputState->guessing == 0 ) {
			search_AST = astFactory->create(search);
			astFactory->makeASTRoot(currentAST, search_AST);
		}
		match(TK_CASE);
		if ( inputState->guessing==0 ) {
			search_AST->setType(SEARCHED_CASE);
		}
		sql92_weakExpression();
		if (inputState->guessing==0) {
			astFactory->addASTChild( currentAST, returnAST );
		}
		{ // ( ... )+
		int _cnt233=0;
		for (;;) {
			if ((LA(1) == TK_WHEN)) {
				sql92_whenExpression(false);
				if (inputState->guessing==0) {
					astFactory->addASTChild( currentAST, returnAST );
				}
			}
			else {
				if ( _cnt233>=1 ) { goto _loop233; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());}
			}
			
			_cnt233++;
		}
		_loop233:;
		}  // ( ... )+
		{
		switch ( LA(1)) {
		case TK_ELSE:
		{
			sql92_elseExpression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
			break;
		}
		case TK_END:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp218_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp218_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp218_AST);
		}
		match(TK_END);
		sql92_caseExpression_AST = currentAST.root;
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	returnAST = sql92_caseExpression_AST;
}

void MTSQLOracleParser::sql92_whenExpression(
	bool isSimple
) {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_whenExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  tkw = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST tkw_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	tkw = LT(1);
	if ( inputState->guessing == 0 ) {
		tkw_AST = astFactory->create(tkw);
		astFactory->makeASTRoot(currentAST, tkw_AST);
	}
	match(TK_WHEN);
	if ( inputState->guessing==0 ) {
		if (isSimple) tkw_AST->setType(SIMPLE_WHEN);
	}
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp219_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp219_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp219_AST);
	}
	match(TK_THEN);
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_whenExpression_AST = currentAST.root;
	returnAST = sql92_whenExpression_AST;
}

void MTSQLOracleParser::sql92_elseExpression() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_elseExpression_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp220_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	if ( inputState->guessing == 0 ) {
		tmp220_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp220_AST);
	}
	match(TK_ELSE);
	sql92_weakExpression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	sql92_elseExpression_AST = currentAST.root;
	returnAST = sql92_elseExpression_AST;
}

void MTSQLOracleParser::sql92_builtInType() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_builtInType_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  i = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST i_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  chr = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST chr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dbl = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dbl_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  str = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST str_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  wstr = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST wstr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dec = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dec_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  dt = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST dt_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  bi = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST bi_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	{
	switch ( LA(1)) {
	case TK_INTEGER:
	{
		i = LT(1);
		if ( inputState->guessing == 0 ) {
			i_AST = astFactory->create(i);
			astFactory->makeASTRoot(currentAST, i_AST);
		}
		match(TK_INTEGER);
		if ( inputState->guessing==0 ) {
			i_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_CHAR:
	{
		chr = LT(1);
		if ( inputState->guessing == 0 ) {
			chr_AST = astFactory->create(chr);
			astFactory->makeASTRoot(currentAST, chr_AST);
		}
		match(TK_CHAR);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp221_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp221_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp221_AST);
		}
		match(LPAREN);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp222_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp222_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp222_AST);
		}
		match(NUM_INT);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp223_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp223_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp223_AST);
		}
		match(RPAREN);
		if ( inputState->guessing==0 ) {
			chr_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DOUBLE:
	{
		dbl = LT(1);
		if ( inputState->guessing == 0 ) {
			dbl_AST = astFactory->create(dbl);
			astFactory->makeASTRoot(currentAST, dbl_AST);
		}
		match(TK_DOUBLE);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp224_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp224_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp224_AST);
		}
		match(TK_PRECISION);
		if ( inputState->guessing==0 ) {
			dbl_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_VARCHAR:
	{
		str = LT(1);
		if ( inputState->guessing == 0 ) {
			str_AST = astFactory->create(str);
			astFactory->makeASTRoot(currentAST, str_AST);
		}
		match(TK_VARCHAR);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp225_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp225_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp225_AST);
		}
		match(LPAREN);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp226_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp226_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp226_AST);
		}
		match(NUM_INT);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp227_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp227_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp227_AST);
		}
		match(RPAREN);
		if ( inputState->guessing==0 ) {
			str_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_NVARCHAR:
	{
		wstr = LT(1);
		if ( inputState->guessing == 0 ) {
			wstr_AST = astFactory->create(wstr);
			astFactory->makeASTRoot(currentAST, wstr_AST);
		}
		match(TK_NVARCHAR);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp228_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp228_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp228_AST);
		}
		match(LPAREN);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp229_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp229_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp229_AST);
		}
		match(NUM_INT);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp230_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp230_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp230_AST);
		}
		match(RPAREN);
		if ( inputState->guessing==0 ) {
			wstr_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DECIMAL:
	{
		dec = LT(1);
		if ( inputState->guessing == 0 ) {
			dec_AST = astFactory->create(dec);
			astFactory->makeASTRoot(currentAST, dec_AST);
		}
		match(TK_DECIMAL);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp231_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp231_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp231_AST);
		}
		match(LPAREN);
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp232_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp232_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp232_AST);
		}
		match(NUM_INT);
		{
		switch ( LA(1)) {
		case COMMA:
		{
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp233_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp233_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp233_AST);
			}
			match(COMMA);
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp234_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp234_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp234_AST);
			}
			match(NUM_INT);
			break;
		}
		case RPAREN:
		{
			break;
		}
		default:
		{
			throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
		}
		}
		}
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp235_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		if ( inputState->guessing == 0 ) {
			tmp235_AST = astFactory->create(LT(1));
			astFactory->addASTChild(currentAST, tmp235_AST);
		}
		match(RPAREN);
		if ( inputState->guessing==0 ) {
			dec_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_DATETIME:
	{
		dt = LT(1);
		if ( inputState->guessing == 0 ) {
			dt_AST = astFactory->create(dt);
			astFactory->makeASTRoot(currentAST, dt_AST);
		}
		match(TK_DATETIME);
		if ( inputState->guessing==0 ) {
			dt_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	case TK_BIGINT:
	{
		bi = LT(1);
		if ( inputState->guessing == 0 ) {
			bi_AST = astFactory->create(bi);
			astFactory->makeASTRoot(currentAST, bi_AST);
		}
		match(TK_BIGINT);
		if ( inputState->guessing==0 ) {
			bi_AST->setType(BUILTIN_TYPE);
		}
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	sql92_builtInType_AST = currentAST.root;
	returnAST = sql92_builtInType_AST;
}

void MTSQLOracleParser::sql92_expressionList() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sql92_expressionList_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	sql92_expression();
	if (inputState->guessing==0) {
		astFactory->addASTChild( currentAST, returnAST );
	}
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			ANTLR_USE_NAMESPACE(antlr)RefAST tmp236_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
			if ( inputState->guessing == 0 ) {
				tmp236_AST = astFactory->create(LT(1));
				astFactory->addASTChild(currentAST, tmp236_AST);
			}
			match(COMMA);
			sql92_expression();
			if (inputState->guessing==0) {
				astFactory->addASTChild( currentAST, returnAST );
			}
		}
		else {
			goto _loop242;
		}
		
	}
	_loop242:;
	} // ( ... )*
	if ( inputState->guessing==0 ) {
		sql92_expressionList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
		sql92_expressionList_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(astFactory->make((new ANTLR_USE_NAMESPACE(antlr)ASTArray(2))->add(astFactory->create(ELIST,"ELIST"))->add(sql92_expressionList_AST)));
		currentAST.root = sql92_expressionList_AST;
		if ( sql92_expressionList_AST!=ANTLR_USE_NAMESPACE(antlr)nullAST &&
			sql92_expressionList_AST->getFirstChild() != ANTLR_USE_NAMESPACE(antlr)nullAST )
			  currentAST.child = sql92_expressionList_AST->getFirstChild();
		else
			currentAST.child = sql92_expressionList_AST;
		currentAST.advanceChildToEnd();
	}
	sql92_expressionList_AST = currentAST.root;
	returnAST = sql92_expressionList_AST;
}

void MTSQLOracleParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(165);
}
const char* MTSQLOracleParser::tokenNames[] = {
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
	0
};

const unsigned long MTSQLOracleParser::_tokenSet_0_data_[] = { 1627931650UL, 2684354688UL, 540697UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// EOF "BEGIN" "BREAK" "CONTINUE" "DECLARE" "ELSE" "END" "IF" "PRINT" "RAISERROR" 
// "RETURN" "SELECT" "SET" "WHILE" "LOCK" 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_0(_tokenSet_0_data_,8);
const unsigned long MTSQLOracleParser::_tokenSet_1_data_[] = { 17318912UL, 2684354688UL, 540697UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// "BEGIN" "BREAK" "CONTINUE" "DECLARE" "IF" "PRINT" "RAISERROR" "RETURN" 
// "SELECT" "SET" "WHILE" "LOCK" 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_1(_tokenSet_1_data_,8);
const unsigned long MTSQLOracleParser::_tokenSet_2_data_[] = { 1763395106UL, 2688286851UL, 2048601UL, 32486656UL, 0UL, 0UL, 0UL, 0UL };
// EOF "ALL" "AVG" "BEGIN" "BREAK" "CASE" "CAST" "CONTINUE" "COUNT" "DECLARE" 
// "DISTINCT" "ELSE" "END" "EXISTS" "FALSE" "IF" "MAX" "MIN" "NOT" "NULL" 
// "PRINT" "RAISERROR" "RETURN" "SELECT" "SET" "SUM" "TRUE" "WHILE" NUM_DECIMAL 
// NUM_FLOAT NUM_BIGINT "LOCK" "TABLE" LPAREN MINUS PLUS SEMI STAR STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL TILDE ID LOCALVAR GLOBALVAR NUM_INT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_2(_tokenSet_2_data_,8);
const unsigned long MTSQLOracleParser::_tokenSet_3_data_[] = { 4221271730UL, 2709404039UL, 4229913433UL, 32505319UL, 0UL, 0UL, 0UL, 0UL };
// EOF "AND" "ALL" "AS" "AVG" "BEGIN" "BETWEEN" "BIGINT" "BOOLEAN" "BREAK" 
// "CASE" "CAST" "CONTINUE" "COUNT" "DATETIME" "DECLARE" "DECIMAL" "DISTINCT" 
// "DOUBLE" "ELSE" "END" "ENUM" "EXISTS" "FALSE" "FROM" "IF" "IN" "INTO" 
// "INTEGER" "IS" "LIKE" "MAX" "MIN" "NOT" "NULL" "NVARCHAR" "OR" "PRINT" 
// "RAISERROR" "RETURN" "SELECT" "SET" "SUM" "TIME" "TRUE" "VARCHAR" "WHEN" 
// "WHILE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT "LOCK" "TABLE" AMPERSAND EQUALS 
// NOTEQUALS NOTEQUALS2 LTN LTEQ GT GTEQ MODULO CARET COMMA DOT LPAREN 
// MINUS PIPE PLUS SEMI SLASH STAR STRING_LITERAL ENUM_LITERAL WSTRING_LITERAL 
// TILDE ID LOCALVAR GLOBALVAR NUM_INT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_3(_tokenSet_3_data_,8);
const unsigned long MTSQLOracleParser::_tokenSet_4_data_[] = { 2UL, 0UL, 0UL, 0UL, 0UL, 0UL };
// EOF 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_4(_tokenSet_4_data_,6);
const unsigned long MTSQLOracleParser::_tokenSet_5_data_[] = { 196608UL, 3145730UL, 459264UL, 32445696UL, 0UL, 0UL, 0UL, 0UL };
// "CASE" "CAST" "FALSE" "NOT" "NULL" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT 
// LPAREN MINUS PLUS STRING_LITERAL ENUM_LITERAL WSTRING_LITERAL TILDE 
// ID LOCALVAR GLOBALVAR NUM_INT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_5(_tokenSet_5_data_,8);
const unsigned long MTSQLOracleParser::_tokenSet_6_data_[] = { 1245696UL, 3932163UL, 459328UL, 24057088UL, 0UL, 0UL, 0UL, 0UL };
// "AVG" "CASE" "CAST" "COUNT" "EXISTS" "FALSE" "MAX" "MIN" "NOT" "NULL" 
// "SUM" "TRUE" NUM_DECIMAL NUM_FLOAT NUM_BIGINT LPAREN MINUS PLUS STRING_LITERAL 
// ENUM_LITERAL WSTRING_LITERAL TILDE ID LOCALVAR NUM_INT 
const ANTLR_USE_NAMESPACE(antlr)BitSet MTSQLOracleParser::_tokenSet_6(_tokenSet_6_data_,8);


