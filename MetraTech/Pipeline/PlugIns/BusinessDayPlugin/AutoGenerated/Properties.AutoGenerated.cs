#region Generated using ICE (Do not modify this region)
/// Generated using ICE
/// ICE CodeGen Version: 1.0.0
#endregion
//////////////////////////////////////////////////////////////////////////////
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Diagnostics;
using System.Configuration;
using System.Collections.Generic;
using System.Xml;
using MetraTech.Pipeline;
using MetraTech.Interop.MTPipelineLib;
//STANDARD_ENUM_REFERENCES

using IMTSystemContext = MetraTech.Interop.SysContext.IMTSystemContext;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;
using MTLog = MetraTech.Interop.SysContext.MTLog;
using IMTNameID = MetraTech.Interop.SysContext.IMTNameID;
using IEnumConfig = MetraTech.Interop.SysContext.IEnumConfig;
using System.Collections.ObjectModel;
//ENUM_USING

namespace MetraTech.Pipeline.Plugins
{
    #region Properties class
    public class Properties
    {
        #region Variables
        private PipelineProperties m_pipeline;
        private ISession m_session;
        #endregion

        #region Construction
        internal static Properties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
			PipelineProperties pipelinePrototype = PipelineProperties.CreatePrototype(log, systemContext, xmlConfig);

