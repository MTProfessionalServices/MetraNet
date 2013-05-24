namespace MetraTech.FileService
{
  using System;
  using System.Collections.Generic;
  using System.Text.RegularExpressions;
  using Core.FileLandingService;
  using MetraTech.Basic;
  using MetraTech.Basic.Exception;


  /// <summary>
  /// Represents a set of candidates that we should watch for changes, matching with either a wildcard
  /// expression or a regex.
  /// </summary>
  public class NameFilter
  {
    private string m_filter = String.Empty;
    private static readonly TLog m_log = new TLog("MetraTech.FileService.FileNameFilter");

    public NameFilter(string filter)
    {
      m_filter = filter;
    }

    public bool IsMatch(string candidate)
    {
      return candidate.Equals(m_filter);
    }

    /// <summary>
    /// The expression to use to match against filenames to determine which ones we are 
    /// concerned with.
    /// </summary>
    public string MatchString
    {
      get
      {
        return m_filter;
      }
      set
      {
        m_filter = value;
      }
    }
  }
}
