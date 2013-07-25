using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class Quantity
  {
    [DataMember]
    public string UnitOfMeasure { get; set; }
    [DataMember]
    public Decimal Amount { get; set; }

    public Quantity(Decimal amount, string unitOfMeasure)
    {
      Amount = amount;
      UnitOfMeasure = unitOfMeasure;
    }
  }
}
