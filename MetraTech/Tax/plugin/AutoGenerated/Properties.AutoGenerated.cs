#region Generated using ICE (Do not modify this region)

/// Generated using ICE
/// ICE CodeGen Version: 1.0.0

#endregion

//////////////////////////////////////////////////////////////////////////////
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////

#region

using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Diagnostics;
using MetraTech.Interop.SysContext;
using MetraTech.Pipeline;
using IMTConfigProp = MetraTech.Interop.MTPipelineLib.IMTConfigProp;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;

//STANDARD_ENUM_REFERENCES

#endregion

//ENUM_USING

namespace MetraTech.Tax.Plugins.BillSoft
{

  #region Properties class

  public class Properties
  {
    #region Variables

    private PipelineProperties m_pipeline;
    private ISession m_session;

    #endregion

    #region Construction

    private Properties(PipelineProperties pipeline) : this(pipeline, null)
    {
    }

    private Properties(PipelineProperties pipeline, ISession session)
    {
      m_pipeline = pipeline;
      m_session = session;
    }

    internal static Properties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext,
                                               IMTConfigPropSet propSet)
    {
      var pipelinePrototype = PipelineProperties.CreatePrototype(log, systemContext, propSet);

      return new Properties(pipelinePrototype);
    }

    internal static Properties Create(Properties prototype, ISession session)
    {
      var pipeline = PipelineProperties.Create(prototype.m_pipeline, session);

      return new Properties(pipeline, session);
    }

    #endregion

    #region Properties

    internal ISession Session
    {
      get { return m_session; }
    }

    internal PipelineProperties Pipeline
    {
      get { return m_pipeline; }
    }

