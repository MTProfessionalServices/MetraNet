using System;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
using MetraTech.DomainModel.Enums;
using MetraTech.Tax.Framework;
using MetraTech.Tax.Framework.DataAccess;
using MetraTech.Tax.MetraTax.Test;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.UsageServer;
using MetraTech.DataAccess;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Data.SqlClient;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.DomainModel.Enums.Tax.Metratech_com_tax;


namespace MetraTech.Tax.Taxware.Test
{
    //
    // To run the this test fixture:
    // ncover //x ncoverOutput.xml
    // nunit-console /fixture:MetraTech.Tax.Taxware.Test.TaxwareTests /assembly:O:\debug\bin\MetraTech.Tax.Taxware.Test.dll
    //
    // To produce a Taxware price list, use a command like this:
    //     pcimportexport -epl "TaxwareDefault" -file "c:\temp\junk.xml" -username admin -password Admin123

    [TestClass]
    //[ComVisible(false)]
    public class TaxwareTests
    {

        const string TEST_DIR = "t:\\Development\\Core\\Tax\\Taxware\\";

        const string SELECT_FROM_T_TAX_OUTPUT = "select tax_fed_amount, tax_fed_name, tax_fed_rounded, tax_state_amount, tax_state_name, tax_state_rounded, tax_county_amount, tax_county_name, tax_county_rounded, tax_local_amount, tax_local_name, tax_local_rounded, tax_other_amount, tax_other_rounded from t_tax_output_{0} order by id_tax_charge";

        private bool m_isSqlServer = true;

        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            Console.WriteLine("Perform setup tasks");
        	MetraTech.Tax.Taxware.Test.TaxwareTests t = new TaxwareTests();
            t.DetermineIfOracle();
        }

        private long m_counter = 99999999999;    // MAXINT32 + 10
        //private long m_counter = 1001;
        public long GetUniqueIdTaxCharge()
        {
            return m_counter++;
        }

        private string GetInvoiceDate()
        {
            if (m_isSqlServer)
            {
                DateTime invoiceDate = new DateTime(2012, 3, 15, 8, 0, 0);
                return string.Format("'{0}'", invoiceDate.ToString());
            }
            else
            {
                return "TO_TIMESTAMP('2012-03-15 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
            }
        }

        private void DetermineIfOracle()
        {
            string oracleString = Environment.GetEnvironmentVariable("TESTORACLE");
            if (oracleString != null && oracleString.Equals("1"))
            {
                Console.WriteLine("Running Oracle based tests.");
                m_isSqlServer = false;
            }
        }

#if true
        /// <summary>
        /// Perform a single valid TWE transaction
        /// </summary>
        [TestMethod]
        public void TestSingleTransactionSuccess()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +        // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'false', 'none'," +                     // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesSingleTransaction.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge,id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesSingleTransaction.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }
#endif

#if true
        /// <summary>
        /// Insert two rows to t_tax_input_*, calculate taxes, no rounding
        /// </summary>
        [TestMethod]
        public void TestCalculateTaxesNoRounding()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesNoRounding.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge,id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesNoRounding.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Insert two rows to t_tax_input_*, calculate implied taxes, no rounding
        /// </summary>
        [TestMethod]
        public void TestCalculateImpliedTaxesNoRounding()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255) ," +
                "[los_city] [varchar](255) ," +
                "[los_state_province] [varchar](255) ," +
                "[los_postal_code] [varchar](16) ," +
                "[los_country] [varchar](255) ," +
                "[los_location_code] [varchar](255) ," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255) ," +
                "[bill_to_city] [varchar](255) ," +
                "[bill_to_state_province] [varchar](255) ," +
                "[bill_to_postal_code] [varchar](16) ," +
                "[bill_to_country] [varchar](255) ," +
                "[bill_to_location_code] [varchar](255) ," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255) ," +
                "[ship_to_city] [varchar](255) ," +
                "[ship_to_state_province] [varchar](255) ," +
                "[ship_to_postal_code] [varchar](16) ," +
                "[ship_to_country] [varchar](255) ," +
                "[ship_to_location_code] [varchar](255) ," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'TRUE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'TRUE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateImpliedTaxesNoRounding.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge,id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateImpliedTaxesNoRounding.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Insert two rows to t_tax_input_444, calculate taxes, round=bank, round_digits=1
        /// </summary>
        [TestMethod]
        public void TestCalculateTaxesWithRounding()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'BANK'," +                           // currency, is_implied_tax, round_alg
                "1)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'BANK'," +                           // currency, is_implied_tax, round_alg
                "1)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesWithRounding.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesWithRounding.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }
        /// <summary>
        /// Reverse tax transactions after the audit is committed
        /// </summary>
        [TestMethod]
        public void TestReverseTransactionAfterCommitted()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            taxManager.ReverseTaxRun();

            try
            {
                string sqlStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
                string saw = SqlWizard.getSelectAsXml(sqlStatement);
                throw new TaxException(String.Format("t_tax_output_{0} should not exist after ReverseTaxRun", taxManager.TaxRunId));
            }
            catch (Exception e)
            {
                Console.WriteLine("Ignoring {0}", e.Message);
                // We expect an SqlException because that table shouldn't exist
            }

            Console.WriteLine("...Done.");
        }
