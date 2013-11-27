using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Messages
{
  public class Simulator
  {
    public static void ProcessIncreaseBalanceRequest(IncreaseBalanceRequestMessage request, IncreaseBalanceResponseMessage response)
    {
      Console.WriteLine("Processing Increase Balance Request for AccountId {0} Amount: {1} {2}", request.AccountId, request.Amount, request.AmountCurrency);

      response.OriginalRequest = request;

      response.ResponseSuccess = true;
      response.BalanceIncreasedByAmount = request.Amount;
      response.BalanceIncreasedByAmountCurrency = request.AmountCurrency;

      return;
    }
  }
}
