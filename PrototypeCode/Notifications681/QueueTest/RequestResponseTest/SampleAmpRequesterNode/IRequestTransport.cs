using System;
namespace RequestResponseTest
{
  interface IRequestTransport
  {
    void Connect(string hostName, RequestResponseTest.Configuration configuration);

    void SendMessage<T>(T message);
    void SendMessage<T>(T message, string replyTo);

    void Disconnect();
  }
}
