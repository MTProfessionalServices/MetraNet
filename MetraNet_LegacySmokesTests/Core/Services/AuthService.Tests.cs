using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.Interop.MTAuth;


//
// To run the this test fixture:
// nunit-console /fixture:MetraTech.Core.Services.Test.AuthServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    public class AuthServiceTest
    {
        private Logger m_Logger = new Logger("[AuthServiceTestLogger]");
        [Test]
        [Category("LoginAccount")]
        public void LoginAccount()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";
            
            string ticket;
            string context;
            int? passExpireDays;

            client.LoginAccount("mt", "mark", "MetraTech1", 20, out passExpireDays,  out ticket, out context);

            Assert.IsNotNull(ticket);
            Assert.IsNotNull(context);
            Assert.IsNotEmpty(ticket); 
            Assert.IsNotEmpty(context);
             
        }

        [Test]
        [Category("InvalidateTicket")]
        public void InvalidateTicket()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            
            string ticket;
            string context;
            int? passExpireDays;

            client.LoginAccount("mt", "paul", "123", 20, out passExpireDays, out ticket, out context);

            Assert.IsNotNull(ticket);
            Assert.IsNotNull(context);
            Assert.IsNotEmpty(ticket);
            Assert.IsNotEmpty(context);

            client.InvalidateTicket(ticket);
            
        }

        [Test]
        [Category("TicketToAccount")]
        public void TicketToAccount()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";
            
            string ticket;
            string context;

            client.TicketToAccount("mt", "paul", 20, out ticket, out context);

            Assert.IsNotNull(ticket);
            Assert.IsNotNull(context);
            Assert.IsNotEmpty(ticket);
            Assert.IsNotEmpty(context);
            
        }

        [Test]
        [Category("ValidateTicket")]
        public void ValidateTicket()
        {
            AuthServiceClient client = new AuthServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";
            
            string ticket;
            string context;

            client.TicketToAccount("mt", "paul", 20, out ticket, out context);

            Assert.IsNotNull(ticket);
            Assert.IsNotNull(context);
            Assert.IsNotEmpty(ticket);
            Assert.IsNotEmpty(context);

            string userName;
            string sessionContext;
            string nameSpace;

            client.ValidateTicket(ticket, out nameSpace, out userName, out sessionContext);

            Assert.IsNotEmpty(userName);
            Assert.AreEqual("paul", userName.ToLower());
            Assert.IsNotEmpty(nameSpace);
            Assert.AreEqual("mt", nameSpace.ToLower());
            
        }


        [Test]
        [Category("CORE3332")]
        public void CORE3332()
        {
          AuthServiceClient client = new AuthServiceClient();
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";

          string ticket;
          string context;
          m_Logger.LogInfo("Calling 1");
          client.TicketToAccount("mt", "paul", 20, out ticket, out context);

          Assert.IsNotNull(ticket);
          Assert.IsNotNull(context);
          Assert.IsNotEmpty(ticket);
          Assert.IsNotEmpty(context);

          string userName;
          string sessionContext;
          string nameSpace;

          //System.Threading.Thread.Sleep(10000);
          m_Logger.LogInfo("Calling 2");
          client.ValidateTicket(ticket, out nameSpace, out userName, out sessionContext);

          Assert.IsNotEmpty(userName);
          Assert.AreEqual("paul", userName.ToLower());
          Assert.IsNotEmpty(nameSpace);
          Assert.AreEqual("mt", nameSpace.ToLower());

          //System.Threading.Thread.Sleep(10000);
          m_Logger.LogInfo("Calling 3");
          client.InvalidateTicket(ticket);
        }

    }
}