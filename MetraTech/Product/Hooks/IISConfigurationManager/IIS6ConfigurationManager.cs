using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.DirectoryServices;

namespace ICEUtils
{
  class IIS6ConfigurationManager : IIISConfigurationManager
  {
    #region Constants
    public const string METRANET_SYSTEM_APP_POOL = "MetraNetSystemAppPool";
    public const string METRANET_USER_APP_POOL = "MetraNetUserAppPool";
    #endregion

    #region Private Members
    private System.DirectoryServices.DirectoryEntry GetAdminEntry(string serverName)
    {
      System.DirectoryServices.DirectoryEntry iISAdmin = null;

      System.DirectoryServices.DirectoryEntry iISSchema = new System.DirectoryServices.DirectoryEntry("IIS://" + serverName + "/Schema/AppIsolated");
      bool bCanCreate = !(iISSchema.Properties["Syntax"].Value.ToString().ToUpper() == "BOOLEAN");
      iISSchema.Dispose();

      if (bCanCreate)
      {
        try
        {
          iISAdmin = new System.DirectoryServices.DirectoryEntry("IIS://" + serverName + "/W3SVC/1/Root");
        }
        catch
        {
          return null;
        }
      }

      return iISAdmin;
    }

    #endregion

    #region IIISConfigurationManager Members

    public void AddWebApp(string appName, string fullPath, string appPool)
    {
      System.DirectoryServices.DirectoryEntry iisAdmin = GetAdminEntry("localhost");

      if (iisAdmin != null)
      {
        System.DirectoryServices.DirectoryEntry vdir = iisAdmin.Children.Add(appName, "IIsWebVirtualDir");

        vdir.Properties["Path"][0] = fullPath;
        vdir.Properties["AppFriendlyName"][0] = appName;
        vdir.Properties["EnableDirBrowsing"][0] = false;
        vdir.Properties["AccessRead"][0] = true;
        vdir.Properties["AccessExecute"][0] = false;
        vdir.Properties["AccessWrite"][0] = false;
        vdir.Properties["AccessScript"][0] = true;
        vdir.Properties["AuthNTLM"][0] = true;
        vdir.Properties["EnableDefaultDoc"][0] = true;
        vdir.Properties["DefaultDoc"][0] = "default.htm,default.aspx,default.asp";
        vdir.Properties["AspEnableParentPaths"][0] = true;
        vdir.CommitChanges();

        //'the following are acceptable params
        //'INPROC = 0
        //'OUTPROC = 1
        //'POOLED = 2
        //vdir.Invoke("AppCreate", 1);

        object[] param = { 0, appPool, true };
        vdir.Invoke("AppCreate3", param);

        //Not sure why but AppFriendlyName set beforehand (above) does not seem to 'stick'; resetting it after creation works for Windows Server 2003
        vdir.Properties["AppFriendlyName"].Value = appName;
        vdir.CommitChanges();
      }
    }

    public void RemoveWebApp(string appName)
    {
      System.DirectoryServices.DirectoryEntry iisAdmin = GetAdminEntry("localhost");

      if (iisAdmin != null)
      {
        //If the virtual directory already exists then delete it
        foreach (System.DirectoryServices.DirectoryEntry vd in iisAdmin.Children)
        {
          if (vd.Name == appName)
          {
            iisAdmin.Invoke("Delete", new string[] { vd.SchemaClassName, appName });
            iisAdmin.CommitChanges();
            break;
          }
        }
      }
    }

    public bool WebAppExists(string appName)
    {
      System.DirectoryServices.DirectoryEntry iisAdmin = GetAdminEntry("localhost");

      if (iisAdmin != null)
      {
        foreach (System.DirectoryServices.DirectoryEntry vd in iisAdmin.Children)
        {
          if (vd.Name == appName)
            return true;
        }
      }
      else
      {
        throw new Exception("Unable to retrieve System.DirectoryServices.DirectoryEntry");
      }

      return false;
    }

    #endregion
  }
}

#region Additional code for application pools that might be useful in the future
//using System;
//using System.Collections;
//using System.Collections.Generic;
//using System.Text;
//using System.DirectoryServices;
//using System.DirectoryServices.ActiveDirectory;
//using System.IO;
//using System.Diagnostics;
//using IISOle; // IISOle requires a reference to the Active Directory Services.
//using System.Reflection;
//using System.Configuration;
//using System.Text.RegularExpressions;

