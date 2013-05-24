/* $ANTLR 2.7.6 (2005-12-22): "record_parser.g" -> "RecordFormatParser.cpp"$ */
#include "RecordFormatParser.hpp"
#include <antlr/NoViableAltException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/ASTFactory.hpp>
#line 1 "record_parser.g"
#line 8 "RecordFormatParser.cpp"
RecordFormatParser::RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,k)
{
}

RecordFormatParser::RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenBuffer& tokenBuf)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(tokenBuf,3)
{
}

RecordFormatParser::RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer, int k)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,k)
{
}

RecordFormatParser::RecordFormatParser(ANTLR_USE_NAMESPACE(antlr)TokenStream& lexer)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(lexer,3)
{
}

RecordFormatParser::RecordFormatParser(const ANTLR_USE_NAMESPACE(antlr)ParserSharedInputState& state)
: ANTLR_USE_NAMESPACE(antlr)LLkParser(state,3)
{
}

void RecordFormatParser::program() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	try {      // for error handling
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp1_AST = astFactory->create(LT(1));
		astFactory->makeASTRoot(currentAST, tmp1_AST);
		match(ID);
		{ // ( ... )*
		for (;;) {
			if ((LA(1) == ID)) {
				typeDefinition();
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop3;
			}
			
		}
		_loop3:;
		} // ( ... )*
		recordDefinition();
		astFactory->addASTChild( currentAST, returnAST );
		program_AST = currentAST.root;
	}
	catch (ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex) {
		reportError(ex);
		recover(ex,_tokenSet_0);
	}
	returnAST = program_AST;
}

void RecordFormatParser::typeDefinition() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDefinition_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp2_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, tmp2_AST);
	match(ID);
	typeDefinition_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 113 "record_parser.g"
	typeDefinition_AST->setType(TYPE_DEFINITION);
#line 80 "RecordFormatParser.cpp"
	match(EQUALS);
	typeSpecification();
	astFactory->addASTChild( currentAST, returnAST );
	typeDefinition_AST = currentAST.root;
	returnAST = typeDefinition_AST;
}

void RecordFormatParser::recordDefinition() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST recordDefinition_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp4_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, tmp4_AST);
	match(LPAREN);
	recordDefinition_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 118 "record_parser.g"
	recordDefinition_AST->setType(RECORD_DEFINITION);
#line 100 "RecordFormatParser.cpp"
	fieldDefinition();
	astFactory->addASTChild( currentAST, returnAST );
	{ // ( ... )*
	for (;;) {
		if ((LA(1) == COMMA)) {
			match(COMMA);
			fieldDefinition();
			astFactory->addASTChild( currentAST, returnAST );
		}
		else {
			goto _loop7;
		}
		
	}
	_loop7:;
	} // ( ... )*
	match(RPAREN);
	recordDefinition_AST = currentAST.root;
	returnAST = recordDefinition_AST;
}

void RecordFormatParser::typeSpecification() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeSpecification_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp7_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp7_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, tmp7_AST);
	match(ID);
	typeSpecification_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 123 "record_parser.g"
	typeSpecification_AST->setType(TYPE_SPECIFICATION);
#line 134 "RecordFormatParser.cpp"
	match(LPAREN);
	{
	switch ( LA(1)) {
	case ID:
	{
		typeParameter();
		astFactory->addASTChild( currentAST, returnAST );
		{ // ( ... )*
		for (;;) {
			if ((LA(1) == COMMA)) {
				match(COMMA);
				typeParameter();
				astFactory->addASTChild( currentAST, returnAST );
			}
			else {
				goto _loop11;
			}
			
		}
		_loop11:;
		} // ( ... )*
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
	typeSpecification_AST = currentAST.root;
	returnAST = typeSpecification_AST;
}

void RecordFormatParser::fieldDefinition() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST fieldDefinition_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  fd = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST fd_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefToken  tr = ANTLR_USE_NAMESPACE(antlr)nullToken;
	ANTLR_USE_NAMESPACE(antlr)RefAST tr_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	fd = LT(1);
	fd_AST = astFactory->create(fd);
	astFactory->makeASTRoot(currentAST, fd_AST);
	match(ID);
#line 133 "record_parser.g"
	fd_AST->setType(FIELD_DEFINITION); mNumFields += 1;
#line 188 "RecordFormatParser.cpp"
	{
	if ((LA(1) == ID) && (LA(2) == COMMA || LA(2) == RPAREN)) {
		tr = LT(1);
		tr_AST = astFactory->create(tr);
		astFactory->addASTChild(currentAST, tr_AST);
		match(ID);
#line 133 "record_parser.g"
		tr_AST->setType(TYPE_REFERENCE);
#line 197 "RecordFormatParser.cpp"
	}
	else if ((LA(1) == ID) && (LA(2) == LPAREN)) {
		typeSpecification();
		astFactory->addASTChild( currentAST, returnAST );
	}
	else {
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	
	}
	fieldDefinition_AST = currentAST.root;
	returnAST = fieldDefinition_AST;
}

void RecordFormatParser::typeParameter() {
	returnAST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)ASTPair currentAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST typeParameter_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp11_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
	tmp11_AST = astFactory->create(LT(1));
	astFactory->makeASTRoot(currentAST, tmp11_AST);
	match(ID);
	typeParameter_AST = ANTLR_USE_NAMESPACE(antlr)RefAST(currentAST.root);
#line 128 "record_parser.g"
	typeParameter_AST->setType(TYPE_PARAMETER);
#line 224 "RecordFormatParser.cpp"
	match(EQUALS);
	{
	switch ( LA(1)) {
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp13_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp13_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp13_AST);
		match(STRING_LITERAL);
		break;
	}
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp14_AST = ANTLR_USE_NAMESPACE(antlr)nullAST;
		tmp14_AST = astFactory->create(LT(1));
		astFactory->addASTChild(currentAST, tmp14_AST);
		match(ID);
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(LT(1), getFilename());
	}
	}
	}
	typeParameter_AST = currentAST.root;
	returnAST = typeParameter_AST;
}

void RecordFormatParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& factory )
{
	factory.setMaxNodeType(51);
}
const char* RecordFormatParser::tokenNames[] = {
	"<0>",
	"EOF",
	"<2>",
	"NULL_TREE_LOOKAHEAD",
	"\"FALSE\"",
	"\"TRUE\"",
	"NUM_DECIMAL",
	"NUM_FLOAT",
	"NUM_BIGINT",
	"AMPERSAND",
	"ARROW",
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
	"LBRACKET",
	"LCURLY",
	"\'(\'",
	"RBRACKET",
	"RCURLY",
	"\')\'",
	"MINUS",
	"PIPE",
	"PLUS",
	"COLON",
	"SEMI",
	"SLASH",
	"STAR",
	"STRING_LITERAL",
	"TILDE",
	"WS",
	"ID",
	"NUM_INT",
	"EXPONENT",
	"FLOAT_SUFFIX",
	"BIGINT_SUFFIX",
	"HEX_DIGIT",
	"FIELD_DEFINITION",
	"RECORD_DEFINITION",
	"TYPE_DEFINITION",
	"TYPE_PARAMETER",
	"TYPE_REFERENCE",
	"TYPE_SPECIFICATION",
	0
};

const unsigned long RecordFormatParser::_tokenSet_0_data_[] = { 2UL, 0UL, 0UL, 0UL };
// EOF 
const ANTLR_USE_NAMESPACE(antlr)BitSet RecordFormatParser::_tokenSet_0(_tokenSet_0_data_,4);


