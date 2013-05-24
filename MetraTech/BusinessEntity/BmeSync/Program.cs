using System;
using System.Collections.Generic;
using System.IO;
using System.IO.Pipes;
using System.Linq;
using System.Dynamic;
using System.Reflection;
using System.Text;
using System.Xml.Linq;
using System.Xml.Serialization;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using MetraTech.BusinessEntity.Core;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Metadata;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using MetraTech.BusinessEntity.DataAccess.Persistence.Sync;
using MetraTech.ActivityServices.Common;

using NHibernate.Cfg.MappingSchema;
using NHibernate.Util;

namespace BmeSync
{
  public class Program
  {
    /// <summary>
    /// Adds the UID property to existing generated XML files for entities
    /// </summary>
    /// <param name="file">File to update</param>
    /// <remarks>FEAT-1398 Add UID to BME History Table</remarks>
    static void UpdateFile(string file)
    {
      XElement doc = XElement.Load(file);

      foreach (var attr in doc.Descendants().Attributes())
      {
        if (attr.Name == "name" && attr.Value == "UID")
          return;
      }

      XElement updateProperty = doc.Descendants().FirstOrDefault(xe => xe.Name.LocalName == "property" && xe.Attribute("name").Value == "UpdateDate");

      if (updateProperty == null)
        return;

      XElement uidProperty = new XElement("property", new XAttribute("name", "UID"), new XAttribute("column", "c_UID"),
        new XElement("meta", new XAttribute("attribute", "label")),
        new XElement("meta", new XAttribute("attribute", "description")),
        new XElement("meta", new XAttribute("attribute", "defaultvalue")),
        new XElement("meta", new XAttribute("attribute", "sortable"), "true"),
        new XElement("meta", new XAttribute("attribute", "searchable"), "false"),
        new XElement("meta", new XAttribute("attribute", "association-entity")),
        new XElement("meta", new XAttribute("attribute", "encrypted"), "false"),
        new XElement("meta", new XAttribute("attribute", "computed"), "false"),
        new XElement("meta", new XAttribute("attribute", "computation-type-name")),
        new XElement("meta", new XAttribute("attribute", "record-history"), "true"),
        new XElement("meta", new XAttribute("attribute", "is-custom-base-class-property"), "false"),
        new XElement("type", new XAttribute("name", "System.Int32, mscorlib")));

      using (StreamWriter sw = new StreamWriter(file, false))
      {
        updateProperty.AddAfterSelf(uidProperty);
        sw.Write(doc.ToString().Replace("<property name=\"UID\" column=\"c_UID\" xmlns=\"\">",
                                        "<property name=\"UID\" column=\"c_UID\">"));
        sw.Close();
      }
    }

    static void UpdateHbmGeneratedFilesWithUID()
    {
      var extensionsDirPath = Path.Combine(SystemConfig.GetRmpDir(), "extensions");
      var extensionsDir =  Directory.GetDirectories(extensionsDirPath);

      foreach (var dir in extensionsDir)
      {
        string interfaceDir = Path.Combine(dir, "BusinessEntity", "Interface");

        if (Directory.Exists(interfaceDir))
        {
          try
          {
            Directory.Delete(interfaceDir, true);
          }
          catch (Exception ex)
          {
            logger.Error(string.Format("Cann't delete folder {0}", interfaceDir), ex);
            Console.WriteLine("Cann't delete folder {0}", interfaceDir);
          }
        }
      }
      

      foreach (string file in Directory.GetFiles(Path.Combine(SystemConfig.GetRmpDir(), "extensions"), "*.Generated.hbm.xml", SearchOption.AllDirectories))
      {
        if (!file.ToLower().Contains("\\temp\\"))
          UpdateFile(file);
      }

      const string FILE_NAME = "predefined.cfg.xml";
      string path = Path.Combine(SystemConfig.GetRmpDir(), "config", "BusinessEntity", FILE_NAME);
      
      XDocument doc = XDocument.Load(path, LoadOptions.None);
      var isUpdatedProperty = doc.Descendants().FirstOrDefault(xe => xe.Name.LocalName == "filesUpdated");
      
      if (isUpdatedProperty != null)
        isUpdatedProperty.Value = "true";
      
      doc.Save(path);
    }

    static void CreateConfigFile(string path)
    {
      XElement filesUpdated = new XElement("filesUpdated");
      filesUpdated.Value = "false";

      const string COMMENT = "FEAT-1398 Add UID to BME History Table\nUpdates generated files with newly added predefined properties";

      XDocument doc = new XDocument(new XComment(COMMENT), filesUpdated);

      doc.Save(path);
    }

