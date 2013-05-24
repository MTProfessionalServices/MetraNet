#ifndef INC_RecordFormatTreeParserTokenTypes_hpp_
#define INC_RecordFormatTreeParserTokenTypes_hpp_

/* $ANTLR 2.7.6 (2005-12-22): "record_analyze.g" -> "RecordFormatTreeParserTokenTypes.hpp"$ */

#ifndef CUSTOM_API
# define CUSTOM_API
#endif

#ifdef __cplusplus
struct CUSTOM_API RecordFormatTreeParserTokenTypes {
#endif
	enum {
		EOF_ = 1,
		TK_FALSE = 4,
		TK_TRUE = 5,
		NUM_DECIMAL = 6,
		NUM_FLOAT = 7,
		NUM_BIGINT = 8,
		AMPERSAND = 9,
		ARROW = 10,
		EQUALS = 11,
		NOTEQUALS = 12,
		NOTEQUALS2 = 13,
		LTN = 14,
		LTEQ = 15,
		GT = 16,
		GTEQ = 17,
		MODULO = 18,
		SL_COMMENT = 19,
		ML_COMMENT = 20,
		CARET = 21,
		COMMA = 22,
		DOT = 23,
		LBRACKET = 24,
		LCURLY = 25,
		LPAREN = 26,
		RBRACKET = 27,
		RCURLY = 28,
		RPAREN = 29,
		MINUS = 30,
		PIPE = 31,
		PLUS = 32,
		COLON = 33,
		SEMI = 34,
		SLASH = 35,
		STAR = 36,
		STRING_LITERAL = 37,
		TILDE = 38,
		WS = 39,
		ID = 40,
		NUM_INT = 41,
		EXPONENT = 42,
		FLOAT_SUFFIX = 43,
		BIGINT_SUFFIX = 44,
		HEX_DIGIT = 45,
		FIELD_DEFINITION = 46,
		RECORD_DEFINITION = 47,
		TYPE_DEFINITION = 48,
		TYPE_PARAMETER = 49,
		TYPE_REFERENCE = 50,
		TYPE_SPECIFICATION = 51,
		NULL_TREE_LOOKAHEAD = 3
	};
#ifdef __cplusplus
};
#endif
#endif /*INC_RecordFormatTreeParserTokenTypes_hpp_*/
