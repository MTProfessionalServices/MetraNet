using MetraTech.DataAccess;
using NUnit.Framework;
using System;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for DBAccessValidatorUnitTests and is intended
    ///to contain all DBAccessValidatorUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class DBAccessValidatorUnitTests
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
        ///A test for Initialize
        ///</summary>
        [Test]
        public void InitializeTest()
        {
//            var target = new DBAccessValidator(); // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
//            actual = target.Initialize();
 //           Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