    static bool IsFilesUpdated()
    {
      const string FILE_NAME = "predefined.cfg.xml";
      string path = Path.Combine(SystemConfig.GetRmpDir(), "config", "BusinessEntity", FILE_NAME);
      if (!File.Exists(path))
      {
        CreateConfigFile(path);
      }
      else
      {
        XDocument doc = XDocument.Load(path, LoadOptions.None);
        var isUpdatedProperty = doc.Descendants().FirstOrDefault(xe => xe.Name.LocalName == "filesUpdated");
        bool isUpdated;

        if (isUpdatedProperty != null)
          if (bool.TryParse(isUpdatedProperty.Value, out isUpdated))
            return isUpdated;
      }

      return false;
    }

    static int Main(string[] args)
    {
      int ERROR = -1;
      int SUCCESS = 0;
      try
      {
        if (args.Length == 0)
        {
          PrintUsage();
          return ERROR;
        }

        if (!IsFilesUpdated())
          UpdateHbmGeneratedFilesWithUID();

        switch (args[0].ToLower())
        {
          case "-sync":
            {
              // (1) BmeSync -sync -writeHbm
              // (2) BmeSync -sync -writeHbm -ext ExtensionName

              string extensionName = null;
              bool writeHbm = false;

              if (args.Length != 1)
              {
                // BmeSync -sync -writeHbm
                if (args.Length == 2)
                {
                  if (args[1].Trim().ToLower() != "-writehbm")
                  {
                    Console.WriteLine("Expected -writeHbm");
                    PrintUsage();
                    return ERROR;
                  }

                  writeHbm = true;
                }
                // BmeSync -sync -ext ExtensionName
                else if (args.Length == 3)
                {
                  if (args[1].Trim().ToLower() != "-ext")
                  {
                    Console.WriteLine("Expected -ext");
                    PrintUsage();
                    return ERROR;
                  }

                  extensionName = args[2].Trim();
                }
                // BmeSync -sync -writeHbm -ext ExtensionName
                else if (args.Length == 4)
                {
                  if (args[1].Trim().ToLower() != "-writehbm")
                  {
                    Console.WriteLine("Expected -writeHbm");
                    PrintUsage();
                    return ERROR;
                  }

                  writeHbm = true;

                  if (args[2].Trim().ToLower() != "-ext")
                  {
                    Console.WriteLine("Expected -ext");
                    PrintUsage();
                    return ERROR;
                  }

                  extensionName = args[3].Trim();
                }

                else
                {
                  Console.WriteLine("Invalid or extra arguments");
                  PrintUsage();
                  return ERROR;
                }
              }

              if (!String.IsNullOrEmpty(extensionName) && !SystemConfig.ExtensionExists(extensionName))
              {
                Console.WriteLine(String.Format("Cannot find extension '{0}'", extensionName));
                return ERROR;
              }

              Console.WriteLine(String.IsNullOrEmpty(extensionName)
                                  ? "Synchronizing BME's across all extensions"
                                  : String.Format("Synchronizing BME's for extension '{0}'", extensionName));

              MetadataAccess.Instance.Synchronize(writeHbm, extensionName);

              Console.WriteLine(String.IsNullOrEmpty(extensionName)
                                  ? "Finished synchronizing BME's across all extensions"
                                  : String.Format("Finished synchronizing BME's for extension '{0}'", extensionName));
              break;
            }
          case "-build":
            {
              bool writeHbm = false;

              if (args.Length != 1)
              {
                // BmeSync -build -writeHbm
                if (args.Length == 2)
                {
                  if (args[1].Trim().ToLower() != "-writehbm")
                  {
                    Console.WriteLine("Expected -writeHbm");
                    PrintUsage();
                    return ERROR;
                  }

                  writeHbm = true;
                }
                else
                {
                  Console.WriteLine("Invalid or extra arguments");
                  PrintUsage();
                  return ERROR;
                }
              }

              Console.WriteLine("Building BME assemblies");
              var syncManager = new SyncManager();
              syncManager.BuildAssemblies(writeHbm);
              Console.WriteLine("Finished building BME assemblies");
              break;
            }
          case "-setdb":
            {
              // Expect: BmeSync -setdb DatabaseName -ext ExtensionName
              if (args.Length != 4)
              {
                Console.WriteLine("Invalid or extra arguments");
                PrintUsage();
                return ERROR;
              }

              string databaseName = args[1].Trim().ToLower();

              if (args[2].Trim().ToLower() != "-ext")
              {
                Console.WriteLine("Expected -ext");
                PrintUsage();
                return ERROR;
              }

              string extensionName = args[3].Trim().ToLower();

              Console.WriteLine(String.Format("Setting database name '{0}' for all BME's in extension '{1}'", databaseName, extensionName));
              var syncManager = new SyncManager();
              syncManager.SetDatabaseName(databaseName, extensionName);
              Console.WriteLine(String.Format("Finished setting database name '{0}' for all BME's in extension '{1}'", databaseName, extensionName));

              break;
            }
          case "-dt":
          case "-droptables":
            {
              // (1) BmeSync -dt DatabaseName 
              // (2) BmeSync -dt DatabaseName -ext ExtensionName

              string databaseName = String.Empty;
              string extensionName = String.Empty;

              if (args.Length == 2)
              {
                // DatabaseName
                databaseName = args[1].Trim();

              }
              else if (args.Length == 4)
              {
                // DatabaseName
                databaseName = args[1].Trim();

                if (args[2].Trim().ToLower() != "-ext")
                {
                  Console.WriteLine("Expected -ext");
                  PrintUsage();
                  return ERROR;
                }

                // ExtensionName
                extensionName = args[3].Trim();
              }
              else
              {
                Console.WriteLine("Invalid or extra arguments");
                PrintUsage();
                return ERROR;
              }

              Check.Require(!String.IsNullOrEmpty(databaseName), "Database name must be specified");

              // Confirmation prompt
              string response = String.Empty;
              var validResponses = new List<string> { "y", "yes", "n", "no" };

              while (!validResponses.Contains(response.ToLower()))
              {
                Console.WriteLine(String.IsNullOrEmpty(extensionName)
                                    ? String.Format("Do you want to drop all BME tables from database '{0}'? (Y/N)", databaseName)
                                    : String.Format("Do you want to drop all BME tables for extension '{0}' from database '{1}'? (Y/N)",
                                                    extensionName, databaseName));

                response = Console.ReadLine();
                if (!validResponses.Contains(response.ToLower()))
                {
                  Console.WriteLine(String.Format("'{0}' is not a valid response. Type 'Y' or 'N'", response));
                }
              }

              if (response.ToLower() == "y" || response.ToLower() == "yes")
              {
                if (!NHibernateConfig.IsBmeDatabase(databaseName))
                {
                  Console.WriteLine(String.Format("Database '{0}' is not marked as a BME database", databaseName));
                  return ERROR;
                }

                if (!SystemConfig.ExtensionExists(extensionName))
                {
                  Console.WriteLine(String.Format("Cannot find extension '{0}'", extensionName));
                  return ERROR;
                }

                Console.WriteLine(String.IsNullOrEmpty(extensionName)
                                    ? String.Format("Dropping all BME tables from database '{0}'", databaseName)
                                    : String.Format("Dropping all BME tables for extension '{0}' from database '{1}'",
                                                    extensionName, databaseName));

                RepositoryAccess.Instance.Initialize();
                RepositoryAccess.Instance.DropTables(databaseName, extensionName.ToLower());

                Console.WriteLine(String.IsNullOrEmpty(extensionName)
                                    ? String.Format("Succesfully dropped all BME tables from database '{0}'", databaseName)
                                    : String.Format("Succesfully dropped all BME tables for extension '{0}' from database '{1}'",
                                                    extensionName, databaseName));
              }
              break;
            }
          case "-subclass":
            {
              // Expect: BmeSync -subclass parentEntityName derivedEntityName
              if (args.Length != 3)
              {
                Console.WriteLine("Invalid or extra arguments");
                PrintUsage();
                return ERROR;
              }

              string parentEntityName = args[1].Trim();
              string derivedEntityName = args[2].Trim();

              Console.WriteLine(String.Format("Setting entity '{0}' to be a subclass of entity '{1}'",
                                              derivedEntityName, parentEntityName));
              MetadataAccess.Instance.MakeSubclass(parentEntityName, derivedEntityName);
              Console.WriteLine(String.Format("Finished setting entity '{0}' to be a subclass of entity '{1}'",
                                              derivedEntityName, parentEntityName));
              break;
            }
          case "-updrel":
            {
              // Expect: BmeSync -updrel ExtensionName
              if (args.Length != 2)
              {
                Console.WriteLine("Invalid or extra arguments");
                PrintUsage();
                return ERROR;
              }

              string extensionName = args[1].Trim();

              if (!SystemConfig.ExtensionExists(extensionName))
              {
                Console.WriteLine(String.Format("Cannot find extension '{0}'", extensionName));
                return ERROR;
              }

              Console.WriteLine(String.Format("Removing join tables from hbm specification for one-to-many and one-to-one relationships in extension '{0}'",
                                               extensionName));

              SyncManager.RemoveJoinTables(extensionName.ToLower());
              Console.WriteLine(String.Format("Finished removing join tables from hbm specification for one-to-many and one-to-one relationships in extension '{0}'",
                                               extensionName));

              break;
            }
          case "-ucprop":
            {
              // Expect: BmeSync -ucprop ExtensionName
              if (args.Length != 2)
              {
                Console.WriteLine("Invalid or extra arguments");
                PrintUsage();
                return ERROR;
              }

              string extensionName = args[1].Trim();

              if (!SystemConfig.ExtensionExists(extensionName))
              {
                Console.WriteLine(String.Format("Cannot find extension '{0}'", extensionName));
                return ERROR;
              }

              Console.WriteLine(String.Format("Upper-case the first letter of all property names and remove all properties with name 'creationdate' or 'updatedate' in extension '{0}'",
                                               extensionName));

              SyncManager.UpperCasePropertyNamesAndRemoveCreationDateUpdateDateUIDProperties(extensionName.ToLower());
              Console.WriteLine(String.Format("Finished Upper-casing the first letter of all property names and removed all properties with name 'creationdate' or 'updatedate' in extension '{0}'",
                                               extensionName));

              break;
            }
          case "-sqlonly":
            {
              // Generate the synchronization sql only 
              // The sql will be written to the file specified in the <synchronization-sql-file> element
              // in RMP\config\businessentity\be.cfg.xml
              throw new NotImplementedException("BmeSync -sqlonly has not been implemented");
            }
          default:
            {
              Console.WriteLine(String.Format("The specified argument '{0}' is not recognized", args[0]));
              PrintUsage();
              break;
            }
        }
      }
      catch (Exception e)
      {
        logger.Error("BmeSync failed", e);
        Console.WriteLine("BmeSync failed. See log for details.");
        return ERROR;
      }
      return SUCCESS;
    }

