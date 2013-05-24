using System;
using System.Diagnostics;
using System.IO;
using MetraTech.Basic;
using MetraTech.Basic.Config;
using QuickGraph.Graphviz;
using QuickGraph.Graphviz.Dot;

namespace MetraTech.BusinessEntity.DataAccess.Metadata.Graph
{
  public class DotEngine : IDotEngine
  {
    #region Public Properties
    public string DotFile { get; set; }
    #endregion

    #region IDotEngine Members
    public string Run(GraphvizImageType imageType, string dot, string outputFileName)
    {
      Check.Require(!String.IsNullOrEmpty(DotFile), "DotFile cannot be null or empty", SystemConfig.CallerInfo);

      string dotExecutablePath = SystemConfig.GetGraphvizDotPath();
      if (String.IsNullOrEmpty(dotExecutablePath))
      {
        logger.Debug("Cannot render graph because 'Graphviz' is not installed");
        return null;
      }

      if (String.IsNullOrEmpty(dot))
      {
        logger.Debug("Cannot render graph because dot content is empty");
        return null;
      }

      try
      {
        // Write the dot file
        using (var writer = new StreamWriter(new FileStream(DotFile, FileMode.Create)))
        {
          writer.Write(dot);
          writer.Flush();
        }

        using (var process = new Process())
        {
          process.StartInfo.FileName = dotExecutablePath;

          //Provide arguments
          process.StartInfo.Arguments =
            String.Format("-T {0} -O {1}", imageType.ToString().ToLower(), DotFile);
          process.StartInfo.UseShellExecute = false;
          process.StartInfo.CreateNoWindow = true;
          process.StartInfo.RedirectStandardError = true;

          process.Start();

          string error = process.StandardError.ReadToEnd();
          process.WaitForExit();

          if (!String.IsNullOrEmpty(error))
          {
            logger.Error(error);
          }
        }
      }
      catch (System.Exception e)
      {
        logger.Error("Cannot render graph", e);
      }
      finally
      {
        if (File.Exists(DotFile))
        {
          File.Delete(DotFile);
        }
      }

      return null;
    }
    #endregion

    #region Data
    internal static ILog logger = LogManager.GetLogger("DotEngine");
    #endregion
  }
}
