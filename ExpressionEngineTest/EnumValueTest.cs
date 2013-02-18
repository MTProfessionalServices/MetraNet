using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{  
    /// <summary>
    ///This is a test class for EnumValueTest and is intended
    ///to contain all EnumValueTest Unit Tests
    ///</summary>
    [TestClass()]
    public class EnumValueTest
    {
        #region Context Instance
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
        #endregion

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
        ///A test for ToExpressionSnippet
        ///</summary>
        [TestMethod()]
        public void ToExpressionSnippetTest()
        {
            var enumValue = GetEnumValue("metratech.com", "global", "countryname", 320);
            Assert.AreEqual("Enum.metratech_com.global.countryname#", enumValue.ToMtsql());
        }

        /// <summary>
        ///A test for ToMtsql
        ///</summary>
        [TestMethod()]
        public void ToMtsqlTest()
        {
            var enumValue = GetEnumValue("metratech.com", "global", "countryname", 320);
            Assert.AreEqual("#metratech.com/global/countryname#", enumValue.ToMtsql());
        }

        /// <summary>
        ///A test for EnumValue Constructor
        ///</summary>
        [TestMethod()]
        public void EnumValueConstructorTest()
        {
            var parent = new EnumType(null, "Length", null);
            string name = "Inch";
            int id = 500; 
            var target = new EnumValue(parent, name, id);
            Assert.AreSame(parent, target.EnumType, "EnumType");
            Assert.AreEqual(name, target.Name);
            Assert.AreEqual(id, target.Id);
        }

        #region Helper Methods
        private EnumValue GetEnumValue(string enumSpace, string enumType, string enumValue, int id)
        {
            var space = new EnumSpace(enumSpace, null);
            var type = space.AddType(enumType, null);
            var value = type.AddValue(enumValue, id);
            return value;
        }
        #endregion
    }
}
