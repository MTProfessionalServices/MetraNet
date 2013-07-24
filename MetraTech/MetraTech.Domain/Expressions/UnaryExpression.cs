using System;
using System.Runtime.Serialization;
using System.Text;

namespace MetraTech.Domain.Expressions
{
    /// <summary>
    /// An expression that is evaluated by taking an operator and 1 input expressions
    /// </summary>
    [DataContract(Namespace = "MetraTech")]
    public class UnaryExpression : Expression
    {
        /// <summary>
        /// The operator used to evaluate the expression
        /// </summary>
        [DataMember]
        public UnaryOperator Operator { get; set; }
        /// <summary>
        /// The left operand for the binary expression
        /// </summary>
        [DataMember]
        public Expression Expression { get; set; }

        private static System.Linq.Expressions.UnaryExpression CreateUnaryLinqExpression(UnaryOperator unaryOperator, System.Linq.Expressions.Expression expression)
        {
            System.Linq.Expressions.UnaryExpression unaryExpression = null;
            switch (unaryOperator)
            {
                case UnaryOperator.Not:
                    unaryExpression = System.Linq.Expressions.Expression.IsFalse(expression);
                    break;
                case UnaryOperator.Minus:
                    unaryExpression = System.Linq.Expressions.Expression.Negate(expression);
                    break;
            }
            if (unaryExpression == null) throw new NotImplementedException();
            return unaryExpression;
        }

        /// <summary>
        /// Converts a Metanga Expression into a Linq expression that can be executed against an IQueryable
        /// </summary>
        /// <param name="parameters">A parameter to be referenced by an variable expressions</param>
        /// <returns>A linq expression</returns>
        public override System.Linq.Expressions.Expression ConvertToLinq(params System.Linq.Expressions.ParameterExpression[] parameters)
        {
            var expression = Expression.ConvertToLinq(parameters);
            return CreateUnaryLinqExpression(Operator, expression);
        }

        /// <summary>
        /// Validate binary expression
        /// </summary>
        public override void Validate()
        {
            if (Expression == null) throw new ApplicationException("Invalid unary expression");
        }

        /// <summary>
        /// Represents string interpretation of binary expression
        /// </summary>
        /// <returns>A string value</returns>
        public override string ToString()
        {
            var sb = new StringBuilder();
            sb.Append(OperatorHelper.UnaryOperatorToString[Operator]).Append(" ");
            ToStringChild(sb, Expression);
            return sb.ToString();
        }

        private void ToStringChild(StringBuilder sb, Expression expr)
        {
            if (expr == null)
            {
                sb.Append("NULL");
                return;
            }
            var unaryExpression = expr as UnaryExpression;
            if (unaryExpression != null && unaryExpression.Operator < Operator)
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
