// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;
using ParserRuleContext = Antlr4.Runtime.ParserRuleContext;

public partial class ExpressionLanguageBaseVisitor<Result> : AbstractParseTreeVisitor<Result>, IExpressionLanguageVisitor<Result> {
	public virtual Result VisitFunctionExpression(ExpressionLanguageParser.FunctionExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitBinaryExpression(ExpressionLanguageParser.BinaryExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitPropertyExpression(ExpressionLanguageParser.PropertyExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitUnaryExpression(ExpressionLanguageParser.UnaryExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitStringExpression(ExpressionLanguageParser.StringExpressionContext context) { return VisitChildren(context); }

	public virtual Result VisitParse(ExpressionLanguageParser.ParseContext context) { return VisitChildren(context); }

	public virtual Result VisitFunction(ExpressionLanguageParser.FunctionContext context) { return VisitChildren(context); }
}
} // namespace MetraTech.Domain