#endif

#if false
        /// <summary>
        /// Reverse tax transactions after the audit is committed
        /// </summary>
        [TestMethod]
        public void TestReverseTransactionAfterCommittedOracle()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE t_tax_input_{0}(" +
                "id_tax_charge NUMBER(20) NOT NULL," +
                "id_acc NUMBER(10,0) NOT NULL," +
                "amount NUMBER(22, 10) NOT NULL," +
                "invoice_date DATE NOT NULL," +
                "product_code nvarchar2(255) NOT NULL," +
                "customer_name nvarchar2(255) NOT NULL," +
                "customer_code nvarchar2(255) NOT NULL," +
                "los_address nvarchar2(255) ," +
                "los_city nvarchar2(255) ," +
                "los_state_province nvarchar2(255) ," +
                "los_postal_code nvarchar2(16) ," +
                "los_country nvarchar2(255) ," +
                "los_location_code nvarchar2(255) ," +
                "los_geo_code NUMBER(10,0) ," +
                "bill_to_address nvarchar2(255) ," +
                "bill_to_city nvarchar2(255) ," +
                "bill_to_state_province nvarchar2(255) ," +
                "bill_to_postal_code nvarchar2(16) ," +
                "bill_to_country nvarchar2(255) ," +
                "bill_to_location_code nvarchar2(255) ," +
                "bill_to_geo_code NUMBER(10,0) ," +
                "ship_to_address nvarchar2(255) ," +
                "ship_to_city nvarchar2(255) ," +
                "ship_to_state_province nvarchar2(255) ," +
                "ship_to_postal_code nvarchar2(16) ," +
                "ship_to_country nvarchar2(255) ," +
                "ship_to_location_code nvarchar2(255) ," +
                "ship_to_geo_code NUMBER(10,0) ," +
                "good_or_service_code nvarchar2(255) ," +
                "sku nvarchar2(255) ," +
                "currency nvarchar2(16) NOT NULL," +
                "is_implied_tax nvarchar2(16) NOT NULL," +
                "round_alg nvarchar2(255) ," +
                "round_digits NUMBER(10,0) " +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "GETUTCDATE(), 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "GETUTCDATE(), 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            taxManager.ReverseTaxRun();

            try
            {
                string sqlStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
                string saw = SqlWizard.getSelectAsXml(sqlStatement);
                throw new TaxException(String.Format("t_tax_output_{0} should not exist after ReverseTaxRun", taxManager.TaxRunId));
            }
            catch (Exception e)
            {
                Console.WriteLine(" Ignoring {0}", e.Message);
                // We expect an SqlException because that table shouldn't exist
            }
            Console.WriteLine("...Done.");
        }
#endif

