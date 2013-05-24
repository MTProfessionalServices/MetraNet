using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;
using MetraTech.ActivityServices.Common;
using System.IO;
using MetraTech.Basic.Config;
using MetraTech.Xml;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;

namespace MetraTech.Approvals
{
  public class ChangeTypeConfiguration
  {
    public string Name { get; set; }

    [XmlIgnoreAttribute]
    public string Extension { get; set; } //Not important to framework but important to ICE

    [XmlElement(IsNullable = true)]
    public string Description { get; set; } //Not important to framework but important to ICE

    public bool Enabled { get; set; }
    public bool AllowMoreThanOnePendingChange { get; set; }
    public string CapabilityRequiredForApproveOrDeny { get; set; }
    public string CapabilityRequiredToBypassApprovalProcess { get; set; }

    public MethodConfiguration MethodForApply { get; set; }
    public MethodConfiguration MethodForSubmit { get; set; }
    public MethodConfiguration MethodForDeny { get; set; }

    public WebPageConfiguration WebpageForView { get; set; }
    public WebPageConfiguration WebpageForEdit { get; set; }

    [XmlIgnoreAttribute]
    public Dictionary<string, string> LocalizedDisplayNames { get; set; }

    [XmlIgnoreAttribute]
    public string ConfigFilePath { get; set; }
  }

  public class MethodConfiguration
  {
    public string Name { get; set; }
    public string ClientProxyType { get; set; }
    public string ConfigFileLocation { get; set; }
    public string EndPointName { get; set; }

    public string Assembly { get; set; }
    public string Classname { get; set; }
  }

  public class MethodConfigurationManager
  {
    public static string GetFullPathToWebServiceConfigFile(string configFileLocation)
    {
      string configFileFullPath = configFileLocation;
      if (!Path.IsPathRooted(configFileFullPath))
        configFileFullPath = Path.Combine(SystemConfig.GetRmpDir(), configFileLocation);
      return configFileFullPath;
    }

    public static void Validate(MethodConfiguration methodConfiguration)
    {

    }
  }

  public class WebPageConfiguration
  {
    public string URL { get; set; }
  }

  public class ApprovalsConfiguration : Dictionary<string, ChangeTypeConfiguration>
  {
    protected internal List<string> filesLoaded = new List<string>();

    public List<string> FilesLoaded
    {
      get { return filesLoaded; }
    }

    public ChangeTypeConfiguration GetChangeTypeConfiguration(string changeTypeName)
    {
      try
      {
        return this[changeTypeName];
      }
      catch (Exception)
      {
        throw new MASBasicException(string.Format("The change type of '{0}' is invalid/unconfigured", changeTypeName));
      }
    }

    protected bool? approvalsEnabled = null;
    protected Object approvalsEnabledLock = new Object();

    public bool ApprovalsEnabled
    {
      get
      {
        if (approvalsEnabled == null)
        {
          lock (approvalsEnabledLock)
          {
            if (approvalsEnabled == null)
            {
              foreach (ChangeTypeConfiguration changeType in this.Values)
              {
                if (changeType.Enabled)
                {
                  approvalsEnabled = true;
                  break;
                }
              }
              if (approvalsEnabled == null)
                approvalsEnabled = false;
            }
          }
        }
        return (approvalsEnabled == true);
      }
    }
  }

  public class ApprovalsConfigurationManager
  {
    public static ApprovalsConfiguration Load()
    {
      return LoadChangeTypesFromAllExtensions();
    }

    public static ApprovalsConfiguration LoadDummyConfiguration()
    {
      ApprovalsConfiguration results = new ApprovalsConfiguration();

      //Fake the loading for now

      //Rate Update
      ChangeTypeConfiguration rateUpdate = new ChangeTypeConfiguration()
                                             {
                                               Name = "RateUpdate",
                                               Enabled = true,
                                               AllowMoreThanOnePendingChange = false,
                                               CapabilityRequiredForApproveOrDeny = "Approve RateUpdates"
                                             };
      MethodConfiguration rateUpdateHandler = new MethodConfiguration()
                                                {
                                                  Assembly = "MetraTech.Approvals.dll",
                                                  Classname = "MetraTech.Approvals.ChangeTypes.RateUpdateChangeType"
                                                };
      rateUpdate.MethodForApply = rateUpdateHandler;
      results.Add(rateUpdate.Name, rateUpdate);

      //Account Update
      ChangeTypeConfiguration accountUpdate = new ChangeTypeConfiguration()
                                                {
                                                  Name = "AccountUpdate",
                                                  Enabled = true,
                                                  AllowMoreThanOnePendingChange = false,
                                                  CapabilityRequiredForApproveOrDeny = "Approve AccountChanges"
                                                };
      accountUpdate.MethodForApply = new MethodConfiguration()
                                       {
                                         ClientProxyType =
                                           "MetraTech.Account.ClientProxies.AccountCreationClient, MetraTech.Account.ClientProxies",
                                         EndPointName = "WSHttpBinding_IAccountCreation",
                                         ConfigFileLocation = @"extensions\Account\bin\MetraTech.Account.config",
                                         Name = "UpdateAccountView"
                                       };
      results.Add(accountUpdate.Name, accountUpdate);

      //Dummy Update for testing
      ChangeTypeConfiguration testUpdate = new ChangeTypeConfiguration()
                                             {
                                               Name = "SampleUpdate",
                                               Enabled = true,
                                               AllowMoreThanOnePendingChange = true,
                                               CapabilityRequiredForApproveOrDeny = "Allow ApprovalsView"
                                             };
      MethodConfiguration customTestUpdateHandler = new MethodConfiguration()
                                                      {
                                                        Assembly = "MetraTech.Approvals.dll",
                                                        Classname =
                                                          "MetraTech.Approvals.ChangeTypes.SampleUpdateChangeType"
                                                      };
      testUpdate.MethodForApply = customTestUpdateHandler;
      testUpdate.MethodForSubmit = customTestUpdateHandler;
      testUpdate.MethodForDeny = customTestUpdateHandler;

      results.Add(testUpdate.Name, testUpdate);


      return results;
    }

