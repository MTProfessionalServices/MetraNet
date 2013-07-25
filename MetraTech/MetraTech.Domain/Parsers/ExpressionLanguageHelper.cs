using System;
using System.Collections.Generic;
using Antlr4.Runtime;
using MetraTech.Domain.Expressions;

namespace MetraTech.Domain.Parsers
{
    public static class ExpressionLanguageHelper
    {
        public static Expression ParseExpression(string input)
        {
            var lex = new ExpressionLanguageLexer(new AntlrInputStream(input));
            var tokens = new CommonTokenStream(lex);
            var parser = new ExpressionLanguageParser(tokens);
            parser.RemoveErrorListeners(); // remove default ConsoleErrorListener
            var syntaxErrors = new List<SyntaxErrorDetail>();
            parser.AddErrorListener(new ExpressionErrorListener(syntaxErrors));
            var context = parser.parse();
            if (syntaxErrors.Count > 0)
            {
                throw new ExpressionParsingException(syntaxErrors);
            }
            var visitor = new ExpressionBuilder();
            var expression = visitor.Visit(context);
            return expression;
        }
    }
}
