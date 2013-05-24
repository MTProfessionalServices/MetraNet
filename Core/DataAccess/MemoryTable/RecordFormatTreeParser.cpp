/* $ANTLR 2.7.6 (2005-12-22): "record_analyze.g" -> "RecordFormatTreeParser.cpp"$ */
#include "RecordFormatTreeParser.hpp"
#include <antlr/NoViableAltException.hpp>
#include <antlr/SemanticException.hpp>
#include <antlr/BitSet.hpp>
#line 1 "record_analyze.g"
#line 11 "RecordFormatTreeParser.cpp"
RecordFormatTreeParser::RecordFormatTreeParser()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void RecordFormatTreeParser::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST program_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t2 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp1_AST_in = _t;
	match(_t,ID);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TYPE_DEFINITION)) {
			typeDefinition(_t);
			_t = _retTree;
		}
		else {
			goto _loop4;
		}
		
	}
	_loop4:;
	} // ( ... )*
	recordDefinition(_t);
	_t = _retTree;
	_t = __t2;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatTreeParser::typeDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeDefinition_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST td = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST ts = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t6 = _t;
	td = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TYPE_DEFINITION);
	_t = _t->getFirstChild();
	ts = _t;
	match(_t,TYPE_SPECIFICATION);
	_t = _t->getNextSibling();
	_t = __t6;
	_t = _t->getNextSibling();
#line 81 "record_analyze.g"
	
	// TODO: Warn if multiple definitions.
	mTypeDefinitions[td->getText()] = ts;
	
#line 64 "RecordFormatTreeParser.cpp"
	_retTree = _t;
}

void RecordFormatTreeParser::recordDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST recordDefinition_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t8 = _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tmp2_AST_in = _t;
	match(_t,RECORD_DEFINITION);
	_t = _t->getFirstChild();
	{ // ( ... )+
	int _cnt10=0;
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == FIELD_DEFINITION)) {
			fieldDefinition(_t);
			_t = _retTree;
		}
		else {
			if ( _cnt10>=1 ) { goto _loop10; } else {throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);}
		}
		
		_cnt10++;
	}
	_loop10:;
	}  // ( ... )+
	_t = __t8;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatTreeParser::fieldDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST fieldDefinition_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST fd = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tr = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 124 "record_analyze.g"
	
	std::wstring wstrFieldName;
	
#line 105 "RecordFormatTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
	fd = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,FIELD_DEFINITION);
	_t = _t->getFirstChild();
#line 130 "record_analyze.g"
	
	::ASCIIToWide(wstrFieldName, fd->getText()); 
	
#line 115 "RecordFormatTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TYPE_REFERENCE:
	{
		tr = _t;
		match(_t,TYPE_REFERENCE);
		_t = _t->getNextSibling();
#line 135 "record_analyze.g"
		
		std::map<std::string, antlr::RefAST>::iterator it = mTypeDefinitions.find(tr->getText());
		if (it == mTypeDefinitions.end())
		{
		throw std::runtime_error((boost::format("Undefined type reference: %1%") % tr->getText()).str());
		}
		typeSpecification(it->second,wstrFieldName);
		
#line 134 "RecordFormatTreeParser.cpp"
		break;
	}
	case TYPE_SPECIFICATION:
	{
		typeSpecification(_t,wstrFieldName);
		_t = _retTree;
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	_t = __t19;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatTreeParser::typeSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	const std::wstring& fieldName
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeSpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ts = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 92 "record_analyze.g"
	
	bool isRequired=true;
	
#line 163 "RecordFormatTreeParser.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t12 = _t;
	ts = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TYPE_SPECIFICATION);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TYPE_PARAMETER)) {
			typeParameter(_t,isRequired);
			_t = _retTree;
		}
		else {
			goto _loop14;
		}
		
	}
	_loop14:;
	} // ( ... )*
#line 98 "record_analyze.g"
	
	try
	{
	mBuilder->add_field(fieldName, ts->getText(), isRequired);
	}
	catch(std::exception& ex)
	{
	reportError(ex.what());
	throw antlr::RecognitionException("Invalid importer specification");
	}
	
#line 196 "RecordFormatTreeParser.cpp"
	_t = __t12;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatTreeParser::typeParameter(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	bool& isRequired
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeParameter_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tp = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t16 = _t;
	tp = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TYPE_PARAMETER);
	_t = _t->getFirstChild();
#line 115 "record_analyze.g"
	
	if (tp->getText() == "null_value")
	{
	isRequired = false;
	}
	
#line 219 "RecordFormatTreeParser.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_LITERAL:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp3_AST_in = _t;
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
		break;
	}
	case ID:
	{
		ANTLR_USE_NAMESPACE(antlr)RefAST tmp4_AST_in = _t;
		match(_t,ID);
		_t = _t->getNextSibling();
		break;
	}
	default:
	{
		throw ANTLR_USE_NAMESPACE(antlr)NoViableAltException(_t);
	}
	}
	}
	_t = __t16;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatTreeParser::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* RecordFormatTreeParser::tokenNames[] = {
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