    public static ApprovalsConfiguration LoadChangeTypesFromAllExtensions()
    {
      ApprovalsConfiguration results = new ApprovalsConfiguration();

      IMTRcd mRcd = new MTRcd();
      MTRcdFileList files =
        (MTRcdFileList) MetraTech.Xml.MTXmlDocument.FindFilesInExtensions("ChangeTypeConfiguration.xml");

      foreach (string file in files)
      {
        // Unfortunate that there is no better way to get extension name
        string extensionName = "";
        MetraTechPathHelper.TryGetExtensionFromPath(file, out extensionName);

        foreach (ChangeTypeConfiguration changeTypeConfig in LoadChangeTypesFromFile(file, extensionName))
        {
          results.Add(changeTypeConfig.Name, changeTypeConfig);
        }

        results.filesLoaded.Add(file);
      }

      return results;
    }

    public static List<ChangeTypeConfiguration> LoadChangeTypesFromFile(string filePath, string extension)
    {
      List<ChangeTypeConfiguration> results = new List<ChangeTypeConfiguration>();

      XmlSerializer serializer = new XmlSerializer(typeof (ChangeTypeConfiguration));

      try
      {

        //load config file
        MTXmlDocument doc = new MTXmlDocument();

        doc.Load(filePath);


        XmlNodeList subNodes = doc.SelectNodes("//ChangeTypeConfiguration");
        for (int i = 0; i < subNodes.Count; i++)
        {
          try
          {
            string xml = subNodes[i].OuterXml;

            MemoryStream stm = new MemoryStream();

            StreamWriter stw = new StreamWriter(stm);
            stw.Write(xml);
            stw.Flush();

            stm.Position = 0;

            ChangeTypeConfiguration temp = (serializer.Deserialize(stm) as ChangeTypeConfiguration);
            temp.Extension = extension;
            temp.ConfigFilePath = filePath;
            results.Add(temp);
          }
          catch (Exception ex)
          {
            throw new Exception("Unable to load change type " + filePath + ": " + ex.Message); //Add ICE Error
          }
        }

      }
      catch (Exception ex)
      {
        throw new Exception("Unable to load file " + filePath + ": " + ex.Message); //Add ICE Error
      }

      return results;
    }

    public static void SaveChangeType(ChangeTypeConfiguration changeType)
    {
      if (string.IsNullOrEmpty(changeType.ConfigFilePath))
        throw new Exception("The file path of the config file the change type was loaded from is not specified");
      else
        SaveChangeType(changeType, changeType.ConfigFilePath);
    }

    public static void SaveChangeType(ChangeTypeConfiguration changeType, string filePath)
    {
      //Locate the existing change xmlnode, remove it
      XmlDocument doc = new XmlDocument();
      doc.Load(filePath);

      XmlNode nodeNewChangeType = SerializeObjectToXmlNode(changeType);

      XmlNode nodeChangeType =
        doc.SelectSingleNode("/ChangeTypes/ChangeTypeConfiguration[Name='" + changeType.Name + "']");

      if (nodeChangeType == null)
      {
        //Create a new one
        XmlNode nodeChangeTypes = doc.SelectSingleNode("/ChangeTypes");
        if (nodeChangeTypes == null)
          throw new Exception(
            string.Format(
              "Change Type Configuration file {0} does not contain ChangeTypes xml node. Are you sure this is a Change Type Configuration file?",
              filePath));
        else
          nodeChangeTypes.AppendChild(doc.ImportNode(nodeNewChangeType, true));
      }
      else
      {
        //Update the existing one
        nodeChangeType.ParentNode.ReplaceChild(doc.ImportNode(nodeNewChangeType, true), nodeChangeType);
      }

      doc.Save(filePath);

    }

    public static void CreateNewFile(string filePath)
    {
      throw new Exception(
        "Not Implemented: When we add the ability to create new change types in new Extensions, like ICE, need to add this.");
    }

