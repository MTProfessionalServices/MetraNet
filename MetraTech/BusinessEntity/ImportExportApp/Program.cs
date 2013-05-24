using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.IO;

using MetraTech.BusinessEntity.ImportExport;
using MetraTech.Interop.RCD;

namespace MetraTech.BusinessEntity.ImportExport.App
{
  class Program
  {
    private static MetraTech.Logger Logger = new MetraTech.Logger("[ConsoleApp]");

    static int Main(string[] args)
    {
      try
      {
        if (ProcessArgs(args))
        {
          Logger.LogDebug("Business Entities Import Export tool called with the following parameters:");
          Logger.LogDebug(string.Join(" ", args));
          RootExportDirectory();
          WriteAndLog("Export files directory: {0}", dir);
          if (doExport)
          {
            WriteAndLog("Mode: export");
            EntityExporter exporter = new EntityExporter();
            foreach (string entityName in entityNames)
            {
              WriteAndLog("Entity: {0}", entityName);
              exporter.AddEntity(entityName, false);
            }
            foreach (string entityName in entityNamesCascade)
            {
              WriteAndLog("Entity: {0}", entityName);
              exporter.AddEntity(entityName, true);
            }
            exporter.Export(dir);
            WriteAndLog("Success. Entities exported to {0}", dir);
          }
          else if (doImport)
          {
            WriteAndLog("Mode: import");
            EntityImporter importer = new EntityImporter();
            foreach (string entityName in entityNames)
            {
              WriteAndLog("Entity: {0}", entityName);
              importer.AddEntity(entityName, false);
            }
            foreach (string entityName in entityNamesCascade)
            {
              WriteAndLog("Entity: {0}", entityName);
              importer.AddEntity(entityName, true);
            }
            WriteAndLog("IgnoreMetadataDifferences :{0}", Options.IgnoreMetadataDifferences.ToString());
            WriteAndLog("ImportMode :{0}", Options.ImportMode.ToString());
            importer.Import(dir);
            WriteAndLog("Success. Entities imported from {0}", dir);
          }
        }
        else
        {
          return 3; // return some error code, so Database.vbs knows we are in trouble
        }
        return 0;
      }
      catch (Exception ex)
      {
        Console.WriteLine("\n *** Critical error: {0}. Check mtlog for details", ex.Message);
        Logger.LogException("Critical error", ex);
        return 2; // return some error code, so Database.vbs knows we are in trouble
        //Console.ReadLine();
      }
    }

    private static void RootExportDirectory()
    {
      if (!Path.IsPathRooted(dir))
      {
        IMTRcd rcd = new MTRcdClass();
        string rmpDir = rcd.InstallDir;
        WriteAndLog("path {0} is not rooted, using {1} as root", dir, rmpDir);
        dir = Path.Combine(rmpDir, dir);
      }
    }