#if true
        /// <summary>
        /// input row missing address info
        /// </summary>
        [TestMethod]
        public void TestCalculateTaxesMissingAddresses()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 0, ''," +                                  // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2040181', '60400003100'," +                // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesMissingAddresses.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesMissingAddresses.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// 10 successful transactions
        /// </summary>
        [TestMethod]
        public void TestTenTransactions()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            for (int i = 0; i < 10; i++)
            {
                string insertStatement = String.Format(
                    "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                    "(id_tax_charge, id_acc, amount, " +
                    "invoice_date, product_code, customer_name," +
                    "customer_code, los_address, los_city," +
                    "los_state_province, los_postal_code, los_country," +
                    "los_location_code, los_geo_code, bill_to_address, " +
                    "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                    "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                    "ship_to_address, ship_to_city, ship_to_state_province, " +
                    "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                    "ship_to_geo_code, good_or_service_code, sku, " +
                    "currency, is_implied_tax, round_alg," +
                    "round_digits)" +
                    "VALUES" +
                    "({1}, 20202, {2}, " +                          // id_tax_charge, id_acc, amount
                    "{3}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                    "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                    "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                    "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                    "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                    "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                    "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                    "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                    "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                    "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                    "0)",                                           // round_digits
                    taxManager.TaxRunId, GetUniqueIdTaxCharge(), (i + 1) * 100.00, GetInvoiceDate());
                SqlWizard.execute(insertStatement, m_isSqlServer);
            }

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testTenTransactions.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testTenTransactions.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Adjustment after audit committed
        /// </summary>
        [TestMethod]
        public void TestTaxAdjustment()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 1000.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Now adjust the prior two tax amounts
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            createTableStatement = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTableStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, -50.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, -100.00, " +                      // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Staples, Inc.'," +           // invoice_date, product_code, customer_name
                "'Staples00001', '', ''," +                     // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 4180, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 4180," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "4180, '2040182', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testTaxAdjustment.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testTaxAdjustment.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Attempt to calculate taxes in euros
        /// </summary>
        [TestMethod]
        public void TestSingleTransactionFrance()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 11016, ''," +                              // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 11016," +                              // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "11016, '2038584', 'XXXYYYZZZZ'," +             // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testSingleTransactionFrance.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge,id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testSingleTransactionFrance.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Attempt transactions with duplicate IDs
        /// </summary>
        [TestMethod]
        public void TestDuplicateTransactionIds()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);

            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 11016, ''," +                              // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 11016," +                              // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "11016, '2038584', 'XXXYYYZZZZ'," +             // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, 77778888, GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 11016, ''," +                              // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 11016," +                              // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "11016, '2038584', 'XXXYYYZZZZ'," +             // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, 77778888, GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            try
            {
                taxManager.CalculateTaxes();
                Assert.Fail("Expected exception to be thrown because of duplicate transaction ids");
            }
            catch (Exception)
            {
                // We expect an Exception because the transactions ids are duplicates
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Perform a single valid TWE transaction without GEOCODE
        /// </summary>
        [TestMethod]
        public void TestSingleTransactionNoGeoCode()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'CT', '06033', 'UNITED STATES', " +            // los_state_province, los_postal_code, los_country
                "'', 0, ''," +                                  // los_location_code, los_geo_code, bill_to_address
                "'', 'CT', '06033'," +                          // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'UNITED STATES', '', 0," +                     // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'CT'," +                               // ship_to_address, ship_to_city, ship_to_state_province
                "'06033', 'UNITED STATES', ''," +               // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2040181', '60400003100'," +                // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," + // customer_code, los_address, los_city
                "'NY', '10110', 'UNITED STATES', " +            // los_state_province, los_postal_code, los_country
                "'', 0, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', 'NY', '10110'," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'UNITED STATES', '', 0," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'NY'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'10110', 'UNITED STATES', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testNoGeoCode.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by tax_amount", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testNoGeoCode.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

#endif

#if true
        /// <summary>
        /// Perform two identical transactions with different dates
        /// </summary>
        [TestMethod]
        public void TestDateChange()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);

            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            DateTime invoiceDate1 = new DateTime(2010, 4, 1, 8, 0, 0);
            DateTime invoiceDate2 = new DateTime(2012, 4, 1, 8, 0, 0);
            string invoiceDate1String = "'" + invoiceDate1.ToString() + "'";
            string invoiceDate2String = "'" + invoiceDate2.ToString() + "'";
            if (!m_isSqlServer)
            {
                invoiceDate1String = "TO_TIMESTAMP('2010-04-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
                invoiceDate2String = "TO_TIMESTAMP('2012-04-01 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
            }

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," + // customer_code, los_address, los_city
                "'CT', '06033', 'UNITED STATES', " +            // los_state_province, los_postal_code, los_country
                "'', 0, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', 'CT', '06033'," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'UNITED STATES', '', 0," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'CT'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'06033', 'UNITED STATES', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), invoiceDate1String);
            SqlWizard.execute(insertStatement, m_isSqlServer);


            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," + // customer_code, los_address, los_city
                "'CT', '06033', 'UNITED STATES', " +            // los_state_province, los_postal_code, los_country
                "'', 0, ''," +                               // los_location_code, los_geo_code, bill_to_address
                "'', 'CT', '06033'," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'UNITED STATES', '', 0," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'CT'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'06033', 'UNITED STATES', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), invoiceDate2String);
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testDateChange.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by tax_amount", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testDateChange.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }
#endif

