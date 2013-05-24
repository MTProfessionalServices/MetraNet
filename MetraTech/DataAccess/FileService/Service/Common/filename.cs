namespace MetraTech.FileService
{
  using System;
  using System.Text.RegularExpressions;
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;
  using MetraTech.Basic;

  /// <summary>
  /// Helper class for cracking FileNames
  /// <ControlNumber>.<Target Tag>.<Service Tag>.<Extension>
  /// <ControlNumber> This is the grouping control number assigned by the customer.
  /// <Target Tag>    This is the target match field to allow selection of the appropriate target.
  /// <Service Tag>   This is the service (or argument sort) field used to match the file to the target file parameter requirements.
  /// <Extension>     This is an extension of users choice. Rename the extension of a file in the group to .Start will trigger batch consumption.
  /// </summary>
  public class ParsedFileName
  {
    #region Private Data
    enum eNmSeg
    {
      CID = 0,
      TGT = 1,
      SVC = 2,
      EXT = 3,
      MAX = 4
    };

    private bool m_isHealthy = true;
    private string m_fullName = String.Empty;
    private string m_name = String.Empty;
    private string m_path = String.Empty;
    private string[] m_nameSegments = null;
    private static Regex m_regexEng = new Regex(@"\.", RegexOptions.Compiled);
    
    #endregion

    private static readonly TLog m_log = new TLog("MetraTech.cFileService.cFileService");

    #region Constructors

    /// <summary>
    /// Given a full path filename, constructs a cFileName.
    /// Logs an error and sets isHealthy to false if the
    /// name is invalid.
    /// </summary>
    /// <param name="fullname"></param>
    public ParsedFileName(string fullname)
    {
        if (fullname == String.Empty)
        {
            m_isHealthy = false;
            m_log.Error("The FileLandingService received an empty filename.");
            return;
        }

        m_fullName = fullname;
        m_name = System.IO.Path.GetFileName(m_fullName);
        m_path = System.IO.Path.GetDirectoryName(m_fullName) + System.IO.Path.DirectorySeparatorChar;
        m_nameSegments = m_regexEng.Split(m_name);
        if (m_nameSegments.Length != (int)eNmSeg.MAX)
        {
            m_log.Error("The FileLandingService received file: " +
                     fullname + " which violates the file naming convention.");
            m_isHealthy = false;
            return;
        }

        m_isHealthy = true;
    }

    /// <summary>
    /// 
    /// </summary>
    ~ParsedFileName()
    {
    } 
    #endregion

    #region Accessors
    /// <summary>
    /// Full name of file, including path
    /// </summary>
    public string FullName
    {
      get
      {
        return m_fullName;
      }
    }

    /// <summary>
    /// Return true if this a properly constructd ParsedFileName
    /// </summary>
    public bool IsHealthy
    {
        get
        {
            return m_isHealthy;
        }
    }

    /// <summary>
    /// Name of file, excluding path
    /// </summary>
    public string Name
    {
      get
      {
        return m_name;
      }
    }
    /// <summary>
    /// Path to file
    /// </summary>
    public string Path
    {
      get
      {
        return m_path;
      }
    }
    /// <summary>
    /// Customer ID value
    /// </summary>
    public string ControlNumber
    {
      get
      {
        return m_nameSegments[(int)eNmSeg.CID];
      }
    }
    /// <summary>
    /// Target identification string
    /// </summary>
    public string TargetTag
    {
      get
      {
        return m_nameSegments[(int)eNmSeg.TGT];
      }
    }
    /// <summary>
    /// Argument (service) identification string
    /// </summary>
    public string FileNameTag
    {
      get
      {
        return m_nameSegments[(int)eNmSeg.SVC];
      }
    }
    /// <summary>
    /// Extension of the file.
    /// </summary>
    public string Extension
    {
      get
      {
        return m_nameSegments[(int)eNmSeg.EXT];
      }
    }
    
    #endregion
  } 
}
