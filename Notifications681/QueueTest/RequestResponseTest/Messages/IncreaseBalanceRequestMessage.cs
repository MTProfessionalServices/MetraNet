using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  [Serializable]
  public class IncreaseBalanceRequestMessage
  {
    
    public int Id { get; set; }
    public string TestingMessage { get; set; }
    public SimulatorDesiredOutcome DesiredTestingOutcome { get; set; }

    //Sample properties assumed to be needed by payment processor
    public int AccountId { get; set; }
    public decimal Amount { get; set; }
    public string AmountCurrency { get; set; }

    //Sample properties assumed to be needed by requester/amp
    public string AmpNodeId { get; set; }
    public int AmpPropertyOne { get; set; }
    public string AmpPropertyTwo { get; set; }

    public override string ToString()
    {
      return string.Format("Id: {0} TestingMessage: '{1}' AccountId: {2} Amount: {3} {4}", Id, TestingMessage, AccountId, Amount, AmountCurrency);
    }
  }
}
