// nunit-console /fixture:MetraTech.DataAccess.QueryManagement.UnitTests.QueryInfoValidatorUnitTests /assembly:o:\debug\bin\MetraTech.DataAccess.QueryManagement.UnitTests.dll
namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    using System;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    using System.Collections.Generic;

    /// <summary>
    ///This is a test class for QueryInfoValidatorUnitTests and is intended
    ///to contain all QueryInfoValidatorUnitTests Unit Tests
    ///</summary>
    [TestClass]
    public class QueryInfoValidatorUnitTests
    {
#if false
        private QueryInfoValidator mInstanceUnderTest = new QueryInfoValidator();

        private const string DataFilePath = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\";

        [TestInitialize]
        public void Init()
        {

            //
            // TODO: Code to run at the start of every test case
            //
        }


        [TestCleanup]
        public void Clean()
        {
            //
            // TODO: Code that will be called after each Test case
            //
        }

        /// <summary>
        ///A test for QueryInfoValidator Constructor
        ///</summary>
        [TestMethod()]
        public void QueryInfoValidatorConstructorTest()
        {
            mInstanceUnderTest = new QueryInfoValidator();
            Assert.IsFalse(ReferenceEquals(null, mInstanceUnderTest));
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeNoDataTest()
        {
            try
            {
                var fqnInfoFilePath = string.Empty;
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.None, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeNoTargetDBsSupportedTest()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_DBNotSupportedAtAll.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadTargetTest()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_PerfectFile.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.None, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeMissingTargetDBImpleTest()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_MissingTargettSupportFile.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeOnlyCommonDBImpleTest_v1()
        {
            var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_OnlyCommonValidFile.info.xml";
            mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeOnlyCommonDBImpleTest_v2()
        {
            var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_OnlyCommonValidFile.info.xml";
            mInstanceUnderTest.Initialize(DatabaseTypeEnum.Oracle, fqnInfoFilePath);
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeNoFileNameTest()
        {
            try
            {
                var fqnInfoFilePath = string.Empty;
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeMissingFileTest()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_MissingFile.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadFileNameFormatTest_1()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest.BadNameFileFormat.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadFileNameFormatTest_2()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest._info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadFileContentFormatTest_1()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_MalformedFileContentFormat.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadFileContentFormatTest_2()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_MissingFileContentFormat.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }


        /// <summary>
        ///A test for Initialize
        ///</summary>
        [TestMethod()]
        public void InitializeBadFileContentFormatTest_3()
        {
            try
            {
                var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_IncorrectImplementationNameInContent.info.xml";
                mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
                Assert.Fail("Should not pass");
            }
            catch
            { }
        }

        public void InitializeBadFileContentFormatTest_4()
        {
            var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_ExtraData.info.xml";
            mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
        }

        /// <summary>
        ///A test for IsConflictingImplementation_PerfectFileTest
        ///</summary>
        [TestMethod()]
        public void InitializePerfectTest()
        {
            var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_PerfectFile.info.xml";
            mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
            Assert.IsFalse(mInstanceUnderTest.AreImplementationsConflicting());
        }

        /// <summary>
        ///A test for IsConflictingImplementation_PerfectFileTest
        ///</summary>
        [TestMethod()]
        public void InitializeCaseInsensativeTest()
        {
            var fqnInfoFilePath = DataFilePath + "QueryInfoValidatorTest_IgnoreCaseFile.info.xml";
            mInstanceUnderTest.Initialize(DatabaseTypeEnum.SqlServer, fqnInfoFilePath);
            Assert.IsFalse(mInstanceUnderTest.AreImplementationsConflicting());
        }

        /// <summary>
        ///A test for IsExtraImplementationsInDirectory
        ///</summary>
        [TestMethod()]
        public void IsExtraImplementationsInDirectoryTest()
        {
            QueryInfoValidator target = new QueryInfoValidator(); // TODO: Initialize to an appropriate value
            List<string> extrafiles = null; // TODO: Initialize to an appropriate value
            List<string> extrafilesExpected = null; // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = target.IsExtraImplementationsInDirectory(out extrafiles);
            Assert.AreEqual(extrafilesExpected, extrafiles);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for IsFileNameInExpectedFormat
        ///</summary>
        [TestMethod()]
        public void IsFileNameInExpectedFormatTest_1()
        {
            string file = string.Empty; // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = QueryInfoValidator.IsFileNameInExpectedFormat(file, false);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
        /// <summary>
        ///A test for IsFileNameInExpectedFormat
        ///</summary>
        [TestMethod()]
        public void IsFileNameInExpectedFormatTest_2()
        {
            string file = string.Empty; // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = QueryInfoValidator.IsFileNameInExpectedFormat(file, true);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for IsSqlFileImplemenationSupported
        ///</summary>
        [TestMethod()]
        public void IsFileSupportedTest()
        {
            QueryInfoValidator target = new QueryInfoValidator(); // TODO: Initialize to an appropriate value
            string filename = string.Empty; // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = target.IsSqlFileImplemenationSupported(filename, true);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for IsImplementationFilePresent
        ///</summary>
        [TestMethod()]
        public void IsImplementationFilePresentTest()
        {
            var target = new QueryInfoValidator(); // TODO: Initialize to an appropriate value
            DatabaseTypeEnum e = new DatabaseTypeEnum(); // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = target.IsImplementationFilePresent(e);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for IsImplementationSupported
        ///</summary>
        [TestMethod()]
        public void IsImplementationSupportedTest()
        {
            QueryInfoValidator target = new QueryInfoValidator(); // TODO: Initialize to an appropriate value
            DatabaseTypeEnum e = new DatabaseTypeEnum(); // TODO: Initialize to an appropriate value
            bool expected = false; // TODO: Initialize to an appropriate value
            bool actual;
            actual = target.IsImplementationSupported(e);
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
#endif
    }
}
