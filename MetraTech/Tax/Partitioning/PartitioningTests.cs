using System;
using System.Diagnostics;
using System.Text.RegularExpressions;
using System.Xml;
using System.IO;
using System.Collections;
using System.Reflection;
using MetraTech.Tax.Framework;
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


namespace MetraTech.Tax.Partitioning.Test
{
    //
    // To run the this test fixture:
    // ncover //x ncoverOutput.xml
    // nunit-console /fixture:MetraTech.Tax.Partitioning.Test.PartitioningTests /assembly:O:\debug\bin\MetraTech.Tax.Partitioning.Test.dll
    //
    [TestClass]
    //[ComVisible(false)]
    public class PartitioningTests
    {

        const string TEST_DIR = "t:\\Development\\Core\\Tax\\Taxware\\";

        [TestMethod()]
        public void Init()
        {
            Console.WriteLine("Perform setup tasks");
        }

        private int m_counter = 1000;
        public int GetUniqueIdTaxCharge()
        {
            return m_counter++;
        }

        private DateTime GetInvoiceDate()
        {
            DateTime invoiceDate = new DateTime(2012, 3, 15, 8, 0, 0);
            return invoiceDate;
        }


        /// <summary>
        /// Perform a single valid TWE transaction
        /// </summary>
		[TestMethod()]
        public void TestAddPartitions()
        {
            Console.Write("Starting {0}", System.Reflection.MethodBase.GetCurrentMethod().Name);
#if false

            SqlWizard.execute("use netmeter; INSERT INTO t_usage_interval " +
                "(id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status) values " +
                "(1015283744, 32, '20120601', '20120630', 'O')");

            SqlWizard.execute("use netmeter; exec CreateTaxDetailPartitions");

            // Validate results
            string extractStatement = String.Format("select * from v_partition_info");
            string saw = SqlWizard.getSelectAsXml(extractStatement);
            Console.WriteLine(saw);

            // Insert some data into t_tax_details to see where the rows go
            for (int month = 5; month <= 6; month++ )
            {
                for (int i = 0; i < 5; i++)
                {
                    DateTime transactionDate = new DateTime(2012, month, 15);
                    DateTime epochDate = new DateTime(1970, 1, 1);
                    TimeSpan dateDiff = transactionDate - epochDate;
                    int myInterval = (dateDiff.Days*65536) + 32; // 32 is id of the interval cycle

                    string insertStatement = "insert into t_tax_details " +
                                             "(id_tax_charge, id_acc, id_usage_interval, " +
                                             "id_tax_run, dt_calc, tax_amount, " +
                                             "rate, tax_jur_level, tax_jur_name, " +
                                             "tax_type, tax_type_name, is_implied, " +
                                             "notes) values " +
                                             "(111, 1111, " + myInterval.ToString() + ", " +
                                             "11111, '20120515', 111.11, " +
                                             "11.11, 1, 'federal', " +
                                             "1, 'federal', 0, " +
                                             "'just for testing partitions')";

                    SqlWizard.execute(insertStatement);
                }
            }

            // Validate results
            extractStatement = String.Format("select * from v_partition_info");
            saw = SqlWizard.getSelectAsXml(extractStatement);
            Console.WriteLine(saw);

            SqlWizard.execute("use netmeter; INSERT INTO t_usage_interval " +
                "(id_interval, id_usage_cycle, dt_start, dt_end, tx_interval_status) values " +
                "(1015283744, 32, '20120601', '20120630', 'O')");

            SqlWizard.execute("use netmeter; exec CreateTaxDetailPartitions");

            extractStatement = String.Format("select * from v_partition_info");
            saw = SqlWizard.getSelectAsXml(extractStatement);
            Console.WriteLine(saw);

            if (!compareToExpected("testCalculateTaxesSingleTransaction.expected_tax_output.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax output didn't match.");
            }

            extractStatement = String.Format("SELECT [tax_amount], " +
                "[rate], [tax_jur_level], [tax_jur_name], [tax_type], [tax_type_name], [is_implied] " +
                "from t_tax_details where id_tax_run={0} order by id_tax_charge", taxManager.TaxRunId);
            saw = SqlWizard.getSelectAsXml(extractStatement);
            if (!compareToExpected("testCalculateTaxesSingleTransaction.expected_tax_details.txt", saw))
            {
                Console.Write("Fail");
                throw new TaxException("Tax details didn't match.");
            }
#endif

            Console.WriteLine("...Done.");
        }

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

            string expected2 = removeWhitespace(expected);
            string saw2 = removeWhitespace(saw);

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

