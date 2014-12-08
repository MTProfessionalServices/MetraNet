using System;

namespace MetraNet
{
  public class Formatters
  {
    /// <summary>
    /// This method is a replica on the method mom_GetAdapterInstanceStatusMessage(string, string) (mom/default/lib/MomLibrary.asp)
    /// </summary>
    /// <param name="statusCode">Adapter's status code</param>
    /// <param name="effectiveDate">Adapter instance effective date</param>
    /// <returns></returns>
    public static string GetAdapterInstanceStatusMessage(string statusCode, DateTime? effectiveDate)
    {
      var statusText = "";
      switch (statusCode)
      {
        case "ReadyToRun":
          statusText = Resources.Resource.AdapterStatusCode_ReadyToRun;
          break;
        case "ReadyToReverse":
          statusText = Resources.Resource.AdapterStatusCode_ReadyToReverse;
          break;
        case "NotYetRun":
          statusText = Resources.Resource.AdapterStatusCode_NotYetRun;
          break;
        default:
          statusText = statusCode;
          break;
      }

      if (effectiveDate.HasValue)
        statusText = String.Format("{0} after {1}", statusText, effectiveDate.Value.ToLongDateString());
      return statusText;
    }
 
  }
}