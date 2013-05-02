#region

using System;
using MetraTech.DataAccess;
using MetraTech.Tax.UnitTests.General;

#endregion

namespace MetraTech.Tax.UnitTests
{
    public class DatabaseHelper
    {
        private static bool IsOracle()
        {
            string oracleString = Environment.GetEnvironmentVariable("TESTORACLE");
            if (oracleString != null && oracleString.Equals("1"))
            {
                return true;
            }
            return false;
        }

        /// <summary>
        /// Drops the table if it exists
        /// </summary>
        /// <param name="tablename"></param>
        public static void DropTable(string tablename)
        {
            string queryTemplate;

            using (var conn = ConnectionManager.CreateConnection())
            {
                if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
                    queryTemplate = @"IF EXISTS (SELECT 1 FROM dbo.sysobjects WHERE id = object_id(N'{0}'))
                                             drop table {0}";
                else // Oracle
                    queryTemplate = @"begin " +
                                             "if table_exists('{0}') then " +
                                             "execute immediate 'drop table {0}'; " +
                                             "end if; end;";
                string query = String.Format(queryTemplate, tablename);
                using (var stmt = conn.CreateAdapterStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// Removes all rows from the specified table
        /// </summary>
        /// <param name="tablename">name of the table to update</param>
        public static void RemoveAllRowsFromTable(string tablename)
        {
            string QueryStatement = String.Format("DELETE FROM {0}", tablename);
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateAdapterStatement(QueryStatement))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public static void CreateInputTable(int runId)
        {
            string queryTemplate;

            using (var conn = ConnectionManager.CreateConnection())
            {
                if (conn.ConnectionInfo.DatabaseType == DBType.SQLServer)
                    queryTemplate =
                @"create table t_tax_input_{0}
                                                (
	                                                id_tax_charge int,
	                                                invoice_id	varchar(255),
	                                                amount	decimal,
	                                                orig_pcode	int,
	                                                term_pcode	int,
	                                                svc_addr_pcode	int,
	                                                customer_type	varchar(255),
	                                                invoice_date	date,
	                                                is_implied_tax	varchar(255),
	                                                round_alg	varchar(255),
	                                                round_digits int,
	                                                lines	int,
	                                                location	int, 
	                                                product_code	varchar(255),
	                                                client_resale	varchar(255),
	                                                inc_code	varchar(255),
	                                                id_acc	int, 
	                                                is_regulated	varchar(255),
	                                                call_duration	decimal,
	                                                telecom_type	varchar(255),
	                                                svc_class_ind	varchar(255),
	                                                lifeline_flag	varchar(255),
	                                                facilities_flag	varchar(255),
	                                                franchise_flag	varchar(255),
	                                                bus_class_ind	varchar(255)
                                                )";
                else
                {
                    queryTemplate =
                @"create table t_tax_input_{0}
                                                (
	                                                id_tax_charge number(10,0),
	                                                invoice_id	varchar(255),
	                                                amount	decimal(22, 10),
	                                                orig_pcode	number(10,0),
	                                                term_pcode	number(10,0),
	                                                svc_addr_pcode	number(10,0),
	                                                customer_type	varchar(255),
	                                                invoice_date	date,
	                                                is_implied_tax	varchar(255),
	                                                round_alg	varchar(255),
	                                                round_digits number(10,0),
	                                                lines	number(10,0),
	                                                location	number(10,0), 
	                                                product_code	varchar(255),
	                                                client_resale	varchar(255),
	                                                inc_code	varchar(255),
	                                                id_acc	number(10,0), 
	                                                is_regulated	varchar(255),
	                                                call_duration	decimal(22, 10),
	                                                telecom_type	varchar(255),
	                                                svc_class_ind	varchar(255),
	                                                lifeline_flag	varchar(255),
	                                                facilities_flag	varchar(255),
	                                                franchise_flag	varchar(255),
	                                                bus_class_ind	varchar(255)
                                                )";
                }
                string query = String.Format(queryTemplate, runId);
                using (var stmt = conn.CreateAdapterStatement(query))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }

        public static bool AreOutputTablesTheSame(string tableOne, string tableTwo)
        {
            string queryFormat =
            @"SELECT * FROM {0} t1 
		      LEFT OUTER JOIN {1} t2 
			          ON t1.id_tax_charge = t2.id_tax_charge 
          WHERE 
		          t1.tax_fed_amount <> t2.tax_fed_amount OR
		          t1.tax_state_amount <> t2.tax_state_amount OR
		          t1.tax_county_amount <> t2.tax_county_amount OR
		          t1.tax_local_amount <> t2.tax_local_amount OR
		          t1.tax_other_amount <> t2.tax_other_amount";
            string QueryStatement = String.Format(queryFormat, tableOne, tableTwo);
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateAdapterStatement(QueryStatement))
                {
                    var reader = stmt.ExecuteReader();
                    if (reader.Read())
                        return false;
                    return true;
                }
            }
        }

        /// <summary>
        /// Bulk inserts the data specified in the data path + file into the table
        /// </summary>
        /// <param name="tbl"></param>
        /// <param name="path"></param>
        /// <param name="file"></param>
        public static void BulkLoadData(string tbl, string path, string file)
        {
            try
            {
                if (IsOracle())
                    SqlWizard.executeSqlInFile(path + file + ".oracle.sql"); //"exemptionTestData.oracle.sql");
                else
                    BulkLoadData(tbl, path + file);
            }
            catch (Exception e)
            {
                Console.WriteLine("Attempting to load data for table: " + tbl +
                                  " using file " + path + file +
                                  " Exception: " + e.Message + " Inner message: " + e.InnerException +
                                  " Stack: " + e.StackTrace);
                throw e;
            }
        }

        public static void LoadDataFromSql(string path, string file)
        {
            try
            {
                if (IsOracle())
                    SqlWizard.executeSqlInFile(path + file + ".oracle.sql"); 
                else
                    SqlWizard.executeSqlInFile(path + file + ".sql");
            }
            catch (Exception e)
            {
                Console.WriteLine("Attempting to load data for " +
                                  " using file " + path + file +
                                  " Exception: " + e.Message + " Inner message: " + e.InnerException +
                                  " Stack: " + e.StackTrace);
                throw e;
            }
        }

        /// <summary>
        /// Bulk inserts the data specified in the data path + file into the table
        /// </summary>
        /// <param name="tbl"></param>
        /// <param name="path"></param>
        /// <param name="file"></param>
        public static void BulkLoadData(string tbl, string fullpath)
        {
            string mImportDataFormatString =
              @"BULK INSERT {0} FROM '{1}'
                                                WITH (
                                                    KEEPIDENTITY,
	                                                FIELDTERMINATOR =',', 
	                                                ROWTERMINATOR = '\n'
                                                )";
            string QueryStatement = String.Format(mImportDataFormatString, tbl, fullpath);
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateAdapterStatement(QueryStatement))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }

        public static void LoadProductCodeMappingsForTest()
        {
            DropTable("t_tax_billsoft_pc_map");
            CreateTable("__CREATE_T_TAX_BILLSOFT_PC_MAP__");
            BulkLoadData("t_tax_billsoft_pc_map", @"U:\MetraTech\Tax\BillSoft\data\", "BillSoftTestProductCodemap.csv");
        }

        public static void CreateTable(string tagname)
        {
            using (var conn = ConnectionManager.CreateConnection())
            {
                using (var stmt = conn.CreateAdapterStatement(@"Queries\DBInstall\Tax", tagname))
                {
                    stmt.ExecuteNonQuery();
                }
            }
        }

        /// <summary>
        /// 
        /// </summary>
        public static void RunQuery(string path, string tag)
        {
            using (var conn = ConnectionManager.CreateConnection())
            using (var stmt = conn.CreateAdapterStatement(path, tag))
            {
                stmt.ExecuteNonQuery();
            }
        }
#if false
    /// <summary>
    /// 
    /// </summary>
    public static void SumTables(string path, string tag)
    {
      string query = String.Format(
// Fast but may have accuracy problems
@"DECLARE @TaxSumTbl TABLE ({0} decimal, RunningTotal decimal)
DECLARE @RunningTotal decimal
SET @RunningTotal = 0.0
 
INSERT INTO @TaxSumTbl SELECT {0}, null
FROM {1}
 
UPDATE @TaxSumTbl
	SET @RunningTotal = RunningTotal = @RunningTotal + {0} 
		FROM @TaxSumTbl

SELECT * FROM @TaxSumTbl");
      using (var conn = ConnectionManager.CreateConnection())
      using (var stmt = conn.CreateStatement(query))
      {
        stmt.ExecuteNonQuery();
  }
    }
#endif
    }
}