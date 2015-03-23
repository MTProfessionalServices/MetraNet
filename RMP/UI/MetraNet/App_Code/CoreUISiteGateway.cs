using System;
using System.Collections.Generic;
using System.Web;
using System.Web.SessionState;
using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;
using Core.UI;
using MetraTech.SecurityFramework;

namespace MetraTech.Core.UI
{
  /// <summary>
  /// 
  /// </summary>
  public static class CoreUISiteGateway
  {
    private static Dictionary<string, string> _siteDictionary;
    private static Logger _logger;

    public static void InitializeSiteDictionary()
    {
      _siteDictionary = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase);
        // Make key comparison case insensitive
      Site site = new Site();
      MTList<DataObject> DataObjectList = new MTList<DataObject>();
      RepositoryServiceClient repositoryServiceClient = new RepositoryServiceClient();

      UIManager UI = HttpContext.Current.Session[Constants.UI_MANAGER] as UIManager;
        // Session information with current user credentials

      // CANNOT use logged in user credentials because that user may not have BME Read capabilities. Must use SuperUser for this
      // repositoryServiceClient.ClientCredentials.UserName.UserName = UI.User.UserName;
      // repositoryServiceClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
      Interop.MTServerAccess.IMTServerAccessDataSet accessDataSet = new Interop.MTServerAccess.MTServerAccessDataSet();
      accessDataSet.Initialize();
      Interop.MTServerAccess.IMTServerAccessData accessData = accessDataSet.FindAndReturnObject("SuperUser");
      if (repositoryServiceClient.ClientCredentials != null)
      {
        repositoryServiceClient.ClientCredentials.UserName.UserName = accessData.UserName;
        repositoryServiceClient.ClientCredentials.UserName.Password = accessData.Password;
      }
      repositoryServiceClient.LoadInstances(site.GetType().FullName, ref DataObjectList);

      _logger.LogInfo("Loading information for {0} sites", DataObjectList.TotalRows);

      foreach (DataObject dataObj in DataObjectList.Items)
      {
        site = (Site) dataObj;
        // logger.LogInfo("Site = {0} - RootURL = {1} - Namespace = {2}", site.SiteBusinessKey.SiteName, site.RootUrl, site.AuthenticationNamespace);
        _siteDictionary.Add(site.AuthenticationNamespace, site.SiteBusinessKey.SiteName);
      }
    }

    public static string GetRootURL(string name_space)
    {
      if (_logger == null)
      {
        _logger = new Logger("[CoreUISiteGateway]");
      }

      // The first time this method is called (dictionary is null), the static dictionary is initialized
      // Also initialize the dictionary if the namespace is not found because it may be a new namespace that was just added
      if (_siteDictionary == null || _siteDictionary.Count == 0 || !_siteDictionary.ContainsKey(name_space))
      {
        InitializeSiteDictionary();
      }

      if (_siteDictionary != null && _siteDictionary.ContainsKey(name_space))
      {
        return _siteDictionary[name_space];
      }

      var info = string.Format("Cannot find Site for namespace '{0}'", name_space);
      _logger.LogError(info);
      throw new ApplicationException(info);
    }

    public static string GetDefaultHelpPage(HttpServerUtility server, HttpSessionState session, string gotoUrl, Logger logger)
    {
      try
      {
        var input = new ApiInput(gotoUrl);
        SecurityKernel.AccessController.Api.ExecuteDefaultByCategory(AccessControllerEngineCategory.UrlController.ToString(), input);
      }
      catch (AccessControllerException accessExp)
      {
        session[Constants.ERROR] = accessExp.Message;
      }
      catch (Exception exp)
      {
        session[Constants.ERROR] = exp.Message;
        throw;
      }

      // Setup help URL - it should have empty page name
      const string helpPage = "/MetraNet/Help.aspx?PageName=";
      logger.LogDebug(string.Format("HelpPage: {0}", helpPage));

      return helpPage;
    }

    public static string GetAspResponse(string helpPage, string url)
    {
      var sb = new MTStringBuilder();
      sb.Append("<script language='javascript'>");
      sb.Append(Environment.NewLine);
      sb.Append("if(typeof window.getFrameMetraNet === 'function'){");
      sb.Append(Environment.NewLine);
      sb.Append("window.getFrameMetraNet().helpPage = '" + helpPage + "';");
      sb.Append(Environment.NewLine);
      sb.Append("}");
      sb.Append(Environment.NewLine);
      sb.Append("window.location.href = '" + url + "';");
      sb.Append("</script>");
      return sb.ToString();
    }
  }
}