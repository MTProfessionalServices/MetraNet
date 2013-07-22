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
            var visitor = new ExpressionBuilder();
            var context = parser.parse();
            var expression = visitor.Visit(context);
            return expression;
        }
    }
}
