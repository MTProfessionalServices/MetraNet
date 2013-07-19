// Generated from Parsers\ExpressionLanguage.g4 by ANTLR 4.0.1-SNAPSHOT
namespace MetraTech.Domain {

using System;

using Antlr4.Runtime.Tree;
using IToken = Antlr4.Runtime.IToken;

public interface IExpressionLanguageListener : IParseTreeListener {
	void EnterField(ExpressionLanguageParser.FieldContext context);
	void ExitField(ExpressionLanguageParser.FieldContext context);

	void EnterHdr(ExpressionLanguageParser.HdrContext context);
	void ExitHdr(ExpressionLanguageParser.HdrContext context);

	void EnterFile(ExpressionLanguageParser.FileContext context);
	void ExitFile(ExpressionLanguageParser.FileContext context);

	void EnterRow(ExpressionLanguageParser.RowContext context);
	void ExitRow(ExpressionLanguageParser.RowContext context);
}
} // namespace MetraTech.Domain
