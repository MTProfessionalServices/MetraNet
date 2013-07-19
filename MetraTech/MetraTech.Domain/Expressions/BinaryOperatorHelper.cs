using System.Collections.Generic;

namespace MetraTech.Domain.Expressions
{
  internal static class BinaryOperatorHelper
  {
    public static IDictionary<BinaryOperator, string> BinaryOperatorToString =
      new Dictionary<BinaryOperator, string>
        {
          { BinaryOperator.And, "AND" },
          { BinaryOperator.Or, "OR" },
          { BinaryOperator.Equal, "=" },
          { BinaryOperator.NotEqual, "NOT" },
          { BinaryOperator.GreaterThan, ">" },
          { BinaryOperator.GreaterThanOrEqual, ">=" },
          { BinaryOperator.LessThan, "<" },
          { BinaryOperator.LessThanOrEqual, "<="}
        };
  }
}
