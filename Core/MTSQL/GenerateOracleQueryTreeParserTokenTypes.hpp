#ifndef INC_GenerateOracleQueryTreeParserTokenTypes_hpp_
#define INC_GenerateOracleQueryTreeParserTokenTypes_hpp_

/* $ANTLR 2.7.6 (2005-12-22): "expandedgenerate_query_oracle.g" -> "GenerateOracleQueryTreeParserTokenTypes.hpp"$ */

#ifndef CUSTOM_API
# define CUSTOM_API
#endif

#ifdef __cplusplus
struct CUSTOM_API GenerateOracleQueryTreeParserTokenTypes {
#endif
	enum {
		EOF_ = 1,
		TK_AND = 4,
		TK_ALL = 5,
		TK_ANY = 6,
		TK_AS = 7,
		TK_ASC = 8,
		TK_AVG = 9,
		TK_BEGIN = 10,
		TK_BETWEEN = 11,
		TK_BIGINT = 12,
		TK_BOOLEAN = 13,
		TK_BREAK = 14,
		TK_BY = 15,
		TK_CASE = 16,
		TK_CAST = 17,
		TK_CHAR = 18,
		TK_CONTINUE = 19,
		TK_COUNT = 20,
		TK_CREATE = 21,
		TK_CROSS = 22,
		TK_DATETIME = 23,
		TK_DECLARE = 24,
		TK_DECIMAL = 25,
		TK_DESC = 26,
		TK_DISTINCT = 27,
		TK_DOUBLE = 28,
		TK_ELSE = 29,
		TK_END = 30,
		TK_ENUM = 31,
		TK_EXISTS = 32,
		TK_FALSE = 33,
		TK_FROM = 34,
		TK_FULL = 35,
		TK_FUNCTION = 36,
		TK_GROUP = 37,
		TK_HAVING = 38,
		TK_IF = 39,
		TK_IN = 40,
		TK_INDEX = 41,
		TK_INNER = 42,
		TK_INTO = 43,
		TK_INTEGER = 44,
		TK_IS = 45,
		TK_JOIN = 46,
		TK_KEY = 47,
		TK_LEFT = 48,
		TK_LIKE = 49,
		TK_MAX = 50,
		TK_MIN = 51,
		TK_NOT = 52,
		TK_NULL = 53,
		TK_NVARCHAR = 54,
		TK_ON = 55,
		TK_OR = 56,
		TK_ORDER = 57,
		TK_OUTER = 58,
		TK_OUTPUT = 59,
		TK_PRECISION = 60,
		TK_PRINT = 61,
		TK_PROCEDURE = 62,
		TK_RAISERROR = 63,
		TK_RETURN = 64,
		TK_RETURNS = 65,
		TK_RIGHT = 66,
		TK_SELECT = 67,
		TK_SET = 68,
		TK_SOME = 69,
		TK_SUM = 70,
		TK_THEN = 71,
		TK_TIME = 72,
		TK_TRUE = 73,
		TK_UNION = 74,
		TK_VARCHAR = 75,
		TK_WHEN = 76,
		TK_WHERE = 77,
		TK_WHILE = 78,
		TK_WITH = 79,
		NUM_DECIMAL = 80,
		NUM_FLOAT = 81,
		NUM_BIGINT = 82,
		TK_LOCK = 83,
		TK_TABLE = 84,
		TK_MODE = 85,
		TK_FOR = 86,
		TK_UPDATE = 87,
		TK_OF = 88,
		TK_NOWAIT = 89,
		AMPERSAND = 90,
		EQUALS = 91,
		NOTEQUALS = 92,
		NOTEQUALS2 = 93,
		LTN = 94,
		LTEQ = 95,
		GT = 96,
		GTEQ = 97,
		MODULO = 98,
		SL_COMMENT = 99,
		ML_COMMENT = 100,
		CARET = 101,
		COMMA = 102,
		DOT = 103,
		LPAREN = 104,
		RPAREN = 105,
		MINUS = 106,
		PIPE = 107,
		PLUS = 108,
		SEMI = 109,
		SLASH = 110,
		STAR = 111,
		STRING_LITERAL = 112,
		ENUM_LITERAL = 113,
		WSTRING_LITERAL = 114,
		TILDE = 115,
		WS = 116,
		ID = 117,
		LOCALVAR = 118,
		GLOBALVAR = 119,
		NUM_INT = 120,
		EXPONENT = 121,
		FLOAT_SUFFIX = 122,
		BIGINT_SUFFIX = 123,
		HEX_DIGIT = 124,
		ALIAS = 125,
		ARRAY = 126,
		ASSIGN = 127,
		ASSIGN_QUERY = 128,
		BAND = 129,
		BNOT = 130,
		BOR = 131,
		BXOR = 132,
		BUILTIN_TYPE = 133,
		CROSS_JOIN = 134,
		DELAYED_STMT = 135,
		DERIVED_TABLE = 136,
		DIVIDE = 137,
		ELIST = 138,
		EXPR = 139,
		GROUPED_JOIN = 140,
		IDENT = 141,
		IFTHENELSE = 142,
		ISNULL = 143,
		LAND = 144,
		LNOT = 145,
		LOR = 146,
		METHOD_CALL = 147,
		MODULUS = 148,
		QUERY = 149,
		QUERYPARAM = 150,
		QUERYSTRING = 151,
		RAISERROR1 = 152,
		RAISERROR2 = 153,
		SCALAR_SUBQUERY = 154,
		SCOPE = 155,
		SEARCHED_CASE = 156,
		SELECT_LIST = 157,
		SIMPLE_CASE = 158,
		SIMPLE_WHEN = 159,
		SLIST = 160,
		TABLE_REF = 161,
		TIMES = 162,
		UNARY_MINUS = 163,
		UNARY_PLUS = 164,
		WHILE = 165,
		ESEQ = 166,
		SEQUENCE = 167,
		CAST_TO_INTEGER = 168,
		CAST_TO_BIGINT = 169,
		CAST_TO_DOUBLE = 170,
		CAST_TO_DECIMAL = 171,
		CAST_TO_STRING = 172,
		CAST_TO_WSTRING = 173,
		CAST_TO_BOOLEAN = 174,
		CAST_TO_DATETIME = 175,
		CAST_TO_TIME = 176,
		CAST_TO_ENUM = 177,
		CAST_TO_BINARY = 178,
		INTEGER_PLUS = 179,
		BIGINT_PLUS = 180,
		DOUBLE_PLUS = 181,
		DECIMAL_PLUS = 182,
		STRING_PLUS = 183,
		WSTRING_PLUS = 184,
		INTEGER_MINUS = 185,
		BIGINT_MINUS = 186,
		DOUBLE_MINUS = 187,
		DECIMAL_MINUS = 188,
		INTEGER_TIMES = 189,
		BIGINT_TIMES = 190,
		DOUBLE_TIMES = 191,
		DECIMAL_TIMES = 192,
		INTEGER_DIVIDE = 193,
		BIGINT_DIVIDE = 194,
		DOUBLE_DIVIDE = 195,
		DECIMAL_DIVIDE = 196,
		INTEGER_UNARY_MINUS = 197,
		BIGINT_UNARY_MINUS = 198,
		DOUBLE_UNARY_MINUS = 199,
		DECIMAL_UNARY_MINUS = 200,
		INTEGER_GETMEM = 201,
		BIGINT_GETMEM = 202,
		DOUBLE_GETMEM = 203,
		DECIMAL_GETMEM = 204,
		STRING_GETMEM = 205,
		WSTRING_GETMEM = 206,
		BOOLEAN_GETMEM = 207,
		DATETIME_GETMEM = 208,
		TIME_GETMEM = 209,
		ENUM_GETMEM = 210,
		BINARY_GETMEM = 211,
		INTEGER_SETMEM = 212,
		BIGINT_SETMEM = 213,
		DOUBLE_SETMEM = 214,
		DECIMAL_SETMEM = 215,
		STRING_SETMEM = 216,
		WSTRING_SETMEM = 217,
		BOOLEAN_SETMEM = 218,
		DATETIME_SETMEM = 219,
		TIME_SETMEM = 220,
		ENUM_SETMEM = 221,
		BINARY_SETMEM = 222,
		INTEGER_SETMEM_QUERY = 223,
		BIGINT_SETMEM_QUERY = 224,
		DOUBLE_SETMEM_QUERY = 225,
		DECIMAL_SETMEM_QUERY = 226,
		STRING_SETMEM_QUERY = 227,
		WSTRING_SETMEM_QUERY = 228,
		BOOLEAN_SETMEM_QUERY = 229,
		DATETIME_SETMEM_QUERY = 230,
		TIME_SETMEM_QUERY = 231,
		ENUM_SETMEM_QUERY = 232,
		BINARY_SETMEM_QUERY = 233,
		IFEXPR = 234,
		IFBLOCK = 235,
		RAISERRORINTEGER = 236,
		RAISERRORSTRING = 237,
		RAISERRORWSTRING = 238,
		RAISERROR2STRING = 239,
		RAISERROR2WSTRING = 240,
		STRING_LIKE = 241,
		WSTRING_LIKE = 242,
		STRING_PRINT = 243,
		WSTRING_PRINT = 244,
		INTEGER_MODULUS = 245,
		BIGINT_MODULUS = 246,
		NULL_TREE_LOOKAHEAD = 3
	};
#ifdef __cplusplus
};
#endif
#endif /*INC_GenerateOracleQueryTreeParserTokenTypes_hpp_*/
