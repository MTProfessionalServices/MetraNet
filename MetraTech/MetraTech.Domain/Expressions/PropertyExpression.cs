using System;
using System.Globalization;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Expressions
{
  /// <summary>
  /// Refers to an expression evaluated as the value of a named property in an Entity
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  public class PropertyExpression : Expression
  {
    /// <summary>
    /// The expression whose property is bein accessed
    /// </summary>
    [DataMember]
    public Expression Expression { get; set; }

    /// <summary>
    /// The name of the property to be evaluated
    /// </summary>
    [DataMember]
    public string PropertyName { get; set; }

    /// <summary>
    /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
    /// </summary>
    /// <param name="parameters">A parameter to be referenced by an variable expressions</param>
    /// <returns>A linq expression</returns>
    public override System.Linq.Expressions.Expression ConvertToLinq(params System.Linq.Expressions.ParameterExpression[] parameters)
    {
        var expression = Expression.ConvertToLinq(parameters);
        var inputType = expression.Type;
        var propertyInfo = inputType.GetProperty(PropertyName);
        if (propertyInfo == null)
            throw new ApplicationException(String.Format(CultureInfo.CurrentCulture,
                                                     "Property Expression is not valid: {0} {1}", PropertyName,
                                                     inputType.Name));
        return System.Linq.Expressions.Expression.Property(expression, PropertyName);
    }

      /// <summary>
    /// Represents string interpretation of property expression
    /// </summary>
    /// <returns>A string value</returns>
    public override string ToString()
    {
      return PropertyName ?? "NULL";
    }
  }
}
