using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
  /// <summary>
  /// A Constant expression is a basic type of expression that is defined as constant value.
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  public class ConstantExpression : Expression
  {
    /// <summary>
    /// The constant value for this expression. Data types can be string, boolean, decimal, or integer
    /// </summary>
    [DataMember]
    public object Value { get; set; }

    /// <summary>
    /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
    /// </summary>
    /// <param name="parameter">A parameter to be referenced by an variable expressions</param>
    /// <returns>A linq expression</returns>
    public override System.Linq.Expressions.Expression ConvertToLinq(System.Linq.Expressions.Expression parameter)
    {
      return System.Linq.Expressions.Expression.Constant(Value);
    }

    /// <summary>
    /// Represents string interpretation of constant expression
    /// </summary>
    /// <returns>A string value</returns>
    public override string ToString()
    {
      return (Value ?? "NULL").ToString();
    }
  }
}
