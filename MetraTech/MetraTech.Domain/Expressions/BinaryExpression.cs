using System;
using System.Runtime.Serialization;
using System.Text;

namespace MetraTech.Domain.Expressions
{
  /// <summary>
  /// An expression that is evaluated by taking an operator and 2 input expressions
  /// </summary>
  [DataContract(Namespace = "MetraTech")]
  public class BinaryExpression : Expression
  {
    /// <summary>
    /// The operator used to evaluate the expression
    /// </summary>
    [DataMember]
    public BinaryOperator Operator { get; set; }
    /// <summary>
    /// The left operand for the binary expression
    /// </summary>
    [DataMember]
    public Expression Left { get; set; }
    /// <summary>
    /// The right operand for the binary expression
    /// </summary>
    [DataMember]
    public Expression Right { get; set; }

    private static System.Linq.Expressions.BinaryExpression CreateBinaryLinqExpression(System.Linq.Expressions.Expression leftExpression, BinaryOperator binaryOperator, System.Linq.Expressions.Expression rightExpression)
    {
      System.Linq.Expressions.BinaryExpression binaryExpression = null;
      switch (binaryOperator)
      {
        case BinaryOperator.Equal:
          binaryExpression = System.Linq.Expressions.Expression.Equal(leftExpression, rightExpression);
          break;
        case BinaryOperator.NotEqual:
          binaryExpression = System.Linq.Expressions.Expression.NotEqual(leftExpression, rightExpression);
          break;
        case BinaryOperator.GreaterThan:
          binaryExpression = System.Linq.Expressions.Expression.GreaterThan(leftExpression, rightExpression);
          break;
        case BinaryOperator.GreaterThanOrEqual:
          binaryExpression = System.Linq.Expressions.Expression.GreaterThanOrEqual(leftExpression, rightExpression);
          break;
        case BinaryOperator.LessThan:
          binaryExpression = System.Linq.Expressions.Expression.LessThan(leftExpression, rightExpression);
          break;
        case BinaryOperator.LessThanOrEqual:
          binaryExpression = System.Linq.Expressions.Expression.LessThanOrEqual(leftExpression, rightExpression);
          break;
        case BinaryOperator.And:
          binaryExpression = System.Linq.Expressions.Expression.AndAlso(leftExpression, rightExpression);
          break;
        case BinaryOperator.Or:
          binaryExpression = System.Linq.Expressions.Expression.OrElse(leftExpression, rightExpression);
          break;
        case BinaryOperator.Add:
          binaryExpression = System.Linq.Expressions.Expression.Add(leftExpression, rightExpression);
          break;
        case BinaryOperator.Subtract:
          binaryExpression = System.Linq.Expressions.Expression.Subtract(leftExpression, rightExpression);
          break;
        case BinaryOperator.Multiply:
          binaryExpression = System.Linq.Expressions.Expression.Multiply(leftExpression, rightExpression);
          break;
        case BinaryOperator.Divide:
          binaryExpression = System.Linq.Expressions.Expression.Divide(leftExpression, rightExpression);
          break;
        case BinaryOperator.Modulo:
          binaryExpression = System.Linq.Expressions.Expression.Modulo(leftExpression, rightExpression);
          break;
        case BinaryOperator.Power:
          binaryExpression = System.Linq.Expressions.Expression.Power(leftExpression, rightExpression);
          break;
      }
      if (binaryExpression == null) throw new NotImplementedException();
      return binaryExpression;
    }

    /// <summary>
    /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
    /// </summary>
    /// <param name="parameter">A parameter to be referenced by an variable expressions</param>
    /// <returns>A linq expression</returns>
    public override System.Linq.Expressions.Expression ConvertToLinq(System.Linq.Expressions.Expression parameter)
    {
      var leftLinqExpression = Left.ConvertToLinq(parameter);
      var rightLinqExpression = Right.ConvertToLinq(parameter);
      return CreateBinaryLinqExpression(leftLinqExpression, Operator, rightLinqExpression);
    }

    /// <summary>
    /// Validate binary expression
    /// </summary>
    public override void Validate()
    {
      if ((Left == null) || (Right == null)) throw new ApplicationException("Invalid binary expression");
    }

    /// <summary>
    /// Represents string interpretation of binary expression
    /// </summary>
    /// <returns>A string value</returns>
    public override string ToString()
    {
      var sb = new StringBuilder();
      ToStringChild(sb, Left);
      sb.Append(" ").Append(OperatorHelper.BinaryOperatorToString[Operator]).Append(" ");
      ToStringChild(sb, Right);
      return sb.ToString();
    }

    private void ToStringChild(StringBuilder sb, Expression expr)
    {
      if (expr == null)
      {
        sb.Append("NULL"); 
        return;
      }
      var binExpr = expr as BinaryExpression;
      if (binExpr != null && binExpr.Operator < Operator)
      {
        sb.Append("(").Append(expr).Append(")");
      }
      else
      {
        sb.Append(expr);
      }
    }
  }
}
