header {
  #include "MTSQLInterpreter.h"
  #include <iostream>
  #include <sstream>
}

options {
  mangleLiteralPrefix = "TK_";
  language="Cpp";
}

class MTSQLRefactorLexer extends Lexer;
options {
	k=8;
	exportVocab=MTSQL;
	charVocabulary = '\3'..'\377';
  caseSensitiveLiterals = false;
}
tokens {
	"AND";
	"ALL";
	"ANY";
	"AS";
  "ASC";
  "AVG";
	"BEGIN";
	"BETWEEN";
  "BIGINT";
	"BOOLEAN";
	"BREAK";
  "BY";
	"CASE";
  "CAST";
  "CHAR";
  "CONTINUE";
  "COUNT";
	"CREATE";
  "CROSS";
	"DATETIME";
  "DECLARE";
  "DECIMAL";
  "DESC";
  "DISTINCT";
	"DOUBLE";
	"ELSE";
	"END";
	"ENUM";
  "EXISTS";
	"FALSE";
  "FROM";
  "FULL";
  "FUNCTION";
  "GROUP";
  "HAVING";
	"IF";
	"IN";
  "INDEX";
  "INNER";
  "INTO";
	"INTEGER"; 
	"IS";
  "JOIN";
	"KEY"; 
  "LEFT";
	"LIKE";
  "MAX";
  "MIN";
	"NOT"; 
	"NULL";
  "NVARCHAR";
	"ON";
	"OR";
  "ORDER";
  "OUTER";
	"OUTPUT";
	"PRECISION";
  "PRINT";
	"PROCEDURE";
  "RAISERROR";
	"RETURN";
	"RETURNS";
  "RIGHT";
  "SELECT";
	"SET";
	"SOME";
  "SUM";
	"THEN";
	"TIME";
	"TRUE";
  "UNION";
        "VARCHAR"; //	VARCHAR="VARCHAR";
	"WHEN";
	"WHERE";
	"WHILE";
  "WITH";
  NUM_DECIMAL;
	NUM_FLOAT;
	NUM_BIGINT;
	/*
	   Below is just for Oracle. Ideally we would have 2 lexers, but I could not find
	   a way to reference 2 separate token dictionaries without collisions.
	*/
	"LOCK";
	"TABLE";
	"MODE";
  "FOR";
	"UPDATE";
	"OF";
	"NOWAIT";
}

{
private:
  Logger* mLog;

  // Is a variable being renamed in the refactoring?
  bool mIsVariableRenamed;

  // Original name of variable to rename.
  string mOldVariableName;

  // New name of variable being renamed;
  string mNewVariableName;

  // Holds refactored script
  ostringstream mConvertedScript;

  // True if VARCHAR is being refactored to NVARCHAR.
  bool mIsVarcharRefactor;

public:

	// Override the error and warning reporting
  virtual void reportError(const ANTLR_USE_NAMESPACE(antlr)RecognitionException& ex)
  {
	mLog->logError(ex.toString());
  }

	/** Parser error-reporting function can be overridden in subclass */
  virtual void reportError(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logError(s);
  }

	/** Parser warning-reporting function can be overridden in subclass */
  virtual void reportWarning(const ANTLR_USE_NAMESPACE(std)string& s)
  {
	mLog->logWarning(s);
  }

  void setLog(Logger * log)
  {
	mLog = log;
  }

  void setRefactorRenameVariable(const string &oldName, const string &newName)
  {
        mIsVarcharRefactor = false;
        mIsVariableRenamed = true;
        mOldVariableName = oldName;
        mNewVariableName = newName;
  }

  void setRefactorVarchar()
  {
        mIsVarcharRefactor = true;
        mIsVariableRenamed = false;
  }

  string getConvertedScript()
  {
        return mConvertedScript.str();
  }
}

AMPERSAND
	:
	'&'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

EQUALS	:
	'='
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;
	
NOTEQUALS
	:
	'<' '>'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

