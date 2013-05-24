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

namespace MetraTech.Tax.Framework.MetraTax
{
    /// <summary>
    /// Reads configuration parameter values from configuration files,
    /// stores them in member variables, and provides access to the configuration values
    /// </summary>
    public class MetraTaxConfiguration
    {
        private static readonly Logger m_Logger = new Logger("[TaxManager.MetraTaxConfiguration]");

        /// <summary>
        /// Reads configuration parameter values from configuration files
        /// and stores them in member variables.
        /// </summary>
        public MetraTaxConfiguration()
        {
            // Default values
            m_shouldUseCountryName = false;
            m_jurisdicationToUse = 0; // federal

            try
            {
                IMTRcd rcd = new MTRcd();
                m_ConfigFile = Path.Combine(rcd.ExtensionDir, @"MetraTax\config\MetraTaxConfig.xml");

                if (!File.Exists(m_ConfigFile))
                {
                    m_Logger.LogError("Config file " + m_ConfigFile + " does not exist");
                    return;
                }

                MTXmlDocument configDoc = new MTXmlDocument();
                configDoc.Load(m_ConfigFile);

                try
                {
                    m_shouldUseCountryName = configDoc.GetNodeValueAsBool("/xmlconfig/MetraTax/ShouldUseCountryName");
                }
                catch (Exception)
                {
                    m_Logger.LogError("Failed to retrieve ShouldUseCountryName from MetraTaxConfig.xml");
                }

                try
                {
                    int jurisdication = configDoc.GetNodeValueAsInt("/xmlconfig/MetraTax/JurisdicationToUse");
                    if (jurisdication < 0 || jurisdication > 4)
                    {
                        m_Logger.LogError("Encountered invalid juridication in MetraTaxConfig.xml. Saw " + jurisdication);
                        jurisdication = 0;
                    }
                    m_jurisdicationToUse = (TaxJurisdiction)jurisdication;
                }
                catch (Exception)
                {
                    m_Logger.LogError("Failed to retrieve JurisdictionToUse from MetraTaxConfig.xml");
                }

            }
            catch
            {
                m_Logger.LogError("Failed reading config file " + m_ConfigFile);
            }
        }

        // General MetraTax config file.  
        private readonly string m_ConfigFile = "";

        /// <summary> 
        /// Determines how many threads that the MetraTax tax manager should spawn
        /// </summary>
        private readonly bool m_shouldUseCountryName = false;

        /// <summary> 
        /// Determines which jurisdication to use for storing taxes.
        /// </summary>
        private readonly TaxJurisdiction m_jurisdicationToUse = TaxJurisdiction.Federal;

        public bool ShouldUseCountryName
        {
            get { return m_shouldUseCountryName; }
        }

        public TaxJurisdiction JurisdicationToUse
        {
            get { return m_jurisdicationToUse; }
        }
    }
}
