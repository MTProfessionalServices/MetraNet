using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace MetraTech.Domain
{
  [Serializable]
  public class LocalizationDictionary : Dictionary<string, string>
  {
    public LocalizationDictionary()
    {
    }

    protected LocalizationDictionary(SerializationInfo info, StreamingContext context)
      : base(info, context)
    {
    }
  }
}
