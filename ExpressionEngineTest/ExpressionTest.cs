using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    /// <summary>
    ///This is a test class for ExpressionTest and is intended
    ///to contain all ExpressionTest Unit Tests
    ///</summary>
    [TestClass()]
    public class ExpressionTest
    {


        /// <summary>
        ///A test for Parse
        ///</summary>
        [TestMethod()]
        public void ParseTest()
        {
            var expression = new Expression(ExpressionType.Email, "hello {Invoice.Payer} world", null);
            var results = expression.Parse();
            Assert.AreEqual(1, results.Parameters.Count);
            var parameter = results.Parameters.Get("Invoice.Payer");
            Assert.IsNotNull(parameter);
            Assert.AreEqual("Invoice.Payer}", parameter.Name);
        }
    }
}
