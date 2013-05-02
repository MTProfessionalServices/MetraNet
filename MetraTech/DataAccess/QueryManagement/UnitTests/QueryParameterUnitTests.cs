using NUnit.Framework;
using System;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for QueryParameterUnitTests and is intended
    ///to contain all QueryParameterUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class QueryParameterUnitTests
    {
        [SetUp]
        public void Init()
        {
            //
            // TODO: Code to run at the start of every test case
            //
        }


        [TearDown]
        public void Clean()
        {
            //
            // TODO: Code that will be called after each Test case
            //
        }

        /// <summary>
        ///A test for QueryParameter Constructor
        ///</summary>
        [Test]
        public void QueryParameterConstructorTest()
        {
            QueryParameter target = new QueryParameter();
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for DataType
        ///</summary>
        [Test]
        public void DataTypeTest()
        {
            QueryParameter target = new QueryParameter(); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.DataType = expected;
            actual = target.DataType;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for Description
        ///</summary>
        [Test]
        public void DescriptionTest()
        {
            QueryParameter target = new QueryParameter(); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.Description = expected;
            actual = target.Description;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for Name
        ///</summary>
        [Test]
        public void NameTest()
        {
            QueryParameter target = new QueryParameter(); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.Name = expected;
            actual = target.Name;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for SampleValue
        ///</summary>
        [Test]
        public void SampleValueTest()
        {
            QueryParameter target = new QueryParameter(); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            target.SampleValue = expected;
            actual = target.SampleValue;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
