using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine.Test
{
    interface IProcessingEngine
    {
        ExpressionParseResults EvaluateExpression(Expression expression);
    }
}
