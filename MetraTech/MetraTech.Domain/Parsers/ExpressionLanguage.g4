/* 
   Before making changes to this file, you need to remove comments from line 215 in MetraTech.Domain.csproj
   This will add the Antlr target that will update the parser files as this file is edited.
   Do not push MetraTech.Domain.csproj with the Antlr target, because it will break on the build server.
   The Antlr target requires Java 7, which is not installed on the build server. It cannot be installed there
   because it will break the build of the MetraNet Java SDK, which requires Java 4. After this conflict is resolved,
   it should be safe to remove the comments from the Antlr target.
 */
grammar ExpressionLanguage;

parse
 : expression
 ;

expression
 : '(' expression ')'                       # ParenthesisExpression
 | expression DOT IDENTIFIER				# PropertyExpression
 | expression (EQUALS|NOTEQUALS) expression # BinaryExpression
 | expression (LT|LTEQ|GT|GTEQ) expression  # BinaryExpression
 | MINUS expression                         # UnaryExpression
 | expression POW expression                # BinaryExpression
 | expression (MULT|DIV|MOD) expression     # BinaryExpression
 | expression (PLUS|MINUS) expression       # BinaryExpression
 | NOT expression                           # UnaryExpression
 | expression AND expression                # BinaryExpression
 | expression OR expression                 # BinaryExpression
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
DOT        : '.';
STRING     : '"' ( EscapeSequence | ~('\u0000'..'\u001f' | '\\' | '"' ))* '"';
INTEGER    : [0-9]+;
DECIMAL    : [0-9]* '.' [0-9]+;
DATETIME   : '#' (~'#')* '#';
BOOLEAN	   : 'true'	| 'false';
IDENTIFIER : [a-zA-Z_] [a-zA-Z_0-9]*;
SPACE      : [ \t\r\n]+ -> skip;

fragment EscapeSequence : '\\' ('n' | 'r' | 't' | '"' | '\\' | UnicodeEscape);
fragment UnicodeEscape : 'u' HexDigit HexDigit HexDigit HexDigit;
fragment HexDigit : ('0'..'9'|'a'..'f'|'A'..'F');
