using System;
using System.Collections.Generic;
using System.Runtime.Serialization;

namespace MetraTech.Domain.Notifications
{
  [Serializable]
  public class EmailTemplateDictionary : Dictionary<string, LocalizedEmailTemplate>
  {
    public EmailTemplateDictionary()
    {
    }

    protected EmailTemplateDictionary(SerializationInfo info, StreamingContext context)
      : base(info, context)
    {
    }
  }
}
