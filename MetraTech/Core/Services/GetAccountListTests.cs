using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.ServiceModel;
using System.Diagnostics;

using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.DomainModel.ProductCatalog;
using MetraTech.Interop.MTYAAC;
using Microsoft.VisualStudio.TestTools.UnitTesting;

using MetraTech;

using MetraTech.DomainModel.Common;
using MetraTech.Core.Services;



using System.Collections;
using MetraTech.Interop.MTAuth;
using System.Runtime.InteropServices;
using MetraTech.DomainModel.BaseTypes;
using IMTCompositeCapability = MetraTech.Interop.MTAuth.IMTCompositeCapability;
using IMTYAAC = MetraTech.Interop.MTAuth.IMTYAAC;


//
// To Run this test
// "c:\Program Files (x86)\NUnit 2.5.10\bin\net-2.0\nunit-console-x86.exe" /fixture:MetraTech.Core.Services.UnitTests.GetAccountListTests O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
// "c:\Program Files (x86)\NUnit 2.6\bin\nunit-console-x86.exe" /fixture:MetraTech.Core.Services.UnitTests.GetAccountListTests O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll /output=testOutput.txt
namespace MetraTech.Core.Services.UnitTests
{
    [TestClass]
    public class GetAccountListTests
    {

        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
        }

        [TestMethod]
        public void TestGetAccountList()
        {
            AccountServiceClient client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            // Note: these are the only "real" accounts in the DB.
            // The other accounts fail.
            List<string> lastNames = new List<string>()
                                 {
                                   "Product Management",
                                   "Cook",
                                   "Spicoli",
                                   "EMEA HQ",
                                   "Software, Inc.",
                                   "Americas HQ",
                                   "Asia Pacific HQ"
                                 };

            int numIterations = 1;

            long sumMilliseconds = 0;
            long maxMilliseconds = -1;
            long minMilliseconds = 999999999;
            long firstMilliseconds = 0;
            bool isFirst = true;

            for (int i = 0; i < numIterations; i++)
            {
                foreach (var lastName in lastNames)
                {

                    MTList<Account> accounts = new MTList<Account>();
                    accounts.Filters.Add(new MTFilterElement("LastName", MTFilterElement.OperationType.Equal, lastName));
                    accounts.PageSize = 10;
                    accounts.CurrentPage = 1;

                    Stopwatch stopWatch = new Stopwatch();
                    stopWatch.Start();

                    client.GetAccountList(DateTime.Now, ref accounts, false);

                    stopWatch.Stop();
                    Console.WriteLine("GetAccountList with LastName=={0}, milliseconds={1}, accounts.TotalRows={2}",
                                      lastName, stopWatch.ElapsedMilliseconds, accounts.Items.Count);

                    if (isFirst == true)
                    {
                        firstMilliseconds = stopWatch.ElapsedMilliseconds;
                        isFirst = false;
                    }
                    else
                    {
                        sumMilliseconds += stopWatch.ElapsedMilliseconds;
                        if (stopWatch.ElapsedMilliseconds < minMilliseconds)
                        {
                            minMilliseconds = stopWatch.ElapsedMilliseconds;
                        }

                        if (stopWatch.ElapsedMilliseconds > maxMilliseconds)
                        {
                            maxMilliseconds = stopWatch.ElapsedMilliseconds;
                        }
                    }

                }
            }

            Console.WriteLine("averageMilliseconds={0}, maxMilliseconds={1}, minMilliseconds={2}, firstMilliseconds={3}",
              sumMilliseconds / ((numIterations * lastNames.Count) - 1), maxMilliseconds, minMilliseconds, firstMilliseconds);
        }

        [TestMethod]
        public void TestGetAccountListTotalRows()
        {
            AccountServiceClient client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            MTList<Account> accounts = new MTList<Account>();

            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();
            int numRows = 0;

            client.GetAccountListTotalRows(DateTime.Now, accounts, false, out numRows);
            //client.GetAccountList(DateTime.Now, ref accounts, false);

            stopWatch.Stop();

            Console.WriteLine("GetAccountListTotalRows accounts.TotalRows={0}, numRows={1}, elapsedMilliseconds={2}",
                              accounts.Items.Count, numRows, stopWatch.ElapsedMilliseconds);

            List<Account> accountList = accounts.Items;
            foreach (var acct in accountList)
            {
                Console.WriteLine("_AccountId={0}, UserName={1}, AccountIdDisplayName={2}, UserNameDisplayName={3}", 
                    acct._AccountID, acct.UserName, acct._AccountIDDisplayName, acct.UserNameDisplayName);
            }

        }


        [TestMethod]
        public void TestGetAccountIdList()
        {
            AccountServiceClient client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            MTList<Account> accounts = new MTList<Account>();
            List<int> idList;


            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();

            client.GetAccountIdList(DateTime.Now, ref accounts, false, out idList);

            stopWatch.Stop();
            Console.WriteLine("GetAccountIdList: elapsedMilliseconds={0}",
                              stopWatch.ElapsedMilliseconds);
        }

        [TestMethod]
        public void TestLoadAccount()
        {
            AccountServiceClient client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier acctId = new AccountIdentifier(123);
            Account acct;


            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();

            client.LoadAccount(acctId, DateTime.Now, out acct);

            stopWatch.Stop();
            Console.WriteLine("TestLoadAccount: elapsedMilliseconds={0}",
                              stopWatch.ElapsedMilliseconds);
            Assert.AreEqual(acct.UserName, "demo");
        }

        [TestMethod]
        public void TestLoadAccountWithViews()
        {
            AccountServiceClient client = new AccountServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            AccountIdentifier acctId = new AccountIdentifier(123);
            Account acct;

            Stopwatch stopWatch = new Stopwatch();
            stopWatch.Start();

            client.LoadAccountWithViews(acctId, DateTime.Now, out acct);

            stopWatch.Stop();
            Console.WriteLine("TestLoadAccountWithViews: elapsedMilliseconds={0}",
                              stopWatch.ElapsedMilliseconds);
            Assert.AreEqual(acct.UserName, "demo");
        }
    }
}
