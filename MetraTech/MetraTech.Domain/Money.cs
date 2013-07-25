using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class Money
  {
    [DataMember]
    public string Currency { get; set; }
    [DataMember]
    public Decimal Amount { get; set; }

    public Money(Decimal amount, string currency)
    {
      Amount = amount;
      Currency = currency;
    }

  }
}
