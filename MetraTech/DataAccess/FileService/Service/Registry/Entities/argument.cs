/*
 * Represents an argument to be used when invoking the
 * executable associated with a target.
 */
namespace MetraTech.FileService
{
  // MetraTech Assemblies
  using System;
  using System.IO;
  using System.Collections.Generic;
  using System.Text.RegularExpressions;
  using System.Transactions;

  using Core.FileLandingService;

  using MetraTech.Basic;
  using MetraTech.Basic.Config;
  using MetraTech.Basic.Exception;
  using MetraTech.BusinessEntity.DataAccess.Metadata;
  using MetraTech.BusinessEntity.DataAccess.Persistence;
  using MetraTech.ActivityServices.Common; // For access to MTList
  using MetraTech.DomainModel.Enums.Core.Metratech_com_FileLandingService;

  public enum ArgType
  {
    FILE = 0,
    FIXED = 1,
    TRACKINGID = 2,
    BATCHID = 3,
  }

  public class Argument : BasicEntity
  {
    private static readonly TLog m_log = new TLog("MetraTech.FileService.Argument");
    private NameFilter m_Filter = null;
    private ArgType m_Type = ArgType.FIXED;
    private bool m_isMatched = false;

    #region Contructor
    /// <summary>
    /// Creates a new instance of a target, and performs any validation and creation of internal data. 
    /// </summary>
    /// <param name="db">Database access reference</param>
    /// <param name="t">Execution DataObject reference</param>
    public Argument(IStandardRepository db, ArgumentBE a)
      : base(db, a)
    {
      try
      {
        m_Filter = new NameFilter(a._Regex);
        String tag = String.Empty;
        RegexOptions ops = RegexOptions.IgnoreCase | RegexOptions.Singleline;

        if (Regex.IsMatch(a._Format, @"\$\(file\)", ops))
        {
          if (Regex.Matches(a._Format, @"\$\(file\)", ops).Count != 1)
          {
            string msg = "Argument contains more than one file keyword";
            m_log.Error(msg);
            throw new Exception(msg);
          }
          tag = @"\$\(file\)";
          m_Type = ArgType.FILE;
        }
        else if (Regex.IsMatch(a._Format, @"\$\(batchid\)", ops))
        {
          if (Regex.Matches(a._Format, @"\$\(batchid\)", ops).Count != 1)
          {
            string msg = "Argument contains more than one batchid keyword";
            m_log.Error(msg);
            throw new Exception(msg);
          }
          tag = @"\$\(batchid\)";
          m_Type = ArgType.BATCHID;
        }
        else if (Regex.IsMatch(a._Format, @"\$\(trackingid\)", ops))
        {
          if (Regex.Matches(a._Format, @"\$\(trackingid\)", ops).Count != 1)
          {
            string msg = "Argument contains more than one trackingid keyword";
            m_log.Error(msg);
            throw new Exception(msg);
          }
          tag = @"\$\(trackingid\)";
          m_Type = ArgType.TRACKINGID;
        }
        if (String.Empty != tag)
        {
          string newFmt = Regex.Replace(a._Format, tag, "{0}", ops);
          a._Format = newFmt;
        }
      }
      catch (System.ArgumentOutOfRangeException ex)
      {
        m_log.Error(ex.Message + " Argument options contains an invalid flag (" + a._Format + ":" + a._Regex + ")");
        throw new Exception("Bad target argument");
      }
      catch (System.ArgumentNullException ex)
      {
        m_log.Error(ex.Message + " Argument pattern is null (" + a._Format + ":" + a._Regex + ")");
        throw new Exception("Bad target argument");
      }
      catch (System.ArgumentException ex)
      {
        m_log.Error(ex.Message + " Argument pattern parsing error, pattern invalid (" + a._Format + ":" + a._Regex + ")");
        throw new Exception("Bad target argument");
      }
    }
    #endregion

    #region Accesors

    public int Order
    {
      get
      {
        return (Instance as ArgumentBE)._Order;
      }
    }

    public ArgType Type
    {
      get
      {
        return m_Type;
      }
    }

    public EConditionalType Condition
    {
      get
      {
        return (Instance as ArgumentBE)._ConditionalFlag;
      }
    }

    public string Format
    {
      get
      {
        return (Instance as ArgumentBE)._Format;
      }
    }

    public NameFilter Filter
    {
      get
      {
        return m_Filter;
      }
    }

	#endregion

    public bool IsMatch(String fullName)
    {
      ParsedFileName parsedName = new ParsedFileName(fullName);
      if (!parsedName.IsHealthy)
      {
        m_log.Debug("Unable to parse the file name: " + fullName);
        return false;
      }

      return m_Filter.IsMatch(parsedName.FileNameTag);
    }

    public bool IsMatched
    {
      get
      {
        return m_isMatched;
      }
      set
      {
        m_isMatched = value;
      }
    }

    /// <summary>
    /// Determines if the instance is current
    /// </summary>
    /// <returns></returns>
    public override bool IsUpToDate()
    {
      ArgumentBE me = Instance as ArgumentBE;
      if (null == me || me.Id == Guid.Empty)
        return false;

      ArgumentBE arg = DB.LoadInstance(typeof(ArgumentBE).FullName, Instance.Id) as ArgumentBE;
      if (null != arg)
      {
        if (me._Version < arg._Version)
        {
          return false;
        }
        return true;
      }
      return false;
    }
  }
}