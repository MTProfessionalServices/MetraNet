using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;

namespace MetraTech.Messaging.Framework.Messages
{
  public class Message
  {
    protected XmlDocument mBodyDoc = new XmlDocument();
    public Guid CorrelationId { get; set; }
    public string MessageBody
    {
      get { return mBodyDoc.OuterXml; }
      set {
        ParseMessageBody(value);
      }
    }

    protected virtual void ParseMessageBody(string value)
    {
      try
      {
        mBodyDoc.LoadXml(value);
      }
      catch (Exception ex)
      {
        string msg = string.Format("Message body is not a valid xml string: [{0}]", value);
        throw new Exception(msg, ex);
      }
    }

    public Message()
    {
      //MessageBody = "<root/>";
      CorrelationId = Guid.NewGuid();
    }

    public virtual void Parse(BasicDeliverEventArgs ea)
    {
      if (ea == null) throw new ArgumentNullException("ea", "BasicDeliveryEventArgs must not be null");
      IBasicProperties props = ea.BasicProperties;
      if (props == null) throw new Exception("BasicProperties cannot be null");
      if (!props.IsCorrelationIdPresent()) throw new Exception("Correlation Id must be present");
      Guid parsedCorrelationId;
      if (Guid.TryParse(props.CorrelationId, out parsedCorrelationId))
      {
        CorrelationId = parsedCorrelationId;
      } else 
      {
        throw new Exception(string.Format("Correlation id is not a valid Guid: {0}", props.CorrelationId));
      }
      byte[] body = ea.Body;
      string message = System.Text.Encoding.UTF8.GetString(body);
      MessageBody = message;
      //string root = xmlDoc.SelectNodes("/root")[0].InnerText;
    }
  }

}