//Functions

//public static bool RecycleAppPool(string serverName, string adminUsername, string adminPassword, string appPoolName)
//        {
//            DirectoryEntry appPools = new DirectoryEntry("IIS://" + serverName + "/w3svc/apppools", adminUsername, adminPassword);
//            bool status = false;
//            foreach (DirectoryEntry AppPool in appPools.Children)
//            {
//                if (appPoolName.Equals(AppPool.Name, StringComparison.OrdinalIgnoreCase))
//                {
//                    AppPool.Invoke("Recycle", null);
//                    status = true;
//                    break;
//                }
//            }
//            appPools = null;
//            return status;
//        }

 

///// <summary>
//        /// Creates AppPool
//        /// </summary>
//        /// <param name="metabasePath"></param>
//        /// <param name="appPoolName"></param>
//        public static bool CreateAppPool(string metabasePath, string appPoolName)
//        {
//            //  metabasePath is of the form "IIS://<servername>/W3SVC/AppPools"
//            //    for example "IIS://localhost/W3SVC/AppPools"
//            //  appPoolName is of the form "<name>", for example, "MyAppPool"
//            DirectoryEntry newpool, apppools;
//            try
//            {
//                if (metabasePath.EndsWith("/W3SVC/AppPools"))
//                {
//                    apppools = new DirectoryEntry(metabasePath);
//                    newpool = apppools.Children.Add(appPoolName, "IIsApplicationPool");
//                    newpool.CommitChanges();
//                    newpool = null;
//                    apppools = null;
//                    return true;
//                }
//                else
//                    throw new Exception(" Failed in CreateAppPool; application pools can only be created in the */W3SVC/AppPools node.");               
//            }
//            catch (Exception ex)
//            {
//                throw new Exception(string.Format("Failed in CreateAppPool with the following exception: \n{0}", ex.Message));
//            }
//            finally
//            {
//                newpool = null;
//                apppools = null;
//            }
//        }

//        /// <summary>
//        /// Assigns AppPool to Virtual Directory
//        /// </summary>
//        /// <param name="metabasePath"></param>
//        /// <param name="appPoolName"></param>
//        public static bool AssignVDirToAppPool(string metabasePath, string appPoolName)
//        {
//            //  metabasePath is of the form "IIS://<servername>/W3SVC/<siteID>/Root[/<vDir>]"
//            //    for example "IIS://localhost/W3SVC/1/Root/MyVDir"
//            //  appPoolName is of the form "<name>", for example, "MyAppPool"
//            //Console.WriteLine("\nAssigning application {0} to the application pool named {1}:", metabasePath, appPoolName);

//            DirectoryEntry vDir = new DirectoryEntry(metabasePath);
//            string className = vDir.SchemaClassName.ToString();
//            if (className.EndsWith("VirtualDir"))
//            {
//                object[] param = { 0, appPoolName, true };
//                vDir.Invoke("AppCreate3", param);
//                vDir.Properties["AppIsolated"][0] = "2";
//                vDir = null;
//                return true;
//            }
//            else
//                throw new Exception(" Failed in AssignVDirToAppPool; only virtual directories can be assigned to application pools");
//        }

 

//  /// <summary>
//        /// Delete AppPool
//        /// </summary>
//        /// <param name="metabasePath"></param>
//        /// <param name="appPoolName"></param>
//        public static bool DeleteAppPool(string serverName, string adminUsername, string adminPassword, string appPoolName)
//        {
//            //  metabasePath is of the form "IIS://<servername>/W3SVC/AppPools"
//            //  for example "IIS://localhost/W3SVC/AppPools"
//            //  appPoolName is of the form "<name>", for example, "MyAppPool"

//            DirectoryEntry appPools = new DirectoryEntry("IIS://" + serverName + "/w3svc/apppools", adminUsername, adminPassword);
//            bool status = false;
//            foreach (DirectoryEntry AppPool in appPools.Children)
//            {
//                if (appPoolName.Equals(AppPool.Name, StringComparison.OrdinalIgnoreCase))
//                {
//                    AppPool.DeleteTree();
//                    status = true;
//                    break;
//                }
//            }
//            appPools = null;
//            return status;
//        }
#endregion

