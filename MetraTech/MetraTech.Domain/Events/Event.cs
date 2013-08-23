using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.Serialization;
using System.Xml.Linq;

namespace MetraTech.Domain.Events
{
  [DataContract(Namespace = "MetraTech.MetraNet")]
  [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Naming", "CA1716:IdentifiersShouldNotMatchKeywords", MessageId = "Event")]
  public class Event
  {
    public XElement Serialize(IEnumerable<Type> knownTypes)
    {
      var xs = new DataContractSerializer(typeof(Event), knownTypes);

      using (var ms = new MemoryStream())
      {
        xs.WriteObject(ms, this);
        ms.Position = 0;
        return XElement.Load(ms);
      }
    }
  }
}
