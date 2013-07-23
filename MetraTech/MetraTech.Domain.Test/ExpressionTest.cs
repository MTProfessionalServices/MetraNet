using System.Collections.Generic;
using System.Linq;
using MetraTech.Domain.DataAccess;
using MetraTech.Domain.Expressions;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace Metanga.Domain.Test
{
    /// <summary>
    ///This is a test class for ExpressionTest and is intended
    ///to contain all ExpressionTest Unit Tests
    ///</summary>
    [TestClass]
    public class ExpressionTest
    {
        private const string UnitTestCategory = "UnitTest";

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext { get; set; }

        #region Additional test attributes

        // 
        //You can use the following additional attributes as you write your tests:
        //
        //Use ClassInitialize to run code before running the first test in the class
        //[ClassInitialize()]
        //public static void MyClassInitialize(TestContext testContext)
        //{
        //}
        //
        //Use ClassCleanup to run code after all tests in a class have run
        //[ClassCleanup()]
        //public static void MyClassCleanup()
        //{
        //}
        //
        //Use TestInitialize to run code before running each test
        //[TestInitialize()]
        //public void MyTestInitialize()
        //{
        //}
        //
        //Use TestCleanup to run code after each test has run
        //[TestCleanup()]
        //public void MyTestCleanup()
        //{
        //}
        //

        #endregion

        private static BinaryExpression BuildBinaryExpression(string propertyName, BinaryOperator binaryOperator, string propertyValue)
        {
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            var propertyExpression = new PropertyExpression { Expression = identifierExpression, PropertyName = propertyName };
            var constantExpression = new ConstantExpression { Value = propertyValue };
            return new BinaryExpression { Left = propertyExpression, Operator = binaryOperator, Right = constantExpression };
        }

        /// <summary>
        ///A test for Expression Constructor
        ///</summary>
        [TestMethod]
        public void ExpressionConstructorTest()
        {
            var expression = new ConstantExpression();
            Assert.IsNotNull(expression);
        }

        [TestMethod]
        public void ConstantExpressionValueSetTest()
        {
            var constantExpression = new ConstantExpression { Value = 5 };
            Assert.AreEqual(5, constantExpression.Value);
        }

        [TestMethod]
        public void PropertyExpressionValueSetTest()
        {
            var propertyExpression = new PropertyExpression { PropertyName = "Currency" };
            Assert.AreEqual("Currency", propertyExpression.PropertyName);
        }

        [TestMethod]
        public void BinaryExpressionSetTest()
        {
            var binaryExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            Assert.AreEqual("Currency", ((PropertyExpression)binaryExpression.Left).PropertyName);
            Assert.AreEqual(BinaryOperator.Equal, binaryExpression.Operator);
            Assert.AreEqual("USD", ((ConstantExpression)binaryExpression.Right).Value);
        }

        [TestMethod]
        public void EvaluateConstantExpressionIntegerTest()
        {
            var constantExpression = new ConstantExpression { Value = 5 };
            var result = constantExpression.Evaluate<int>();
            Assert.AreEqual(5, result);
        }

        [TestMethod]
        public void EvaluateConstantExpressionStringTest()
        {
            var constantExpression = new ConstantExpression { Value = "Test Value" };
            var result = constantExpression.Evaluate<string>();
            Assert.AreEqual("Test Value", result);
        }

        [TestMethod]
        public void EvaluateConstantExpressionWithInputTest()
        {
            var constantExpression = new ConstantExpression { Value = "Test Value" };
            var result = constantExpression.Evaluate<string, int>(5);
            Assert.AreEqual("Test Value", result);
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]
        public void PropertyExpressionRequiresAnInput()
        {
          var parameterExpression = new PropertyExpression {Name = "SomeField"};
          ExceptionAssert.Expected<MetangaException>(() => parameterExpression.Evaluate<int>(),
                                                     ErrorMessages.ERROR_PROPERTY_EXPRESSION_REQUIRES);
        }
        */

        [TestMethod]
        public void PropertyExpressionTest()
        {
            var payment = new FakePayment { Currency = "USD" };
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            var parameterExpression = new PropertyExpression { Expression = identifierExpression, PropertyName = "Currency" };
            var result = parameterExpression.Evaluate<string, FakePayment>(payment);
            Assert.AreEqual("USD", result);
        }

        [TestMethod]
        public void PropertyExpressionDecimalTest()
        {
            var payment = new FakePayment { Amount = 5m };
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            var parameterExpression = new PropertyExpression { Expression = identifierExpression, PropertyName = "Amount" };
            var result = parameterExpression.Evaluate<decimal, FakePayment>(payment);
            Assert.AreEqual(5m, result);
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]
        public void PropertyExpressionInvalidProperty()
        {
            var payment = new FakePayment {Amount = 5m};
            var parameterExpression = new PropertyExpression {Name = "BadProperty"};
            ExceptionAssert.Expected<MetangaException>(() => parameterExpression.Evaluate<int, FakePayment>(payment),
                                                       String.Format(CultureInfo.CurrentCulture,
                                                                     ErrorMessages.ERROR_PROPERTY_EXPRESSION_IS_NOT_VALID,
                                                                     parameterExpression.Name, typeof (FakePayment).Name));
        }
        */

        [TestMethod]
        public void EvaluateSimpleUnaryExpressionTest()
        {
            var constant = new ConstantExpression { Value = true };
            var unaryExpression = new UnaryExpression() { Operator = UnaryOperator.Not, Expression = constant };
            var result = unaryExpression.Evaluate<bool>();
            Assert.AreEqual(false, result);
        }

        [TestMethod]
        public void EvaluateSimpleBinaryExpressionTest()
        {
            var constant1 = new ConstantExpression { Value = 3 };
            var constant2 = new ConstantExpression { Value = 4 };
            var binaryExpression = new BinaryExpression { Left = constant1, Operator = BinaryOperator.Equal, Right = constant2 };
            var result = binaryExpression.Evaluate<bool>();
            Assert.AreEqual(false, result);
        }

        [TestMethod]
        public void EvaluateBinaryExpressionTest()
        {
            var binaryExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var payment = new FakePayment { Amount = 5, Currency = "USD" };
            var result = binaryExpression.Evaluate<bool, FakePayment>(payment);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateBinaryExpressionFalseTest()
        {
            var binaryExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var payment = new FakePayment { Amount = 5, Currency = "EUR" };
            var result = binaryExpression.Evaluate<bool, FakePayment>(payment);
            Assert.AreEqual(false, result);
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]
        public void EvaluateWithoutInputThrowsArgumentException()
        {
          var propertyExpression = new PropertyExpression {Name = "SomeProperty"};
          ExceptionAssert.Expected<MetangaException>(() => propertyExpression.Evaluate<bool, FakePayment>(null),
                                                     String.Format(CultureInfo.CurrentCulture, ErrorMessages.ERROR_PROPERTY_EXPRESSION_IS_NOT_VALID, propertyExpression.Name, typeof(FakePayment).Name));
        }

        [TestMethod]
        public void InvalidOperationThrowsNotImplementedException()
        {
          const BinaryOperator invalidOperator = (BinaryOperator) 1000;
          var binaryExpression = BuildBinaryExpression("Currency", invalidOperator, "USD");
          var payment = new FakePayment {Amount = 5, Currency = "EUR"};
          ExceptionAssert.Expected<NotImplementedException>(() => binaryExpression.Evaluate<bool, FakePayment>(payment));
        }*/

        private static bool EvaluateBinaryOperation(object left, BinaryOperator binaryOperator, object right)
        {
            var leftExpression = new ConstantExpression { Value = left };
            var rightExpression = new ConstantExpression { Value = right };
            var binaryExpression = new BinaryExpression { Left = leftExpression, Operator = binaryOperator, Right = rightExpression };
            return binaryExpression.Evaluate<bool>();
        }

        [TestMethod]
        public void EvaluateNotEqualOperator()
        {
            var result = EvaluateBinaryOperation("USD", BinaryOperator.NotEqual, "EUR");
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateGreaterThanOperator()
        {
            var result = EvaluateBinaryOperation(5, BinaryOperator.GreaterThan, 4);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateGreaterThanOrEqualOperator()
        {
            var result = EvaluateBinaryOperation(5, BinaryOperator.GreaterThanOrEqual, 4);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateLessThanOperator()
        {
            var result = EvaluateBinaryOperation(5, BinaryOperator.LessThan, 6);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateLessThanOrEqualOperator()
        {
            var result = EvaluateBinaryOperation(5, BinaryOperator.LessThanOrEqual, 6);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateAndOperator()
        {
            var result = EvaluateBinaryOperation(true, BinaryOperator.And, true);
            Assert.AreEqual(true, result);
        }

        [TestMethod]
        public void EvaluateOrOperator()
        {
            var result = EvaluateBinaryOperation(false, BinaryOperator.Or, true);
            Assert.AreEqual(true, result);
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]// Mario: Not the best behavior... need to think about this
        public void EvaluateGreaterThanOperatorIncompatibleInputs()
        {
          ExceptionAssert.Expected<InvalidOperationException>(
            () => EvaluateBinaryOperation(5, BinaryOperator.GreaterThan, "USD"));
        }*/

        [TestMethod]
        public void ConstantExpressionTest()
        {
            var constantExpression = new ConstantExpression { Value = 5 };
            constantExpression.ConvertToLinq(null);
        }

        [TestMethod]
        public void IdentifierExpressionTest()
        {
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            identifierExpression.ConvertToLinq(null);
        }

        [TestMethod]
        public void ParameterExpressionTest()
        {
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            var propertyExpression = new PropertyExpression { Expression = identifierExpression, PropertyName = "Currency" };
            var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(FakePayment), "x");
            propertyExpression.ConvertToLinq(parameterExpression);
        }

        /* todo: how to assert exceptions? */
        /*
        /// <summary>
        /// Test for ConvertToLinq method
        /// </summary>
        [TestCategory(UnitTestCategory)]
        [TestMethod]
        public void ParameterExpressionExceptionTest()
        {
            const string notValideProperty = "notValideProperty";
            var parameterExpression = System.Linq.Expressions.Expression.Parameter(typeof(FakePayment), "x");
            var propertyExpression = new PropertyExpression { Name = notValideProperty };
            ExceptionAssert.Expected<MetangaException>(() => propertyExpression.ConvertToLinq(parameterExpression), (String.Format(CultureInfo.CurrentCulture, ErrorMessages.ERROR_PROPERTY_EXPRESSION_IS_NOT_VALID, notValideProperty, typeof(FakePayment).Name)));
        }

        /// <summary>
        /// 
        /// </summary>
        [TestCategory(UnitTestCategory)]
        [TestMethod]
        public void ParameterExpressionNullValueExceptionTest()
        {
          var propertyExpression = new PropertyExpression {Name = "propertyName"};
          var binaryExpression = new BinaryExpression {Left = propertyExpression};
          ExceptionAssert.Expected<MetangaException>(binaryExpression.Validate, ErrorMessages.BINARYEXPRESSION_VALIDATE);
        }

        /// <summary>
        /// 
        /// </summary>
        [TestCategory(UnitTestCategory)]
        [TestMethod]
        public void ParameterExpressionNullNameExceptionTest()
        {
          var constantExpression = new ConstantExpression { Value = "propertyValue" };
          var binaryExpression = new BinaryExpression { Right = constantExpression };
          ExceptionAssert.Expected<MetangaException>(binaryExpression.Validate, ErrorMessages.BINARYEXPRESSION_VALIDATE);
        }*/

        /// <summary>
        /// 
        /// </summary>
        /*[TestCategory(UnitTestCategory)]
        [TestMethod]
        public void ParameterExpressionNullValueExceptionTest1()
        {
          using (ShimsContext.Create())
          {
            var isValidateInvoked = false;
            ShimBinaryExpression.AllInstances.Validate = t1 => { isValidateInvoked = true; };
            var payments = new List<FakePayment> {new FakePayment()}.AsQueryable();
            var filterExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");

            filterExpression.CreateLinqPredicate(payments);
            Assert.IsTrue(isValidateInvoked);
          }
        }*/

        [TestMethod]
        public void BinaryExpressionFilter()
        {
            var payments = new List<FakePayment> { new FakePayment { Amount = 5m, Currency = "USD" }, new FakePayment { Amount = 10m, Currency = "USD" }, new FakePayment { Amount = 7m, Currency = "EUR" } }.AsQueryable();
            var filterExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var whereCallExpression = filterExpression.CreateLinqPredicate(payments);
            var results = payments.Provider.CreateQuery<FakePayment>(whereCallExpression);
            Assert.AreEqual(2, results.Count());
        }

        [TestMethod]
        public void TestSimpleSerializationDeserialization()
        {
            var filterExpression = (Expression)BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var serializedExpression = filterExpression.Serialize();
            var deserializedExpression = SerializationHelper.Deserialize<Expression>(serializedExpression);
            var fakePayment = new FakePayment { Amount = 5, Currency = "USD" };
            Assert.IsTrue(deserializedExpression.Evaluate<bool, FakePayment>(fakePayment));
        }

        [TestMethod]
        public void TestComplexSerializationDeserialization()
        {
            var currencyExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var identifierExpression = new IdentifierExpression { Name = "variable" };
            var amountExpression = new BinaryExpression { Left = new PropertyExpression { Expression = identifierExpression, PropertyName = "Amount" }, Operator = BinaryOperator.GreaterThan, Right = new ConstantExpression { Value = 5m } };
            var complexExpression = (Expression)new BinaryExpression { Left = currencyExpression, Operator = BinaryOperator.And, Right = amountExpression };
            var serializedExpression = complexExpression.Serialize();
            var deserializedExpression = SerializationHelper.Deserialize<Expression>(serializedExpression);

            var fakePayments =
              new List<FakePayment>
        {
          new FakePayment {Amount = 3, Currency = "USD"},
          new FakePayment {Amount = 5, Currency = "USD"},
          new FakePayment {Amount = 8, Currency = "EUR"},
          new FakePayment {Amount = 13, Currency = "USD"},
          new FakePayment {Amount = 21, Currency = "USD"}
        }.AsQueryable();
            var whereExpression = deserializedExpression.CreateLinqPredicate(fakePayments);
            var results = fakePayments.Provider.CreateQuery<FakePayment>(whereExpression);
            Assert.AreEqual(2, results.Count());
        }

        [TestMethod]
        public void TestConstantSerializationDeserialization()
        {
            Expression amountExpression = new BinaryExpression { Left = new ConstantExpression { Value = true }, Operator = BinaryOperator.Equal, Right = new ConstantExpression { Value = true } };
            var serializedExpression = amountExpression.Serialize();
            var deserializedExpression = SerializationHelper.Deserialize<Expression>(serializedExpression);

            var fakePayments =
              new List<FakePayment>
        {
          new FakePayment {Amount = 3, Currency = "USD"},
          new FakePayment {Amount = 5, Currency = "USD"},
          new FakePayment {Amount = 8, Currency = "EUR"},
          new FakePayment {Amount = 13, Currency = "USD"},
          new FakePayment {Amount = 21, Currency = "USD"}
        }.AsQueryable();
            var whereExpression = deserializedExpression.CreateLinqPredicate(fakePayments);
            var results = fakePayments.Provider.CreateQuery<FakePayment>(whereExpression);
            Assert.AreEqual(5, results.Count());
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]
        public void CreateLinqPredicateNullArgument()
        {
          var filterExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
          ExceptionAssert.ExpectedArgumentNullException(() => filterExpression.CreateLinqPredicate<FakePayment>(null),
                                                        "queryable");
        }*/

        [TestMethod]
        public void DetermineTypeOfExpression()
        {
            var filterExpression = BuildBinaryExpression("Currency", BinaryOperator.Equal, "USD");
            var type = filterExpression.ResolveType(typeof(FakePayment));
            Assert.AreEqual(typeof(bool), type);
        }

        /* todo: how to assert exceptions? */
        /*
        [TestMethod]
        public void TypeCannotBeDeterminedForInvalidComparison()
        {
          var filterExpression = new BinaryExpression {Left = new PropertyExpression {Name = "Currency"}, Operator = BinaryOperator.Equal, Right = new ConstantExpression {Value = 5m}};
          ExceptionAssert.Expected<InvalidOperationException>(() => filterExpression.ResolveType(typeof (FakePayment)));
        }*/

        [TestMethod]
        public void ToStringBinaryExpression1()
        {
            var expression = new BinaryExpression
              {
                  Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Currency" },
                        Operator = BinaryOperator.Equal,
                        Right = new ConstantExpression { Value = "USD" }
                    },
                  Operator = BinaryOperator.And,
                  Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.NotEqual,
                        Right = new ConstantExpression { Value = 35m }
                    }
              };
            Assert.AreEqual("Currency = USD AND Amount NOT 35", expression.ToString());
        }

        [TestMethod]
        public void ToStringBinaryExpression2()
        {
            var expression = new BinaryExpression
            {
                Left = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.And,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThanOrEqual,
                        Right = new ConstantExpression { Value = 21m }
                    },
                },
                Operator = BinaryOperator.Or,
                Right = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.And,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThanOrEqual,
                        Right = new ConstantExpression { Value = 45m }
                    },
                },
            };
            Assert.AreEqual("Amount < 35 AND Amount <= 21 OR Amount > 35 AND Amount >= 45", expression.ToString());
        }

        [TestMethod]
        public void ToStringBinaryExpression3()
        {
            var expression = new BinaryExpression
            {
                Left = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.Or,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThanOrEqual,
                        Right = new ConstantExpression { Value = 21m }
                    },
                },
                Operator = BinaryOperator.Or,
                Right = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.And,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThanOrEqual,
                        Right = new ConstantExpression { Value = 45m }
                    },
                },
            };
            Assert.AreEqual("Amount < 35 OR Amount <= 21 OR Amount > 35 AND Amount >= 45", expression.ToString());
        }

        [TestMethod]
        public void ToStringBinaryExpression4()
        {
            var expression = new BinaryExpression
            {
                Left = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.Or,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.LessThanOrEqual,
                        Right = new ConstantExpression { Value = 21m }
                    },
                },
                Operator = BinaryOperator.And,
                Right = new BinaryExpression
                {
                    Left = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThan,
                        Right = new ConstantExpression { Value = 35m }
                    },
                    Operator = BinaryOperator.And,
                    Right = new BinaryExpression
                    {
                        Left = new PropertyExpression { PropertyName = "Amount" },
                        Operator = BinaryOperator.GreaterThanOrEqual,
                        Right = new ConstantExpression { Value = 45m }
                    },
                },
            };
            Assert.AreEqual("(Amount < 35 OR Amount <= 21) AND Amount > 35 AND Amount >= 45", expression.ToString());
        }

        [TestMethod]
        public void ToStringBinaryExpression5()
        {
            var expression = new BinaryExpression
            {
                Operator = BinaryOperator.And,
                Right = new BinaryExpression
                {
                    Left = new PropertyExpression(),
                    Operator = BinaryOperator.NotEqual,
                    Right = new ConstantExpression()
                },
            };
            Assert.AreEqual("NULL AND NULL NOT NULL", expression.ToString());
        }
    }

    /// <summary>
    /// A fake implementation of the payment entity class
    /// </summary>
    public class FakePayment
    {
        /// <summary>
        /// Payment currency
        /// </summary>
        public string Currency { get; set; }

        /// <summary>
        /// Payment amount
        /// </summary>
        public decimal Amount { get; set; }
    }
}