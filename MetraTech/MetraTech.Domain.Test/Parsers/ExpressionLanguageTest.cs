using System;
using Antlr4.Runtime;
using MetraTech.Domain.Expressions;
using MetraTech.Domain.Parsers;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test.Parsers
{
    [TestClass]
    public class ExpressionLanguageTest
    {
        [TestMethod]
        public void ExpressionLanguageBasicTest()
        {
            const string input = "5.3";
            var expression = ExpressionLanguageHelper.ParseExpression(input);
            Assert.IsNotNull(expression);
            Assert.IsInstanceOfType(expression, typeof(ConstantExpression));
            var value = expression.Evaluate<Decimal>();
            Assert.AreEqual(5.3m, value);
        }
    }
}
