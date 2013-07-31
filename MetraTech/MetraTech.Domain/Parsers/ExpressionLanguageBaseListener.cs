// Generated from C:\dev\MetraNet\RMP\Extensions\Legacy_Internal\Source\MetraTech\MetraTech.Domain\Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using IErrorNode = Antlr4.Runtime.Tree.IErrorNode;
using ITerminalNode = Antlr4.Runtime.Tree.ITerminalNode;
using IToken = Antlr4.Runtime.IToken;
using ParserRuleContext = Antlr4.Runtime.ParserRuleContext;

public partial class ExpressionLanguageBaseListener : IExpressionLanguageListener {
	public virtual void EnterFunctionExpression(ExpressionLanguageParser.FunctionExpressionContext context) { }
	public virtual void ExitFunctionExpression(ExpressionLanguageParser.FunctionExpressionContext context) { }

	public virtual void EnterBinaryExpression(ExpressionLanguageParser.BinaryExpressionContext context) { }
	public virtual void ExitBinaryExpression(ExpressionLanguageParser.BinaryExpressionContext context) { }

	public virtual void EnterIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context) { }
	public virtual void ExitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context) { }

	public virtual void EnterParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context) { }
	public virtual void ExitParenthesisExpression(ExpressionLanguageParser.ParenthesisExpressionContext context) { }

	public virtual void EnterBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context) { }
	public virtual void ExitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context) { }

	public virtual void EnterDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context) { }
	public virtual void ExitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context) { }

	public virtual void EnterPropertyExpression(ExpressionLanguageParser.PropertyExpressionContext context) { }
	public virtual void ExitPropertyExpression(ExpressionLanguageParser.PropertyExpressionContext context) { }

	public virtual void EnterNumberExpression(ExpressionLanguageParser.NumberExpressionContext context) { }
	public virtual void ExitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context) { }

	public virtual void EnterUnaryExpression(ExpressionLanguageParser.UnaryExpressionContext context) { }
	public virtual void ExitUnaryExpression(ExpressionLanguageParser.UnaryExpressionContext context) { }

	public virtual void EnterStringExpression(ExpressionLanguageParser.StringExpressionContext context) { }
	public virtual void ExitStringExpression(ExpressionLanguageParser.StringExpressionContext context) { }

	public virtual void EnterParse(ExpressionLanguageParser.ParseContext context) { }
	public virtual void ExitParse(ExpressionLanguageParser.ParseContext context) { }

	public virtual void EnterFunction(ExpressionLanguageParser.FunctionContext context) { }
	public virtual void ExitFunction(ExpressionLanguageParser.FunctionContext context) { }

	public virtual void EnterEveryRule(ParserRuleContext context) { }
	public virtual void ExitEveryRule(ParserRuleContext context) { }
	public virtual void VisitTerminal(ITerminalNode node) { }
	public virtual void VisitErrorNode(IErrorNode node) { }
}
} // namespace MetraTech.Domain
