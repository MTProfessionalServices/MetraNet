using System;
using System.Collections.Generic;

namespace MetraTech.Domain.Parsers
{
    public class ExpressionParsingException : Exception
    {
        public IList<SyntaxErrorDetail> SyntaxErrors { get; private set; }

        public ExpressionParsingException(IList<SyntaxErrorDetail> syntaxErrors)
        {
            SyntaxErrors = syntaxErrors;
        }
    }
}
