using System.IO;
using NUnit.Framework;
using System.Collections.Generic;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for QueryFinderUnitTests and is intended
    ///to contain all QueryFinderUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class QueryFinderUnitTests
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
        ///A test for GetCoreDirectories
        ///</summary>
        [Test]
        public void GetCoreDirectoriesTest()
        {
            // Get directories
            var actual = QueryFinder.GetCoreDirectories();
            var expected = QueryFinder.GetCoreDirectories();
            // Check if each one exists
            foreach (var dir in actual)
            {
                Assert.True(Directory.Exists(dir));
            }

            // Check if there is an info file
            
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetCoreDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreDirectoriesInfoFilesTest()
        {
            var expected = new string[] { "one", "two", "three" }; 
            IEnumerable<string> actual;
            actual = QueryFinder.GetCoreDirectoriesInfoFiles();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectories
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesTest()
        {
            IEnumerable<string> expected = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> actual;
            actual = QueryFinder.GetCoreOverrideDirectories();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetCoreOverrideDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCoreOverrideDirectoriesInfoFilesTest()
        {
            IEnumerable<string> expected = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> actual;
            actual = QueryFinder.GetCoreOverrideDirectoriesInfoFiles();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetCustomDirectories
        ///</summary>
        [Test]
        public void GetCustomDirectoriesTest()
        {
            IEnumerable<string> expected = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> actual;
            actual = QueryFinder.GetCustomDirectories();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetCustomDirectoriesInfoFiles
        ///</summary>
        [Test]
        public void GetCustomDirectoriesInfoFilesTest()
        {
            IEnumerable<string> expected = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> actual;
            actual = QueryFinder.GetCustomDirectoriesInfoFiles();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for GetDbAccessorFiles
        ///</summary>
        [Test]
        public void GetDbAccessorFilesTest()
        {
            IEnumerable<string> expected = null; // TODO: Initialize to an appropriate value
            IEnumerable<string> actual;
            actual = QueryFinder.GetDbAccessorFiles();
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

    }
}
