using MetraTech.DataAccess.QueryManagement;
using NUnit.Framework;
using System;
using System.Collections;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for IQueryFinderWrapperUnitTests and is intended
    ///to contain all IQueryFinderWrapperUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class IQueryFinderUnitTests
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

        internal virtual IQueryFinder CreateIQueryFinderWrapper()
        {
            // TODO: Instantiate an appropriate concrete class.
            IQueryFinder target = null;
            return target;
        }

        /// <summary>
        ///A test for GetCoreDirectories
        ///</summary>
        [Test]
        public void GetCoreDirectoriesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreDirectories(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreDirectoriesInfoFilesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreDirectoriesInfoFiles(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectories
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreOverrideDirectories(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesInfoFilesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreOverrideDirectoriesInfoFiles(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCustomDirectories
        ///</summary>
        [Test]
        public void GetCustomDirectoriesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCustomDirectories(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCustomDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCustomDirectoriesInfoFilesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetCustomDirectoriesInfoFiles(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetDbAccessorFiles
        ///</summary>
        [Test]
        public void GetDbAccessorFilesTest()
        {
            IQueryFinder target = CreateIQueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStr = null; // TODO: Initialize to an appropriate value
            IEnumerator arrayOfBStrExpected = null; // TODO: Initialize to an appropriate value
            target.GetDbAccessorFiles(out arrayOfBStr);
            Assert.AreEqual(arrayOfBStrExpected, arrayOfBStr);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }
    }
}