TK_VARCHAR
	:
	"VARCHAR"
        {
          if (mIsVarcharRefactor)
          {
             mConvertedScript << "N";
          }

          mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

NOTEQUALS2
	:
	'!' '='
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

LTN	:
	'<'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

LTEQ	:
	'<' '='
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

GT	:
	'>'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

GTEQ	:
	'>' '='
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

MODULO	:
	'%'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

SL_COMMENT : 
	"--" 
	(~'\n')* '\n'
	{ newline(); }
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

// [DB] The following ML_COMMENT is snarfed directly from Antlr's example java grammar 
// multiple-line comments
ML_COMMENT
	:	"/*"
		(	/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:
			{ LA(2)!='/' }? '*'
		|	'\r' '\n'		{newline();}
		|	'\r'			{newline();}
		|	'\n'			{newline();}
		|	~('*'|'\n'|'\r')
		)*
		"*/"
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

CARET	
	:
	'^'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

COMMA :
	','
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

DOT
	:
	'.'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

LPAREN
options {
	paraphrase="'('";
}
	:	'('
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

RPAREN
options {
	paraphrase="')'";
}
	:	')'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

MINUS
	:
	'-'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

PIPE
	:
	'|'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

PLUS
	:
	'+'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

SEMI :
	';'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

SLASH
	:
	'/'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;
STAR
	:
	'*'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

STRING_LITERAL
	:	'\'' 
		(	/*	'\r' '\n' can be matched in one alternative or by matching
				'\r' in one iteration and '\n' in another.  I am trying to
				handle any flavor of newline that comes in, but the language
				that allows both "\r\n" and "\r" and "\n" to all be valid
				newline is ambiguous.  Consequently, the resulting grammar
				must be ambiguous.  I'm shutting this warning off.
			 */
			options {
				generateAmbigWarnings=false;
			}
		:
            '\r' '\n'		{newline();}
		|	'\r'			{newline();}
		|	'\n'			{newline();}
        | '\'' '\''!
		|	~('\''|'\n'|'\r')
		)*
		'\''
        {
          if (mIsVarcharRefactor)
          {
             mConvertedScript << "N";
          }

          mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

ENUM_LITERAL
	:	'#' (~'#')* '#'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

WSTRING_LITERAL
	:	'N' '\'' 
		(	// Turn off ambiguity warning caused by \r \n rules.
			options {
				generateAmbigWarnings=false;
			}
		:
            '\r' '\n'		{newline();}
		|	'\r'			{newline();}
		|	'\n'			{newline();}
        | '\'' '\''!
		|	~('\''|'\n'|'\r')
		)*
		'\''
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

TILDE
	:	'~'
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

WS	:	(	' '
		|	'\t'
		|	'\f'
			// handle newlines
		|	(	options {generateAmbigWarnings=false;}
			:	"\r\n"  // Evil DOS
			|	'\r'    // Macintosh
			|	'\n'    // Unix (the right way)
			)
			{ newline(); }
		)+
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

ID
options {
	testLiterals = true;
}
	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;

LOCALVAR
options {
	testLiterals = true;
}
	:	'@' ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9'|'$'|'#')*
        {
             string varName = text.substr(_begin, text.length()-_begin);
             if (mIsVariableRenamed && varName.compare(mOldVariableName) == 0)
             {
               varName = mNewVariableName;
             }
             mConvertedScript << varName;
        }
	;

GLOBALVAR
options {
	testLiterals = true;
}
	:	'@' '@' ('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9'|'$'|'#')*
        {
             string varName = text.substr(_begin, text.length()-_begin);
             if (mIsVariableRenamed && varName.compare(mOldVariableName) == 0)
             {
               varName = mNewVariableName;
             }
             mConvertedScript << varName;
        }
	;

// a numeric literal
NUM_INT
	{bool isDecimal=false;}
	:	'.' { _ttype = DOT; }
			(('0'..'9' { _ttype = NUM_DECIMAL; })+ (EXPONENT { _ttype = NUM_FLOAT; })? (FLOAT_SUFFIX { _ttype = NUM_FLOAT; })? )?
	|	(	'0' {isDecimal = true;} // special case for just '0'
			(	('x'|'X')
				(											// hex
					// the 'e'|'E' and float suffix stuff look
					// like hex digits, hence the (...)+ doesn't
					// know when to stop: ambig.  ANTLR resolves
					// it correctly by matching immediately.  It
					// is therefor ok to hush warning.
					options {
						warnWhenFollowAmbig=false;
					}
				:	HEX_DIGIT
				)+
			|	('0'..'7')+									// octal
			)?
		|	('1'..'9') ('0'..'9')*  {isDecimal=true;}		// non-zero decimal
		)
		(	('l' ('l' { _ttype = NUM_BIGINT; })? |'L' ('L' { _ttype = NUM_BIGINT; })?) 
		
		// only check to see if it's a float if looks like decimal so far
		|	{isDecimal}?
			(	'.' 			{ _ttype = NUM_DECIMAL; } ('0'..'9')* (EXPONENT { _ttype = NUM_FLOAT; })? (FLOAT_SUFFIX { _ttype = NUM_FLOAT; })?
			|	EXPONENT (FLOAT_SUFFIX)? { _ttype = NUM_FLOAT; }
			|	FLOAT_SUFFIX { _ttype = NUM_FLOAT; }
			)
		)?
        {
             mConvertedScript << text.substr(_begin, text.length()-_begin);
        }
	;


// a couple protected methods to assist in matching floating point numbers
protected
EXPONENT
	:	('e'|'E') ('+'|'-')? ('0'..'9')+
	;


protected
FLOAT_SUFFIX
	:	'f'|'F'|'d'|'D'
	;

protected
BIGINT_SUFFIX
	:	"LL"
	;

// hexadecimal digit (again, note it's protected!)
protected
HEX_DIGIT
	:	('0'..'9'|'A'..'F'|'a'..'f')
	;


