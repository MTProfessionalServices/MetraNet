using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Runtime.InteropServices;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;
using MetraTech.Messaging.Framework;
using MetraTech.Messaging.Framework.Messages;
using MetraTech.Messaging.Framework.Configurations;

namespace MetraTech.Messaging.Test
{
  //
  // To run the this test fixture:
  // S:\Thirdparty\NUnit260\bin\nunit-console-x86.exe o:\debug\Bin\MetraTech.Messaging.Test.dll /run MetraTech.Messaging.Test.ConfigurationTest
  //

  [TestClass]
  [ComVisible(false)]
  public class ConfigurationTest
  {
    [TestMethod()]
    public void TestConfigurationLoading()
    {
      string ConfigFileName = @"R:\config\Messaging\MessagingService.xml";

      Configuration config = ConfigurationManager.ReadFromXml(ConfigFileName);
      Assert.IsNotNull(config.MessageTypeRules);
    }

  }
}
