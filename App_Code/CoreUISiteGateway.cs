using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

using MetraTech.ActivityServices.Common;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.Service.ClientProxies;
using MetraTech.UI.Common;
using Core.UI;

/// <summary>
/// Summary description for CoreUISiteGateway
/// </summary>
namespace MetraTech.Core.UI
{
    public static class CoreUISiteGateway
    {
        static private Dictionary<string, string> siteDictionary = null;
        static private MetraTech.Logger logger = null;

        static public void InitializeSiteDictionary()
        {
            siteDictionary = new Dictionary<string, string>(StringComparer.InvariantCultureIgnoreCase); // Make key comparison case insensitive
            Site site = new Site();
            MTList<DataObject> DataObjectList = new MTList<DataObject>();
            RepositoryServiceClient repositoryServiceClient = new RepositoryServiceClient();

            UIManager UI = HttpContext.Current.Session[Constants.UI_MANAGER] as UIManager; // Session information with current user credentials

            // CANNOT use logged in user credentials because that user may not have BME Read capabilities. Must use SuperUser for this
            // repositoryServiceClient.ClientCredentials.UserName.UserName = UI.User.UserName;
            // repositoryServiceClient.ClientCredentials.UserName.Password = UI.User.SessionPassword;
            MetraTech.Interop.MTServerAccess.IMTServerAccessDataSet accessDataSet = new MetraTech.Interop.MTServerAccess.MTServerAccessDataSet();
            accessDataSet.Initialize();
            MetraTech.Interop.MTServerAccess.IMTServerAccessData accessData;
            accessData = accessDataSet.FindAndReturnObject("SuperUser");
            repositoryServiceClient.ClientCredentials.UserName.UserName = accessData.UserName;
            repositoryServiceClient.ClientCredentials.UserName.Password = accessData.Password;

            repositoryServiceClient.LoadInstances(site.GetType().FullName, ref DataObjectList);

            logger.LogInfo("Loading information for {0} sites", DataObjectList.TotalRows);

            foreach (DataObject dataObj in DataObjectList.Items)
            {
                site = (Site)dataObj;
                // logger.LogInfo("Site = {0} - RootURL = {1} - Namespace = {2}", site.SiteBusinessKey.SiteName, site.RootUrl, site.AuthenticationNamespace);
                siteDictionary.Add(site.AuthenticationNamespace, site.SiteBusinessKey.SiteName);
            }
        }

        static public string GetRootURL(string name_space)
        {
            if (logger == null)
            {
                logger = new MetraTech.Logger("[CoreUISiteGateway]");
            }

            // The first time this method is called (dictionary is null), the static dictionary is initialized
            // Also initialize the dictionary if the namespace is not found because it may be a new namespace that was just added
            if (siteDictionary == null || siteDictionary.Count == 0 || !siteDictionary.ContainsKey(name_space))
            {
                InitializeSiteDictionary();
            }

            if (siteDictionary.ContainsKey(name_space))
            {
                return siteDictionary[name_space];
            }
            else
            {
                string info = string.Format("Cannot find Site for namespace '{0}'", name_space);
                logger.LogError(info);
                throw new ApplicationException(info);
            }
        }
    }
}