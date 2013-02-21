using MetraTech.ExpressionEngine.TypeSystem;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    
    
    /// <summary>
    ///This is a test class for EnumerationTypeTest and is intended
    ///to contain all EnumerationTypeTest Unit Tests
    ///</summary>
    [TestClass()]
    public class EnumerationTypeTest
    {


        private TestContext testContextInstance;

        /// <summary>
        ///Gets or sets the test context which provides
        ///information about and functionality for the current test run.
        ///</summary>
        public TestContext TestContext
        {
            get
            {
                return testContextInstance;
            }
            set
            {
                testContextInstance = value;
            }
        }

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


        /// <summary>
        ///A test for EnumerationType Constructor
        ///</summary>
        [TestMethod()]
        public void EnumerationTypeConstructorTest()
        {
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            EnumerationType target = new EnumerationType(enumSpace, enumType);
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for ToString
        ///</summary>
        [TestMethod()]
        public void ToStringTest()
        {
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            EnumerationType target = new EnumerationType(enumSpace, enumType); // TODO: Initialize to an appropriate value
            bool robust = false; // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            actual = target.ToString(robust);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for CompatibleKey
        ///</summary>
        [TestMethod()]
        public void CompatibleKeyTest()
        {
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            EnumerationType target = new EnumerationType(enumSpace, enumType); // TODO: Initialize to an appropriate value
            string actual;
            actual = target.CompatibleKey;
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for EnumSpace
        ///</summary>
        [TestMethod()]
        public void EnumSpaceTest()
        {
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            EnumerationType target = new EnumerationType(enumSpace, enumType); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.Namespace = expected;
            actual = target.Namespace;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for EnumType
        ///</summary>
        [TestMethod()]
        public void EnumTypeTest()
        {
            string enumSpace = string.Empty; // TODO: Initialize to an appropriate value
            string enumType = string.Empty; // TODO: Initialize to an appropriate value
            EnumerationType target = new EnumerationType(enumSpace, enumType); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.Category = expected;
            actual = target.Category;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
