using MetraTech.DataAccess.QueryManagement.Entities;
using System.Collections.Generic;
using NUnit.Framework;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for StringCollectionUnitTests and is intended
    ///to contain all StringCollectionUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class StringCollectionUnitTests
    {
#if false
        // TODO ALL IMPL

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
        ///A test for StringCollection Constructor
        ///</summary>
        [Test]
        public void StringCollectionConstructorTest()
        {
            IEnumerable<string> list = null; // TODO: Initialize to an appropriate value
            int count = 0; // TODO: Initialize to an appropriate value
            StringCollection target = new StringCollection(list, count);
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for StringCollection Constructor
        ///</summary>
        [Test]
        public void StringCollectionConstructorTest1()
        {
            StringCollection_Accessor target = new StringCollection_Accessor();
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for GetCurrent
        ///</summary>
        [Test]
        public void GetCurrentTest()
        {
            StringCollection target = new StringCollection(); // TODO: Initialize to an appropriate value
            string expected = string.Empty; // TODO: Initialize to an appropriate value
            string actual;
            actual = target.GetCurrent();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for HowMany
        ///</summary>
        [Test]
        public void HowManyTest()
        {
            StringCollection target = new StringCollection(); // TODO: Initialize to an appropriate value
            int expected = 0; // TODO: Initialize to an appropriate value
            int actual;
            actual = target.HowMany();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for MoveNext
        ///</summary>
        [Test]
        public void MoveNextTest()
        {
            StringCollection target = new StringCollection(); // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = target.MoveNext();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
#endif
    }
}
