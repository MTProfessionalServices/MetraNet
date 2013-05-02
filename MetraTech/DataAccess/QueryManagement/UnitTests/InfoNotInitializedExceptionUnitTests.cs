using MetraTech.DataAccess.QueryManagement;
using NUnit.Framework;
using System;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for InfoNotInitializedExceptionUnitTests and is intended
    ///to contain all InfoNotInitializedExceptionUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class InfoNotInitializedExceptionUnitTests
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
        ///A test for InfoNotInitializedException Constructor
        ///</summary>
        [Test]
        public void InfoNotInitializedExceptionConstructorTest()
        {
            string errorMessage = string.Empty; // TODO: Initialize to an appropriate value
            Exception innerEx = null; // TODO: Initialize to an appropriate value
            InfoNotInitializedException target = new InfoNotInitializedException(errorMessage, innerEx);
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for InfoNotInitializedException Constructor
        ///</summary>
        [Test]
        public void InfoNotInitializedExceptionConstructorTest1()
        {
            string errorMessage = string.Empty; // TODO: Initialize to an appropriate value
            InfoNotInitializedException target = new InfoNotInitializedException(errorMessage);
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for ErrorMessage
        ///</summary>
        [Test]
        public void ErrorMessageTest()
        {
            string errorMessage = string.Empty; // TODO: Initialize to an appropriate value
            InfoNotInitializedException target = new InfoNotInitializedException(errorMessage); // TODO: Initialize to an appropriate value
            string actual;
            actual = target.ErrorMessage;
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
