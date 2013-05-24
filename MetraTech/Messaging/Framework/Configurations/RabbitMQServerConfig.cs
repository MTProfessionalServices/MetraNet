using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.Messaging.Framework.Configurations
{
  /// <summary>
  /// All options to connect to RabbitMQ Server
  /// </summary>
  public class RabbitMQServerConfig
  {
    public string UserName;
    public string Password;
    public string Address;
    public int Port;
    public bool UseSSL = false;
    public override string ToString()
    {
      string s = string.Format("RabbitMQServerConfig: UserName:{0}, Password:{1}, Address:{2}, Port:{3}, UseSSL:{4}",
        UserName,"***",Address,Port,UseSSL);
      return s;
    }
  }
}