#if true
        /// <summary>
        /// 10 identical transactions, should fail after 4th
        /// </summary>
        [TestMethod]
        public void TestTenFailures()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = false;
            taxManager.MaximumNumberOfErrors = 3;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            for (int i = 0; i < 10; i++)
            {
                string insertStatement = String.Format(
                    "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                    "(id_tax_charge, id_acc, amount, " +
                    "invoice_date, product_code, customer_name," +
                    "customer_code, los_address, los_city," +
                    "los_state_province, los_postal_code, los_country," +
                    "los_location_code, los_geo_code, bill_to_address, " +
                    "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                    "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                    "ship_to_address, ship_to_city, ship_to_state_province, " +
                    "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                    "ship_to_geo_code, good_or_service_code, sku, " +
                    "currency, is_implied_tax, round_alg," +
                    "round_digits)" +
                    "VALUES" +
                    "({1}, 20202, {2}, " +                          // id_tax_charge, id_acc, amount
                    "{3}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                    "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                    "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                    "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                    "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                    "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                    "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                    "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                    "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                    "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                    "0)",                                           // round_digits
                    taxManager.TaxRunId, 11111, (i + 1) * 100.00, GetInvoiceDate());
                SqlWizard.execute(insertStatement, m_isSqlServer);
            }

            try
            {
                taxManager.CalculateTaxes();
            }
            catch (Exception)
            {
                // exception is expected, ignore it
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Attempt transactions with duplicate IDs.
        /// Not auditing, so it shouldn't be a problem.
        /// This tests currently doesn't always work because
        /// the transaction ids might be different (time based).
        /// </summary>
        [TestMethod]
        public void TestDuplicateTransactionIdsNoAudit()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 11016, ''," +                              // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 11016," +                              // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "11016, '2038584', 'XXXYYYZZZZ'," +             // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, 77778888, GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, los_address, los_city," +
                "los_state_province, los_postal_code, los_country," +
                "los_location_code, los_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                "'', 11016, ''," +                              // los_location_code, los_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 11016," +                              // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                "11016, '2038584', 'XXXYYYZZZZ'," +             // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0)",                                           // round_digits
                taxManager.TaxRunId, 77778888, GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            try
            {
                taxManager.IsAuditingNeeded = false;
                taxManager.CalculateTaxes();
            }
            catch (Exception)
            {
                Assert.Fail("Not auditing, so don't expect an exception to be thrown because of duplicate transaction ids");
            }

            Console.WriteLine("...Done.");
        }
#endif

#if true

        /// <summary>
        /// Attempt to calculate taxes in euros for Concur France
        /// </summary>
        [TestMethod]
        public void TestConcurFrance()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[lsp_address] [varchar](255)," +
                "[lsp_city] [varchar](255)," +
                "[lsp_state_province] [varchar](255)," +
                "[lsp_postal_code] [varchar](16)," +
                "[lsp_country] [varchar](255)," +
                "[lsp_location_code] [varchar](255)," +
                "[lsp_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL," +
                "[organization_code] [varchar](255) NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            // location service provided = FRANCE, ship to = FRANCE, expect non-zero VAT
            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'FRANCE', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'FRANCE', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurFrance')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = FRANCE, ship to = GERMANY, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 400.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'FRANCE', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'GERMANY', ''," +                          // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurFrance')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = FRANCE, ship to = JAPAN, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'FRANCE', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'JAPAN', ''," +                            // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurFrance')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            DateTime jimmyFundInvoiceDate = new DateTime(2012, 6, 12, 8, 0, 0);
            string jimmyFundInvoiceDateString = "'" + jimmyFundInvoiceDate.ToString() + "'";
            if (!m_isSqlServer)
            {
                jimmyFundInvoiceDateString = "TO_TIMESTAMP('2012-06-12 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
            }

            // location service provided = FRANCE, ship to = FRANCE, customerCode=JimmyFund, expect zero VAT because of exemption
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'JimmyFund'," +      // invoice_date, product_code, customer_name
                "'JimmyFund', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'FRANCE', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'FRANCE', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurFrance')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), jimmyFundInvoiceDateString);
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurFrance.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurFrance.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Attempt to calculate taxes in euros for Concur Netherlands
        /// </summary>
        [TestMethod]
        public void TestConcurNetherlands()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[lsp_address] [varchar](255)," +
                "[lsp_city] [varchar](255)," +
                "[lsp_state_province] [varchar](255)," +
                "[lsp_postal_code] [varchar](16)," +
                "[lsp_country] [varchar](255)," +
                "[lsp_location_code] [varchar](255)," +
                "[lsp_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL," +
                "[organization_code] [varchar](255) NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            // location service provided = NETH, ship to = NETH, expect non-zero VAT
            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'Netherlands', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'Netherlands', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurNetherland')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = NETH, ship to = GERMANY, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 400.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'NETHERLANDS', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'GERMANY', ''," +                          // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurNETHERLAND')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = NETH, ship to = JAPAN, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'NETHERLANDS', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'JAPAN', ''," +                            // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurNetherland')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            DateTime jimmyFundInvoiceDate = new DateTime(2012, 6, 12, 8, 0, 0);
            string jimmyFundInvoiceDateString = "'" + jimmyFundInvoiceDate.ToString() + "'";
            if (!m_isSqlServer)
            {
                jimmyFundInvoiceDateString = "TO_TIMESTAMP('2012-06-12 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
            }

            // location service provided = NETH, ship to = NETH, customerCode=NethCharity, expect zero VAT because of exemption
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'NethCharity'," +      // invoice_date, product_code, customer_name
                "'NethCharity', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'Netherlands', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'Netherlands', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurNetherland')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), jimmyFundInvoiceDateString);
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurNetherlands.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurNetherlands.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }
#endif

