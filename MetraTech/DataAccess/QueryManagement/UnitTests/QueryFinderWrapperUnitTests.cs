using MetraTech.DataAccess.QueryManagement;
using NUnit.Framework;
using System;
using System.Collections;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for QueryFinderWrapperUnitTests and is intended
    ///to contain all QueryFinderWrapperUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class QueryFinderWrapperUnitTests
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
        ///A test for QueryFinderWrapper Constructor
        ///</summary>
        [Test]
        public void QueryFinderWrapperConstructorTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper();
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for GetCoreDirectories
        ///</summary>
        [Test]
        public void GetCoreDirectoriesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator paths = null; // TODO: Initialize to an appropriate value
            IEnumerator pathsExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreDirectories(out paths);
            Assert.AreEqual(pathsExpected, paths);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreDirectoriesInfoFilesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator files = null; // TODO: Initialize to an appropriate value
            IEnumerator filesExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreDirectoriesInfoFiles(out files);
            Assert.AreEqual(filesExpected, files);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectories
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator paths = null; // TODO: Initialize to an appropriate value
            IEnumerator pathsExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreOverrideDirectories(out paths);
            Assert.AreEqual(pathsExpected, paths);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesInfoFilesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator files = null; // TODO: Initialize to an appropriate value
            IEnumerator filesExpected = null; // TODO: Initialize to an appropriate value
            target.GetCoreOverrideDirectoriesInfoFiles(out files);
            Assert.AreEqual(filesExpected, files);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCustomDirectories
        ///</summary>
        [Test]
        public void GetCustomDirectoriesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator paths = null; // TODO: Initialize to an appropriate value
            IEnumerator pathsExpected = null; // TODO: Initialize to an appropriate value
            target.GetCustomDirectories(out paths);
            Assert.AreEqual(pathsExpected, paths);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetCustomDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCustomDirectoriesInfoFilesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator files = null; // TODO: Initialize to an appropriate value
            IEnumerator filesExpected = null; // TODO: Initialize to an appropriate value
            target.GetCustomDirectoriesInfoFiles(out files);
            Assert.AreEqual(filesExpected, files);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }

        /// <summary>
        ///A test for GetDbAccessorFiles
        ///</summary>
        [Test]
        public void GetDbAccessorFilesTest()
        {
            QueryFinderWrapper target = new QueryFinderWrapper(); // TODO: Initialize to an appropriate value
            IEnumerator files = null; // TODO: Initialize to an appropriate value
            IEnumerator filesExpected = null; // TODO: Initialize to an appropriate value
            target.GetDbAccessorFiles(out files);
            Assert.AreEqual(filesExpected, files);
            Assert.Inconclusive("A method that does not return a value cannot be verified.");
        }
    }
}