    private static void PrintUsage()
    {
      Console.Write(@"BMEImportExport Usage:

BMEImportExport.exe {imp | exp} [-E <EntityName>] [OPTIONS] ExportDirectory

Tool to import and export Business Modeling Entities (BMEs) from NetMeter
database to ExportDirectory and from ExportDirectory to NetMeter database.
Behaves like a BCP tool for BME tables.

exp: Export BME from the database to ExportDirectory 
imp: Import BME from ExportDirectory to the database

[-E <EntityName>]: Specifies full name for Entity to process.
                   All the related entities are included as well.
[-e <EntityName>]: Specifies full name for Entity to process.
                   Related entities are NOT included.
EntityName can be Entity Full Name, Entity Group Name or Extension name
  use: Core.UI.Site, to specify entity
  use: Core.UI.*, to specify extension group
  use: Core.*, to specify all entities from Core extension

ExportDirectory:   directory where to put/get the files
                   relative path will be prefixed with RMP folder

[-f <csv>]:        Format for the datafiles. Currently only supports CSV.

Options only for import:
[-M <replace | append>]: Import mode. Default is replace.
     replace           : Truncate existing records before inserting data
     append           : Append data to existing records
[-I]: Ignore metadata differences. By default, table metadata reported by
      MetadataRepository will be compared with the metadata in the
      ExportDirectory and errors will be reported.
      Metadata includes table name, column names, types, nullable flag, etc.

Usage examples:
BMEImportExport.exe exp -E Core.UI.Site C:\Temp\BME
   will export Core.UI.Site business entity and all child entities and
   relationship entities to C:\Temp\BME directory.

BMEImportExport.exe imp -E Core.UI.Site C:\Temp\BME
   will import Core.UI.Site business entity and all child entities and
   relationship entities from C:\Temp\BME directory.
   Import mode is replace, Metadata will be checked.

BMEImportExport.exe imp -e Core.UI.Site -e Core.UI.Dashboard -e Core.UI.Site_Dashboard -I -M append C:\Temp\BME
   will import Core.UI.Site business entity and Core.UI.Dashboard entity and
   relationship entity Core.UI.Site_Dashboard from C:\Temp\BME directory.
   Import mode is append, Metadata will not be checked.
");
    }

    private static bool doImport = false;
    private static bool doExport = false;
    private static string dir = "";
    private static List<string> entityNames = new List<string>();
    private static List<string> entityNamesCascade = new List<string>();

    private static bool ProcessArgs(string[] args)
    {
      bool retval = true;
      for (int i = 0; i < args.Length; i++)
      {
        if (args[i].ToLower() == "imp")
        {
          if (i > 0)
          {
            Console.WriteLine(" *** imp should be the first parameter");
           retval = false;
          }
          doImport = true;
        }
        else if (args[i].ToLower() == "exp")
        {
          if (i > 0)
          {
            Console.WriteLine(" *** exp should be the first parameter");
            retval = false;
          }
          doExport = true;
        }
        else if (args[i].ToUpper() == "-I")
        {
          Options.IgnoreMetadataDifferences = true;
        }
        else if (args[i].ToUpper() == "-F")
        {
          string dataFileFormat = args[++i];
          if (dataFileFormat.ToLower() != "csv")
          {
            Console.WriteLine(" *** Unsupported datafile format {0}", dataFileFormat);
            retval = false;
          }
        }
        else if (args[i].ToUpper() == "-M")
        {
          string importMode = args[++i];
          switch (importMode.ToLower())
          {
            case "replace":
              Options.ImportMode = Options.ImportModeEnum.Replace;
              break;
            case "append":
              Options.ImportMode = Options.ImportModeEnum.Append;
              break;
            default:
              Console.WriteLine(" *** Unsupported import mode {0}", importMode);
              retval = false;
              break;
          }
        }
        else if (args[i].ToUpper() == "-E")
        {
          bool cascade;
          if (args[i] == "-E") cascade = true;
          else cascade = false;

          string entityName = args[++i];
          if (cascade)
          {
            entityNamesCascade.Add(entityName);
          }
          else
          {
            entityNames.Add(entityName);
          }
        }
        else
        {
          if (i == args.Length - 1) //last argument is directory
          {
            dir = args[i];
          }
          else
          {
            Console.WriteLine(" *** Unknown parameter: {0}", args[i]);
            retval = false;
            break;
          }
        }
      }
      if (retval)
      {
        if (!(doExport || doImport))
        {
          Console.WriteLine(" *** Nothing to do. No functionality specified. Use imp/exp options to specify what to do");
          retval = false;
        }
        if (dir == "")
        {
          Console.WriteLine(" *** Directory not specified");
          retval = false;
        }
        if (entityNames.Count + entityNamesCascade.Count == 0)
        {
          Console.WriteLine(" *** No entities specified. use -E or -e options to specify entities");
          retval = false;
        }
      }
      if (!retval)
      {
        PrintUsage();
      }
      return retval;
    }

    public static void WriteAndLog(string format, params object[] args)
    {
      Console.WriteLine(format, args);
      Logger.LogDebug(format, args);
    }

    public static void WriteAndLog(string msg)
    {
      Console.WriteLine(msg);
      Logger.LogDebug(msg);
    }

  }
}
