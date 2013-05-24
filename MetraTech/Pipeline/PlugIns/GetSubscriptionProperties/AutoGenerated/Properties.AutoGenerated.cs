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

namespace MetraTech.Custom.Plugins.Subscription
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
        private string m_querypath;
		private string m_querytagforsubscription;
		private string m_querytagforgroupsubscription;
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
			
            m_querypath = (string)GetValueFromParameter(generalConfigProps, "QueryPath");
            m_querytagforsubscription = (string)GetValueFromParameter(generalConfigProps, "QueryTagForSubscription");
            m_querytagforgroupsubscription = (string)GetValueFromParameter(generalConfigProps, "QueryTagForGroupSubscription");
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
        /// Path to query folder
        /// </summary>
        internal string QueryPath
        {
            get
            {
                return m_querypath;
            }
        }
        /// <summary>
        /// Query Tag for getting extended subscription properties
        /// </summary>
        internal string QueryTagForSubscription
        {
            get
            {
                return m_querytagforsubscription;
            }
        }
        /// <summary>
        /// Query Tag for getting extended Group Subscription properties
        /// </summary>
        internal string QueryTagForGroupSubscription
        {
            get
            {
                return m_querytagforgroupsubscription;
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
        private Binding<int> m_idsubscription;
		private Binding<bool> m_isgroupsubscription;
		private Binding<int> m_countrecords;
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
			
            m_idsubscription = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "IdSubscription")));
			m_isgroupsubscription = new Binding<bool>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "IsGroupSubscription")));
			m_countrecords = new Binding<int>(nameID.GetNameID(GetValueFromParameter(pipelineProps, "CountRecords")));
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

            m_idsubscription = new Binding<int>(prototype.m_idsubscription.ID);
			m_isgroupsubscription = new Binding<bool>(prototype.m_isgroupsubscription.ID);
			m_countrecords = new Binding<int>(prototype.m_countrecords.ID);
			//BINDING_ID_CLONE
        }
        #endregion

        #region Pipeline Properties
        /// <summary>
        /// (In) ID of Subscription or GroupSubscription
        /// </summary>
        internal int? IdSubscription
        {
            get
            {
                try
                {
                    if (!m_idsubscription.HasValue)
                    {
                        m_idsubscription.HasValue = true;
                        m_idsubscription.Value = m_session.GetIntegerProperty(m_idsubscription.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_idsubscription.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Subscription.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_idsubscription.IsNull)
                    return null;
                else
                    return m_idsubscription.Value;
            }
            
        }
		/// <summary>
        /// (In) 'true' - if IdSubscripton for Group (use id from t_group_sub) or 'false' - if not (use id from t_sub)
        /// </summary>
        internal bool? IsGroupSubscription
        {
            get
            {
                try
                {
                    if (!m_isgroupsubscription.HasValue)
                    {
                        m_isgroupsubscription.HasValue = true;
                        m_isgroupsubscription.Value = m_session.GetBooleanProperty(m_isgroupsubscription.ID);
                    }
                }
                #pragma warning disable 0168
                catch (Exception ex)
				#pragma warning restore 0168
                {
                    m_isgroupsubscription.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Subscription.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_isgroupsubscription.IsNull)
                    return null;
                else
                    return m_isgroupsubscription.Value;
            }
            
        }
		/// <summary>
        /// (Out) Returns the count of reqords from SELECT result
        /// </summary>
        internal int? CountRecords
        {
            
            set
            {
                if (!value.HasValue)
                {
                    string message = Log(MetraTech.Custom.Plugins.Subscription.PlugInBase.LogLevel.Error, "Cannot set pipeline values to null");
                    throw new InvalidValueException(message);
                }

                m_session.SetIntegerProperty(m_countrecords.ID, value.Value);
                m_countrecords.Value = value.Value;
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
