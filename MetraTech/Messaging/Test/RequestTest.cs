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
  // S:\Thirdparty\NUnit260\bin\nunit-console-x86.exe o:\debug\Bin\MetraTech.Messaging.Test.dll /run MetraTech.Messaging.Test.RequestTest
  //

  [TestClass]
  [ComVisible(false)]
  public class RequestTest
  {
    [TestMethod()]
    public void TestConstructor()
    {
      Request r = new Request();
    }

    [TestMethod()]
    public void TestMessageType()
    {
      Request r = new Request();
      string msgType = "TestMessageType";
      r.MessageType = msgType;
      Assert.AreEqual(msgType, r.MessageType, "Message Type does not match");
    }

    [TestMethod()]
    public void TestRequestBodyAsString()
    {
      Request r = new Request();
      string [] bodies = new string[] {"<nicebody />", "123"};
      foreach (string body in bodies)
      {
        //string body = "<nicebody />";
        r.SetRequestBodyAsString(body);
        string body2 = r.GetRequestBodyAsString();
        Assert.AreEqual(body, body2, "Request Body");
      }
    }

    [TestMethod()]
    public void TestRequestBodyAsXml()
    {
      Request r = new Request();
      string[] bodies = new string[] { "<nicebody />", "123" };
      foreach (string body in bodies)
      {
        //string body = "<nicebody />";
        r.SetRequestBodyAsXml(body);
        string body2 = r.GetRequestBodyAsXml();
        Assert.AreEqual(body, body2, "Request Body");
      }
    }

    [TestMethod()]
    public void TestIsTimeoutNeeded()
    {
      Request r = new Request();
      Assert.IsTrue(r.IsTimeoutNeeded, "timeout should be needed by default");
      r.IsTimeoutNeeded = false;
      Assert.IsTrue(r.IsTimeoutNeeded == false, "timeout was set to false");
      r.IsTimeoutNeeded = true;
      Assert.IsTrue(r.IsTimeoutNeeded, "timeout was set to true");
    }

  }
}
