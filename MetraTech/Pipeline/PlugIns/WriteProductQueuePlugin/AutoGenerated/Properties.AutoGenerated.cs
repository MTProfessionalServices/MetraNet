#region Generated using ICE (Do not modify this region)
/// Generated using ICE
/// ICE CodeGen Version: 1.0.0
#endregion
//////////////////////////////////////////////////////////////////////////////
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Diagnostics;
using System.Collections.Generic;

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

namespace MetraTech.Pipeline.Plugins.WriteProductQueue
{
    #region Properties class
    public class Properties
    {
        #region Variables
        private PipelineProperties m_pipeline;
        private ISession m_session;
        #endregion

        #region Construction
        internal static Properties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, IMTConfigPropSet propSet)
        {
            PipelineProperties pipelinePrototype = PipelineProperties.CreatePrototype(log, systemContext, propSet);

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
        private string m_factoryhostname;
        private string m_factoryprotocol;
        private int? m_factoryport;
        private string m_factoryvirtualhost;
        private int? m_requestedheartbeat;
        private string m_exchangename;
        private string m_applicationid;
        private string m_routingkey;
        private bool? m_confirmrouting;
        private bool? m_mandatoryrouting;
        private bool? m_immediatedelivery;
        private bool? m_persistentdelivery;
        private int? m_messagepriority;
        private string m_contentencoding;
        private string m_contenttype;
        private string m_expiration;
        private string m_messagetype;
        private string m_userid;
        private int? m_waittimeout;
        private string m_queuename;
        private string m_serializerclass;
        private int? m_batchsize = 1;
        //GENERAL_CONFIG_VAR
        #endregion

        #region Construction
        internal GeneralConfig(IMTSystemContext systemContext, IMTConfigPropSet propSet)
        {
            IMTConfigPropSet generalConfigProps = propSet.NextSetWithName("GeneralConfig");
            m_factoryhostname = (string)generalConfigProps.NextStringWithName("FactoryHostname");
            try
            {
                generalConfigProps.Reset();
                m_factoryprotocol = (string)generalConfigProps.NextStringWithName("FactoryProtocol");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("FactoryPort");
                if (!string.IsNullOrEmpty(val))
                {
                    m_factoryport = int.Parse(val);
                }
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_factoryvirtualhost = (string)generalConfigProps.NextStringWithName("FactoryVirtualHost");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("RequestedHeartbeat");
                if (!string.IsNullOrEmpty(val))
                {
                    m_requestedheartbeat = int.Parse(val);
                }
                //            m_requestedheartbeat = int.Parse(generalConfigProps.NextStringWithName("RequestedHeartbeat"));
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_exchangename = (string)generalConfigProps.NextStringWithName("ExchangeName");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_applicationid = (string)generalConfigProps.NextStringWithName("ApplicationId");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_routingkey = (string)generalConfigProps.NextStringWithName("RoutingKey");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("ConfirmRouting");
                if (!string.IsNullOrEmpty(val))
                {
                    m_confirmrouting = bool.Parse(val);
                }
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("MandatoryRouting");
                if (!string.IsNullOrEmpty(val))
                {
                    m_mandatoryrouting = bool.Parse(val);
                }
                //            m_mandatoryrouting = bool.Parse(generalConfigProps.NextStringWithName("MandatoryRouting"));
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("ImmediateDelivery");
                if (!string.IsNullOrEmpty(val))
                {
                    m_immediatedelivery = bool.Parse(val);
                }
                //            m_immediatedelivery = bool.Parse(generalConfigProps.NextStringWithName("ImmediateDelivery"));
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("PersistentDelivery");
                if (!string.IsNullOrEmpty(val))
                {
                    m_persistentdelivery = bool.Parse(val);
                }
                //            m_persistentdelivery = bool.Parse(generalConfigProps.NextStringWithName("PersistentDelivery"));
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("MessagePriority");
                if (!string.IsNullOrEmpty(val))
                {
                    m_messagepriority = int.Parse(val);
                }
                //            m_messagepriority = int.Parse(generalConfigProps.NextStringWithName("MessagePriority"));
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_contentencoding = (string)generalConfigProps.NextStringWithName("ContentEncoding");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_contenttype = (string)generalConfigProps.NextStringWithName("ContentType");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_expiration = (string)generalConfigProps.NextStringWithName("Expiration");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_messagetype = (string)generalConfigProps.NextStringWithName("MessageType");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_userid = (string)generalConfigProps.NextStringWithName("UserId");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("WaitTimeout");
                if (!string.IsNullOrEmpty(val))
                {
                    m_waittimeout = int.Parse(val);
                }
            }
            catch
            {
            }
            //            m_asynctimeout = int.Parse(generalConfigProps.NextStringWithName("AsyncTimeout"));
            try
            {
                generalConfigProps.Reset();
                m_queuename = (string)generalConfigProps.NextStringWithName("QueueName");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                m_serializerclass = (string)generalConfigProps.NextStringWithName("SerializerClass");
            }
            catch
            {
            }
            try
            {
                generalConfigProps.Reset();
                var val = generalConfigProps.NextStringWithName("BatchSize");
                if (!string.IsNullOrEmpty(val))
                {
                    m_batchsize = int.Parse(val);
                }
                //            m_batchsize = bool.Parse(generalConfigProps.NextStringWithName("BatchSize"));
            }
            catch
            {
            }
            //GENERAL_CONFIG_ASSIGN
        }
        #endregion

        #region General Config Properties
        /// <summary>
        /// Factory Hostname
        /// </summary>
        internal string FactoryHostname
        {
            get
            {
                return m_factoryhostname;
            }
        }
        /// <summary>
        /// Factory Protocol
        /// </summary>
        internal string FactoryProtocol
        {
            get
            {
                return m_factoryprotocol;
            }
        }
        /// <summary>
        /// Factory Port
        /// </summary>
        internal int? FactoryPort
        {
            get
            {
                return m_factoryport;
            }
        }
        /// <summary>
        /// Factory Virtual Host
        /// </summary>
        internal string FactoryVirtualHost
        {
            get
            {
                return m_factoryvirtualhost;
            }
        }
        /// <summary>
        /// Requested Heartbeat
        /// </summary>
        internal int? RequestedHeartbeat
        {
            get
            {
                return m_requestedheartbeat;
            }
        }
        /// <summary>
        /// Exchange Name
        /// </summary>
        internal string ExchangeName
        {
            get
            {
                return m_exchangename;
            }
        }
        /// <summary>
        /// Application Id
        /// </summary>
        internal string ApplicationId
        {
            get
            {
                return m_applicationid;
            }
        }
        /// <summary>
        /// Routing Key
        /// </summary>
        internal string RoutingKey
        {
            get
            {
                return m_routingkey;
            }
        }
        /// <summary>
        /// Mandatory Routing
        /// </summary>
        internal bool? MandatoryRouting
        {
            get
            {
                return m_mandatoryrouting;
            }
        }
        /// <summary>
        /// Confirm Routing
        /// </summary>
        internal bool? ConfirmRouting
        {
            get
            {
                return m_confirmrouting;
            }
        }
        /// <summary>
        /// Immediate Delivery
        /// </summary>
        internal bool? ImmediateDelivery
        {
            get
            {
                return m_immediatedelivery;
            }
        }
        /// <summary>
        /// Persistent Delivery
        /// </summary>
        internal bool? PersistentDelivery
        {
            get
            {
                return m_persistentdelivery;
            }
        }
        /// <summary>
        /// Batch Size
        /// </summary>
        internal int? BatchSize
        {
            get
            {
                return m_batchsize;
            }
        }
        /// <summary>
        /// Message Priority
        /// </summary>
        internal int? MessagePriority
        {
            get
            {
                return m_messagepriority;
            }
        }
        /// <summary>
        /// Content Encoding
        /// </summary>
        internal string ContentEncoding
        {
            get
            {
                return m_contentencoding;
            }
        }
        /// <summary>
        /// Content Type
        /// </summary>
        internal string ContentType
        {
            get
            {
                return m_contenttype;
            }
        }
        /// <summary>
        /// Expiration
        /// </summary>
        internal string Expiration
        {
            get
            {
                return m_expiration;
            }
        }
        /// <summary>
        /// Message Type
        /// </summary>
        internal string MessageType
        {
            get
            {
                return m_messagetype;
            }
        }
        /// <summary>
        /// User Id
        /// </summary>
        internal string UserId
        {
            get
            {
                return m_userid;
            }
        }
        /// <summary>
        /// How often to poll for sessions being completed
        /// </summary>
        internal int? WaitTimeout
        {
            get
            {
                return m_waittimeout;
            }
        }
        /// <summary>
        /// Name of the queue, as specified in Servers.xml, used to lookup username and password
        /// </summary>
        internal string QueueName
        {
            get
            {
                return m_queuename;
            }
        }
        /// <summary>
        /// The name of the serializer to use
        /// </summary>
        internal string SerializerClass
        {
            get
            {
                return m_serializerclass;
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
        private Binding<string> m_applicationid;
        private Binding<string> m_exchangename;
        private Binding<string> m_correlationid;
        private Binding<string> m_messageid;
        private Binding<string> m_routingkey;
        private Binding<int> m_messagepriority;
        private Binding<string> m_expiration;
        private Binding<DateTime> m_timestamp;
        private Binding<string> m_userid;
        private Binding<string> m_messagetype;
        private Binding<string> m_replyto;
        //BINDING_ID_VAR
        #endregion

        #region Construction
        internal static PipelineProperties CreatePrototype(PlugInBase.LogDelegate log, IMTSystemContext systemContext, IMTConfigPropSet propSet)
        {
            return new PipelineProperties(log, systemContext, propSet);
        }
        internal static PipelineProperties Create(PipelineProperties prototype, ISession session)
        {
            return new PipelineProperties(prototype, session);
        }
        private PipelineProperties(PlugInBase.LogDelegate log, IMTSystemContext systemContext, IMTConfigPropSet propSet)
        {
            Log = log;

            //Init the enum config
            m_enumConfig = systemContext.GetEnumConfig();

            //get the nameID
            IMTNameID nameID = systemContext.GetNameID();

            IMTConfigPropSet pipelineProps = propSet.NextSetWithName("PipelineBinding");
            IMTConfigProp prop = null;
            while (true)
            {
                prop = pipelineProps.Next();
                if (prop == null)
                    break;

                if (prop.PropValue != null)
                {
                    switch (prop.Name)
                    {
                        case "ApplicationId":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_applicationid = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "ExchangeName":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_exchangename = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "CorrelationId":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_correlationid = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "MessageId":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_messageid = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "RoutingKey":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_routingkey = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "MessagePriority":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_messagepriority = new Binding<int>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "Expiration":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_expiration = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "Timestamp":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_timestamp = new Binding<DateTime>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "UserId":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_userid = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "MessageType":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_messagetype = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        case "ReplyTo":
                            if (string.IsNullOrEmpty(prop.ValueAsString))
                            {
                                break;
                            }
                            m_replyto = new Binding<string>(nameID.GetNameID(prop.ValueAsString));
                            break;
                        //BINDING_ID_ASSIGN
                    }
                }
            }
            Log(PlugInBase.LogLevel.Debug, "Finished loading properties...");
        }
        private PipelineProperties(PipelineProperties prototype, ISession session)
        {
            m_session = session;
            m_enumConfig = prototype.m_enumConfig;
            Log = prototype.Log;

            if (prototype.m_applicationid != null)
            {
                m_applicationid = new Binding<string>(prototype.m_applicationid.ID);
            }
            if (prototype.m_exchangename != null)
            {
                m_exchangename = new Binding<string>(prototype.m_exchangename.ID);
            }
            if (prototype.m_correlationid != null)
            {
                m_correlationid = new Binding<string>(prototype.m_correlationid.ID);
            }
            if (prototype.m_messageid != null)
            {
                m_messageid = new Binding<string>(prototype.m_messageid.ID);
            }
            if (prototype.m_routingkey != null)
            {
                m_routingkey = new Binding<string>(prototype.m_routingkey.ID);
            }
            if (prototype.m_messagepriority != null)
            {
                m_messagepriority = new Binding<int>(prototype.m_messagepriority.ID);
            }
            if (prototype.m_expiration != null)
            {
                m_expiration = new Binding<string>(prototype.m_expiration.ID);
            }
            if (prototype.m_timestamp != null)
            {
                m_timestamp = new Binding<DateTime>(prototype.m_timestamp.ID);
            }
            if (prototype.m_userid != null)
            {
                m_userid = new Binding<string>(prototype.m_userid.ID);
            }
            if (prototype.m_messagetype != null)
            {
                m_messagetype = new Binding<string>(prototype.m_messagetype.ID);
            }
            if (prototype.m_replyto != null)
            {
                m_replyto = new Binding<string>(prototype.m_replyto.ID);
            }
            //BINDING_ID_CLONE
        }
        #endregion

        #region Pipeline Properties
        /// <summary>
        /// (In) Application Id
        /// </summary>
        internal string ApplicationId
        {
            get
            {
                if (m_applicationid == null)
                {
                    return null;
                }
                try
                {
                    if (!m_applicationid.HasValue)
                    {
                        m_applicationid.HasValue = true;
                        m_applicationid.Value = m_session.GetStringProperty(m_applicationid.ID);
                    }
                }
                catch
                {
                    m_applicationid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_applicationid.IsNull)
                    return null;
                else
                    return m_applicationid.Value;
            }

        }
        /// <summary>
        /// (In) Exchange Name
        /// </summary>
        internal string ExchangeName
        {
            get
            {
                if (m_exchangename == null)
                {
                    return null;
                }
                try
                {
                    if (!m_exchangename.HasValue)
                    {
                        m_exchangename.HasValue = true;
                        m_exchangename.Value = m_session.GetStringProperty(m_exchangename.ID);
                    }
                }
                catch
                {
                    m_exchangename.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_exchangename.IsNull)
                    return null;
                else
                    return m_exchangename.Value;
            }

        }
        /// <summary>
        /// (In) Correlation Id
        /// </summary>
        internal string CorrelationId
        {
            get
            {
                if (m_correlationid == null)
                {
                    return null;
                }
                try
                {
                    if (!m_correlationid.HasValue)
                    {
                        m_correlationid.HasValue = true;
                        m_correlationid.Value = m_session.GetStringProperty(m_correlationid.ID);
                    }
                }
                catch
                {
                    m_correlationid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_correlationid.IsNull)
                    return null;
                else
                    return m_correlationid.Value;
            }

        }
        /// <summary>
        /// (In) Message Id
        /// </summary>
        internal string MessageId
        {
            get
            {
                if (m_messageid == null)
                {
                    return null;
                }
                try
                {
                    if (!m_messageid.HasValue)
                    {
                        m_messageid.HasValue = true;
                        m_messageid.Value = m_session.GetStringProperty(m_messageid.ID);
                    }
                }
                catch
                {
                    m_messageid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_messageid.IsNull)
                    return null;
                else
                    return m_messageid.Value;
            }

        }
        /// <summary>
        /// (In) Routing Key
        /// </summary>
        internal string RoutingKey
        {
            get
            {
                if (m_routingkey == null)
                {
                    return null;
                }
                try
                {
                    if (!m_routingkey.HasValue)
                    {
                        m_routingkey.HasValue = true;
                        m_routingkey.Value = m_session.GetStringProperty(m_routingkey.ID);
                    }
                }
                catch
                {
                    m_routingkey.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_routingkey.IsNull)
                    return null;
                else
                    return m_routingkey.Value;
            }

        }
        /// <summary>
        /// (In) Message Priority
        /// </summary>
        internal int? MessagePriority
        {
            get
            {
                if (m_messagepriority == null)
                {
                    return null;
                }
                try
                {
                    if (!m_messagepriority.HasValue)
                    {
                        m_messagepriority.HasValue = true;
                        m_messagepriority.Value = m_session.GetIntegerProperty(m_messagepriority.ID);
                    }
                }
                catch
                {
                    m_messagepriority.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_messagepriority.IsNull)
                    return null;
                else
                    return m_messagepriority.Value;
            }

        }
        /// <summary>
        /// (In) Expiration
        /// </summary>
        internal string Expiration
        {
            get
            {
                if (m_expiration == null)
                {
                    return null;
                }
                try
                {
                    if (!m_expiration.HasValue)
                    {
                        m_expiration.HasValue = true;
                        m_expiration.Value = m_session.GetStringProperty(m_expiration.ID);
                    }
                }
                catch
                {
                    m_expiration.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_expiration.IsNull)
                    return null;
                else
                    return m_expiration.Value;
            }

        }
        /// <summary>
        /// (In) Timestamp
        /// </summary>
        internal DateTime? Timestamp
        {
            get
            {
                if (m_timestamp == null)
                {
                    return null;
                }
                try
                {
                    if (!m_timestamp.HasValue)
                    {
                        m_timestamp.HasValue = true;
                        m_timestamp.Value = m_session.GetDateTimeProperty(m_timestamp.ID);
                    }
                }
                catch
                {
                    m_timestamp.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_timestamp.IsNull)
                    return null;
                else
                    return m_timestamp.Value;
            }

        }
        /// <summary>
        /// (In) User Id
        /// </summary>
        internal string UserId
        {
            get
            {
                if (m_userid == null)
                {
                    return null;
                }
                try
                {
                    if (!m_userid.HasValue)
                    {
                        m_userid.HasValue = true;
                        m_userid.Value = m_session.GetStringProperty(m_userid.ID);
                    }
                }
                catch
                {
                    m_userid.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_userid.IsNull)
                    return null;
                else
                    return m_userid.Value;
            }

        }
        /// <summary>
        /// (In) Message Type
        /// </summary>
        internal string MessageType
        {
            get
            {
                if (m_messagetype == null)
                {
                    return null;
                }
                try
                {
                    if (!m_messagetype.HasValue)
                    {
                        m_messagetype.HasValue = true;
                        m_messagetype.Value = m_session.GetStringProperty(m_messagetype.ID);
                    }
                }
                catch
                {
                    m_messagetype.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_messagetype.IsNull)
                    return null;
                else
                    return m_messagetype.Value;
            }

        }
        /// <summary>
        /// (In) Reply To Address
        /// </summary>
        internal string ReplyTo
        {
            get
            {
                if (m_replyto == null)
                {
                    return null;
                }
                try
                {
                    if (!m_replyto.HasValue)
                    {
                        m_replyto.HasValue = true;
                        m_replyto.Value = m_session.GetStringProperty(m_replyto.ID);
                    }
                }
                catch
                {
                    m_replyto.IsNull = true;
#if ERROR_ON_NULL_GET
                    string message = Log(MetraTech.Custom.Plugins.Core.PlugInBase.LogLevel.Error, "An error occurred when trying to get the value");
                    throw new InvalidValueException(message, ex);
#endif
                }

                if (m_replyto.IsNull)
                    return null;
                else
                    return m_replyto.Value;
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
