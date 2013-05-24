#ifndef INC_DataflowTokenTypes_hpp_
#define INC_DataflowTokenTypes_hpp_

/* $ANTLR 2.7.6 (2005-12-22): "dataflow_lexer.g" -> "DataflowTokenTypes.hpp"$ */

#ifndef CUSTOM_API
# define CUSTOM_API
#endif

#ifdef __cplusplus
struct CUSTOM_API DataflowTokenTypes {
#endif
	enum {
		EOF_ = 1,
		TK_FALSE = 4,
		TK_TRUE = 5,
		NUM_DECIMAL = 6,
		NUM_FLOAT = 7,
		NUM_BIGINT = 8,
		IS = 9,
		OPERATOR = 10,
		INPUT = 11,
		OUTPUT = 12,
		STRING_DECL = 13,
		INTEGER_DECL = 14,
		BOOLEAN_DECL = 15,
		SUBLIST_DECL = 16,
		INCLUDE_COMPOSITE = 17,
		STEP_DECL = 18,
		IF_BEGIN = 19,
		IF_END = 20,
		ELSE = 21,
		THEN = 22,
		STEPS_BEGIN = 23,
		STEPS_END = 24,
		AMPERSAND = 25,
		ARROW = 26,
		BANG = 27,
		BOM = 28,
		DOLLAR_SIGN = 29,
		EQUALS = 30,
		NOTEQUALS = 31,
		NOTEQUALS2 = 32,
		LTN = 33,
		LTEQ = 34,
		GT = 35,
		GTEQ = 36,
		MODULO = 37,
		SL_COMMENT = 38,
		ML_COMMENT = 39,
		CARET = 40,
		COMMA = 41,
		DOT = 42,
		LBRACKET = 43,
		LCURLY = 44,
		LPAREN = 45,
		RBRACKET = 46,
		RCURLY = 47,
		RPAREN = 48,
		MINUS = 49,
		PIPE = 50,
		PLUS = 51,
		COLON = 52,
		SEMI = 53,
		SLASH = 54,
		STAR = 55,
		STRING_LITERAL = 56,
		TILDE = 57,
		WS = 58,
		ID = 59,
		NUM_INT = 60,
		EXPONENT = 61,
		FLOAT_SUFFIX = 62,
		BIGINT_SUFFIX = 63,
		HEX_DIGIT = 64,
		NULL_TREE_LOOKAHEAD = 3
	};
#ifdef __cplusplus
};
#endif
#endif /*INC_DataflowTokenTypes_hpp_*/