    #endregion
  }

  #endregion

  #region GeneralConfig class

  public sealed class GeneralConfig
  {
    #region General config variables

    private string m_eztaxinstallpath;
    private bool? m_resolvebynpanxx;
    private bool? m_resolvebyzip;
    //GENERAL_CONFIG_VAR

    #endregion

    #region Construction

    internal GeneralConfig(IMTSystemContext systemContext, IMTConfigPropSet propSet)
    {
      var generalConfigProps = propSet.NextSetWithName("GeneralConfig");
      m_resolvebyzip = bool.Parse(generalConfigProps.NextStringWithName("ResolveByZip"));
      m_resolvebynpanxx = bool.Parse(generalConfigProps.NextStringWithName("ResolveByNPANXX"));
      m_eztaxinstallpath = generalConfigProps.NextStringWithName("EZTaxInstallPath");
      //GENERAL_CONFIG_ASSIGN
    }

    #endregion

    #region General Config Properties

    /// <summary>
    /// %SUMMARY_TEXT%
    /// </summary>
    internal bool? ResolveByZip
    {
      get { return m_resolvebyzip; }
    }

    /// <summary>
    /// %SUMMARY_TEXT%
    /// </summary>
    internal bool? ResolveByNPANXX
    {
      get { return m_resolvebynpanxx; }
    }

    /// <summary>
    /// %SUMMARY_TEXT%
    /// </summary>
    internal string EZTaxInstallPath
    {
      get { return m_eztaxinstallpath; }
    }

    //GENERAL_CONFIG_PROP

    #endregion
  }

  #endregion

  #region Properties Collection class

  public sealed class PropertiesCollection : IEnumerable<Properties>
  {
    private Properties m_prototype;
    private ReadOnlyCollection<ISession> m_sessions;

    public PropertiesCollection(Properties prototype, ReadOnlyCollection<ISession> sessions)
    {
      m_sessions = sessions;
      m_prototype = prototype;
    }

    public Properties this[int index]
    {
      get { return Properties.Create(m_prototype, m_sessions[index]); }
    }

    public int Count
    {
      get { return m_sessions.Count; }
    }

    public bool IsReadOnly
    {
      get { return true; }
    }

    #region IEnumerable<Properties> Members

    public IEnumerator<Properties> GetEnumerator()
    {
      return new PropertiesEnumerator(this);
    }

    System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
    {
      return new PropertiesEnumerator(this);
    }

    #endregion

    public int IndexOf(Properties item)
    {
      return m_sessions.IndexOf(item.Session);
    }

    public bool Contains(Properties item)
    {
      return m_sessions.Contains(item.Session);
    }

    public void CopyTo(Properties[] array, int arrayIndex)
    {
      for (int i = 0, j = arrayIndex;
           j < array.Length && i < m_sessions.Count;
           ++i, ++j)
      {
        array[j] = Properties.Create(m_prototype, m_sessions[i]);
      }
    }

    #region Nested type: PropertiesEnumerator

    public struct PropertiesEnumerator : IEnumerator<Properties>
    {
      private const int START = -1;
      private int m_index;
      private PropertiesCollection m_propsCol;

      public PropertiesEnumerator(PropertiesCollection propsCol)
      {
        m_propsCol = propsCol;
        m_index = START;
      }

      #region IEnumerator<Properties> Members

      public Properties Current
      {
        get { return m_propsCol[m_index]; }
      }

      public void Dispose()
      {
        m_propsCol = null;
        m_index = START;
      }

      object System.Collections.IEnumerator.Current
      {
        get { return Current; }
      }

      public bool MoveNext()
      {
        if ((m_index + 1) > (m_propsCol.Count - 1))
          return false;
        ++m_index;
        return true;
      }

      public void Reset()
      {
        m_index = START;
      }

      #endregion
    }

    #endregion
  }

  #endregion

  #region PipelineProperties Class

  public sealed class PipelineProperties
  {
    #region Non-Pipeline variables

    private PlugInBase.LogDelegate Log;
    private IEnumConfig m_enumConfig;
    private ISession m_session;

    #endregion

    #region Pipeline variables

    private Binding<string> m_city;
    private Binding<string> m_countrycode;
    private Binding<string> m_npanxxnumber;
    private Binding<string> m_stateabbr;
    private Binding<long> m_taxpcodevalue;
    private Binding<string> m_zipcode;
    //BINDING_ID_VAR

    #endregion

    #region Construction

    private PipelineProperties(PlugInBase.LogDelegate log, IMTSystemContext systemContext, IMTConfigPropSet propSet)
    {
      Log = log;

      //Init the enum config
      m_enumConfig = systemContext.GetEnumConfig();

      //get the nameID
      var nameID = systemContext.GetNameID();

      var pipelineProps = propSet.NextSetWithName("PipelineBinding");
      IMTConfigProp prop = null;
      while (true)
      {
        prop = pipelineProps.Next();
        if (prop == null)
          break;

        switch (prop.Name)
        {
          case "CountryCode":
            m_countrycode = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
            break;
          case "StateAbbr":
            m_stateabbr = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
            break;
          case "City":
            m_city = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
            break;
          case "ZipCode":
            m_zipcode = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
            break;
          case "NPANXXNumber":
            m_npanxxnumber = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
            break;
          case "TaxPCodeValue":
            m_taxpcodevalue = new Binding<long>(nameID.GetNameID(prop.ValueAsString));
            break;
            //BINDING_ID_ASSIGN
        }
      }
    }

    private PipelineProperties(PipelineProperties prototype, ISession session)
    {
      m_session = session;
      m_enumConfig = prototype.m_enumConfig;
      Log = prototype.Log;

      m_countrycode = new Binding<string>(prototype.m_countrycode.ID);
      m_stateabbr = new Binding<string>(prototype.m_stateabbr.ID);
      m_city = new Binding<string>(prototype.m_city.ID);
      m_zipcode = new Binding<string>(prototype.m_zipcode.ID);
      m_npanxxnumber = new Binding<string>(prototype.m_npanxxnumber.ID);
      m_taxpcodevalue = new Binding<long>(prototype.m_taxpcodevalue.ID);
      //BINDING_ID_CLONE
    }

    internal static PipelineProperties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext,
                                                       IMTConfigPropSet propSet)
    {
      return new PipelineProperties(log, systemContext, propSet);
    }

    internal static PipelineProperties Create(PipelineProperties prototype, ISession session)
    {
      return new PipelineProperties(prototype, session);
    }

    #endregion

    #region Pipeline Properties

    /// <summary>
    /// (In) Country Code
    /// </summary>
    internal string CountryCode
    {
      get
      {
        try
        {
          if (!m_countrycode.HasValue)
          {
            m_countrycode.HasValue = true;
            m_countrycode.Value = m_session.GetStringProperty(m_countrycode.ID);
          }
        }
        catch (Exception ex)
        {
          m_countrycode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Tax.Plugins.BillSoft.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
        }

        return m_countrycode.IsNull ? null : m_countrycode.Value;
      }
    }

    /// <summary>
    /// (In) State Abbrviation
    /// </summary>
    internal string StateAbbr
    {
      get
      {
        try
        {
          if (!m_stateabbr.HasValue)
          {
            m_stateabbr.HasValue = true;
            m_stateabbr.Value = m_session.GetStringProperty(m_stateabbr.ID);
          }
        }
        catch (Exception ex)
        {
          m_stateabbr.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Tax.Plugins.BillSoft.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
        }

        return m_stateabbr.IsNull ? null : m_stateabbr.Value;
      }
    }

    /// <summary>
    /// (In) City
    /// </summary>
    internal string City
    {
      get
      {
        try
        {
          if (!m_city.HasValue)
          {
            m_city.HasValue = true;
            m_city.Value = m_session.GetStringProperty(m_city.ID);
          }
        }
        catch (Exception ex)
        {
          m_city.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Tax.Plugins.BillSoft.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
        }

        return m_city.IsNull ? null : m_city.Value;
      }
    }

    /// <summary>
    /// (In) Zip Code
    /// </summary>
    internal string ZipCode
    {
      get
      {
        try
        {
          if (!m_zipcode.HasValue)
          {
            m_zipcode.HasValue = true;
            m_zipcode.Value = m_session.GetStringProperty(m_zipcode.ID);
          }
        }
        catch (Exception ex)
        {
          m_zipcode.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Tax.Plugins.BillSoft.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
        }

        return m_zipcode.IsNull ? null : m_zipcode.Value;
      }
    }

    /// <summary>
    /// (In) NPANXXNumber
    /// </summary>
    internal string NPANXXNumber
    {
      get
      {
        try
        {
          if (!m_npanxxnumber.HasValue)
          {
            m_npanxxnumber.HasValue = true;
            m_npanxxnumber.Value = m_session.GetStringProperty(m_npanxxnumber.ID);
          }
        }
        catch (Exception ex)
        {
          m_npanxxnumber.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Tax.Plugins.BillSoft.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
        }

        return m_npanxxnumber.IsNull ? null : m_npanxxnumber.Value;
      }
    }

    /// <summary>
    /// (Out) Discovered PCode, or Zero if not able to resolve 
    /// </summary>
    internal long? TaxPCodeValue
    {
      set
      {
        if (!value.HasValue)
        {
          var message = Log(PlugInBase.LogLevel.Error,
                            "Cannot set pipeline values to null");
          throw new InvalidValueException(message);
        }

        m_session.SetLongProperty(m_taxpcodevalue.ID, value.Value);
        m_taxpcodevalue.Value = value.Value;
      }
    }

    //BINDING_ID_PROP

    #endregion
  }

  #endregion

  #region Binding Class

  [DebuggerStepThrough]
  internal class Binding<T>
  {
    #region Protected Variables

    protected readonly int m_id;
    protected bool m_hasValue;
    protected bool m_isNull;
    protected T m_value;

    #endregion

    internal Binding(int id)
    {
      m_id = id;
      m_value = default(T);
      m_isNull = false;
      m_hasValue = false;
    }

    internal bool HasValue
    {
      get { return m_hasValue; }
      set { m_hasValue = value; }
    }

    internal bool IsNull
    {
      get { return m_isNull; }
      set { m_isNull = value; }
    }

    internal T Value
    {
      get { return m_value; }
      set { m_value = value; }
    }

    internal int ID
    {
      get { return m_id; }
    }

    internal virtual void Reset()
    {
      m_hasValue = false;
      m_isNull = false;
      m_value = default(T);
    }
  }

  #endregion

