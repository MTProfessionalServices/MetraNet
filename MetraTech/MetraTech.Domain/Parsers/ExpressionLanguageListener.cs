// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {
using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;

public interface IExpressionLanguageListener : IParseTreeListener {
	void EnterFunctionExpression(ExpressionLanguageParser.FunctionExpressionContext context);
	void ExitFunctionExpression(ExpressionLanguageParser.FunctionExpressionContext context);

	void EnterBinaryExpression(ExpressionLanguageParser.BinaryExpressionContext context);
	void ExitBinaryExpression(ExpressionLanguageParser.BinaryExpressionContext context);

	void EnterIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context);
	void ExitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context);

	void EnterParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context);
	void ExitParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context);

	void EnterBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context);
	void ExitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context);

	void EnterDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context);
	void ExitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context);

	void EnterPropertyExpression(ExpressionLanguageParser.PropertyExpressionContext context);
	void ExitPropertyExpression(ExpressionLanguageParser.PropertyExpressionContext context);

	void EnterNumberExpression(ExpressionLanguageParser.NumberExpressionContext context);
	void ExitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context);

	void EnterUnaryExpression(ExpressionLanguageParser.UnaryExpressionContext context);
	void ExitUnaryExpression(ExpressionLanguageParser.UnaryExpressionContext context);

	void EnterStringExpression(ExpressionLanguageParser.StringExpressionContext context);
	void ExitStringExpression(ExpressionLanguageParser.StringExpressionContext context);

	void EnterParse(ExpressionLanguageParser.ParseContext context);
	void ExitParse(ExpressionLanguageParser.ParseContext context);

	void EnterFunction(ExpressionLanguageParser.FunctionContext context);
	void ExitFunction(ExpressionLanguageParser.FunctionContext context);
}
} // namespace MetraTech.Domain
