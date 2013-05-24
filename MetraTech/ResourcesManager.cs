using System;
using System.Linq;
using System.Resources;
using System.Text;
using System.IO;
using System.Collections.Generic;
using System.IO.Compression;
using System.Globalization;
using System.Threading;
using MetraTech.Interop.RCD;

namespace MetraTech
{
 public class ResourcesManager
  {

    #region Public Methods
    /// <summary>
    /// Retrieve the localized resource value for any given resource field.
    /// </summary>
    public string GetLocalizedResource(string resourceField)
    {
      try
      {
        IMTRcd rcd = new MTRcd();
        string resourceFileLocation = Path.Combine(rcd.ConfigDir, @"Localization\Global");
        string resourceValue = String.Empty;
        ResourceManager resourceMgr;

        DirectoryInfo dir = new DirectoryInfo(resourceFileLocation);
        foreach (FileInfo file in dir.GetFiles("*.resx"))
        {
          string[] resourceFileName = file.Name.Split('.');

          if (File.Exists(resourceFileLocation + @"\" + resourceFileName[0] + "." +
                    Thread.CurrentThread.CurrentUICulture.ToString()+".resx"))
            resourceMgr = ResourceManager.CreateFileBasedResourceManager(resourceFileName[0] + "." + Thread.CurrentThread.CurrentUICulture.ToString(), resourceFileLocation, null);
          else
            resourceMgr = ResourceManager.CreateFileBasedResourceManager(resourceFileName[0], resourceFileLocation, null);
          
          resourceValue = resourceMgr.GetString(resourceField, Thread.CurrentThread.CurrentCulture);
          if (!String.IsNullOrEmpty(resourceValue))
          {
            break;
          }
        }
        return resourceValue;
      }
      catch (Exception)
      {
        throw new ApplicationException("Error while retrieving the localized resource.");
      }
     
    }

    #endregion


  }
}