#if CONTAINS_ENUMS
    #region EnumBinding Class
    internal sealed class EnumBinding<T> : Binding<T>
        where T : struct
    {
        #region Private Variables
        private readonly Dictionary<int, int> m_csToDb;
        private readonly Dictionary<int, int> m_dbToCs;
        private readonly string m_enumSpace;
        private readonly string m_enumName;
        #endregion

    #region Construction
        internal EnumBinding(int id, IEnumConfig enumConfig)
            : base(id)
        {
            m_csToDb = new Dictionary<int, int>();
            m_dbToCs = new Dictionary<int, int>();

            //build the enum id mapping
            object[] attrs = typeof(T).GetCustomAttributes(typeof(MTEnumAttribute), false);

            MTEnumAttribute info = attrs[0] as MTEnumAttribute;

            m_enumSpace = info.EnumSpace;
            m_enumName = info.EnumName;

            //get the ordinal of the value in the C# enum and save it along with the db id for the enum value
            foreach (string oldEnumStr in info.OldEnumValues)
            {
                if (!oldEnumStr.Contains(":"))
                    throw new InvalidEnumAttributeException(m_enumSpace + " " + m_enumName + " has an invalid OldEnumValues value on it's MTEnumAttribute");

                string[] set = oldEnumStr.Split(':');
                int ordinal = int.Parse(set[0]);
                string strVal = set[1];

                //trim extra quotes
                strVal = strVal.Trim('"');

                //get the id from the database
                int dbId = enumConfig.GetID(m_enumSpace, m_enumName, strVal);

                //add to both forward and reverse lookup lists
                //this will use up twice as much memory (still very little compared to everything else...)
                //but it will be just as fast for forward and reverse lookups
                m_csToDb.Add(ordinal, dbId);
                m_dbToCs.Add(dbId, ordinal);
            }
        }
        #endregion

    #region Properties and Methods
        internal int GetDatabaseIDForValue(T value)
        {
            return m_csToDb[Convert.ToInt32(value)];
        }
        internal void SetUsingDatabaseID(int dbId)
        {
            m_value = (T)Enum.ToObject(typeof(T), m_dbToCs[dbId]);
        }
        internal string EnumSpace
        {
            get { return m_enumSpace; }
        }
        internal string EnumName
        {
            get { return m_enumName; }
        }
        #endregion
    }
    #endregion
#endif
}