grammar ExpressionLanguage;

parse
 : expression
 ;

expression
 : '(' expression ')'                       # ParenthesisExpression
 | NOT expression                           # UnaryExpression
 | expression AND expression                # BinaryExpression
 | expression OR expression                 # BinaryExpression
 | expression (EQUALS|NOTEQUALS) expression # BinaryExpression
 | expression (LT|LTEQ|GT|GTEQ) expression  # BinaryExpression
 | MINUS expression                         # UnaryExpression
 | expression POW expression                # BinaryExpression
 | expression (MULT|DIV|MOD) expression     # BinaryExpression
 | expression (PLUS|MINUS) expression       # BinaryExpression
 | STRING                                   # StringExpression
 | INTEGER                                  # NumberExpression
 | DECIMAL                                  # NumberExpression
 | DATETIME                                 # DateTimeExpression
 | BOOLEAN                                  # BooleanExpression
 | IDENTIFIER                               # IdentifierExpression
 | function                                 # FunctionExpression
 ;

function
	:	IDENTIFIER '(' ( expression (',' expression)* )? ')'
	;

OR         : '||' | 'or';
AND        : '&&' | 'and';
EQUALS     : '=' | '==';
NOTEQUALS  : '!=' | '<>';
LT         : '<';
LTEQ       : '<=';
GT         : '>';
GTEQ       : '>=';
PLUS       : '+';
MINUS      : '-';
MULT       : '*';
DIV        : '/';
MOD        : '%';
POW        : '^';
NOT        : '!' | 'not';
STRING     : '"' ( EscapeSequence | ~('\u0000'..'\u001f' | '\\' | '"' ))* '"';
INTEGER    : [0-9]+;
DECIMAL    : [0-9]* '.' [0-9]+;
DATETIME   : '#' (~'#')* '#';
BOOLEAN	   : 'true'	| 'false';
IDENTIFIER : [a-zA-Z_] [a-zA-Z_0-9]*;
SPACE      : [ \t\r\n]+ -> skip;

fragment EscapeSequence : '\\' ('n' | 'r' | 't' | '"' | '\\' | UnicodeEscape);
fragment UnicodeEscape : 'u' HexDigit HexDigit HexDigit HexDigit;
fragment HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;
