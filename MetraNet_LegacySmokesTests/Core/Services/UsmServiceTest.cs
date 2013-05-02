using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using NUnit.Framework;
using MetraTech.Core.Services.ClientProxies;
using MetraTech.ActivityServices.Common;
using MetraTech.DomainModel.Billing;
using MetraTech.DomainModel.BaseTypes;
using MetraTech.DomainModel.Enums.Core.Global;
using MetraTech.UsageServer;


//
// To run the this test fixture:
//  First, meter usage for audioConf subscriber Kevin
// nunit-console /fixture:MetraTech.Core.Services.Test.UsmServiceTest /assembly:O:\debug\bin\MetraTech.Core.Services.Test.dll
//
namespace MetraTech.Core.Services.Test
{
  [Category("NoAutoRun")]
  [TestFixture]
    public class UsmServiceTest
    {
        private Logger m_Logger = new Logger("[UsmServiceLogger]");

        [Test]
        [Category("GetConfigCrossServer")]
        public void GetConfigCrossServer()
        {
            UsmServiceClient client = new UsmServiceClient();
            client.ClientCredentials.UserName.UserName = "su";
            client.ClientCredentials.UserName.Password = "su123";

            ConfigCrossServer config;
            client.GetConfigCrossServer(out config);

            Console.WriteLine("config.gracePeriodBiWeeklyInDays = " + config.gracePeriodBiWeeklyInDays);
        }

        [Test]
        [Category("SetConfigCrossServer")]
        public void SetConfigCrossServer()
        {
          UsmServiceClient client = new UsmServiceClient();
          client.ClientCredentials.UserName.UserName = "su";
          client.ClientCredentials.UserName.Password = "su123";

          ConfigCrossServer config = new ConfigCrossServer();
          client.SetConfigCrossServer(config);

          Console.WriteLine("Done");
        }
    }
}
