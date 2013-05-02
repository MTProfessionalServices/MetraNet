namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    using MetraTech.DataAccess.QueryManagement;
    using NUnit.Framework;
    using System;
    using System.Collections.Generic;    
    
    /// <summary>
    ///This is a test class for QueryManagementValidatorUnitTests and is intended
    ///to contain all QueryManagementValidatorUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class QueryManagementValidatorUnitTests
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
        ///A test for QueryManagementValidator Constructor
        ///</summary>
        [Test]
        public void QueryManagementValidatorConstructorTest()
        {
            QueryManagementValidator target = new QueryManagementValidator();
            Assert.Inconclusive("TODO: Implement code to verify target");
        }


        /// <summary>
        ///A test for ValidateAllQueryDirectories
        ///</summary>
        [Test]
        public void ValidateAllQueryDirectoriesTest()
        {
            IEnumerable<string> badDirectories = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> badDirectoriesExpected = null; // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = QueryManagementValidator.ValidateAllQueryDirectories(DatabaseTypeEnum.SqlServer, out badDirectories);
            Assert.AreEqual(badDirectoriesExpected, badDirectories);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
