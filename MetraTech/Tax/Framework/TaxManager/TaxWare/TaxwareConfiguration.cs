//=============================================================================
// Copyright 1997-2012 by MetraTech
// All rights reserved.
//
// THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
// REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
// example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
// WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
// OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
// INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
// RIGHTS.
//
// Title to copyright in this software and any associated
// documentation shall at all times remain with MetraTech, and USER
// agrees to preserve the same.
//
//=============================================================================

using System;
using System.IO;
using MetraTech.Interop.RCD;
using MetraTech.Xml;
using System.Xml;
using MetraTech.Security.Crypto;

namespace MetraTech.Tax.Framework.Taxware
{
    /// <summary>
    /// Reads configuration parameter values from configuration files,
    /// stores them in member variables, and provides access to the configuration values
    /// IMPORTANT: move user/password to servers.xml and make the password encrypted.
    /// </summary>
    public class TaxwareConfiguration
    {
        private static readonly Logger m_Logger = new Logger("[TaxManager.TaxwareConfiguration]");


        /// <summary>
        /// Reads configuration parameter values from configuration files
        /// and stores them in member variables.
        /// </summary>
        public TaxwareConfiguration()
        {
            try
            {
                IMTRcd rcd = new MTRcd();
                m_ConfigFile = Path.Combine(rcd.ExtensionDir, @"Taxware\config\TaxwareConfig.xml");

                if (!File.Exists(m_ConfigFile))
                {
                    string err = System.Reflection.MethodBase.GetCurrentMethod().Name +
                        ": config file " + m_ConfigFile + " does not exist";
                    m_Logger.LogError(err);
                    throw new TaxException(err);
                }

                m_ServersXmlFile = Path.Combine(rcd.ExtensionDir, @"Taxware\config\ServerAccess\servers.xml");

                if (!File.Exists(m_ServersXmlFile))
                {
                    string err = System.Reflection.MethodBase.GetCurrentMethod().Name +
                        ": config file " + m_ServersXmlFile + " does not exist";
                    m_Logger.LogError(err);
                    throw new TaxException(err);
                }

                MTXmlDocument configDoc = new MTXmlDocument();
                configDoc.Load(m_ConfigFile);

                try
                {
                    m_NumWorkerThreads = configDoc.GetNodeValueAsInt("/xmlconfig/Taxware/NumWorkerThreads");
                }
                catch (Exception e)
                {
                    m_Logger.LogError("{0}: failed to retrieve NumWorkerThreads from {1}, using 10, {2}",
                        System.Reflection.MethodBase.GetCurrentMethod().Name,
                        m_ConfigFile, e.Message);
                    m_NumWorkerThreads = 10;
                }

                MTXmlDocument serversXmlDoc = new MTXmlDocument();
                serversXmlDoc.Load(m_ServersXmlFile);

                try
                {
                    m_UserName = serversXmlDoc.GetNodeValueAsString("//username");
                }
                catch (Exception e)
                {
                    m_Logger.LogError("{0}: failed to retrieve UserName from {1}, using default, {2}",
                        System.Reflection.MethodBase.GetCurrentMethod().Name,
                        m_ServersXmlFile, e.Message);
                    m_UserName = "Admin";
                }

                try
                {
                    XmlNode passwordNode = serversXmlDoc.SelectSingleNode("//password");
                    XmlAttribute encrypted = passwordNode.Attributes["encrypted"];
                    if ((encrypted == null) || (encrypted.Value == "false"))
                    {
                        m_Password = passwordNode.InnerText;
                        
                    }
                    else
                    {
                        CryptoManager mgr = new CryptoManager();
                        m_Password = mgr.Decrypt(CryptKeyClass.DatabasePassword, passwordNode.InnerText);
                        
                    }
                    
                }
                catch (Exception e)
                {
                    m_Logger.LogError("{0}: failed to retrieve Password from {1}, using default, {2}",
                        System.Reflection.MethodBase.GetCurrentMethod().Name,
                        m_ServersXmlFile, e.Message);
                    m_Password = "Admin123";
                }

                try
                {
                    m_Address = serversXmlDoc.GetNodeValueAsString("//address");
                }
                catch (Exception e)
                {
                    m_Logger.LogError("{0}: failed to retrieve address/url from {1}, using '{2}', {3}",
                        System.Reflection.MethodBase.GetCurrentMethod().Name,
                        m_ServersXmlFile,
                        "http://twe001:8086/twe/services/TaxCalculationManagerService",
                        e.Message);
                    m_Address = "http://twe001:8086/twe/services/TaxCalculationManagerService";
                }
            }
            catch (Exception ex)
            {
                m_Logger.LogException(@"Please check your Taxmanager\Vendor\Taxware configuration file", ex);
                throw ex;
            }
        }

        // General Taxware config file.  It currently only contains one parameter.
        private readonly string m_ConfigFile = "";

        // Server.XML file contains user/password info for communicating with TWE
        private readonly string m_ServersXmlFile = "";

        /// <summary> 
        /// Determines how many threads that the Taxware tax manager should spawn
        /// </summary>
        private readonly int m_NumWorkerThreads = 10;
        public int NumWorkerThreads
        {
            get { return m_NumWorkerThreads; }
        }

        /// <summary> 
        /// Used in <secrtySbj><usrname>DanS</usrname><pswrd>APT'6a$9I,B4</pswrd></secrtySbj> 
        /// within calculateDocumentRequest message
        /// </summary>
        private readonly string m_UserName;
        public string UserName
        {
            get { return m_UserName; }
        }

        /// <summary> 
        /// Used in <secrtySbj><usrname>DanS</usrname><pswrd>APT'6a$9I,B4</pswrd></secrtySbj> 
        /// within calculateDocumentRequest message
        /// </summary>
        private readonly string m_Password;
        public string Password
        {
            get { return m_Password; }
        
        }

        /// <summary> 
        /// Address or URL where the TWE server lives e.g.
        /// http://twe001:8086/twe/services/TaxCalculationManagerService
        /// </summary>
        private readonly string m_Address;
        public string Address
        {
            get { return m_Address; }
        }


    }
}
