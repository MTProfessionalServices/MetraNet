using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  [Serializable]
  public class IncreaseBalanceResponseMessage
  {
    public int Id { get; set; }
    public string TestingMessage { get; set; }
    public bool ResponseSuccess { get; set; }
    public string ResponseErrorCode { get; set; } //For now, assume there might be an indication as to why the balance couldn't be increased

    //A couple of dummy fields to simulate what might be set by the processor
    public int AccountId { get; set; }
    public decimal BalanceIncreasedByAmount { get; set; }
    public string BalanceIncreasedByAmountCurrency { get; set; }


    //For now, just make the original request part of the response
    public IncreaseBalanceRequestMessage OriginalRequest { get; set; }

    public override string ToString()
    {
      return string.Format("Id: {0} TestingMessage: '{1}' Success:{2} BalanceIncreasedBy: {3}{4}", Id, TestingMessage, ResponseSuccess, BalanceIncreasedByAmount, BalanceIncreasedByAmountCurrency);
    }
  }
    
}





