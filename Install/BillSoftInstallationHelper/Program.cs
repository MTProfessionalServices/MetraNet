namespace MetraTech.Tax.BillSoft.InstallHelper
{
  using System;
  using System.IO;
  using System.Text;
  using Microsoft.Win32;

  public class BillSoftInstallationDetectorAndConfigurationGenerator
  {
    const int SUCCESS = 0;
    const int ARGUMENTNOTPRESET_FAILED = 1;
    const int PATHDOESNOTEXIST_FAILED = 2;
    const int BILLSOFTNOTINSTALLED_FAILED = 3;
    const int UNABLETOWRITEXMLFILE_FAILED = 4;

    public static int Main(string[] args)
    {
      var rmpPathString = String.Empty;
      var CommandLine = new Arguments(args);

      int ReturnCode = SUCCESS;

      if (CommandLine["?"] != null || CommandLine["help"] != null || CommandLine["h"] != null)
      {
        Usage(args);
        return ReturnCode; // Success
      }

      // Make sure RMP is specified
      if (String.IsNullOrEmpty(CommandLine["rmp"]))
      {
        Usage(args);
        Console.WriteLine("Must provide RMP path");
        return ARGUMENTNOTPRESET_FAILED;
      }

      // Make sure RMP is actually valid
      rmpPathString = CommandLine["rmp"];
      if (!Directory.Exists(rmpPathString))
      {
        Usage(args);
        Console.WriteLine(String.Format("{0} does not exists!", rmpPathString));
        return PATHDOESNOTEXIST_FAILED;
      }

      // Discover the billsoft Directory
      var billsoftPathString = GetBillSoftBaseInstallPath();
      if (String.IsNullOrEmpty(billsoftPathString))
      {
        Console.WriteLine("BillSoft does not appear to be installed yet. Setting defaults for later editting.");
        ReturnCode = BILLSOFTNOTINSTALLED_FAILED;
        billsoftPathString = @"C:\TOBEDEFINEDBEFOREFIRSTUSEPLEASE\PATHNOTYETCONFIGURED\";
      }

      if (!WriteBillSoftVendorConfiguration(rmpPathString, billsoftPathString))
      {
        Console.WriteLine(String.Format(@"Couldn't write {0}\extensions\BillSoft\config\BillSoftPathFile.xml", rmpPathString));
        if(ReturnCode != BILLSOFTNOTINSTALLED_FAILED)
          ReturnCode = UNABLETOWRITEXMLFILE_FAILED;
      }
      return ReturnCode;
    }

    /// <summary>
    /// Displays the usage statement.
    /// </summary>
    /// <param name="args"></param>
    private static void Usage(string[] args)
    {
      Console.WriteLine(String.Format("USAGE: {0} /RMP=[PathToRMPDir]", args[0]));
      Console.WriteLine(@"       [PathToRMPDir] Path to the RMP directory, for example d:\MetraTech\RMP");
      Console.WriteLine("");
      Console.WriteLine("Return codes are:");
      Console.WriteLine("Success = 0");
      Console.WriteLine("Failed due to Argument not preset = 1");
      Console.WriteLine("Failed due to Path does not exist = 2");
      Console.WriteLine("Failed due to BillSoft not installed = 3");
      Console.WriteLine("Failed due to unable to write XML file = 4");
      Console.WriteLine("");

    }

    /// <summary>
    /// Writes the billsoft object configuration out to file.
    /// </summary>
    /// <param name="rmpdir"></param>
    /// <param name="billsoftbasedir"></param>
    /// <returns></returns>
    private static bool WriteBillSoftVendorConfiguration(string rmpdir, string billsoftbasedir)
    {
      string fullFilePath = rmpdir + @"\extensions\BillSoft\config\BillSoftPathFile.xml";
      try
      {

        if (File.Exists(fullFilePath))
        {
          File.Delete(fullFilePath);
        }
        using (var fs = File.Create(fullFilePath))
        {
          var billSoftNodeFormat = @"<xmlconfig>
  <BillSoft>
    <EZTaxInstallPath>{0}</EZTaxInstallPath>
    <EZTaxLogPath>{1}\BillSoftLogs</EZTaxLogPath>
    <EZTaxLogFilePrefix>EZTaxLog</EZTaxLogFilePrefix>
  </BillSoft>
</xmlconfig>";

          var billSoftNode = String.Format(billSoftNodeFormat, billsoftbasedir, rmpdir);
          AddText(fs, billSoftNode);
        }
      }
      catch (Exception e)
      {
        Console.WriteLine(String.Format("Couldn't write XML Configuration file {0}. Exception Message = {1}", fullFilePath, e.Message));
        return false;
      }
      return true;
    }

    private static void AddText(Stream fs, string value)
    {
      var info = new UTF8Encoding(true).GetBytes(value);
      fs.Write(info, 0, info.Length);
    }

    /// <summary>
    /// Gets the base installation of BillSoft if it exists
    /// </summary>
    /// <returns>the installation path, or an empty string</returns>
    private static string GetBillSoftBaseInstallPath()
    {
      var baseInstallPath = String.Empty;
      // The name of the key must include a valid root.
      // NOTE: Assume we are on a 64bit machine...
      const string keyPath = @"HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\BillSoft's EZTax Update";
      const string keyName = "UninstallString";
      const string BupkisPattern = "bupkis";

      try
      {
        // Your default value is returned if the name/value pair does not exist.
        var keyVal = (string)Registry.GetValue(keyPath, keyName, BupkisPattern);

        // Make sure we found more than Bupkis :) 
        // come on, you know that is funny
        if (BupkisPattern.Equals(keyVal))
        {
          Console.WriteLine("Found Bupkis");
        }
        else // Found it, lets parse out the base path.
        {
          var stringParts = keyVal.Split(' ');
          foreach (string t in stringParts)
          {
            if (t.Contains("UNWISE.EXE"))
            {
              baseInstallPath = t.Replace(@"Data\UNWISE.EXE", "");
            }
          }
        }
      }
      catch
      {
        // Swallow it, and just return empty string.
        // This may be due to permissions but lets
        // assume if they can install metranet, they can look
        // at the registry.
      }
      return baseInstallPath;
    }
  }
}