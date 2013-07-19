namespace MetraTech.Domain.Parsers
{
    using System;
    using System.Collections.Generic;
    using System.Linq;
    using System.Text;
    using Expressions;

    /// <summary>
    /// Builds a MetraTech Expression after parsing of Expression Language
    /// </summary>
    public class ExpressionBuilder : ExpressionLanguageBaseVisitor<Expression>
    {
        public override Expression VisitNumberExpression(ExpressionLanguageParser.NumberExpressionContext context)
        {
            var value = Decimal.Parse(context.GetText());
            var expression = new ConstantExpression { Value = value };
            return expression;
        }

    }
}
