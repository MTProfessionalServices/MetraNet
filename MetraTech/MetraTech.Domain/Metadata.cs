using System;
using System.Runtime.Serialization;

namespace MetraTech.Domain
{
  /// <summary>
  /// Keeps the system metadata on the certain date.
  /// </summary>
  [DataContract(Namespace = "MetraTech.MetraNet")]
  public class Metadata
  {
    /// <summary>
    /// Date on which the item was originally created
    /// </summary>
    public DateTime TimeCreate { get; set; }

    /// <summary>
    /// Serialized object with metadata.
    /// </summary>
    public String Content { get; set; }
  }
}
