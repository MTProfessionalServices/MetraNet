// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;

public interface IExpressionLanguageListener : IParseTreeListener {
	void EnterOrExpression(ExpressionLanguageParser.OrExpressionContext context);
	void ExitOrExpression(ExpressionLanguageParser.OrExpressionContext context);

	void EnterAndExpression(ExpressionLanguageParser.AndExpressionContext context);
	void ExitAndExpression(ExpressionLanguageParser.AndExpressionContext context);

	void EnterIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context);
	void ExitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context);

	void EnterParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context);
	void ExitParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context);

	void EnterNotExpression(ExpressionLanguageParser.NotExpressionContext context);
	void ExitNotExpression(ExpressionLanguageParser.NotExpressionContext context);

	void EnterBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context);
	void ExitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context);

	void EnterDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context);
	void ExitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context);

	void EnterNumberExpression(ExpressionLanguageParser.NumberExpressionContext context);
	void ExitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context);

	void EnterStringExpression(ExpressionLanguageParser.StringExpressionContext context);
	void ExitStringExpression(ExpressionLanguageParser.StringExpressionContext context);

	void EnterParse(ExpressionLanguageParser.ParseContext context);
	void ExitParse(ExpressionLanguageParser.ParseContext context);

	void EnterFunction(ExpressionLanguageParser.FunctionContext context);
	void ExitFunction(ExpressionLanguageParser.FunctionContext context);
}
} // namespace MetraTech.Domain
