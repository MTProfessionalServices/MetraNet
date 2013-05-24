using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;


namespace MetraTech.Messaging.Framework.Messages
{
  public class Request : Message
  {
    public Request()
    {
      MessageBody = @"
<Request>
 <MessageType></MessageType>
 <Body></Body>
</Request>";
      CorrelationId = Guid.NewGuid();
      CreateDate = MetraTime.Now;
      SetTimeoutSeconds(30);//user will override timeout, right?
      IsTimeoutNeeded = true;
    }

    private XmlNode mRequestNode = null;
    private XmlNode mMessageTypeNode = null;
    private XmlNode mBodyNode = null;

    public override void Parse(BasicDeliverEventArgs ea)
    {
      base.Parse(ea);

      this.ReplyToAddress = ea.BasicProperties.ReplyTo;
    }

    protected override void ParseMessageBody(string value)
    {
      base.ParseMessageBody(value);
      mRequestNode = mBodyDoc.SelectSingleNode("/Request");
      if (mRequestNode == null) 
        throw new Exception("Invalid Request - Request tag must be root tag");
      mMessageTypeNode = mRequestNode.SelectSingleNode("MessageType");
      if (mMessageTypeNode == null) 
        throw new Exception("Invalid Request - MessageType tag is missing");
      mBodyNode = mRequestNode.SelectSingleNode("Body");
      if (mBodyNode == null) 
        throw new Exception("Invalid Request - Body tag is missing");
    }

    public void SetRequestBodyAsString(string body)
    {
      mBodyNode.InnerXml = "";
      mBodyNode.InnerText = body;
    }

    public string GetRequestBodyAsString()
    {
      return mBodyNode.InnerText;
    }

    public void SetRequestBodyAsXml(string body)
    {
      mBodyNode.InnerXml = body;
    }

    public string GetRequestBodyAsXml()
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
    public DateTime CreateDate { get; set; }
    public DateTime TimeoutDate { get; set; }
    public void SetTimeoutSeconds(int seconds)
    {
      TimeoutDate = CreateDate.AddSeconds(seconds);
    }

    private bool IsTimeoutNeededDefault = true;
    public bool IsTimeoutNeeded { 
      get {
        XmlAttribute timeoutAttribute = mRequestNode.Attributes["IsTimeoutNeeded"];
        if (timeoutAttribute == null) return IsTimeoutNeededDefault;
        else
        {
          bool b;
          if (Boolean.TryParse(timeoutAttribute.Value, out b)) return b;
          else throw new Exception(string.Format("Unable to read IsTimeoutNeeded attribute. {0} is not in boolean format", timeoutAttribute.Value));
        }
      }

      set {
        if (IsTimeoutNeeded != value)
        {
          XmlAttribute timeoutAttribute = mRequestNode.Attributes["IsTimeoutNeeded"];
          if (timeoutAttribute != null) timeoutAttribute.Value = value.ToString();
          else
          {
            XmlAttribute t = mBodyDoc.CreateAttribute("IsTimeoutNeeded");
            t.Value = value.ToString();
            mRequestNode.Attributes.Append(t);
          }
        }
      }
    }
    public string ReplyToAddress { get; set; }

  }
}
