using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine.Test
{
    /// <summary>
    /// I have no idea what this shold look like yet, we just need it.
    /// </summary>
    interface IProcessingEngine
    {
        ExpressionParseResults EvaluateExpression(Expression expression);
    }
}
