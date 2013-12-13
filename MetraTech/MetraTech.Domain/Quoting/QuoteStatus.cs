using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Quoting
{
    [DataContract]
    [Serializable]
    public enum QuoteStatus
    {
        [EnumMember]
        None = 0,
        [EnumMember]
        InProgress = 1,
        [EnumMember]
        Failed = 2,
        [EnumMember]
        Complete = 3
    };

    [DataContract]
    [Serializable]
    public enum ActionStatus
    {
      [EnumMember]
      None = 0,
      [EnumMember]
      StatusReport = 1,
      [EnumMember]
      StatusCleanup = 2
    };
}
