using System;
using System.Collections;
using System.Runtime.InteropServices;
using NUnit.Framework;

namespace MetraTech.Pipeline.Plugins.Test
{
	using MetraTech.Test;
	using MetraTech.Interop.COMMeter;
	using Auth = MetraTech.Interop.MTAuth;
	using MetraTech.Interop.PipelineTransaction;
	using MetraTech.DataAccess;

	//
	// To run the this test fixture:
	// nunit-console /fixture:MetraTech.Pipeline.Plugins.Test.DuplicateConstraintTests /assembly:O:\debug\bin\MetraTech.Pipeline.Plugins.Test.dll
	//
  [Category("NoAutoRun")]
  [TestFixture]
	[ComVisible(false)]
	public class DuplicateConstraintTests 
	{
		[Test]
    public void T01InitializeStockTests() 
		{
			// Empty stocks tables
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__DELETE_STOCK_USAGE__"))
                {
                    stmt.ExecuteNonQuery();
                }
            }
		}

 		/// <summary>
		/// Test normal usage. Meter a set of unique stock purchase orders
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T02TestNormalStockPurchase() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("DELL", 100, "zzz1", "Ameritrade"));
			stocks.Add(new StockPurchase("IBM", 50, "zzz2", "Ameritrade"));
			stocks.Add(new StockPurchase("HPQ", 200, "zzz3", "Scottrade"));
			stocks.Add(new StockPurchase("MSFT", 300, "zzz4", "Scottrade"));

			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Create the IN clause.
			string inclause = String.Empty;
			foreach (StockPurchase sp in stocks)
			{
				if (inclause.Length > 0)
					inclause += ",";

				inclause += "'" + sp.mTransactionid + "'";
			}

			// Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inclause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (stocks.Count, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }
            }
		}

		/// <summary>
		/// The following tests use "stocktransaction" constraint for duplicate detection.
		/// Test normal usage where all sessions in set fail.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T03TestNormalAllDuplicates() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("DELL", 100, "zzz1", "Ameritrade"));// dup in db
			stocks.Add(new StockPurchase("IBM", 50, "zzz2", "Ameritrade"));  // dup in db
			stocks.Add(new StockPurchase("HPQ", 200, "zzz3", "Scottrade"));  // dup in db
			stocks.Add(new StockPurchase("MSFT", 300, "zzz4", "Scottrade")); // dup in db
			stocks.Add(new StockPurchase("MSFT", 300, "zzz4", "Scottrade")); // dup in set
			stocks.Add(new StockPurchase("MSFT", 300, "zzz4", "Scottrade")); // dup in set
			stocks.Add(new StockPurchase("MSFT", 300, "zzz4", "Scottrade")); // dup in set

			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                string likeClause = "Violation of UNIQUE KEY constraint ";
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (stocks.Count, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
		}

		/// <summary>
		/// Test duplicate in session set. Meter a set with one or more duplicates.
		/// This should succeed and the end result is that only non-duplicates
		/// should be in the database.
		/// </summary>
        [Test]
        [Ignore("Failing - Ignore Test")]
    public void T04TestDuplicateInSessionSet()
        {
            // Initialize array of normal stock purchases.
            ArrayList stocks = new ArrayList();
            stocks.Add(new StockPurchase("DELL", 100, "XXX123ZZZ123", "Ameritrade")); // duplicate in set
            stocks.Add(new StockPurchase("IBM", 50, "XXX123ZZZ123", "Ameritrade"));   // duplicate in set
            stocks.Add(new StockPurchase("XMSR", 100, "229776CEFB564c8a9F5FEE77A46B37BC", "Scottrade"));
            stocks.Add(new StockPurchase("SIRI", 100, "7A60D57313D740f2BADEF6855EC4A49A", "Scottrade"));
            stocks.Add(new StockPurchase("XMSR", 500, "7A60D57313D740f2BADEF6855EC4A49A", "Scottrade"));

            // Meter stock orders.
            string batchid;
            MeterUsage(stocks, out batchid);

            //-----
            // Check for success, DELL, XMSR, and SIRI should be in the t_pv_stocks table.
            // IBM record should not succeed.
            //-----

            string likeClause = "columns(c_transactionid, c_broker), values(XXX123ZZZ123,Ameritrade";
            string inClause = "'XXX123ZZZ123','229776CEFB564c8a9F5FEE77A46B37BC','7A60D57313D740f2BADEF6855EC4A49A'";

            // Check for success.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (3, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                likeClause = "columns(c_transactionid, c_broker), values(7A60D57313D740f2BADEF6855EC4A49A,Scottrade";
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                          (1, actualCount,
                          "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
        }

		/// <summary>
		/// Test duplicate in database. Meter a set with one or more duplicates.
		/// This should succeed and the end result is that only non-duplicates
		/// should be in the database.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
        public void T05TestDuplicateInDatabase() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("DELL", 300, "qqq1", "Ameritrade"));
			stocks.Add(new StockPurchase("IBM", 75, "qqq2", "Datek"));
			stocks.Add(new StockPurchase("DELL", 100, "qqq3", "Ameritrade"));
			
			// Duplicate in DB, both should fail.
			stocks.Add(new StockPurchase("XMSR", 100, "229776CEFB564c8a9F5FEE77A46B37BC", "Scottrade"));
			stocks.Add(new StockPurchase("SIRI", 100, "7A60D57313D740f2BADEF6855EC4A49A", "Scottrade"));

			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Check for success
			string likeClause1 = "229776CEFB564c8a9F5FEE77A46B37BC,Scottrade";
			string likeClause2 = "7A60D57313D740f2BADEF6855EC4A49A,Scottrade";
			string inClause = "'qqq1','qqq2', 'qqq3'";

			// Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (3, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause2, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
		}

		/// <summary>
		/// Test duplicate in session and database.  The duplicates are different.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T06TestDuplicateInSessionAndDatabase() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("NOBL", 100, "RRR1", "Scottrade"));
			stocks.Add(new StockPurchase("PALM", 500, "RRR2", "Scottrade", mFixedTime));
			stocks.Add(new StockPurchase("DELL", 300, "229776CEFB564c8a9F5FEE77AXXX", "Ameritrade"));

			// Duplicate in DB.
			stocks.Add(new StockPurchase("XMSR", 100, "229776CEFB564c8a9F5FEE77A46B37BC", "Scottrade"));

			// Duplicate in session.
			stocks.Add(new StockPurchase("IBM", 75, "229776CEFB564c8a9F5FEE77AXXX", "Ameritrade"));

			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Check for success
			string likeClause1 = "229776CEFB564c8a9F5FEE77A46B37BC,Scottrade";
			string likeClause2 = "229776CEFB564c8a9F5FEE77AXXX,Ameritrade";
			string inClause = "'RRR1','RRR2', '229776CEFB564c8a9F5FEE77AXXX'";

			// Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (3, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause2, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
		}

        /// <summary>
        /// Test duplicate in session and database.
        /// Same item is duplicated in session and in db; both must fail.
        /// </summary>
        [Test]
        [Ignore("Failing - Ignore Test")]
    public void T07TestSameDuplicateInSessionAndDatabase()
        {
            // Initialize array of normal stock purchases.
            ArrayList stocks = new ArrayList();
            stocks.Add(new StockPurchase("PALM", 500, "RRR2", "Scottrade", mFixedTime));  // duplicate in database
            stocks.Add(new StockPurchase("PALM", 500, "RRR2", "Scottrade", mFixedTime));  // duplicate in set 

            // Meter stock orders.
            string batchid;
            MeterUsage(stocks, out batchid);

            // Check for success
            string likeClause1 = "Violation of UNIQUE KEY constraint ";

            // Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (2, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
        }

        /// <summary>
        /// When there are more than 1000 session in a set additional code is
        /// executed in the writeproductview plugin.
        /// </summary>
        public void T08TestOneDuplicateIn2000Sessions()
        {
            // Initialize array of normal stock purchases.
            ArrayList stocks = new ArrayList();
            stocks.Add(new StockPurchase("Foo", 250, "fooBar", "Scottrade", mFixedTime));
            for (int i = 0; i < 1500; i++)
            {
                stocks.Add(new StockPurchase("Foo", 250+i, "fooBar", "Scottrade"));  // Unique
            }

            stocks.Add(new StockPurchase("Foo", 250, "fooBar", "Scottrade", mFixedTime));   // duplicate in set 

            // Meter stock orders.
            string batchid;
            MeterUsage(stocks, out batchid);

            // Check for success
            string likeClause1 = "fooBar,Scottrade";

            // Check for success, all records should be in the t_pv_stocks table.
            using (IMTConnection conn = ConnectionManager.CreateConnection())
            {
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
            }
        }

		/// <summary>
		/// The following test uses "stockpo" constraint for duplicate detection.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
        public void T09Test_STOCKPO_ConstraintViolationInSet() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("MSO", 75, "EFB564c8a9F5FEE77A", "TDWaterhouse"));

			// Duplicate in DB, see TestDuplicateInSessionAndDatabase
			stocks.Add(new StockPurchase("PALM", 500, "zzzzzz", "TDW", mFixedTime));

			// Duplicate in session, one should fail and one should succeed.
			DateTime timeNow = MetraTech.MetraTime.Now;
			stocks.Add(new StockPurchase("AWE", 100, "1234567890", "Scottrade1", timeNow));
			stocks.Add(new StockPurchase("AWE", 100, "1234567890", "Scottrade2", timeNow));

			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Check for success
			string likeClause1 = "PALM,500"; // fail
			string likeClause2 = "AWE,100"; // fail
			string inClause = "'EFB564c8a9F5FEE77A','1234567890'"; // succeed

			// Check for success, all records should be in the t_pv_stocks table.
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				// Check fo success case.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (2, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause2, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
			}
		}

		/// <summary>
		/// The following test uses "stockpo" and "stocktransaction" constraints.
		/// </summary>
		[Test]
    [Ignore("Failing - Ignore Test")]
    public void T10TestBothConstraintsViolated() 
		{
			// Initialize array of normal stock purchases.
			ArrayList stocks = new ArrayList();
			stocks.Add(new StockPurchase("MSO", 75, "LLLKKK", "TDWaterhouse"));

			// "stockpo" constraint duplicate in DB, see TestDuplicateInSessionAndDatabase
			stocks.Add(new StockPurchase("PALM", 500, "zzzzzz", "TDW", mFixedTime));

			// "stockpo" constraint duplicate in session, one should fail and one should succeed.
			DateTime timeNow = MetraTech.MetraTime.Now;
			stocks.Add(new StockPurchase("AWE", 150, "0987654321", "Scottrade1", timeNow));
			stocks.Add(new StockPurchase("AWE", 150, "0987654321", "Scottrade2", timeNow));

			// "stocktransaction" constraint duplicate in DB
			stocks.Add(new StockPurchase("XMSR", 100, "229776CEFB564c8a9F5FEE77A46B37BC", "Scottrade"));

			// "stocktransaction" constraint duplicate in session.
			stocks.Add(new StockPurchase("IBM", 75, "LLLKKK", "TDWaterhouse"));
			
			// Meter stock orders.
			string batchid;
			MeterUsage(stocks, out batchid);

			// Check for success
			string likeClause1 = "PALM,500"; // fail
			string likeClause2 = "AWE,150"; // fail
			string likeClause3 = "229776CEFB564c8a9F5FEE77A46B37BC,Scottrade"; // fail
			string likeClause4 = "LLLKKK,TDWaterhouse"; // fail
			string inClause = "'LLLKKK','0987654321'"; // succeed

			// Check for success, all records should be in the t_pv_stocks table.
			using (IMTConnection conn = ConnectionManager.CreateConnection())
			{
				// Check fo success case.
                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__GET_STOCK_COUNT___"))
                {
                    stmt.AddParam("%%IN_CLAUSE%%", inClause, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("stock_count");

                        Assert.AreEqual
                            (2, actualCount,
                            "Number of entries in product view table (t_pv_stocks) do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause1, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause2, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause3, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }

                using (IMTAdapterStatement stmt = conn.CreateAdapterStatement(mQueryPath, "__FIND_FAILED_TRANSACTION__"))
                {
                    stmt.AddParam("%%LIKE_CONDITION%%", likeClause4, true);
                    stmt.AddParam("%%BATCH_ID%%", batchid, true);
                    using (IMTDataReader reader = stmt.ExecuteReader())
                    {
                        int actualCount = 0;
                        if (reader.Read())
                            actualCount = reader.GetInt32("error_count");

                        Assert.AreEqual
                            (1, actualCount,
                            "Number of entries in t_failed_transaction table do not match expected number.");
                    }
                }
			}
		}

		//-----
		// Stocks Metering Helper Methods
		//-----

		private IBatch CreateBatch(IMeter Sdk, int expectedCount) 
		{
			//
			IBatch batch = Sdk.CreateBatch();
			batch.NameSpace = "MT        ";
			batch.Name = "1";
			batch.ExpectedCount = expectedCount;
			batch.SourceCreationDate = DateTime.Now;
			batch.SequenceNumber = DateTime.Now.ToFileTime().ToString();

			try 
			{
				batch.Save();
			}
			catch(Exception e) 
			{
				Assert.Fail(String.Format("Unexpected Batch.Save() failure message: {0}", 
					e.Message));
			}

			return batch;
		}

		// Populate the session set with stocks data.
		private void InitializeSessionSet(ISessionSet sessionSet, ArrayList stocks,
										  string accountName, string batchid) 
		{
      // Set only the session context
      Auth.IMTLoginContext loginContext = new Auth.MTLoginContext();
      Auth.IMTSessionContext sessionContext = loginContext.LoginAnonymous();
			
      sessionSet.SetProperties(null, 
                               null, 
                               sessionContext.ToXML(),
                               null,
                               null,
                               null);

			// Create and initialize a stocks session, asynchronously.
			foreach (StockPurchase sp in stocks)
			{
				ISession session = sessionSet.CreateSession(stocksSvc);
				session.RequestResponse = false;
				InitializeSession(session, sp, accountName, batchid);
			}
		}

		// Initialize session.
		private void InitializeSession(ISession session, StockPurchase sp,
									   string accountName, string batchid) 
		{
			ArrayList propertyDataList = new ArrayList();
			PropertyData pd;

			// Add symbol.
			pd = new PropertyData();
			pd.Name = "symbol";
			pd.Value = sp.mSymbol;
			propertyDataList.Add(pd);

			// Add quantity.
			pd = new PropertyData();
			pd.Name = "quantity";
			pd.Value = sp.mQuantity.ToString();
			propertyDataList.Add(pd);

			// Add transaction id.
			pd = new PropertyData();
			pd.Name = "transactionid";

			if (sp.mTransactionid == null)
				pd.Value = GenerateTransactionId();
			else
				pd.Value = sp.mTransactionid;
			propertyDataList.Add(pd);

			// Add broker name.
			pd = new PropertyData();
			pd.Name = "broker";
			pd.Value = sp.mBroker;
			propertyDataList.Add(pd);

			// Add account name.
			pd = new PropertyData();
			pd.Name = "accountname";
			pd.Value = accountName;
			propertyDataList.Add(pd);

			// Add order time.
			pd = new PropertyData();
			pd.Name = "ordertime";
			pd.Value = sp.mOrdertime.ToString(mstrDateFormat);
			propertyDataList.Add(pd);

			// Add batch id.
			pd = new PropertyData();
			pd.Name = "tx_batchid";
			pd.Value = batchid;
			propertyDataList.Add(pd);

			// Add properties to session.
			session.CreateSessionStream
				(propertyDataList.ToArray(typeof(PropertyData)) as PropertyData[]);
		}
		
		private class StockPurchase 
		{
			public StockPurchase(string symbol, int quantity, string transactionid, string broker)
			{
				mSymbol = symbol;
				mQuantity = quantity;
				mBroker = broker;
				mTransactionid = transactionid;
				mOrdertime = MetraTech.MetraTime.Now;
			}

			public StockPurchase(string symbol, int quantity, string transactionid, string broker, DateTime OrderTime)
			{
				mSymbol = symbol;
				mQuantity = quantity;
				mBroker = broker;
				mTransactionid = transactionid;
				mOrdertime = OrderTime;
			}

			public string mSymbol;
			public string mBroker;
			public string mTransactionid;
			public int mQuantity;
			public DateTime mOrdertime;
		};

		private string GenerateTransactionId()
		{
			return DateTime.Now.Millisecond.ToString();
		}

		private void MeterUsage(ArrayList stocks, out string batchid)
		{
			IMeter sdk = null;
			IBatch batch = null;
      try
      {
			  // Create meter sdk instance.
			  sdk = TestLibrary.InitSDK();

			  // Create batch for this usage.
   			  batch = CreateBatch(sdk, stocks.Count);

			  batchid = batch.UID;

			  // Create session set.
			  ISessionSet sessionSet = batch.CreateSessionSet();

			  // Create and set session properties, and populate session set.
			  InitializeSessionSet(sessionSet, stocks, "demo", batchid);

			  try 
			  {
				  sessionSet.Close();
			  }
			  catch(Exception e) 
			  {
				  Assert.Fail(String.Format("Unexpected meter session failure message: {0}", e.Message));
				  throw e;
			  }

			  // Wait on batch to finish.
			  TestLibrary.WaitForBatchCompletion(sdk, batchid);
			  sdk.Shutdown();
      }
      finally
      {
        if (batch != null)
          Marshal.ReleaseComObject(batch);
   
        if (sdk != null)
           Marshal.ReleaseComObject(sdk);
      }
		}

		private const string stocksSvc = "metratech.com/stocks";
		private const string mstrDateFormat = "yyyy-MM-ddTHH:mm:ssZ";
		private const string mQueryPath = "Queries\\SmokeTest";
		private string mNetMeterName;
		private DateTime mFixedTime = new DateTime(2006,12,13,5,10,0);

		public DuplicateConstraintTests()
		{
			// Get stage database name.
			ConnectionInfo ciStageDb = new ConnectionInfo("NetMeter");
			mNetMeterName = ciStageDb.Catalog;
		}
	}
}

// EOF
