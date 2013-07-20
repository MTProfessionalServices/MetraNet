using System;
using Metanga.Domain.Test;
using MetraTech.Domain.Expressions;
using MetraTech.Domain.Parsers;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Domain.Test.Parsers
{
    [TestClass]
    public class ExpressionLanguageTest
    {
        private static void TestConstantExpression<T>(string input, T expected)
        {
            var expression = ExpressionLanguageHelper.ParseExpression(input);
            Assert.IsNotNull(expression);
            Assert.IsInstanceOfType(expression, typeof (ConstantExpression));
            var value = expression.Evaluate<T>();
            Assert.AreEqual(expected, value);
        }

        [TestMethod]
        public void DecimalTest()
        {
            TestConstantExpression("5.3", 5.3m);
        }

        [TestMethod]
        public void IntegerTest()
        {
            TestConstantExpression("54", 54m);
        }

        [TestMethod]
        public void PureDecimalTest()
        {
            TestConstantExpression(".7", .7m);
        }

        [TestMethod]
        public void BooleanTrueTest()
        {
            TestConstantExpression("true", true);
        }

        [TestMethod]
        public void BooleanFalseTest()
        {
            TestConstantExpression("false", false);
        }

        [TestMethod]
        public void StringTest()
        {
            TestConstantExpression("\"simple\"", "simple");
        }

        [TestMethod]
        public void StringLineFeedTest()
        {
            TestConstantExpression("\"line\\n\"", "line\n");
        }

        [TestMethod]
        public void StringBackslashTest()
        {
            TestConstantExpression("\"folder\\\\file\"", "folder\\file");
        }

        [TestMethod]
        public void StringHexTest()
        {
            TestConstantExpression("\"special\\u0a0f\"", "special\u0a0f");
        }

        [TestMethod]
        public void DateTimeTest()
        {
            TestConstantExpression("#2013-07-19 00:00:00Z#", new DateTime(2013, 7, 19));
        }

        [TestMethod]
        public void BinaryExpressionTest()
        {
            var binaryExpression = ExpressionLanguageHelper.ParseExpression("Currency = \"USD\"");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var result = binaryExpression.Evaluate<bool, FakePayment>(payment);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void ComplexExpressionTest()
        {
            var binaryExpression = ExpressionLanguageHelper.ParseExpression("Amount * 3.5 + 2");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var result = binaryExpression.Evaluate<Decimal, FakePayment>(payment);
            Assert.AreEqual(19.5m, result);
        }
    }
}
