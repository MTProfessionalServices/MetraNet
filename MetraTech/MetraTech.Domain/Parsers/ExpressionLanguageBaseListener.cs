// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using System;


using IErrorNode = Antlr4.Runtime.Tree.IErrorNode;
using ITerminalNode = Antlr4.Runtime.Tree.ITerminalNode;
using IToken = Antlr4.Runtime.IToken;
using ParserRuleContext = Antlr4.Runtime.ParserRuleContext;

public partial class ExpressionLanguageBaseListener : IExpressionLanguageListener {
	public virtual void EnterField(ExpressionLanguageParser.FieldContext context) { }
	public virtual void ExitField(ExpressionLanguageParser.FieldContext context) { }

	public virtual void EnterHdr(ExpressionLanguageParser.HdrContext context) { }
	public virtual void ExitHdr(ExpressionLanguageParser.HdrContext context) { }

	public virtual void EnterFile(ExpressionLanguageParser.FileContext context) { }
	public virtual void ExitFile(ExpressionLanguageParser.FileContext context) { }

	public virtual void EnterRow(ExpressionLanguageParser.RowContext context) { }
	public virtual void ExitRow(ExpressionLanguageParser.RowContext context) { }

	public virtual void EnterEveryRule(ParserRuleContext context) { }
	public virtual void ExitEveryRule(ParserRuleContext context) { }
	public virtual void VisitTerminal(ITerminalNode node) { }
	public virtual void VisitErrorNode(IErrorNode node) { }
}
} // namespace MetraTech.Domain
