using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace SampleMetraTechMessaging
{
  public class MetraTechMessage
  {
    public const string BASE_REQUEST = "<Request CreateDate=\"{0}\" NeedsTimeout=\"{1}\"><Type>{2}</Type><Body>{3}</Body></Request>";

    public static string CreateRequestMessage(string messageType, string xmlBody, bool needsTimeout)
    {
      return string.Format(BASE_REQUEST, DateTime.Now.ToUniversalTime().ToString("yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'fff'Z'"), needsTimeout.ToString(), messageType, xmlBody);
    }
  }
}
