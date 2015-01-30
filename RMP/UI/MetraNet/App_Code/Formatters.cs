using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace MetraNet
{
  public class Formatters
  {
    private static IEnumerable<string> _statuses;
    private static IEnumerable<string> _actions;

    /// <summary>
    /// This method is a replica on the method mom_GetAdapterInstanceStatusMessage(string, string) (mom/default/lib/MomLibrary.asp)
    /// </summary>
    /// <param name="statusCode">Adapter's status code</param>
    /// <param name="effectiveDate">Adapter instance effective date</param>
    /// <returns></returns>
    public static string GetAdapterInstanceStatusMessage(string statusCode, DateTime? effectiveDate)
    {
      var statusText = GetAdapterInstanceStatusLocalized(statusCode);

      if (effectiveDate.HasValue)
        statusText = String.Format("{0} after {1}", statusText, effectiveDate.Value.ToLongDateString());
      return statusText;
    }

    /// <summary>
    /// This method is a helper to provide localized name for adapter instance status.
    /// </summary>
    /// <param name="statusCode">Adapter's status code</param>
    /// <returns></returns>
    public static string GetAdapterInstanceStatusLocalized(string statusCode)
    {
      return GetAdapterInstanceStatusesLocalized().ContainsKey(statusCode) ? GetAdapterInstanceStatusesLocalized()[statusCode] : statusCode;
    }

    /// <summary>
    /// This method is a helper to provide a dictionary of localized names for adapter's instance statuses.
    /// </summary>
    /// <returns>Dictionary of localized adapter's status codes</returns>
    public static IDictionary<string,string> GetAdapterInstanceStatusesLocalized()
    {
      if(_statuses == null)
        _statuses = typeof(Resources.Resource).GetProperties().Select(x => x.Name).Where(x => x.Contains("AdapterStatusCode_")).Select(x => x.Replace("AdapterStatusCode_", ""));

      return _statuses.ToDictionary(x => x, x => (string)HttpContext.GetGlobalResourceObject("Resource", "AdapterStatusCode_" + x));
    }

    /// <summary>
    /// This method is a helper to provide a dictionary of localized names for actions on adapter's instance audit.
    /// </summary>
    /// <returns>Dictionary of localized actions on adapter's instance audit</returns>
    public static IDictionary<string, string> GetAdapterInstanceAuditActionsLocalized()
    {
      if (_actions == null)
        _actions = typeof(Resources.Resource).GetProperties().Select(x => x.Name).Where(x => x.Contains("ReceventInstAuditAction_")).Select(x => x.Replace("ReceventInstAuditAction_", ""));

      return _actions.ToDictionary(x => x, x => (string)HttpContext.GetGlobalResourceObject("Resource", "ReceventInstAuditAction_" + x));
    }
  }
}