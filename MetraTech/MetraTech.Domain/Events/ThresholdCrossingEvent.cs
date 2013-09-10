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
    [DataMember]
    public Account Account { get; set; }
  }

  /// <summary>
  /// This should really be the Domain Account class
  /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class Account : Event
  {
      [DataMember]
      public string EmailAddress { get; set; }
      [DataMember]
      public string LanguageCode { get; set; }
  }
}
