// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using System;

using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;

public interface IExpressionLanguageVisitor<Result> : IParseTreeVisitor<Result> {
	Result VisitField(ExpressionLanguageParser.FieldContext context);

	Result VisitHdr(ExpressionLanguageParser.HdrContext context);

	Result VisitFile(ExpressionLanguageParser.FileContext context);

	Result VisitRow(ExpressionLanguageParser.RowContext context);
}
} // namespace MetraTech.Domain
