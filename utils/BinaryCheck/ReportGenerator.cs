using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Collections;
using System.IO;

namespace MetraTech.Tools.BinaryCheck
{
  public static class ReportGenerator
  {
    public static void Generate(Hashtable sa, string outputFile)
    {
      string sep = " ";

      List<string> keys = new List<string>(sa.Keys.Cast<string>());
      keys.Sort();

      StringBuilder outputSb = new StringBuilder();
      foreach (string key in keys)
      {
        var foundFiles = ((List<FoundFile>)sa[key])
          .OrderBy(f => !f.IsMaster)
          .ThenBy(f => f.Directory);

        string fileName = foundFiles.First().FileName; //the first is the master since we sorted it

        //if at least 1 is false and none are true.
        if (foundFiles.Any(f => f.IsComRegistered == false) &&
          foundFiles.All(f => f.IsComRegistered == null || f.IsComRegistered == false))
        {
          string registeredPath = foundFiles.First(f => !Utility.StringIsNullOrWhiteSpace(f.ComRegisteredPath)).ComRegisteredPath;

          outputSb.AppendLine("== " + fileName + " COMRegPath:" + registeredPath);
        }
        else
          outputSb.AppendLine("== " + fileName);

        foreach (var foundFile in foundFiles)
        {
          if (foundFile.IsMaster)
            outputSb.Append("M");
          else if (foundFile.IsDifferentFromMaster)
            outputSb.Append("***:" + foundFile.MasterDiffCode);
          else
            outputSb.Append("S");

          outputSb.Append(sep);
          outputSb.Append(foundFile.Directory);
          outputSb.Append(sep);
          outputSb.Append("Sz:" + foundFile.Size);
          outputSb.Append(sep);
          outputSb.Append("V:" + foundFile.FileVersion);
          outputSb.Append(sep);
          outputSb.Append("C:" + foundFile.CreationDateUtc.ToString("u"));
          outputSb.Append(sep);
          outputSb.Append("M:" + foundFile.ModifiedDateUtc.ToString("u"));
          outputSb.Append(sep);

          outputSb.Append("COM:");
          if (foundFile.IsComRegistered.HasValue)
            outputSb.Append(foundFile.IsComRegistered.Value ? "Y" : "N");
          else
            outputSb.Append("(n/a)");

          outputSb.Append(sep);
          outputSb.Append("PDBMatch:");
          if (foundFile.DoesPDBDateMatch.HasValue)
            outputSb.Append(foundFile.DoesPDBDateMatch.Value ? "Y" : "N");
          else
            outputSb.Append("(n/a)");

          outputSb.Append(sep);
          outputSb.Append("CKSM:" + foundFile.Checksum);
          outputSb.AppendLine();
        }
        outputSb.AppendLine();
      }

      File.WriteAllText(outputFile, outputSb.ToString());
    }
  }
}
