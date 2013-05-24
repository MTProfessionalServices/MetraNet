header {
  #include "LogAdapter.h"
}

options {
  mangleLiteralPrefix = "TK_";
  language="Cpp";
}

class DataflowLexer extends Lexer;
options {
	k=2;
	exportVocab=Dataflow;
	charVocabulary = '\3'..'\377';
  caseSensitiveLiterals = false;
}
tokens {
  "FALSE";
  "TRUE";
  NUM_DECIMAL;
  NUM_FLOAT;
  NUM_BIGINT;
  IS="is";
  OPERATOR="operator";
  INPUT="in";
  OUTPUT="out";
  STRING_DECL="string";
  INTEGER_DECL="integer";
  BOOLEAN_DECL="boolean";
  SUBLIST_DECL="sublist";
  INCLUDE_COMPOSITE="include";
  STEP_DECL="step";
  IF_BEGIN="if";
  IF_END="endif";
  ELSE="else";
  THEN="then";
  STEPS_BEGIN="steps";
  STEPS_END="endsteps";
}

{
private:
  MetraFlowLoggerPtr mLog;
  
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

  void setLog(MetraFlowLoggerPtr log)
  {
	mLog = log;
  }

}

AMPERSAND
	:
	'&'
	;

ARROW
  :
  '-' '>'
	;

BANG
  :
  '!'
  ;

BOM
        :
        '\357' '\273'  '\277'
        ;

DOLLAR_SIGN
  :
  '$'
  ;

EQUALS	:
	'='
	;
	
NOTEQUALS
	:
	'<' '>'
	;

NOTEQUALS2
	:
	'!' '='
	;

LTN	:
	'<'
	;

LTEQ	:
	'<' '='
	;

GT	:
	'>'
	;

GTEQ	:
	'>' '='
	;

MODULO	:
	'%'
	;

SL_COMMENT : 
	"--" 
	(~'\n')* '\n'
	{ newline(); }
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
	;

CARET	
	:
	'^'
	;

COMMA :
	','
	;

DOT
	:
	'.'
	;

LBRACKET
	:	'['
	;

LCURLY
	:	'{'
	;

LPAREN
options {
	paraphrase="'('";
}
	:	'('
	;

RBRACKET
	:	']'
	;

RCURLY
	:	'}'
	;

RPAREN
options {
	paraphrase="')'";
}
	:	')'
	;

MINUS
	:
	'-'
	;

PIPE
	:
	'|'
	;

PLUS
	:
	'+'
	;

COLON :
	':'
	;

SEMI :
	';'
	;

SLASH
	:
	'/'
	;
STAR
	:
	'*'
	;

STRING_LITERAL
	:	'"' 
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
        | '"' '"'!
		|	~('"'|'\n'|'\r')
		)*
		'"'
	;

TILDE
	:	'~'
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
	;

ID
options {
	testLiterals = true;
}
	:	('a'..'z'|'A'..'Z'|'_') ('a'..'z'|'A'..'Z'|'_'|'0'..'9')*
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


