using NUnit.Framework;
using System;

namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    
    
    /// <summary>
    ///This is a test class for QueryConversionAuditUnitTests and is intended
    ///to contain all QueryConversionAuditUnitTests Unit Tests
    ///</summary>
    [TestFixture]
    public class QueryConversionAuditUnitTests
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
        ///A test for QueryConversionAudit Constructor
        ///</summary>
        [Test]
        public void QueryConversionAuditConstructorTest()
        {
            QueryConversionAudit target = new QueryConversionAudit();
            Assert.Inconclusive("TODO: Implement code to verify target");
        }

        /// <summary>
        ///A test for CommonQuerySourceFile
        ///</summary>
        [Test]
        public void CommonQuerySourceFileTest()
        {
            QueryConversionAudit target = new QueryConversionAudit(); // TODO: Initialize to an appropriate value
            object expected = null; // TODO: Initialize to an appropriate value
            object actual;
            target.CommonQuerySourceFile = expected;
            actual = target.CommonQuerySourceFile;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for ConversionDuplicateName
        ///</summary>
        [Test]
        public void ConversionDuplicateNameTest()
        {
            QueryConversionAudit target = new QueryConversionAudit(); // TODO: Initialize to an appropriate value
            object expected = null; // TODO: Initialize to an appropriate value
            object actual;
            target.ConversionDuplicateName = expected;
            actual = target.ConversionDuplicateName;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for OracleQuerySourceFile
        ///</summary>
        [Test]
        public void OracleQuerySourceFileTest()
        {
            QueryConversionAudit target = new QueryConversionAudit(); // TODO: Initialize to an appropriate value
            object expected = null; // TODO: Initialize to an appropriate value
            object actual;
            target.OracleQuerySourceFile = expected;
            actual = target.OracleQuerySourceFile;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }

        /// <summary>
        ///A test for SqlServerQuerySourceFile
        ///</summary>
        [Test]
        public void SqlServerQuerySourceFileTest()
        {
            QueryConversionAudit target = new QueryConversionAudit(); // TODO: Initialize to an appropriate value
            object expected = null; // TODO: Initialize to an appropriate value
            object actual;
            target.SqlServerQuerySourceFile = expected;
            actual = target.SqlServerQuerySourceFile;
            Assert.AreEqual(expected, actual);
            Assert.Inconclusive("Verify the correctness of this test method.");
        }
    }
}
