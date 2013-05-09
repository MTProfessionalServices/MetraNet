using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using RabbitMQ.Client;

namespace RequestResponseTest
{
  public class Configuration
  {
    public string VirtualHostName = "MetraTech";

    public string RequestHostName = "10.200.34.39";
    public string RequestQueueName = "IncreaseBalanceRequestQueue";
    public string ReplyQueueName = "IncreaseBalanceResponseQueue";

    public string RequestMessageTimeoutExchangeName = "Dead_Letter";
    public string RequestMessageTimeoutRoutingKey = "TimeoutRequest";
    public int RequestMessageTimeoutInSeconds = 60;

    public string SystemEventHostName = "10.200.34.39";
    public string SystemEventExchangeName = "SystemEvents";
    
    public bool AutomaticallyAcknowledgeRetrievedMessages = true;

    public string ManagementUserName = "guest";
    public string ManagementPassword = "guest";
    public string ManagementHostName = "localhost"; //May need more than one once we get to federated/cluster
    public int ManagementPort = 55672;

  }


}
