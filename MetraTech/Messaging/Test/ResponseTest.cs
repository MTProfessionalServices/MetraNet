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
  // S:\Thirdparty\NUnit260\bin\nunit-console-x86.exe o:\debug\Bin\MetraTech.Messaging.Test.dll /run MetraTech.Messaging.Test.ResponseTest
  //

  [TestClass]
  [ComVisible(false)]
  public class ResponseTest
  {
    [TestMethod()]
    public void TestConstructor()
    {
      Response r = new Response();
 
      //string host = System.Net.Dns.GetHostName(); 
      //Console.Write(System.Net.Dns.GetHostName());

    }

    [TestMethod()]
    public void TestConstructor2()
    {
      Guid g = Guid.NewGuid();
      Response r = new Response(g);
      Assert.AreEqual(g, r.CorrelationId, "Correlation Id");
    }

    [TestMethod()]
    public void TestConstructor3()
    {
      Guid g = Guid.NewGuid();
      Request request = new Request();
      request.CorrelationId = g;
      request.MessageType = "TestMessageType";
      request.IsTimeoutNeeded = true;
      Response response = new Response(request);
      Assert.AreEqual(g, response.CorrelationId, "Correlation Id");
    }

    [TestMethod()]
    public void TestOriginalRequest()
    {
      Guid g = Guid.NewGuid();
      Response response = new Response();
      response.CorrelationId = g;
      Request request = new Request();
      request.CorrelationId = g;
      request.MessageType = "TestMessageType";
      request.IsTimeoutNeeded = true;
      response.OriginalRequest = request;
      Request savedRequest = response.OriginalRequest;
      Assert.AreEqual(request.CorrelationId, savedRequest.CorrelationId, "Correlation Id");
      Assert.AreEqual(request.IsTimeoutNeeded, savedRequest.IsTimeoutNeeded, "IsTimeoutNeeded");
      Assert.AreEqual(request.MessageType, savedRequest.MessageType, "MessageType");
      Assert.AreEqual(request.GetRequestBodyAsString(), savedRequest.GetRequestBodyAsString(), "Body");
    }

    [TestMethod()]
    public void TestOriginalRequestRedefine()
    {
      Guid g = Guid.NewGuid();
      Response response = new Response();
      response.CorrelationId = g;
      Request request = new Request();
      request.CorrelationId = g;
      request.MessageType = "TestMessageType";
      request.SetRequestBodyAsXml("abc");
      request.IsTimeoutNeeded = true;
      response.OriginalRequest = request;
      request.MessageType = "NewTestMessageType";
      response.OriginalRequest = request;
      Request savedRequest = response.OriginalRequest;
      Assert.AreEqual(request.CorrelationId, savedRequest.CorrelationId, "Correlation Id");
      Assert.AreEqual(request.IsTimeoutNeeded, savedRequest.IsTimeoutNeeded, "IsTimeoutNeeded");
      Assert.AreEqual(request.MessageType, savedRequest.MessageType, "MessageType");
      Assert.AreEqual(request.GetRequestBodyAsString(), savedRequest.GetRequestBodyAsString(), "Body");
    }
    
    [TestMethod()]
    public void TestMessageType()
    {
      Response r = new Response();
      string msgType = "TestMessageType";
      r.MessageType = msgType;
      Assert.AreEqual(msgType, r.MessageType, "Message Type does not match");
    }

    [TestMethod()]
    public void TestCode()
    {
      Response r = new Response();
      string code = "Success";
      r.Code = code;
      Assert.AreEqual(code, r.Code, "Code does not match");
    }

    [TestMethod()]
    public void TestTimeoutResponse()
    {
      Guid g = Guid.NewGuid();
      Request request = new Request();
      request.CorrelationId = g;
      request.MessageType = "TestMessageType";
      request.IsTimeoutNeeded = true;
      Response response = Response.CreateTimeoutResponse(request);

      Assert.AreEqual(request.CorrelationId, response.CorrelationId, "Correlation Id");
      Assert.AreEqual("Timeout", response.Code, "Code");
      Assert.AreEqual("TestMessageTypeResponse", response.MessageType, "Response MessageType");
      Assert.AreEqual(request.IsTimeoutNeeded, response.OriginalRequest.IsTimeoutNeeded, "IsTimeoutNeeded");
      Assert.AreEqual(request.MessageType, response.OriginalRequest.MessageType, "Request MessageType");
      Assert.AreEqual(request.GetRequestBodyAsString(), response.OriginalRequest.GetRequestBodyAsString(), "Body");
    }


    [TestMethod()]
    public void TestResponseBodyAsString()
    {
      Response r = new Response();
      string[] bodies = new string[] { "<nicebody />", "123" };
      foreach (string body in bodies)
      {
        //string body = "<nicebody />";
        r.SetResponseBodyAsString(body);
        string body2 = r.GetResponseBodyAsString();
        Assert.AreEqual(body, body2, "Response Body");
      }
    }

    [TestMethod()]
    public void TestResponseBodyAsXml()
    {
      Response r = new Response();
      string[] bodies = new string[] { "<nicebody />", "123" };
      foreach (string body in bodies)
      {
        //string body = "<nicebody />";
        r.SetResponseBodyAsXml(body);
        string body2 = r.GetResponseBodyAsXml();
        Assert.AreEqual(body, body2, "Response Body");
      }
    }


  }
}
