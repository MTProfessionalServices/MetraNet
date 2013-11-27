using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  public enum RequestTimeoutType
	{
	  Unknown = 0,
    NotDelivered = 1,
    StartedProcessingButResponseUnknown =2     
	}


  [Serializable]
  public class IncreaseBalanceTimeoutMessage
  {
    public int Id { get; set; }
    public string TestingMessage { get; set; }

    public RequestTimeoutType TimeoutType { get; set; }


    //For now, just make the original request part of the response
    public IncreaseBalanceRequestMessage OriginalRequest { get; set; }

    public override string ToString()
    {
      return string.Format("Id: {0} TestingMessage: '{1}' ", Id, TestingMessage);
    }
  }
    
}





