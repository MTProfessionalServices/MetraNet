using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Quoting
{
  [DataContract]
  [Serializable]
  public enum QuoteStatus
  {
    [EnumMember]
    InProgress,
    [EnumMember]
    Failed,
    [EnumMember]
    Complete
  };
}