using System.Runtime.InteropServices;

namespace MetraTech.Statistics
{
  using System;
  using System.Diagnostics;
  using System.Reflection;
  using System.Runtime.InteropServices;
  using System.Management;
  using System.IO;

  using System.Collections;
  using System.Web;
  using System.Text;
  using System.Text.RegularExpressions;

  using System.Xml;
  
  using MetraTech.Xml;
  using MetraTech.Interop.RCD;


  //using MetraTech.Interop.MTUsageServer;
  [Guid("4538E84C-5F55-4ebf-8218-123C4CA3E10C")]
  public interface IVersionInfo 
  {
    string GetOperatingSystemVersionInfo();
    string GetFileVersionInfoAsXML(string FilePath, string FilterRegularExpression);
    string GetManagementObjectInfo(string sQuery);  
    string GetServerDescription(string language);
  }

  [Guid("3ECC2B78-F5B5-49ff-9592-F99969A06677")]
  public class VersionInfo : IVersionInfo
  {
    [StructLayout(LayoutKind.Sequential)]
		private struct OSVERSIONINFO 
    {
      public int dwOSVersionInfoSize;
      public int dwMajorVersion;
      public int dwMinorVersion;
      public int dwBuildNumber;
      public int dwPlatformId;
      [MarshalAs(UnmanagedType.ByValTStr, SizeConst=128)]
      public string szCSDVersion;
    }
    [DllImport("kernel32.Dll")] private static extern short GetVersionEx(ref OSVERSIONINFO o);


    /// <summary>
    /// GetServerDescription - Returns the standard server description found in the MetraNet.xml config file.
    /// </summary>
    /// <param name="language"></param>
    /// <returns>Server Description</returns>
    public string GetServerDescription(string language)
    {
      string lang = "Default";
      string serverDescription = "";

      if(language != string.Empty)
        lang = string.Copy(language);

      SystemInfo si = new SystemInfo();
      string machineName = si.GetEnviromentVariable("COMPUTERNAME");

      // Load config information
      IMTRcd rcd = new MTRcdClass();
      string configFile = rcd.ExtensionDir;
      configFile += @"\SystemConfig\config\MetraNet\MetraNet.xml";

      XmlDocument config = new XmlDocument();
      config.Load(configFile);
      
      // Get description and type
      XmlNode serverDescriptionNode = config.SelectSingleNode("/MTConfig/MetraNet/" + lang + "/MetraNetServerDescription");
      XmlNode serverTypeNode = config.SelectSingleNode("/MTConfig/MetraNet/" + lang + "/MetraNetServerType");

      // MachineName:  Description [TYPE]
      serverDescription = machineName + ":&nbsp;&nbsp;" + serverDescriptionNode.InnerText + "&nbsp;<b>" + serverTypeNode.InnerText + "</b>"; 

      return serverDescription;
    }

    public string GetOperatingSystemVersionInfo()
    {
      // Get the Operating System From Environment Class
      //OperatingSystem os = Environment.OSVersion;

      // Get the version information
      Version vs = Environment.OSVersion.Version;

      string sVersion = "";

      //sVersion = vs.Major + "." + vs.Minor + "." + vs.Revision + "." + vs.Build;
      //sVersion+= " Revision:" + vs.Revision;
      //sVersion+= " Build:" + vs.Build;
      //sVersion+= " Service Pack:" + os.CSD;
      sVersion = Environment.OSVersion.Version.ToString();

      //Get Service Pack Information
      OSVERSIONINFO os = new OSVERSIONINFO();
      os.dwOSVersionInfoSize=Marshal.SizeOf(typeof(OSVERSIONINFO)); 
      GetVersionEx(ref os);
      if (os.szCSDVersion=="")					 
        sVersion+= " [No Service Pack Installed]";
      else
        sVersion+= " [" + os.szCSDVersion + "]"; 

      //Alternate Version
      //SelectQuery query = new SelectQuery("Win32_OperatingSystem");
      //ManagementObjectSearcher searcher = new ManagementObjectSearcher( query);
      //foreach (ManagementObject mo in searcher.Get())
      //  sVersion+= mo["Version"].ToString() + " Service Pack: " + mo["ServicePackMajorVersion"].ToString();

      return sVersion;
    }

    public string GetFileVersionInfoAsXML(string FilePath, string FilterRegularExpression)
    {

      string sXML="";
            
      //declare an absolute path to a file to retrieve information about
      //FilePath = "c:\\winnt\\system32\\wininet.dll";

      sXML = "<Files>";

      if (File.Exists(FilePath))
        GetFileXML(FilePath, ref sXML);
      else
      {
        //Assume this is a directory
        Regex reFilter = null;

        if (FilterRegularExpression.Length>0)
        {
          reFilter = new Regex(FilterRegularExpression, RegexOptions.IgnoreCase);
          //reFilter = new Regex(@"\.dll$|\.exe$", RegexOptions.IgnoreCase);
        }

        GetDirectoryXML(FilePath, reFilter, ref sXML);
      }

      sXML += "</Files>";

      return sXML;
    }

    public string GetManagementObjectInfo(string sQuery)
    {
      //{"Win32_LogicalDisk", "Win32_Processor", "Win32_OperatingSystem"}
      string sInfo = "";

      //Alternate Version
      SelectQuery query = new SelectQuery(sQuery);
      ManagementObjectSearcher searcher = new ManagementObjectSearcher( query);
      foreach (ManagementObject mo in searcher.Get())

        foreach(PropertyData s in mo.Properties)
        {
          try 
          {
            //Console.WriteLine(s.Name + ":\t\t" + mo[s.Name].ToString());
            sInfo+= s.Name + " = " + mo[s.Name].ToString() + "\n";

          }
          catch(System.NullReferenceException)
          {
            //Console.WriteLine("No object reference for: " + s.Name);
            sInfo+= s.Name + " = [NO OBJECT REFERENCE]" + "\n";
            continue;
          }
        }

      return sInfo;
    }

    public void GetDirectoryXML(string sDir,Regex reFilter, ref string sXML)
    {

      try	
      {
        foreach (string f in Directory.GetFiles(sDir, "*.*")) 
        {
          if (reFilter==null || reFilter.IsMatch(f))
            GetFileXML(f, ref sXML);
        }

        foreach (string d in Directory.GetDirectories(sDir)) 
        {
          GetDirectoryXML(d, reFilter, ref sXML);
        }
      }
      catch (System.Exception excpt) 
      {
        Console.WriteLine(excpt.Message);
      }

    }

    public void GetFileXML(string sFilePath, ref string sXML)
    {
      FileVersionInfo fversinfo;
      FileInfo        finfo;

      //get version information
      fversinfo = FileVersionInfo.GetVersionInfo(sFilePath);
        
      sXML += "<File>";
      sXML += "<FilePath>" + fversinfo.FileName + "</FilePath>";    
      sXML += "<Version>" + fversinfo.FileMajorPart + "." + fversinfo.FileMinorPart + "." + fversinfo.FileBuildPart + "." + fversinfo.FilePrivatePart + "</Version>";    

      //cleanup
      fversinfo = null;

      //get general file info
      finfo = new FileInfo(sFilePath);

      sXML += "<Extension>" + finfo.Extension + "</Extension>";    
      sXML += "<Size>" + finfo.Length/1024 + "</Size>"; 
      sXML += "<LastModified>" + finfo.LastWriteTime.ToShortDateString() + " " + finfo.LastWriteTime.ToShortTimeString() + "</LastModified>"; 
        
      //cleanup
      finfo = null;

      sXML += "</File>\n";
    }

  }
}

