//////////////////////////////////////////////////////////////////////////////
// This file was automatically generated using ICE.
// Avoid making changes to this file.
///////////////////////////////////////////////////////////////////////////////
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Text;
using System.Runtime.InteropServices;
using System.Xml;
using MetraTech.Pipeline.PlugIns;
using MetraTech.Interop.SysContext;
using MetraTech.Interop.MTPipelineLib;
using MetraTech.Pipeline;
using MetraTech.Tax.Framework;
using IMTConfigPropSet = MetraTech.Interop.MTPipelineLib.IMTConfigPropSet;
using IMTSystemContext = MetraTech.Interop.SysContext.IMTSystemContext;
using IEnumConfig = MetraTech.Interop.SysContext.IEnumConfig;

namespace MetraTech.Tax.Plugins
{
    public abstract class PlugInBase : PipelinePlugIn
    {
        public enum LogLevel { Info, Warning, Error, Debug, Fatal, Off };
        public delegate string LogDelegate(LogLevel level, string message);

        #region Constants
        protected const int MARK_AS_FAILED_CODE_FAILED = -1;
        #endregion

        #region Variables
        private MTLog m_logger;
        private int? m_currentSessionID;
        private Properties m_prototype;
        private GeneralConfig m_generalConfig;
        #endregion

        protected void SetCurrentSession(ISession session)
        {
            m_currentSessionID = session.InternalID;
        }
        public override void Configure(object systemContext, IMTConfigPropSet propSet)
        {
            try
            {
                //Init the logger
                m_logger = ((MetraTech.Interop.SysContext.IMTSystemContext)systemContext).GetLog();

                Log(LogLevel.Debug, "Start");
				
				XmlDocument xmlConfig = new XmlDocument();
				xmlConfig.LoadXml(propSet.WriteToBuffer());

				if (xmlConfig.DocumentElement == null)
                {
                    throw new ConfigurationErrorsException(String.Format("Configuration does not set. Configuration content = '{0}'", xmlConfig.OuterXml));
                }

                //create the general config
				m_generalConfig = new GeneralConfig((IMTSystemContext)systemContext, xmlConfig);

                //create the properties prototype
				m_prototype = Properties.CreatePrototype(this.Log, (IMTSystemContext)systemContext, xmlConfig);               

                //call startup for any custom startup code
                StartUp((MetraTech.Interop.SysContext.IMTSystemContext)systemContext, propSet);
            }
            catch (Exception ex)
            {
                Log("Configuration failed", ex);
                throw new COMException("Configuration failed " + ex.Message, ex);
            }
        }
        public override void ProcessSessions(ISessionSet sessions)
        {
            Log(LogLevel.Debug, "VertexQ.PlugInBase.Start sessions");

            //add the sessions to a list
            List<ISession> sessionList = new List<ISession>();
            foreach (ISession session in sessions)
            {
                sessionList.Add(session);
            }

            Log(LogLevel.Debug, string.Format("sessionList.Count={0}", sessionList.Count));

            //create the PropertiesCollection
            PropertiesCollection propsCol =
                new PropertiesCollection(m_prototype,
                new System.Collections.ObjectModel.ReadOnlyCollection<ISession>(sessionList));

            //call the user's code to do the processing
            ProcessAllSessions(propsCol);
        }
        protected abstract void ProcessAllSessions(PropertiesCollection propsCol);
        protected virtual void StartUp(MetraTech.Interop.SysContext.IMTSystemContext systemContext, IMTConfigPropSet propSet) { }
        protected abstract void ProcessSession(Properties props);
        public override void Shutdown(){}
        /// <summary>
        /// Plug-in ProcessorInfo
        /// </summary>
        public override int ProcessorInfo
        {
            get
            {
                Log(LogLevel.Debug, "Start");
                return Constants.E_NOTIMPL;
            }
        }
        /// <summary>
        /// General configuration variables
        /// </summary>
        public GeneralConfig GeneralConfig
        {
            get { return m_generalConfig; }
        }

        #region Logging
        /// <summary>
        /// Writes an exception to the log
        /// </summary>
        internal string Log(string prefix, Exception ex)
        {
            string message = null;
            if (m_currentSessionID.HasValue)
                message = string.Format("{0} SessionID: {1}, Source: {2}, Message: {3}", prefix, m_currentSessionID.Value, ex.Source, ex.Message);
            else
                message = string.Format("{0} Source: {1}, Message: {2}", prefix, ex.Source, ex.Message);

            m_logger.LogString(MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR, message);

            return message;
        }
        /// <summary>
        /// Writes a message to the log.
        /// </summary>
        /// <param name="level">The severity of this log entry</param>
        /// <param name="message"></param>
        public string Log(LogLevel level, string message)
        {
            //-- NOTE: Do NOT call this method from an overload as it will throw off 
            //-- the FrameCount and make it unable to get the name of the calling method/type.

            //determine the sys context plugin log level
            MetraTech.Interop.SysContext.PlugInLogLevel? plLevel = null;
            switch (level)
            {
                case LogLevel.Info:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_INFO;
                    break;
                case LogLevel.Warning:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_WARNING;
                    break;
                case LogLevel.Error:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_ERROR;
                    break;
                case LogLevel.Fatal:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_FATAL;
                    break;
                case LogLevel.Off:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_OFF;
                    break;
                case LogLevel.Debug:
                    plLevel = MetraTech.Interop.SysContext.PlugInLogLevel.PLUGIN_LOG_DEBUG;
                    break;
            }

            if (!plLevel.HasValue)
                return string.Empty;

            //find out the name of the calling method
            string method = Utility.GetFQMethodName();

            string _message = null;
            if (m_currentSessionID.HasValue)
                _message = string.Format("{0}: SessionID: {1}, {2}", method, m_currentSessionID.Value, message);
            else
                _message = string.Format("{0}: {1}", method, message);

            m_logger.LogString(plLevel.Value, _message);

            return _message;
        }
        #endregion
    }
}