    /// <summary>
    ///   Print usage
    /// </summary>
    /// <returns></returns>
    private static void PrintUsage()
    {
      Console.WriteLine("\nUsage:");
      Console.WriteLine("--------\n");

      Console.WriteLine("(1) BmeSync -sync [-writeHbm] [-ext ExtensionName]");
      Console.WriteLine("    Synchronize BME's across all extensions or for the specified ExtensionName. Overwrite hbm files if -writeHbm is specified.");
      Console.WriteLine("\n");

      Console.WriteLine("(2) BmeSync -build [-writeHbm]");
      Console.WriteLine("    Build BME assemblies only. Overwrite hbm files if -writeHbm is specified.");
      Console.WriteLine("\n");

      Console.WriteLine("(2) BmeSync -setdb DatabaseName -ext ExtensionName");
      Console.WriteLine("    Set the specified database for all BME's in the specified extension.");
      Console.WriteLine("\n");

      Console.WriteLine("(2) BmeSync -subclass ParentEntityName DerivedEntityName");
      Console.WriteLine("    Make the derived entity (specified by DerivedEntityName) be a subclass of the parent entity (specified by ParentEntityName)");
      Console.WriteLine("\n");

      Console.WriteLine("(2) BmeSync -dropTables DatabaseName [-ext ExtensionName]");
      Console.WriteLine("    Drops all BME tables from the specified database or only the tables for the specified ExtensionName");
      Console.WriteLine("\n");

      //Console.WriteLine("(2) BmeSync -updrel ExtensionName");
      //Console.WriteLine("    Update all one-to-many and one-to-one relationships in the specified extension to not use join tables");
      //Console.WriteLine("\n");

      //Console.WriteLine("(3) BmeSync -cleandb");
      //Console.WriteLine("    Drops those BME tables in the database that");
      //Console.WriteLine("    do not have a corresponding hbm on the file system");
      //Console.WriteLine("\n");

      //Console.WriteLine("(4) BmeSync -sqlOnly");
      //Console.WriteLine("    Generate the synchronization sql in the file specified by");
      //Console.WriteLine("    <synchronization-sql-file> in RMP\\config\\BusinessEntity\\be.cfg.xml");
      //Console.WriteLine("\n");
    }

    #region Data
    private static readonly ILog logger = LogManager.GetLogger("BmeSync");
    #endregion
  }


}
