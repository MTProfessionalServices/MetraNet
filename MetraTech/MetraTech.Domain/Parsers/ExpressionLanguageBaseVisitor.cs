// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using System;

using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;
using ParserRuleContext = Antlr4.Runtime.ParserRuleContext;

public partial class ExpressionLanguageBaseVisitor<Result> : AbstractParseTreeVisitor<Result>, IExpressionLanguageVisitor<Result> {
	public virtual Result VisitField(ExpressionLanguageParser.FieldContext context) { return VisitChildren(context); }

	public virtual Result VisitHdr(ExpressionLanguageParser.HdrContext context) { return VisitChildren(context); }

	public virtual Result VisitFile(ExpressionLanguageParser.FileContext context) { return VisitChildren(context); }

	public virtual Result VisitRow(ExpressionLanguageParser.RowContext context) { return VisitChildren(context); }
}
} // namespace MetraTech.Domain
