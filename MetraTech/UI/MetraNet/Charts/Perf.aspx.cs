using System;
using System.Collections.Generic;
using System.IO;
using System.Xml;
using MetraTech.UI.Common;
using MetraTech.UI.Tools;


public partial class Perf : MTPage
{
  public string RawData { get; set; }
  public string DataLinks { get; set; }
  public Dictionary<string, string> ChartData { get; set; }
  public List<string> PageNames { get; set; }

  protected void Page_Load(object sender, EventArgs e)
  {
     if(!UI.User.SessionContext.SecurityContext.IsSuperUser())
     {
       Response.Write("You do not have access to this page.");
       Response.End();
       return;
     }

    ChartData = new Dictionary<string, string>();
    PageNames = new List<string>();
      
    MetraTech.Interop.RCD.IMTRcd rcd = new MetraTech.Interop.RCD.MTRcd();
    var path = Path.Combine(rcd.ConfigDir + @"Logging\HighResolutionTimer\logging.xml");

    var configDoc = new XmlDocument();
    configDoc.Load(path);
    var node = configDoc.SelectSingleNode(@"/xmlconfig/logging_config/logfilename");
    if (node != null)
    {
      var filename = node.InnerText.Replace("%temp%", Environment.GetEnvironmentVariable("TEMP"));

      if (!File.Exists(filename))
      {
        Response.Write("No logfile has been created yet...");
        Response.End();
        return;
      }

      var data = ParseTimingsFromLog(filename);

      foreach (var str in data)
      {
        RawData += str + Environment.NewLine;
        var arr = str.Split(new[] { ',' });

        if (ChartData.ContainsKey(arr[1].Trim()))
        {
          ChartData[arr[1].Trim()] += "['" + arr[0] + "'," + arr[2] + "],";
        }
        else
        {
          PageNames.Add(arr[1].Trim());
          ChartData.Add(arr[1].Trim(), "['" + arr[0] + "'," + arr[2] + "],");
        }
      }
    }
    char[] comma = { ','};
      foreach (var p in PageNames)
      {
        ChartData[p] = ChartData[p].TrimEnd(comma);
      }

    }

    protected string GetChartData()
    {
      string str = "";
      int i = 1;
      foreach(var p in PageNames)
      {
        str += String.Format("line{0} = [{1}];", i, ChartData[p]);
        i++;
      }
      return str;
    }
  
    protected string GetChartDataVariables()
    {
      string str = "";
      int i = 1;
#pragma warning disable 168
      foreach(var p in PageNames)
#pragma warning restore 168
      {
        str += String.Format("line{0},", i);
        i++;
      }
      char[] comma = { ',' };
      str = str.TrimEnd(comma);
      return str;
     }

    protected string GetLabels()
    {
      string str = "";
      foreach(var p in PageNames)
      {
        str += "{ label: '" + p + "' },";
      }
      char[] comma = { ',' };
      str = str.TrimEnd(comma);
      return str;
    }

    public List<string> ParseTimingsFromLog(string filename)
    {
      var list = new List<string>();
      string line;

      using (var sr = new StreamReader(new FileStream(filename,
          FileMode.Open, FileAccess.Read, FileShare.ReadWrite)))
      {
        long fileLength = sr.BaseStream.Length;
        if (fileLength > 50000000)
        {
          sr.BaseStream.Seek(fileLength - 50000000, SeekOrigin.Begin);
        }

        string match = null;
        if(Request["name"] != null)
        {
          match = Request["name"];
        }

        while (sr.Peek() >= 0)
        {
          line = sr.ReadLine();

          //11/30/10 15:30:19 [WebDev.WebServer40][HighResolutionTimer][INFO] [Security Check] Elapsed time: 20 (ms).  Max time: 10000 (ms)
          //08/04/10 11:49:37 [MASHostService][HighResolutionTimer][INFO] [MetadataRepository Initialization] completed in: 1070 (ms)

          if (line != null && line.Contains("[HighResolutionTimer]"))
          {
            if(match != null)
            {
              if(!line.Contains(match))
              {
                continue;
              }
            }

            var timingName = Utils.ExtractString(line, "[INFO]", "Elapsed time:");
            if (String.IsNullOrEmpty(timingName))
            {
              timingName = Utils.ExtractString(line, "[INFO]", "completed in:");
            }
            var timing = Utils.ExtractString(line, "Elapsed time: ", "(ms).");
            if (String.IsNullOrEmpty(timing))
            {
              timing = Utils.ExtractString(line, "completed in: ", "(ms)");
            }

            DateTime theTime;
            if (!DateTime.TryParse(line.Substring(0, 17), out theTime))
            {
              theTime = DateTime.Parse("1/1/1970 12:00:00 AM");
            }

            var msg = String.Format("{0}, {1}, {2}, {3}",
                                    theTime.ToShortDateString() + " " + theTime.ToShortTimeString(), timingName, timing,
                                    "False");
            list.Add(msg);
          }
        }

      }

      return list;
    }

    // for reading a graph log file
    /*
    public static List<string> ReadTextFileIntoList(string filename)
    {
      List<string> list = new List<string>();
      string line = null;

      using (StreamReader sr = File.OpenText(filename))
      {
        while ((line = sr.ReadLine()) != null)
        {
          list.Add(line);
        }
      }

      return list;
    }
    */

}
