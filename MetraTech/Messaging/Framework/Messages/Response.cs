using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;


namespace MetraTech.Messaging.Framework.Messages
{
  public class Response : Message
  {
    public Response()
    {
      MessageBody = @"
<Response>
 <MessageType></MessageType>
 <Code></Code>
 <Body></Body>
</Response>";
    }

    public Response(Request originalRequest) :this(originalRequest.CorrelationId)
    {
      OriginalRequest = originalRequest;
    }

    public Response(Guid correlationId) : this()
    {
      CorrelationId = correlationId;
    }

    private XmlNode mResponseNode = null;
    private XmlNode mMessageTypeNode = null;
    private XmlNode mCodeNode = null;
    private XmlNode mBodyNode = null;
    private XmlNode mOriginalRequestNode = null;

    protected override void ParseMessageBody(string value)
    {
      base.ParseMessageBody(value);
      mResponseNode = mBodyDoc.SelectSingleNode("/Response");
      if (mResponseNode == null)
        throw new Exception("Invalid Response - Response tag must be root tag");
      mMessageTypeNode = mResponseNode.SelectSingleNode("MessageType");
      if (mMessageTypeNode == null)
        throw new Exception("Invalid Response - MessageType tag is missing");
      mCodeNode = mResponseNode.SelectSingleNode("Code");
      if (mCodeNode == null)
        throw new Exception("Invalid Response - Code tag is missing");
      mBodyNode = mResponseNode.SelectSingleNode("Body");
      if (mBodyNode == null)
        throw new Exception("Invalid Response - Body tag is missing");
      mOriginalRequestNode = mResponseNode.SelectSingleNode("OriginalRequest");
    }

    public void SetResponseBodyAsString(string body)
    {
      mBodyNode.InnerXml = "";
      mBodyNode.InnerText = body;
    }

    public string GetResponseBodyAsString()
    {
      return mBodyNode.InnerText;
    }

    public void SetResponseBodyAsXml(string body)
    {
      mBodyNode.InnerXml = body;
    }

    public string GetResponseBodyAsXml()
    {
      return mBodyNode.InnerXml;
    }

    public string MessageType
    {
      get
      {
        return mMessageTypeNode.InnerText;
      }
      set
      {
        mMessageTypeNode.InnerText = value;
      }
    }

    public string Code
    {
      get
      {
        return mCodeNode.InnerText;
      }
      set
      {
        mCodeNode.InnerText = value;
      }
    }

    public Request OriginalRequest {
      get
      {
        if (mOriginalRequestNode == null) return null;
        string xmlRequest = mOriginalRequestNode.InnerXml;
        Request request = new Request();
        request.CorrelationId = CorrelationId;
        request.MessageBody = xmlRequest;
        return request;
      } 

      set {
        // THis check is only valuable in debugging, but still worth having.
        if (value.CorrelationId != CorrelationId)
        {
          string msg = string.Format("Unable to assign original request. Response guid is different from original Request guid. {0}, {1}",
            CorrelationId, value.CorrelationId);
          throw new Exception(msg);
        }
        if (mOriginalRequestNode == null)
        {
          // Create Original Request Node
          //Create a new node.
          XmlElement elem = mBodyDoc.CreateElement("OriginalRequest");
          elem.InnerXml = value.MessageBody;
          //Add the node to the document.
          mResponseNode.AppendChild(elem);
          //remember the node
          mOriginalRequestNode = mResponseNode.SelectSingleNode("OriginalRequest");
        }
        else
        {
          mOriginalRequestNode.InnerXml = value.MessageBody;
        }
      } 
    }

    public static Response CreateTimeoutResponse(Request request)
    {
      Response response = new Response(request);
      response.Code = "Timeout";
      response.MessageType = request.MessageType + "Response";
      return response;
    }

    public const string ResponseWithErrorMessageBody = @"
      <Response>
       <MessageType></MessageType>
       <Code>Failure</Code>
       <Error><![CDATA[{0}]]></Error>
       <Body><![CDATA[{1}]]></Body>
      </Response>";

    public static byte[] CreateErrorResponseAsByteArray(string errorMessage, byte[] originalMessageWithError)
    {
      string responseErrorMessage = string.Format(ResponseWithErrorMessageBody, errorMessage, System.Text.Encoding.UTF8.GetString(originalMessageWithError));
      return System.Text.Encoding.UTF8.GetBytes(responseErrorMessage);
    }
  }
}
