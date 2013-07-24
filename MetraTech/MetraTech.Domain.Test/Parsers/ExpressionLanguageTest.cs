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
            var binaryExpression = ExpressionLanguageHelper.ParseExpression("payment.Currency = \"USD\"");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var result = binaryExpression.Evaluate<bool, FakePayment>("payment", payment);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void ComplexExpressionTest()
        {
            var binaryExpression = ExpressionLanguageHelper.ParseExpression("payment.Amount * 3.5 + 2");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var result = binaryExpression.Evaluate<Decimal, FakePayment>("payment", payment);
            Assert.AreEqual(19.5m, result);
        }

        [TestMethod]
        public void PropertyChainExpressionTest()
        {
            var emailExpression = ExpressionLanguageHelper.ParseExpression("payment.Payer.EmailAddress");
            var payer = new FakeAccount {EmailAddress = "mdesousa@metratech.com" };
            var payment = new FakePayment { Amount = 5, Currency = "USD", Payer = payer };
            var result = emailExpression.Evaluate<string, FakePayment>("payment", payment);
            Assert.AreEqual("mdesousa@metratech.com", result);
        }

        [TestMethod]
        public void SyntaxErrorTest()
        {
            try
            {
                ExpressionLanguageHelper.ParseExpression("payment 3.5 + 2");
                Assert.Fail();
            }
            catch (ExpressionParsingException e)
            {
                Assert.AreEqual(1, e.SyntaxErrors.Count);
                var errorDetail = e.SyntaxErrors[0];
                Assert.AreEqual(1, errorDetail.Line);
                Assert.AreEqual(8, errorDetail.CharacterPosition);
                Assert.AreEqual("extraneous input '3.5' expecting {<EOF>, OR, AND, EQUALS, NOTEQUALS, '<', '<=', '>', '>=', '+', '-', '*', '/', '%', '^', '.'}", errorDetail.Message);
            }
        }

        [TestMethod]
        public void MultipleSyntaxErrorTest()
        {
            try
            {
                ExpressionLanguageHelper.ParseExpression("payment 3.5 + 2 bad $ +");
                Assert.Fail();
            }
            catch (ExpressionParsingException e)
            {
                Assert.AreEqual(2, e.SyntaxErrors.Count);
            }
        }

        [TestMethod]
        public void MultipleArgumentTest()
        {
            var binaryExpression = ExpressionLanguageHelper.ParseExpression("payment.Currency = \"USD\" and account.Email = \"mdesousa@metratech.com\"");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var account = new FakeAccount { EmailAddress = "mdesousa@metratech.com" };
            var result = binaryExpression.Evaluate<bool, FakePayment, FakeAccount>("payment", payment, "account", account);
            Assert.AreEqual(true, result);
        }

    }
}
