using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{   
    /// <summary>
    ///This is a test class for EnumTypeTest and is intended
    ///to contain all EnumTypeTest Unit Tests
    ///</summary>
    [TestClass()]
    public class EnumTypeTest
    {

        /// <summary>
        ///A test for EnumType Constructor
        ///</summary>
        [TestMethod()]
        public void EnumTypeConstructorTest()
        {
            EnumSpace parent = null; // TODO: Initialize to an appropriate value
            string name = string.Empty; // TODO: Initialize to an appropriate value
            string description = string.Empty; // TODO: Initialize to an appropriate value
            EnumType target = new EnumType(parent, name, description);
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for AddValue
        ///</summary>
        [TestMethod()]
        public void AddValueTest()
        {
            EnumSpace parent = null; // TODO: Initialize to an appropriate value
            string name = string.Empty; // TODO: Initialize to an appropriate value
            string description = string.Empty; // TODO: Initialize to an appropriate value
            EnumType target = new EnumType(parent, name, description); // TODO: Initialize to an appropriate value
            string value = string.Empty; // TODO: Initialize to an appropriate value
            int id = 0; // TODO: Initialize to an appropriate value
            EnumValue expected = null; // TODO: Initialize to an appropriate value
            EnumValue actual;
            actual = target.AddValue(value, id);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for ToolTip
        ///</summary>
        [TestMethod()]
        public void ToolTipTest()
        {
            EnumSpace parent = null; // TODO: Initialize to an appropriate value
            string name = string.Empty; // TODO: Initialize to an appropriate value
            string description = string.Empty; // TODO: Initialize to an appropriate value
            EnumType target = new EnumType(parent, name, description); // TODO: Initialize to an appropriate value
            string actual;
            actual = target.ToolTip;
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for ToExpressionSnippet
        ///</summary>
        [TestMethod()]
        public void ToExpressionSnippetTest()
        {
            EnumSpace parent = null; // TODO: Initialize to an appropriate value
            string name = string.Empty; // TODO: Initialize to an appropriate value
            string description = string.Empty; // TODO: Initialize to an appropriate value
            EnumType target = new EnumType(parent, name, description); // TODO: Initialize to an appropriate value
            string actual;
            actual = target.ToExpressionSnippet;
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