#if true
        /// <summary>
        /// Attempt to calculate taxes in euros for Concur UK
        /// </summary>
        [TestMethod]
        public void TestConcurUK()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[lsp_address] [varchar](255)," +
                "[lsp_city] [varchar](255)," +
                "[lsp_state_province] [varchar](255)," +
                "[lsp_postal_code] [varchar](16)," +
                "[lsp_country] [varchar](255)," +
                "[lsp_location_code] [varchar](255)," +
                "[lsp_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL," +
                "[organization_code] [varchar](255) NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            // location service provided = UK, ship to = UK, expect non-zero VAT
            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'United Kingdom', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'United Kingdom', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurUK')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = UK, ship to = GERMANY, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 400.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'United Kingdom', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'GERMANY', ''," +                          // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurUK')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = UK, ship to = JAPAN, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'United Kingdom', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'JAPAN', ''," +                            // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurUK')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            DateTime jimmyFundInvoiceDate = new DateTime(2012, 6, 12, 8, 0, 0);
            string jimmyFundInvoiceDateString = "'" + jimmyFundInvoiceDate.ToString() + "'";
            if (!m_isSqlServer)
            {
                jimmyFundInvoiceDateString = "TO_TIMESTAMP('2012-06-12 08:00:00', 'YYYY-MM-DD HH24:MI:SS')";
            }

            // location service provided = UK, ship to = UK, organizationCode=MyCharity, expect zero VAT because of exemption
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 300.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'MyCharity'," +      // invoice_date, product_code, customer_name
                "'MyCharity', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'', '', 'United Kingdom', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'United Kingdom', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'EUR', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'ConcurUK')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), jimmyFundInvoiceDateString);
            SqlWizard.execute(insertStatement, m_isSqlServer);

            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurUK.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge,id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurUK.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }
