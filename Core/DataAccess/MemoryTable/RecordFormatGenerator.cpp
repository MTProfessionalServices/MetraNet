/* $ANTLR 2.7.6 (2005-12-22): "record_generate.g" -> "RecordFormatGenerator.cpp"$ */
#include "RecordFormatGenerator.hpp"
#include <antlr/NoViableAltException.hpp>
#include <antlr/SemanticException.hpp>
#line 1 "record_generate.g"
#line 11 "RecordFormatGenerator.cpp"
RecordFormatGenerator::RecordFormatGenerator()
	: ANTLR_USE_NAMESPACE(antlr)TreeParser() {
}

void RecordFormatGenerator::program(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void RecordFormatGenerator::typeDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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
#line 81 "record_generate.g"
	
	// TODO: Warn if multiple definitions.
	mTypeDefinitions[td->getText()] = ts;
	
#line 64 "RecordFormatGenerator.cpp"
	_retTree = _t;
}

void RecordFormatGenerator::recordDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
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

void RecordFormatGenerator::fieldDefinition(ANTLR_USE_NAMESPACE(antlr)RefAST _t) {
	ANTLR_USE_NAMESPACE(antlr)RefAST fieldDefinition_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST fd = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST tr = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 164 "record_generate.g"
	
	std::wstring wstrFieldName;
	
#line 105 "RecordFormatGenerator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t19 = _t;
	fd = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,FIELD_DEFINITION);
	_t = _t->getFirstChild();
#line 170 "record_generate.g"
	
	::ASCIIToWide(wstrFieldName, fd->getText()); 
	
#line 115 "RecordFormatGenerator.cpp"
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case TYPE_REFERENCE:
	{
		tr = _t;
		match(_t,TYPE_REFERENCE);
		_t = _t->getNextSibling();
#line 175 "record_generate.g"
		
		std::map<std::string, antlr::RefAST>::iterator it = mTypeDefinitions.find(tr->getText());
		if (it == mTypeDefinitions.end())
		{
		throw std::runtime_error((boost::format("Undefined type reference: %1%") % tr->getText()).str());
		}
		typeSpecification(it->second,wstrFieldName);
		
#line 134 "RecordFormatGenerator.cpp"
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

void RecordFormatGenerator::typeSpecification(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	const std::wstring& fieldName
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeSpecification_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST ts = ANTLR_USE_NAMESPACE(antlr)nullAST;
#line 92 "record_generate.g"
	
	bool isRequired=true;
	std::string nullValue;
	std::string delimiter;
	std::string enum_space;
	std::string enum_type;
	std::string true_value;
	std::string false_value;
	
#line 169 "RecordFormatGenerator.cpp"
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t12 = _t;
	ts = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TYPE_SPECIFICATION);
	_t = _t->getFirstChild();
	{ // ( ... )*
	for (;;) {
		if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
			_t = ASTNULL;
		if ((_t->getType() == TYPE_PARAMETER)) {
			typeParameter(_t,isRequired, nullValue, delimiter, enum_space, enum_type, true_value, false_value);
			_t = _retTree;
		}
		else {
			goto _loop14;
		}
		
	}
	_loop14:;
	} // ( ... )*
#line 104 "record_generate.g"
	
	mBuilder->add_base_type(fieldName, ts->getText(), isRequired, nullValue, delimiter, enum_space, enum_type, true_value, false_value);
	
#line 194 "RecordFormatGenerator.cpp"
	_t = __t12;
	_t = _t->getNextSibling();
	_retTree = _t;
}

void RecordFormatGenerator::typeParameter(ANTLR_USE_NAMESPACE(antlr)RefAST _t,
	bool& isRequired, std::string& nullValue, std::string& delimiter, std::string& enum_space, std::string& enum_type, std::string& true_value, std::string& false_value
) {
	ANTLR_USE_NAMESPACE(antlr)RefAST typeParameter_AST_in = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	ANTLR_USE_NAMESPACE(antlr)RefAST tp = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST sl = ANTLR_USE_NAMESPACE(antlr)nullAST;
	ANTLR_USE_NAMESPACE(antlr)RefAST id = ANTLR_USE_NAMESPACE(antlr)nullAST;
	
	ANTLR_USE_NAMESPACE(antlr)RefAST __t16 = _t;
	tp = (_t == ANTLR_USE_NAMESPACE(antlr)RefAST(ASTNULL)) ? ANTLR_USE_NAMESPACE(antlr)nullAST : _t;
	match(_t,TYPE_PARAMETER);
	_t = _t->getFirstChild();
	{
	if (_t == ANTLR_USE_NAMESPACE(antlr)nullAST )
		_t = ASTNULL;
	switch ( _t->getType()) {
	case STRING_LITERAL:
	{
		sl = _t;
		match(_t,STRING_LITERAL);
		_t = _t->getNextSibling();
#line 113 "record_generate.g"
		
		if (tp->getText() == "null_value")
		{
		isRequired = false;
		nullValue = sl->getText().substr(1, sl->getText().size()-2);
		}
		else if (tp->getText() == "delimiter")
		{
		delimiter = sl->getText().substr(1, sl->getText().size()-2);
		}
		else if (tp->getText() == "enum_space" ||
		tp->getText() == "enumspace")
		{
		enum_space = sl->getText().substr(1, sl->getText().size()-2);
		}
		else if (tp->getText() == "enum_type" ||
		tp->getText() == "enumtype")
		{
		enum_type = sl->getText().substr(1, sl->getText().size()-2);
		}
		else if (tp->getText() == "true_value" ||
		tp->getText() == "truevalue")
		{
		true_value = sl->getText().substr(1, sl->getText().size()-2);
		}
		else if (tp->getText() == "false_value" ||
		tp->getText() == "falsevalue")
		{
		false_value = sl->getText().substr(1, sl->getText().size()-2);
		}
		
#line 253 "RecordFormatGenerator.cpp"
		break;
	}
	case ID:
	{
		id = _t;
		match(_t,ID);
		_t = _t->getNextSibling();
#line 146 "record_generate.g"
		
		if (tp->getText() == "delimiter" && id->getText() == "crlf")
		{
		delimiter = "\r\n";
		}
		else if (tp->getText() == "delimiter" && id->getText() == "newline")
		{
		delimiter = "\n";
		}
		else 
		{
		throw std::runtime_error("delimiter must be a string or one of the constants: crlf, newline");
		}
		
#line 276 "RecordFormatGenerator.cpp"
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

void RecordFormatGenerator::initializeASTFactory( ANTLR_USE_NAMESPACE(antlr)ASTFactory& )
{
}
const char* RecordFormatGenerator::tokenNames[] = {
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