            return new Properties(pipelinePrototype);
        }
        internal static Properties Create(Properties prototype, ISession session)
        {
            PipelineProperties pipeline = PipelineProperties.Create(prototype.m_pipeline, session);

            return new Properties(pipeline, session);
        }
        private Properties(PipelineProperties pipeline) : this(pipeline, null) { }
        private Properties(PipelineProperties pipeline, ISession session)
        {
            m_pipeline = pipeline;
            m_session = session;
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
        private bool? m_calculateholidays;
		private bool? m_loadcalendars;
		private int? m_defaultcalendarid;
		private string m_defaultcalendarname;
		private long? m_reloadwait;
		//GENERAL_CONFIG_VAR
        #endregion

        #region Construction 
		private const string GeneralConfigTag = "GeneralConfig";
        private readonly string XPathToGeneralConfig = String.Format("{0}", GeneralConfigTag);
        internal GeneralConfig(IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            XmlNode generalConfigProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToGeneralConfig);

            if (generalConfigProps == null)
            {
                throw new ConfigurationException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
					, GeneralConfigTag, XPathToGeneralConfig, xmlConfig.OuterXml));
            }
			
            m_calculateholidays = bool.Parse(GetValueFromParameter(generalConfigProps, "CalculateHolidays"));
            m_loadcalendars = bool.Parse(GetValueFromParameter(generalConfigProps, "LoadCalendars"));
            m_defaultcalendarid = int.Parse(GetValueFromParameter(generalConfigProps, "DefaultCalendarId"));
            m_defaultcalendarname = (string)GetValueFromParameter(generalConfigProps, "DefaultCalendarName");
            m_reloadwait = long.Parse(GetValueFromParameter(generalConfigProps, "ReloadWait"));
            //GENERAL_CONFIG_ASSIGN
        }
		
		private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                    , paramName, GeneralConfigTag, node.OuterXml));
            }
            return childNode.InnerText;
        }
        #endregion

        #region General Config Properties
        /// <summary>
        /// Whether to calculate holidays or not
        /// </summary>
        internal bool? CalculateHolidays
        {
            get
            {
                return m_calculateholidays;
            }
        }
        /// <summary>
        /// Whether to load the working days per calendar from database, or just use Saturday/Sunday.
        /// </summary>
        internal bool? LoadCalendars
        {
            get
            {
                return m_loadcalendars;
            }
        }
        /// <summary>
        /// If no calendar is specified in the pipeline, will use this default calendar
        /// </summary>
        internal int? DefaultCalendarId
        {
            get
            {
                return m_defaultcalendarid;
            }
        }
        /// <summary>
        /// If no calendar is specified in the pipeline, and no DefaultCalendarId is specified, then use this calendar
        /// </summary>
        internal string DefaultCalendarName
        {
            get
            {
                return m_defaultcalendarname;
            }
        }
        /// <summary>
        /// Number of seconds to wait between reloading the calendar tables.
        /// </summary>
        internal long? ReloadWait
        {
            get
            {
                return m_reloadwait;
            }
        }
        //GENERAL_CONFIG_PROP
        #endregion
    }
    #endregion

    #region Properties Collection class
    public sealed class PropertiesCollection : IEnumerable<Properties>
    {
        private ReadOnlyCollection<ISession> m_sessions;
        private Properties m_prototype;

        public PropertiesCollection(Properties prototype, ReadOnlyCollection<ISession> sessions)
        {
            m_sessions = sessions;
            m_prototype = prototype;
        }

        public int IndexOf(Properties item)
        {
            return m_sessions.IndexOf(item.Session);
        }

        public Properties this[int index]
        {
            get
            {
                return Properties.Create(m_prototype, m_sessions[index]);
            }
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

        public int Count
        {
            get { return m_sessions.Count; }
        }

        public bool IsReadOnly
        {
            get { return true; }
        }

        public IEnumerator<Properties> GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            return new PropertiesEnumerator(this);
        }

        public struct PropertiesEnumerator : IEnumerator<Properties>
        {
            private PropertiesCollection m_propsCol;
            private int m_index;
            private const int START = -1;

            public PropertiesEnumerator(PropertiesCollection propsCol)
            {
                m_propsCol = propsCol;
                m_index = START;
            }
            public Properties Current
            {
                get
                {
                    return m_propsCol[m_index];
                }
            }
            public void Dispose()
            {
                m_propsCol = null;
                m_index = START;
            }
            object System.Collections.IEnumerator.Current
            {
                get { return this.Current; }
            }

            public bool MoveNext()
            {
                if ((m_index + 1) <= (m_propsCol.Count - 1))
                {
                    ++m_index;
                    return true;
                }
                else
                    return false;
            }

            public void Reset()
            {
                m_index = START;
            }
        }
    }
    #endregion

    #region PipelineProperties Class
    public sealed class PipelineProperties
    {
        #region Non-Pipeline variables
        private ISession m_session;
        private IEnumConfig m_enumConfig;
        private PlugInBase.LogDelegate Log;
        #endregion

        #region Pipeline variables
        private Binding<DateTime> m_startdate;
        private Binding<DateTime> m_enddate;
        private Binding<int> m_calendarid;
        private Binding<string> m_calendarname;
        private Binding<int> m_numbusinessdays;
        private Binding<int> m_numholidays;
        //BINDING_ID_VAR
        #endregion

        #region Construction
        internal static PipelineProperties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
			return new PipelineProperties(log, systemContext, xmlConfig);
        }
        internal static PipelineProperties Create(PipelineProperties prototype, ISession session)
        {
            return new PipelineProperties(prototype, session);
        }
		
		private const string PipelineBinding = "PipelineBinding";
        private readonly string XPathToPipelineBinding = String.Format("{0}", PipelineBinding);
        private PipelineProperties(PlugInBase.LogDelegate log, IMTSystemContext systemContext, XmlDocument xmlConfig)
        {
            Log = log;

            //Init the enum config
            m_enumConfig = systemContext.GetEnumConfig();

            //get the nameID
            IMTNameID nameID = systemContext.GetNameID();

            XmlNode pipelineProps = xmlConfig.DocumentElement.SelectSingleNode(XPathToPipelineBinding);

            if (pipelineProps == null)
            {
                throw new ConfigurationException(String.Format("The '{0}' was not found in t xpath = {1}. Can not configure Plug-in. Configuration content = '{2}'"
					, PipelineBinding, XPathToPipelineBinding, xmlConfig.OuterXml));
            }
			
            m_startdate = new Binding<DateTime>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "StartDate")));
			m_enddate = new Binding<DateTime>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "EndDate")));
			m_calendarid = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CalendarId")));
			m_calendarname = new Binding<string>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CalendarName")));
			m_numbusinessdays = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "NumBusinessDays")));
			m_numholidays = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "NumHolidays")));
			//BINDING_ID_ASSIGN            
        }
		
		 private static string GetValueFromParameter(XmlNode node, string paramName)
        {
            XmlNode childNode = node.SelectSingleNode(paramName);
            if (childNode == null)
            {
                throw new ConfigurationException(String.Format("The '{0}' parametr name does not set into '{1}'. Section content = '{2}'"
                   , paramName, PipelineBinding, node.OuterXml));
            }
            return childNode.InnerText;
        }
		
        private PipelineProperties(PipelineProperties prototype, ISession session)
        {
            m_session = session;
            m_enumConfig = prototype.m_enumConfig;
            Log = prototype.Log;

            m_startdate = new Binding<DateTime>(prototype.m_startdate.ID);
			m_enddate = new Binding<DateTime>(prototype.m_enddate.ID);
			m_calendarid = new Binding<int>(prototype.m_calendarid.ID);
			m_calendarname = new Binding<string>(prototype.m_calendarname.ID);
			m_numbusinessdays = new Binding<int>(prototype.m_numbusinessdays.ID);
			m_numholidays = new Binding<int>(prototype.m_numholidays.ID);
			//BINDING_ID_CLONE
        }
        #endregion

        #region Pipeline Properties
        /// <summary>
        /// (In) The start date (inclusive)
        /// </summary>
        internal DateTime? StartDate
        {
            get
            {
                try
                {
                    if (!m_startdate.HasValue)
                    {
                        m_startdate.HasValue = true;
                        m_startdate.Value = m_session.GetDateTimeProperty(m_startdate.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_startdate.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_startdate.IsNull)
                    return null;
                else
                    return m_startdate.Value;
            }
            
        }
		/// <summary>
        /// (In) The end date (inclusive)
        /// </summary>
        internal DateTime? EndDate
        {
            get
            {
                try
                {
                    if (!m_enddate.HasValue)
                    {
                        m_enddate.HasValue = true;
                        m_enddate.Value = m_session.GetDateTimeProperty(m_enddate.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_enddate.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_enddate.IsNull)
                    return null;
                else
                    return m_enddate.Value;
            }
            
        }
		/// <summary>
        /// (In/Out) The calendar id to use
        /// </summary>
        internal int? CalendarId
        {
            get
            {
                try
                {
                    if (!m_calendarid.HasValue)
                    {
                        m_calendarid.HasValue = true;
                        m_calendarid.Value = m_session.GetIntegerProperty(m_calendarid.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_calendarid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_calendarid.IsNull)
                    return null;
                else
                    return m_calendarid.Value;
            }
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Pipeline.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetIntegerProperty(m_calendarid.ID, value.Value);
                m_calendarid.Value = value.Value;
            }
        }
		/// <summary>
        /// (In/Out) The calendar name to use (not used if CalendarId is set)
        /// </summary>
        internal string CalendarName
        {		
            get
            {
                try
                {
                    if (!m_calendarname.HasValue)
                    {
                        m_calendarname.HasValue = true;
                        m_calendarname.Value = m_session.GetStringProperty(m_calendarname.ID);
                    }
                }
				#pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_calendarname.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_calendarname.IsNull)
                    return null;
                else
                    return m_calendarname.Value;
            }
            set
            {
                if (value == null)
                {
                    string message = Log(MetraTech.Pipeline.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetStringProperty(m_calendarname.ID, value);
                m_calendarname.Value = value;
            }
        }
		/// <summary>
        /// (Out) The number of business days (including holidays)
        /// </summary>
        internal int? NumBusinessDays
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Pipeline.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetIntegerProperty(m_numbusinessdays.ID, value.Value);
                m_numbusinessdays.Value = value.Value;
            }
        }
		/// <summary>
        /// (Out) The number of holidays
        /// </summary>
        internal int? NumHolidays
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Pipeline.Plugins.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetIntegerProperty(m_numholidays.ID, value.Value);
                m_numholidays.Value = value.Value;
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
        protected T m_value;
        protected bool m_isNull;
        protected bool m_hasValue;
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
