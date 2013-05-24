using System;
using System.Collections.Generic;
using System.Text;
using System.Configuration;
using System.IO;
using System.Diagnostics;

namespace DBUpgradeExec
{
  class DBUpgradeExec
  {
    private static string m_DBType = null;
    private static string m_Server = null;
    private static string m_Username = null;
    private static string m_Password = null;
    private static string m_NetMeterSchema = null;
    private static string m_MetraPaySchema = null;
    private static string m_ScriptFolder = null;

    private static string m_Command = null;
    private static string m_CommandLine = null;

    private const string DBTYPE_ARG = "/DBTYPE:";
    private const string SERVER_ARG = "/SERVER:";
    private const string USERNAME_ARG = "/USER:";
    private const string PASSWORD_ARG = "/PWD:";
    private const string NETMETER_ARG = "/NETMETER:";
    private const string METRAPAY_ARG = "/METRAPAY:";
    private const string PATH_ARG = "/PATH:";

    private const string TEMP_FILE_NAME = @"DBUpgradeExec.sql";

    static void Main(string[] args)
    {
      if (ProcessArgs(args))
      {
        if (m_DBType == "SQL")
        {
          m_Command = ConfigurationManager.AppSettings["SQLCommand"];
          m_CommandLine = ConfigurationManager.AppSettings["SQLCommandLine"];
        }
        else if (m_DBType == "ORACLE")
        {
          m_Command = ConfigurationManager.AppSettings["ORACommand"];
          m_CommandLine = ConfigurationManager.AppSettings["ORACommandLine"];
        }
        else
        {
          Console.WriteLine("Invalid DB type specified\n");
          PrintUsage();
        }

        if (!string.IsNullOrEmpty(m_CommandLine) || !string.IsNullOrEmpty(m_Command))
        {
          if (Directory.Exists(m_ScriptFolder))
          {
            if (!Directory.Exists(Path.Combine(m_ScriptFolder, "LogFiles")))
            {
              Directory.CreateDirectory(Path.Combine(m_ScriptFolder, "LogFiles"));
            }

            string [] fileList = Directory.GetFiles(m_ScriptFolder, "*.sql", SearchOption.TopDirectoryOnly);
            Array.Sort(fileList);

            string tempPath = Path.Combine(Environment.GetEnvironmentVariable("TEMP"), TEMP_FILE_NAME);

            if (fileList.Length > 0)
            {
              foreach (string file in fileList)
              {
                Console.WriteLine("Processing {0}", Path.GetFileName(file));

                using (StreamReader rdr = new StreamReader(file))
                {
                  string contents = rdr.ReadToEnd();

                  contents = contents.Replace("%%NETMETER%%", m_NetMeterSchema);
                  contents = contents.Replace("%%METRAPAY%%", m_MetraPaySchema);

                  using (StreamWriter writer = new StreamWriter(tempPath, false))
                  {
                    writer.Write(contents);
                  }
                }

                string tempArgs = string.Format(m_CommandLine, m_Username, m_Password, m_Server);
                string arguments = string.Format("{0} \"{1}\"", tempArgs, tempPath);

                ProcessStartInfo startInfo = new ProcessStartInfo();
                startInfo.FileName = m_Command;
                startInfo.Arguments = arguments;
                startInfo.CreateNoWindow = false;
                startInfo.WorkingDirectory = m_ScriptFolder;
                startInfo.UseShellExecute = false;
                startInfo.RedirectStandardError = true;
                startInfo.RedirectStandardOutput = true;
                
                Process execProcess = Process.Start(startInfo);
                
                using (StreamWriter writer = new StreamWriter(Path.Combine(m_ScriptFolder, Path.Combine("LogFiles", Path.ChangeExtension(Path.GetFileName(file), "log")))))
                {
                  while (!execProcess.StandardOutput.EndOfStream)
                  {
                    writer.WriteLine(execProcess.StandardOutput.ReadLine());
                  }
                }

                if (!execProcess.StandardError.EndOfStream)
                {
                  Console.WriteLine("Errors:");

                  while (!execProcess.StandardError.EndOfStream)
                  {
                    Console.WriteLine("{0}", execProcess.StandardError.ReadLine());
                  }
                }

                execProcess.WaitForExit();

              }
            }
            else
            {
              Console.WriteLine("No SQL files found in script folder\n");
              PrintUsage();
            }
          }
          else
          {
            Console.WriteLine("Specified script folder does not exist\n");
            PrintUsage();
          }
        }
      }
      else
      {
        PrintUsage();
      }
    }

    private static bool ProcessArgs(string[] args)
    {
      bool retval = true;

      if (args.Length == 7)
      {
        foreach (string arg in args)
        {
          if (arg.ToUpper().StartsWith(DBTYPE_ARG))
          {
            m_DBType = arg.Substring(DBTYPE_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(SERVER_ARG))
          {
            m_Server = arg.Substring(SERVER_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(USERNAME_ARG))
          {
            m_Username = arg.Substring(USERNAME_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(PASSWORD_ARG))
          {
            m_Password = arg.Substring(PASSWORD_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(NETMETER_ARG))
          {
            m_NetMeterSchema = arg.Substring(NETMETER_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(METRAPAY_ARG))
          {
            m_MetraPaySchema = arg.Substring(METRAPAY_ARG.Length);
          }
          else if (arg.ToUpper().StartsWith(PATH_ARG))
          {
            m_ScriptFolder = arg.Substring(PATH_ARG.Length);
          }
        }

        if (string.IsNullOrEmpty(m_DBType) ||
          string.IsNullOrEmpty(m_Server) ||
          string.IsNullOrEmpty(m_Username) ||
          string.IsNullOrEmpty(m_Password) ||
          string.IsNullOrEmpty(m_NetMeterSchema) ||
          string.IsNullOrEmpty(m_MetraPaySchema) ||
          string.IsNullOrEmpty(m_ScriptFolder))
        {
          retval = false;
        }
      }
      else
      {
        retval = false;
      }

      return retval;
    }

    public static void PrintUsage()
    {
      Console.WriteLine("Executes a set of .SQL files against a specified database.");
      Console.WriteLine("Searches each file for%%NETMETER%% and %%METRAPAY%% tags and");
      Console.WriteLine("replaces them with the specified schema names.");
      Console.WriteLine("Files are executed in alphabetical order.");
      Console.WriteLine();
      Console.WriteLine("Usage:");
      Console.WriteLine("DBUpgradeExec /dbType:<dbType> /server:<server> /user:<uid> /pwd:<password>");
      Console.WriteLine("       /netMeter:<schema name> /metraPay:<schema name> /path:<script path>");
      Console.WriteLine();
      Console.WriteLine("/dbType:<dbType>         Specifies the database type");
      Console.WriteLine("                         Values are SQL or ORACLE");
      Console.WriteLine("/server:<server>         Specifies the database server");
      Console.WriteLine("/user:<uid>              Username to use when logging into the database");
      Console.WriteLine("/pwd:<password>          Password to use when logging into the database");
      Console.WriteLine("/netMeter:<schema name>  Specifies the name of the NetMeter schema");
      Console.WriteLine("                         Replaces %%NETMETER%% in script file");
      Console.WriteLine("/metraPay:<scheam name>  Specifies the name of the MetraPay schema");
      Console.WriteLine("                         Replaces %%METRAPAY%% in script file");
      Console.WriteLine("/path:<script path>      Folder that contains the *.sql files to execute");
    }
  }
}
