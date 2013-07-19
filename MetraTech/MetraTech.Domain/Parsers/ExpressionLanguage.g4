grammar ExpressionLanguage;

parse
 : expression
 ;

expression
 : '(' expression ')'           # ParenthesisExpression
 | IDENTIFIER                   # IdentifierExpression
 | STRING                       # StringExpression
 | INTEGER                      # NumberExpression
 | DECIMAL                      # NumberExpression
 | DATETIME                     # DateTimeExpression
 | BOOLEAN                      # BooleanExpression
 | NOT expression               # NotExpression
 | expression AND? expression   # AndExpression
 | expression OR expression     # OrExpression
 ;

LPAREN     : '(';
RPAREN     : ')';
NOT        : 'NOT';
AND        : 'AND';
OR         : 'OR';
IDENTIFIER : [a-zA-Z_] [a-zA-Z_0-9]*;
STRING     : '"' ( EscapeSequence | (options {greedy=false;} : ~('\u0000'..'\u001f' | '\\' | '\'' ) ) )* '"';
INTEGER    : ('0'..'9')+;
DECIMAL    : ('0'..'9')* '.' ('0'..'9')+;
DATETIME   : '#' (~'#')* '#';
BOOLEAN	   : 'true'	| 'false';
SPACE      : [ \t\r\n]+ -> skip;

fragment EscapeSequence : '\\' ('n' | 'r' | 't' | '\'' | '\\' | UnicodeEscape);
fragment UnicodeEscape : 'u' HexDigit HexDigit HexDigit HexDigit;
fragment HexDigit : ('0'..'9'|'a'..'f'|'A'..'F') ;
