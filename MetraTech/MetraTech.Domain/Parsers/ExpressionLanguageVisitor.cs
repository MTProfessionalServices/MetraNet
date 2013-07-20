// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;

public interface IExpressionLanguageVisitor<Result> : IParseTreeVisitor<Result> {
	Result VisitOrExpression(ExpressionLanguageParser.OrExpressionContext context);

	Result VisitAndExpression(ExpressionLanguageParser.AndExpressionContext context);

	Result VisitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context);

	Result VisitParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context);

	Result VisitNotExpression(ExpressionLanguageParser.NotExpressionContext context);

	Result VisitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context);

	Result VisitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context);

	Result VisitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context);

	Result VisitStringExpression(ExpressionLanguageParser.StringExpressionContext context);

	Result VisitParse(ExpressionLanguageParser.ParseContext context);

	Result VisitFunction(ExpressionLanguageParser.FunctionContext context);
}
} // namespace MetraTech.Domain
