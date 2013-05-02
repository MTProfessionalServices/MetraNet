
using System;
using MetraTech.Interop.QueryAdapter;
using MetraTech.Interop.Rowset;
using Microsoft.VisualStudio.TestTools.UnitTesting;

// nunit-console /fixture:MetraTech.DataAccess.QueryManagement.UnitTests.QueryCacheUnitTests /assembly:o:\debug\bin\MetraTech.DataAccess.QueryManagement.UnitTests.dll

// TODO: Test V2, Make sure it is enabled (Can we use a mock Config Here?)
// TODO: Test V2 SQL
// TODO: Test V2 Oracle
// TODO: Test V1
// TODO: Test V1 SQL
// TODO: Test V1 Oracle
namespace MetraTech.DataAccess.QueryManagement.UnitTests
{
    [TestClass]
    public class QueryCacheUnitTests
    {
        private static MetraTech.Interop.QueryAdapter.IMTQueryCache mQueryCache;
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            mQueryCache = new MetraTech.Interop.QueryAdapter.MTQueryCacheClass();
        }
        [ClassCleanup]
        public static void TearDown()
        {
            mQueryCache = null;
        }
        #region Version 2 Init Tests
        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_BadPath()
        {
            mQueryCache.Init(@"some\junk");
        }
        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_DoubleInit()
        {
            mQueryCache.Init(@"some\junk");
            mQueryCache.Init(@"some\junk");
        }
        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_OldPath()
        {
            mQueryCache.Init(@"Queries\Tax\BillSoft");
        }
        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_EmptyPath()
        {
            mQueryCache.Init(@"");
        }
        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_NULLPath()
        {
            mQueryCache.Init(null);
        }

        [TestMethod()]
        public void Test_QueryCache_Init_Mode_V2_GoodPath()
        {
            mQueryCache.Init(@"Database");
        }
        #endregion // Version 2 Init Tests

        #region Version 2 Get Query Tests
        [TestMethod()]
        public void Test_QueryCache_GetQueryString_Mode_V2_DML_ProductCatalog_GoodTag()
        {
            mQueryCache.Init(@"");
            var query = mQueryCache.GetQueryString(@"Queries\ProjectCatalog", "__ADD_CHARGE__");
        }
        [TestMethod()]
        public void Test_QueryCache_Init_QueryAdapter()
        {
            mQueryCache.Init(@"queries\meterrowset");
            var to = mQueryCache.GetTimeout(@"queries\meterrowset");
            Assert.AreEqual(300, to);
            var ln = mQueryCache.GetLogicalServerName(@"queries\meterrowset");
            Assert.AreEqual(ln, "NetMeter");
        }
        [TestMethod()]
        public void Test_QueryCache_GetQueryString_Mode_V2_DML_ProductCatalog_GoodTag_BadPath()
        {
            mQueryCache.Init(@"");
            var query = mQueryCache.GetQueryString(@"", "__ADD_CHARGE__");
        }
        [TestMethod()]
        public void Test_QueryCache_GetQueryString_Mode_V2_DML_ProductCatalog_EmptyTag()
        {
            mQueryCache.Init(@"");
            try
            {
                var query = mQueryCache.GetQueryString(@"Queries\ProjectCatalog", "");
                Assert.Fail("Should fail");
            }
            catch (Exception)
            {
            }
        }
        [TestMethod()]
        public void Test_QueryCache_GetQueryString_Mode_V2_DML_ProductCatalog_NullTag()
        {
            mQueryCache.Init(@"");
            try
            {
                var query = mQueryCache.GetQueryString(@"Queries\ProjectCatalog", null);
                Assert.Fail("Should fail");
            }
            catch (Exception)
            {
            }
        }
        [TestMethod()]
        public void Test_QueryCache_GetQueryString_Mode_V2_DML_ProductCatalog_NoInitCache()
        {
            var uninitializedCache = new MetraTech.Interop.QueryAdapter.MTQueryCacheClass();
            try
            {
                var query = uninitializedCache.GetQueryString(@"Queries\ProjectCatalog", "__ADD_CHARGE__");
                Assert.Fail("Should fail");
            }
            catch (Exception)
            {
            }
        }
        #endregion // Version 2 Get Query Tests

        #region Version 2 Get DBAccess Info
        #region GetDataSource
        [TestMethod()]
        public void Test_QueryCache_GetDataSource_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetDataSource(@"Queries\ProductCatalog");
        }
        #endregion
        #region GetTimeout
        [TestMethod()]
        public void Test_QueryCache_GetTimeout_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetTimeout(@"Queries\ProductCatalog");
        }
        #endregion
        #region GetAccessType
        [TestMethod()]
        public void Test_QueryCache_GetAccessType_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetAccessType(@"Queries\ProductCatalog");
            //Assert.IsNotNullOrEmpty(src);
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetDBType
        [TestMethod()]
        public void Test_QueryCache_GetDBType_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetDBType(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetProvider
        [TestMethod()]
        public void Test_QueryCache_GetProvider_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetProvider(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetServerName
        [TestMethod()]
        public void Test_QueryCache_GetServerName_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetServerName(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetDBName
        [TestMethod()]
        public void Test_QueryCache_GetDBName_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetDBName(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetPassword
        [TestMethod()]
        public void Test_QueryCache_GetPassword_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetPassword(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetUserName
        [TestMethod()]
        public void Test_QueryCache_GetUserName_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetUserName(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetDBDriver
        [TestMethod()]
        public void Test_QueryCache_GetDBDriver_Mode_V2_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetDBDriver(@"Queries\ProductCatalog");
			Assert.IsFalse(string.IsNullOrEmpty(src));
        }
        #endregion
        #region GetHinter
        [TestMethod()]
        public void Test_QueryCache_GetHinter_Mode_V2_DataAccess_Simple()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetHinter(@"Queries\ProductCatalog", "__ADD_CHARGE__");
        }
        [TestMethod()]
        public void Test_QueryCache_GetHinter_Mode_V2_NullPath()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetHinter(null, "__ADD_CHARGE__");
        }
        [TestMethod()]
        public void Test_QueryCache_GetHinter_Mode_V2_EmptyPath()
        {
            mQueryCache.Init(@"");
            var src = mQueryCache.GetHinter(@"", "__ADD_CHARGE__");
        }
        [TestMethod()]
        public void Test_QueryCache_GetHinter_Mode_V2_NullTag()
        {
            mQueryCache.Init(@"");
            try
            {
                var src = mQueryCache.GetHinter(@"Queries\ProductCatalog", null);
                Assert.Fail("Should not get here");
            }
            catch (Exception)
            {
            }
        }
        [TestMethod()]
        public void Test_QueryCache_GetHinter_Mode_V2_EmptyTag()
        {
            mQueryCache.Init(@"");
            try
            {
                var src = mQueryCache.GetHinter(@"Queries\ProductCatalog", "");
                Assert.Fail("Should not get here");
            }
            catch (Exception)
            {
            }
        }
        #endregion
        #endregion // Version 2  Get DBAccess Info
    }
}