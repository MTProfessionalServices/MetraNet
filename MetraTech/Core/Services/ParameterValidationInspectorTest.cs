/**************************************************************************
* Copyright 1997-2012 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Borys Sokolov <bsokolov@metratech.com>
*
* 
***************************************************************************/
using System.ServiceModel;
using MetraTech.ActivityServices.Common;
using MetraTech.Core.Services.ClientProxies;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace MetraTech.Core.Services.UnitTests
{
    // SECURITY-213: Implement protection from SQL and XSS injections in Activity Services
    // To Run this fixture
    // nunit-console /fixture:MetraTech.Core.Services.UnitTests.ParameterValidationInspectorTest /assembly:O:\Debug\bin\MetraTech.Core.Services.UnitTests.dll
    [TestClass]
    public class ParameterValidationInspectorTest
    {
        /// <summary>
        ///    Runs once before any of the tests are run.
        /// </summary>
        [ClassInitialize]
		public static void InitTests(TestContext testContext)
        {
            //MakeSureServiceIsStarted("ActivityServices");
        }

        /// <summary>
        ///   Runs once after all the tests are run.
        /// </summary>
        [ClassCleanup]
        public static void Dispose()
        {
        }

        [TestMethod]
        [TestCategory("LoginAccount")]
        public void LoginAccount()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            string ticket;
            string context;
            int? passExpireDays;

            client.LoginAccount("mt", "hanzel", "h", 20, out passExpireDays, out ticket, out context);

            Assert.IsNotNull(ticket);
            Assert.IsNotNull(context);
			Assert.IsFalse(string.IsNullOrEmpty(ticket));
            Assert.IsFalse(string.IsNullOrEmpty(context));
        }

        [TestMethod]
        [TestCategory("LoginAccountWithXSS")]
        public void LoginAccountWithXSS()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                string ticket;
                string context;
                int? passExpireDays;

                client.LoginAccount("mt", "<LINK REL=\"stylesheet\" HREF=\"javascript:alert('XSS');\">", "h", 20, out passExpireDays, out ticket, out context);
                Assert.Fail("Injection passed");
            }
            catch (FaultException<MASBasicFaultDetail>)
            {
            }
        }

        [TestMethod]
        [TestCategory("LoginAccountWithXSS2")]
        public void LoginAccountWithXSS2()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                string ticket;
                string context;
                int? passExpireDays;

                client.LoginAccount("mt", "<p onmousemove='doSomething();'/>", "h", 20, out passExpireDays, out ticket, out context);
                Assert.Fail("Injection passed");
            }
            catch (FaultException<MASBasicFaultDetail>)
            {
            }
        }

        [TestMethod]
        [TestCategory("LoginAccountWithSQL")]
        public void LoginAccountWithSQL()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            try
            {
                string ticket;
                string context;
                int? passExpireDays;

                client.LoginAccount("mt", "select 1 from dual", "h", 20, out passExpireDays, out ticket, out context);
                Assert.Fail("Injection passed");
            }
            catch (FaultException<MASBasicFaultDetail>)
            {
            }
        }

    }
}