#endif

        /// <summary>
        /// Attempt to calculate taxes in for Concur Canada
        /// </summary>
        [TestMethod]
        public void TestConcurCanada()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[lsp_address] [varchar](255)," +
                "[lsp_city] [varchar](255)," +
                "[lsp_state_province] [varchar](255)," +
                "[lsp_postal_code] [varchar](16)," +
                "[lsp_country] [varchar](255)," +
                "[lsp_location_code] [varchar](255)," +
                "[lsp_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL," +
                "[organization_code] [varchar](255) NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            // location service provided = FRANCE, ship to = FRANCE, expect non-zero VAT
            string insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 9144.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Morguard Investments Limited'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'Alberta', '', 'CANADA', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'Alberta'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'CANADA', ''," +                           // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'CAD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'Root')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = FRANCE, ship to = GERMANY, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 400.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Canaccord Genuity Corp.'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'British Columbia', '', 'CANADA', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'British Columbia'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'Canada', ''," +                          // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'CAD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'Root')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);

            // location service provided = Canada, ship to = JAPAN, expect zero VAT
            insertStatement = String.Format(
                "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                "(id_tax_charge, id_acc, amount, " +
                "invoice_date, product_code, customer_name," +
                "customer_code, lsp_address, lsp_city," +
                "lsp_state_province, lsp_postal_code, lsp_country," +
                "lsp_location_code, lsp_geo_code, bill_to_address, " +
                "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                "ship_to_address, ship_to_city, ship_to_state_province, " +
                "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                "ship_to_geo_code, good_or_service_code, sku, " +
                "currency, is_implied_tax, round_alg," +
                "round_digits, organization_code)" +
                "VALUES" +
                "({1}, 20202, 500.00, " +                       // id_tax_charge, id_acc, amount
                "{2}, 'unused', 'Kruger, Inc'," +      // invoice_date, product_code, customer_name
                "'BV0000001', '', ''," +                        // customer_code, lsp_address, lsp_city
                "'Ontario', '', 'CANADA', " +                          // lsp_state_province, lsp_postal_code, lsp_country
                "'', 0, ''," +                                  // lsp_location_code, lsp_geo_code, bill_to_address
                "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                "'', '', 0," +                                  // bill_to_country, bill_to_location_code, bill_to_geo_code
                "'', '', 'Ontario'," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                "'', 'CANADA', ''," +                            // ship_to_postal_code, ship_to_country, ship_to_location_code
                "0, '2038584', 'XXXYYYZZZZ'," +                 // ship_to_geo_code, good_or_service_code, sku
                "'CAD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                "0, 'Root')",                           // round_digits, organization_code
                taxManager.TaxRunId, GetUniqueIdTaxCharge(), GetInvoiceDate());
            SqlWizard.execute(insertStatement, m_isSqlServer);


            taxManager.CalculateTaxes();

            // Validate results
            string extractStatement = String.Format(SELECT_FROM_T_TAX_OUTPUT, taxManager.TaxRunId);
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurCanada.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge, id_tax_detail", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testConcurCanada.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }

            Console.WriteLine("...Done.");
        }

        /// <summary>
        /// Test AMP CalculateTaxes method
        /// </summary>
        [TestMethod]
        public void TestAmpCalculateTaxesMethod()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);

            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = false;

            // Missing "TaxVendor", so expect exception
            try
            {
                Dictionary<string, string> usageRecord = new Dictionary<string, string>();
                usageRecord["id_tax_charge"] = GetUniqueIdTaxCharge().ToString();
                usageRecord["id_acc"] = "20202";
                usageRecord["amount"] = "300.00";
                usageRecord["currency"] = "USD";

                IDictionary<string, string> transactionSummary;
                List<TransactionIndividualTax> transactionDetails;
                taxManager.CalculateTaxes(usageRecord, out transactionSummary, out transactionDetails);
                Assert.Fail("expect exception because no 'TaxVendor' in usageRecord");
            }
            catch (Exception)
            {
                // PASSED
            }

            // Missing "currency", so expect exception
            try
            {
                Dictionary<string, string> usageRecord = new Dictionary<string, string>();
                usageRecord["id_tax_charge"] = GetUniqueIdTaxCharge().ToString();
                usageRecord["id_acc"] = "20202";
                usageRecord["amount"] = "300.00";
                int taxVendorInt = (int)EnumHelper.GetDbValueByEnum(TaxVendor.Taxware);
                usageRecord["TaxVendor"] = taxVendorInt.ToString();

                IDictionary<string, string> transactionSummary;
                List<TransactionIndividualTax> transactionDetails;
                taxManager.CalculateTaxes(usageRecord, out transactionSummary, out transactionDetails);
                Assert.Fail("expect exception because no 'currency' in usageRecord");
            }
            catch (Exception)
            {
                // PASSED
            }

            // This one should work. Check the output values
            {
                Dictionary<string, string> usageRecord = new Dictionary<string, string>();
                usageRecord["id_tax_charge"] = GetUniqueIdTaxCharge().ToString();
                usageRecord["id_acc"] = "20202";
                usageRecord["amount"] = "300.00";
                DateTime invoiceDate = new DateTime(2012, 3, 15, 8, 0, 0);
                usageRecord["invoice_date"] = invoiceDate.ToString();
                usageRecord["los_geo_code"] = "1683";
                usageRecord["bill_to_geo_code"] = "1683";
                usageRecord["ship_to_geo_code"] = "1683";
                usageRecord["good_or_service_code"] = "2040181";
                usageRecord["currency"] = "USD";
                int taxVendorInt = (int) EnumHelper.GetDbValueByEnum(TaxVendor.Taxware);
                usageRecord["TaxVendor"] = taxVendorInt.ToString();

                IDictionary<string, string> transactionSummary;
                List<TransactionIndividualTax> transactionDetails;
                taxManager.CalculateTaxes(usageRecord, out transactionSummary, out transactionDetails);

                Assert.AreEqual(transactionSummary["TaxFedName"], "");
                Assert.AreEqual(transactionSummary["TaxFedAmount"], "0");
                Assert.AreEqual(transactionSummary["TaxFedRounded"], "0");
                Assert.AreEqual(transactionSummary["TaxStateName"], "CA State Tax");
                Assert.AreEqual(transactionSummary["TaxStateAmount"], "18.75");
                Assert.AreEqual(transactionSummary["TaxStateRounded"], "18.75");
                Assert.AreEqual(transactionSummary["TaxCountyName"], "CA County Tax");
                Assert.AreEqual(transactionSummary["TaxCountyAmount"], "3.00");
                Assert.AreEqual(transactionSummary["TaxCountyRounded"], "3.00");
                Assert.AreEqual(transactionSummary["TaxLocalName"], "CA District Tax");
                Assert.AreEqual(transactionSummary["TaxLocalAmount"], "4.5");
                Assert.AreEqual(transactionSummary["TaxLocalRounded"], "4.5");
                Assert.AreEqual(transactionSummary["TaxOtherName"], "");
                Assert.AreEqual(transactionSummary["TaxOtherAmount"], "0");
                Assert.AreEqual(transactionSummary["TaxOtherRounded"], "0");
            }

            Console.WriteLine("...Done.");

        }

