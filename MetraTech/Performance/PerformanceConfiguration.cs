//=============================================================================
// Copyright 2012 by MetraTech
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
//-----------------------------------------------------------------------------
//
// MODULE: QueryManagementConfiguration.cs
//
//=============================================================================

namespace MetraTech.Performance
{
    using System;
    using System.IO;
    using System.Runtime.InteropServices;

    using MetraTech.Xml;
    using MetraTech.Interop.RCD;
    
    /// <summary>
    /// Provides access to the Performance configuration file.
    /// </summary>
    [ComVisible(true)]
    [ClassInterface(ClassInterfaceType.None)]
    [Guid("8D581432-29D7-48E3-BADA-8E27C75C584A")]
    public static class PerformanceConfiguration
    {
        /// <summary>
        /// Name of this class.
        /// </summary>
        private const string ClassName = "PerformanceConfiguration";

        /// <summary>
        /// Local logging object
        /// </summary>
        private static ILogger Logger = null;

        /// <summary>
        /// Gets or sets the Performance Enabled property
        /// </summary>
        public static bool Enabled
        {
            get;
            private set;
        }

        /// <summary>
        /// Initializes a new instance of the PerformanceConfiguration class
        /// </summary>
        static PerformanceConfiguration()
        {
            const string methodName = "[Constructor]";

            try
            {
                PerformanceConfiguration.Logger = new Logger(@"Logging\Performance", string.Concat("[", PerformanceConfiguration.ClassName, "]"));

                if (PerformanceConfiguration.Logger.WillLogTrace)
                {
                    Logger.LogTrace(string.Concat(methodName), " - Enter");
                }

                var mtRcd = new MTRcd();
                var configurationFileName = Path.Combine(mtRcd.ConfigDir, @"Performance\Performance.xml");
                
                var mtXmlDocument = new MTXmlDocument();
                mtXmlDocument.Load(configurationFileName);

                PerformanceConfiguration.Enabled = mtXmlDocument.GetNodeValueAsBool("/configuration/enabled");

                Logger.LogDebug(string.Concat("The performance configuration's enabled setting is set to ", PerformanceConfiguration.Enabled, "."));

                if (PerformanceConfiguration.Logger.WillLogTrace)
                {
                    Logger.LogTrace(string.Concat(methodName), " - Leave");
                }
            }
            catch(Exception exception)
            {
                if (PerformanceConfiguration.Logger != null)
                {
                    PerformanceConfiguration.Logger.LogException("Exception caught:  ", exception);
                }

                throw;
            }
        }
    }
}