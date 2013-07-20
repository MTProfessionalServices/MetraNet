using System;
using System.Globalization;
using System.Text.RegularExpressions;
using Antlr4.Runtime;
using MetraTech.Domain.Expressions;

namespace MetraTech.Domain.Parsers
{
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

        public override Expression VisitBooleanExpression(ExpressionLanguageParser.BooleanExpressionContext context)
        {
            var value = context.GetText() == "true";
            var expression = new ConstantExpression { Value = value };
            return expression;
        }

        public override Expression VisitStringExpression(ExpressionLanguageParser.StringExpressionContext context)
        {
            var stringWithQuotes = context.GetText();
            var value = String.Format(CultureInfo.InvariantCulture, stringWithQuotes.Substring(1, stringWithQuotes.Length - 2));

            // Replace escape sequences
            var regxex = new Regex(@"\\u([0-9A-Fa-f]{4})");
            value = regxex.Replace(value, match => ((char)Int32.Parse(match.Value.Substring(2), NumberStyles.HexNumber)).ToString(CultureInfo.InvariantCulture));
            value = value.Replace("\\n", "\n");
            value = value.Replace("\\r", "\r");
            value = value.Replace("\\t", "\t");
            value = value.Replace("\\\"", "\"");
            value = value.Replace("\\\\", "\\");
            
            var expression = new ConstantExpression { Value = value };
            return expression;
        }

        public override Expression VisitDateTimeExpression(ExpressionLanguageParser.DateTimeExpressionContext context)
        {
            var stringWithPounds = context.GetText();
            var stringDateTime = String.Format(CultureInfo.InvariantCulture, stringWithPounds.Substring(1, stringWithPounds.Length - 2));
            DateTime value;
            if (!DateTime.TryParseExact(stringDateTime, "u", CultureInfo.InvariantCulture, DateTimeStyles.None, out value))
            {
                throw new RecognitionException(String.Format("{0} is not a valid DateTime format", stringDateTime), null, null, context);
            }
            var expression = new ConstantExpression { Value = value };
            return expression;
        }

        public override Expression VisitIdentifierExpression(ExpressionLanguageParser.IdentifierExpressionContext context)
        {
            var name = context.GetText();
            var expression = new PropertyExpression { Name = name };
            return expression;
        }
    }
}