#if false
        /// <summary>
        /// 1000 successful transactions
        /// </summary>
        [TestMethod]
        public void Test1000()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
            SyncTaxManagerBatchDb taxManager = SyncTaxManagerBatchDbFactory.GetTaxManagerBatchDb(TaxVendor.Taxware);
            taxManager.TaxRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.AdapterUniqueRunId = taxManager.GenerateUniqueTaxRunID();
            taxManager.TaxDetailsNeeded = true;

            SqlWizard.RemoveAllRowsFromTable("t_tax_details", m_isSqlServer);
            string tableName = String.Format("t_tax_output_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);
            tableName = String.Format("t_tax_input_{0}", taxManager.TaxRunId);
            SqlWizard.RemoveTable(tableName, m_isSqlServer);


            string createTable = String.Format(
                "CREATE TABLE [dbo].[t_tax_input_{0}](" +
                "[id_tax_charge] [bigint] NOT NULL," +
                "[id_acc] [int] NOT NULL," +
                "[amount] [numeric](22, 10) NOT NULL," +
                "[invoice_date] [datetime] NOT NULL," +
                "[product_code] [varchar](255) NOT NULL," +
                "[customer_name] [varchar](255) NOT NULL," +
                "[customer_code] [varchar](255) NOT NULL," +
                "[los_address] [varchar](255)," +
                "[los_city] [varchar](255)," +
                "[los_state_province] [varchar](255)," +
                "[los_postal_code] [varchar](16)," +
                "[los_country] [varchar](255)," +
                "[los_location_code] [varchar](255)," +
                "[los_geo_code] [int] NOT NULL," +
                "[bill_to_address] [varchar](255)," +
                "[bill_to_city] [varchar](255)," +
                "[bill_to_state_province] [varchar](255)," +
                "[bill_to_postal_code] [varchar](16)," +
                "[bill_to_country] [varchar](255)," +
                "[bill_to_location_code] [varchar](255)," +
                "[bill_to_geo_code] [int] NOT NULL," +
                "[ship_to_address] [varchar](255)," +
                "[ship_to_city] [varchar](255)," +
                "[ship_to_state_province] [varchar](255)," +
                "[ship_to_postal_code] [varchar](16)," +
                "[ship_to_country] [varchar](255)," +
                "[ship_to_location_code] [varchar](255)," +
                "[ship_to_geo_code] [int] NOT NULL," +
                "[good_or_service_code] [varchar](255) NOT NULL," +
                "[sku] [varchar](255) NOT NULL," +
                "[currency] [varchar](16) NOT NULL," +
                "[is_implied_tax] [varchar](16) NOT NULL," +
                "[round_alg] [varchar](255) NOT NULL," +
                "[round_digits] [int] NOT NULL" +
                ")", taxManager.TaxRunId);
            SqlWizard.execute(createTable, m_isSqlServer);

            for (int i=0; i<1000; i++)
            {
                string insertStatement = String.Format(
                    "INSERT INTO NetMeter.dbo.t_tax_input_{0}" +
                    "(id_tax_charge, id_acc, amount, " +
                    "invoice_date, product_code, customer_name," +
                    "customer_code, los_address, los_city," +
                    "los_state_province, los_postal_code, los_country," +
                    "los_location_code, los_geo_code, bill_to_address, " +
                    "bill_to_city, bill_to_state_province, bill_to_postal_code, " +
                    "bill_to_country, bill_to_location_code, bill_to_geo_code, " +
                    "ship_to_address, ship_to_city, ship_to_state_province, " +
                    "ship_to_postal_code, ship_to_country, ship_to_location_code," +
                    "ship_to_geo_code, good_or_service_code, sku, " +
                    "currency, is_implied_tax, round_alg," +
                    "round_digits)" +
                    "VALUES" +
                    "({1}, 20202, {2}, " +                          // id_tax_charge, id_acc, amount
                    "{3}, 'unused', 'Office Supplier 01'," +      // invoice_date, product_code, customer_name
                    "'BV0000001', '', ''," +                        // customer_code, los_address, los_city
                    "'', '', '', " +                                // los_state_province, los_postal_code, los_country
                    "'', 1683, ''," +                               // los_location_code, los_geo_code, bill_to_address
                    "'', '', ''," +                                 // bill_to_city, bill_to_state_province, bill_to_postal_code
                    "'', '', 1683," +                               // bill_to_country, bill_to_location_code, bill_to_geo_code
                    "'', '', ''," +                                 // ship_to_address, ship_to_city, ship_to_state_province
                    "'', '', ''," +                                 // ship_to_postal_code, ship_to_country, ship_to_location_code
                    "1683, '2040181', '60400003100'," +             // ship_to_geo_code, good_or_service_code, sku
                    "'USD', 'FALSE', 'none'," +                           // currency, is_implied_tax, round_alg
                    "0)",                                           // round_digits
                    taxManager.TaxRunId, GetUniqueIdTaxCharge(), 10000.00 + i, GetInvoiceDate());
                SqlWizard.execute(insertStatement, m_isSqlServer);
            }

            Console.WriteLine("Before Calculate Taxes: {0}", DateTime.Now);
            taxManager.CalculateTaxes();
            Console.WriteLine("After Calculate Taxes: {0}", DateTime.Now);
            Console.WriteLine("...Done.");
        }
