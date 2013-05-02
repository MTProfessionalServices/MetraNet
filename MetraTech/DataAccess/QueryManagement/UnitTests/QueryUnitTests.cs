
// nunit-console /fixture:MetraTech.DataAccess.QueryManagement.UnitTests.QueryUnitTests /assembly:o:\debug\bin\MetraTech.DataAccess.QueryManagement.UnitTests.dll

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    using System.IO;
    using Microsoft.VisualStudio.TestTools.UnitTesting;
    
    
    /// <summary>
    ///This is a test class for QueryUnitTests and is intended
    ///to contain all QueryUnitTests Unit Tests
    ///</summary>
    [TestClass]
    public class QueryUnitTests
    {
#if false
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
        /// Test helper method to create a test file.
        /// </summary>
        /// <param name="filename">full path to the test xml file which you desire to create</param>
        /// <returns></returns>
        private static Query CreateTestQueryFile(string filename)
        {
            // Creates an instance of the XmlSerializer class;
            // specifies the type of object to serialize.
            var writer = new XMLFileSerializerHelper<Query>(); 
            var q = new Query {Description = "This is a query info file", Action = "Query"};

            // Creates an address to ship and bill to.
            var implementations = new string[3];
            implementations[0] = DatabaseTypeConstants.Oracle;
            implementations[1] = DatabaseTypeConstants.SqlServer;
            implementations[2] = DatabaseTypeConstants.Common;
            q.Implementations = implementations;

            var p1 = new QueryParameter
            {
                Name = "Foo",
                DataType = "string",
                SampleValue = "Foo",
                Description = "This is a Foo"
            }; 
            var p2 = new QueryParameter
            {
                Name = "Bar",
                DataType = "int",
                SampleValue = "Bar",
                Description = "This is a Bar"
            };
            QueryParameter[] Parameters = { p1, p2 };
            q.Parameters = Parameters;

            writer.Save(filename, q);
            return q;
        }

        /// <summary>
        /// Creates a query file, then reads it back
        /// Then performs a number of modification to the file contents
        /// to ensure the comparitors work correctly
        ///</summary>
        [TestMethod()]
        public void QueryInfoCompareOfDifferentFiles()
        {
            var testFile = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\test.info.xml";
            // Do some house cleaning first
            if (File.Exists(testFile)) File.Delete(testFile);
            var reader = new XMLFileSerializerHelper<Query>();
            var expected = CreateTestQueryFile(testFile);

            var target = reader.Read(testFile);
            target.Description = string.Empty; // Wack a field to force false comparison
            Assert.AreNotEqual(expected, target);

            target = reader.Read(testFile);
            target.Action = string.Empty; // Wack a field to force false comparison
            Assert.AreNotEqual(expected, target);

            target = reader.Read(testFile);
            target.Implementations[1] = DatabaseTypeConstants.None; // Wack a field to force false comparison
            expected.Equals(target);

            target = reader.Read(testFile);
            target.Parameters[0] = null; // Wack a field to force false comparison
            Assert.AreNotEqual(expected, target);

            target = reader.Read(testFile);
            target.ConversionAudit = new QueryConversionAudit();
            Assert.AreNotEqual(expected, target);

            target.ConversionAudit.OracleQuerySourceFile = "foo";
            Assert.AreNotEqual(expected, target);
        }
        /// <summary>
        /// Creates a query file, then reads it back and compares it. 
        /// This test covers the serialization save and read.
        /// It uses a perfect file.
        ///</summary>
        [TestMethod()]
        public void QueryInfoReadAndWriteTestGoodFile()
        {
            var testFile = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\test.info.xml";
            // Do some house cleaning first
            if (File.Exists(testFile)) File.Delete(testFile);
            var reader = new XMLFileSerializerHelper<Query>();
            var expected = CreateTestQueryFile(testFile);
            var target = reader.Read(testFile);
            Assert.AreEqual(expected, target);
        }

        /// <summary>
        /// Reads an xml file which is malformed.
        ///</summary>
        [TestMethod()]
        public void QueryInfoReadBadXMLFile()
        {
            var testFile = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\malformed.info.xml";
            Assert.IsTrue(File.Exists(testFile));
            try
            {
                var reader = new XMLFileSerializerHelper<Query>();
                reader.Read(testFile);
                Assert.Fail("Should not be able to parse malformed XML");
            }
            catch
            {
                // Ignore
            }
        }

        /// <summary>
        /// Reads a junk file
        ///</summary>
        [TestMethod()]
        public void QueryInfoReadExtraJunkFile()
        {
            var testFile = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\extrajunk.info.xml";
            Assert.IsTrue(File.Exists(testFile));
            try
            {
                var reader = new XMLFileSerializerHelper<Query>();
                reader.Read(testFile);
                Assert.Fail("Should not be able to parse XML with extra data");
            }
            catch
            {
                // Test Pass
            }
        }


        /// <summary>
        /// Reads a junk file
        ///</summary>
        [TestMethod()]
        public void QueryInfoReadMissingFile()
        {
            var testFile = @"U:\MetraTech\DataAccess\QueryManagement\UnitTests\Data\filethatdoesntexist.info.xml";
            Assert.IsFalse(File.Exists(testFile));
            try
            {
                var reader = new XMLFileSerializerHelper<Query>();
                reader.Read(testFile);
                Assert.Fail("Should not be able to parse XML missing file");
            }
            catch
            {
                // Test Pass
            }
        }
#endif
    }
}
