using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Events
{
  [DataContract(Namespace="MetraTech.MetraNet")]
  public class ThresholdCrossingEvent : Event
  {
    [DataMember]
    public Quantity UsageQuantityForPriorTier { get; set; }
    [DataMember]
    public Money PriceForPriorTier { get; set; }
    [DataMember]
    public Quantity UsageQuantityForNextTier { get; set; }
    [DataMember]
    public Money PriceForNextTier { get; set; }
    [DataMember]
    public Quantity CurrentUsageQuantity { get; set; }
    [DataMember]
    public DateTime ThresholdPeriodStart { get; set; }
    [DataMember]
    public DateTime ThresholdPeriodEnd { get; set; }
    [DataMember]
    public Guid SubscriptionId { get; set; }
  }
}