#endif


        private void ExecuteBatFile(string batFileName)
        {
            System.Diagnostics.Process proc = new System.Diagnostics.Process();
            proc.EnableRaisingEvents = false;
            proc.StartInfo.FileName = batFileName;
            proc.Start();
            proc.WaitForExit();

        }

        private String removeWhitespace(string inputString)
        {
            char[] charsToRemove = new char[] { '\r', '\t', '\n', ' ' };
            string[] results = inputString.Split(charsToRemove);
            StringBuilder transformedString = new StringBuilder();

            foreach (string s in results)
            {
                transformedString.Append(s);
            }

            return transformedString.ToString();
        }

        private bool compareToExpected(string expectedFile, string saw)
        {
            StreamReader reader = new StreamReader(TEST_DIR + expectedFile);
            string expected = "";
            while (reader.Peek() >= 0)
            {
                expected = expected + reader.ReadLine() + "\n";
            }

            string expected2 = removeWhitespace(expected.ToUpper());

            if (!m_isSqlServer)
            {
                // For oracle, remove trailing zeroes from the expected
                Regex rgx = new Regex("\\.0000000000");
                expected2 = rgx.Replace(expected2, "");

                rgx = new Regex("00000000");
                expected2 = rgx.Replace(expected2, "");

                rgx = new Regex("000000");
                expected2 = rgx.Replace(expected2, "");

                rgx = new Regex("0000");
                expected2 = rgx.Replace(expected2, "");
            }
            string saw2 = removeWhitespace(saw.ToUpper());

            if (saw2 == expected2)
            {
                return true;
            }

            Console.Write("Expected: " + expected);
            Console.Write("Saw: " + saw);
            return false;
        }

    }
}

