using System;
namespace RequestResponseTest
{
  public interface INotificationsManagement
  {
    void Connect(RequestResponseTest.Configuration configuration);
    void Disconnect();
    System.Collections.Generic.Dictionary<string, string> GetQueueInformation(string queueName);
    System.Collections.Generic.List<string> GetQueues();
    void MoveMessages(string fromQueueName, string toQueueName);
    void MoveMessages(string fromQueueName, string toQueueName, System.Collections.Generic.List<string> messageIdentifiers);
    void PurgeQueue(string queueName);
  }
}
