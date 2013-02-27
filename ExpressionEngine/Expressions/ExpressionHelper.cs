using System.Collections.Generic;
using MetraTech.ExpressionEngine.Expressions.Constants;

namespace MetraTech.ExpressionEngine.Expressions
{
    public static class ExpressionHelper
    {
        public static readonly IEnumerable<string> EqualityOperators = new string[]
        {
            ExpressionConstants.EqualityTechnical, 
            ExpressionConstants.EqualityBusiness
        };

        public static readonly IEnumerable<string> InequalityOperators = new string[] 
        {
            ExpressionConstants.InequalityTechnical, 
            ExpressionConstants.InequalityBusiness
        };

    }
}