    public static XmlNode SerializeObjectToXmlNode(Object obj)
    {
      if (obj == null)
        throw new ArgumentNullException("Argument cannot be null");

      XmlNode resultNode = null;
      XmlSerializer xmlSerializer = new XmlSerializer(obj.GetType());
      using (MemoryStream memoryStream = new MemoryStream())
      {
        try
        {
          xmlSerializer.Serialize(memoryStream, obj);
        }
        catch (InvalidOperationException)
        {
          return null;
        }
        memoryStream.Position = 0;
        XmlDocument doc = new XmlDocument();
        doc.Load(memoryStream);
        resultNode = doc.DocumentElement;
      }

      //Couldn't decide on the appropriate comment: Please choose your favoriate:
      // 1. 'Schema Attributes... we don't need not stinkin' schema attributes'
      // 2. 'Clearing the schema attributes because that is just how we roll!'
      if (resultNode != null)
        resultNode.Attributes.RemoveAll();

      return resultNode;
    }

    /// <summary>
    /// Used to register change handlers for when a configuration file changes based on an existing, loaded
    /// approval configuration.
    /// </summary>
    /// <param name="approvalConfig">approvals configuration used to get the list of relevant config files</param>
    /// <param name="onChangeMethod">method to call when file changes</param>
    /// <returns></returns>
    public static ApprovalsFileWatcher GetFileWatcherFromConfiguration(ApprovalsConfiguration approvalConfig,
                                                                       FileSystemEventHandler onChangeMethod)
    {
      ApprovalsFileWatcher result = new ApprovalsFileWatcher();
      foreach (string file in approvalConfig.FilesLoaded)
      {
        result.RegisterFile(file, onChangeMethod);
      }

      //if (onChangeMethod!=null)
      //  result.OnChanged += onChangeMethod;

      return result;
    }

    /// <summary>
    /// Used by ICE or other tools to validate the configuration
    /// </summary>
    public static void Validate()
    {
    }
  }
}

/// <summary>
  /// Used to encapsulate the list of filewatchers and event handlers registered for the list of existing configuration
  /// files.
  /// </summary>
  public class ApprovalsFileWatcher
  {
    protected List<FileSystemWatcher> watchers = new List<FileSystemWatcher>();

    public event FileSystemEventHandler OnChanged
    {
      add
      {
        foreach(FileSystemWatcher watcher in watchers)
        {
          watcher.Changed += value;
        }
      }

      remove
      {
        foreach (FileSystemWatcher watcher in watchers)
        {
          watcher.Changed -= value;
        }
      }
    }

    public void RegisterFile(string filePath, FileSystemEventHandler onChangeMethod)
    {
      // Create a new FileSystemWatcher and set its properties.
      FileSystemWatcher watcher = new FileSystemWatcher();
      watcher.Path = Path.GetDirectoryName(filePath);


        watcher.NotifyFilter =  NotifyFilters.LastWrite; //| NotifyFilters.FileName | NotifyFilters.DirectoryName;
        // Only watch our one file.
        watcher.Filter = Path.GetFileName(filePath);

        // Add event handlers.
        if (onChangeMethod != null)
          watcher.Changed += onChangeMethod;

        watcher.Changed += new FileSystemEventHandler(OnChangedHandler);
        //watcher.Created += new FileSystemEventHandler(OnChanged);
        //watcher.Deleted += new FileSystemEventHandler(OnChanged);
        //watcher.Renamed += new RenamedEventHandler(OnRenamed);

        // Begin watching.
        watcher.EnableRaisingEvents = true;

      watchers.Add(watcher);
    }

    // Define the event handlers.
    private static void OnChangedHandler(object source, FileSystemEventArgs e)
    {
        // Specify what is done when a file is changed, created, or deleted.
       Console.WriteLine("Default Handler: File: " +  e.FullPath + " " + e.ChangeType);

    }
    
  }

  public class MetraTechPathHelper
  {
    /// <summary>
    /// Need to determine the extension name for file paths found. Given a file path, this method returns true and 
    /// the name of the extension the file is in.
    /// </summary>
    /// <param name="path">Given path</param>
    /// <param name="extension">Name of extension or null if not found</param>
    /// <returns>True if extension was found in the path, otherwise false</returns>
    public  static bool TryGetExtensionFromPath(string path, out string extension/*, out string message*/)
    {
      List<string> pathTokens = TokenizePath(path);

      //determine the extension
      int i = pathTokens.FindIndex(p => p != null && p.Equals("Extensions", StringComparison.CurrentCultureIgnoreCase));
      if (i > -1 && i + 1 < pathTokens.Count)
      {
        extension = pathTokens[i + 1];
        //message = null;
        return true;
      }
      else
      {
        extension = null;
        //message = "Could not get the extention from the path";
        return false;
      }
    }

    private static List<string> TokenizePath(string path)
    {
      path = Path.GetFullPath(path);
      string dir = Path.GetDirectoryName(path);

      List<string> pathTokens = new List<string>(dir.Split('\\'));
      return pathTokens;
    }
  }

