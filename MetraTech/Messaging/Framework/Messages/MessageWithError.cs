using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using RabbitMQ.Client;
using RabbitMQ.Client.Events;


namespace MetraTech.Messaging.Framework.Messages
{
  public class MessageWithError
  {
    public string Error {get; set;}
    public string Message {get; set;}

    public const string ErrorQueueMessageBody = @"
        <MessageWithError>
         <Error><![CDATA[{0}]]></Error>
         <Message><![CDATA[{1}]]></Message>
        </MessageWithError>";


    

    public MessageWithError()
    {
    }

    public MessageWithError(string error, string message)
    {
    }

    public string Body
    {
      get { return String.Format(ErrorQueueMessageBody, Error, Message); }
    }

    public static implicit operator byte[](MessageWithError errorMessage)
    {
      return System.Text.Encoding.UTF8.GetBytes(errorMessage.Body);
    }
  }
}
