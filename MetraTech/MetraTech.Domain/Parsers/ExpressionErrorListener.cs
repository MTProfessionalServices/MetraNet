using System.Collections.Generic;
using Antlr4.Runtime;

namespace MetraTech.Domain.Parsers
{
    /// <summary>
    /// TODO: Update summary.
    /// </summary>
    public class ExpressionErrorListener : IAntlrErrorListener<object>
    {
        private readonly IList<SyntaxErrorDetail> _errorDetails;
        public ExpressionErrorListener(IList<SyntaxErrorDetail> errorDetails)
        {
            _errorDetails = errorDetails;
        }

        public void SyntaxError(IRecognizer recognizer, object offendingSymbol, int line, int charPositionInLine, string msg,
                                RecognitionException e)
        {
            var errorDetail = new SyntaxErrorDetail(line, charPositionInLine, msg);
            _errorDetails.Add(errorDetail);
        }
    }
}
