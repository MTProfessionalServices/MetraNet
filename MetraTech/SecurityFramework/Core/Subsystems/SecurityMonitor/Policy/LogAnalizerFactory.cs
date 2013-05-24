/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Core.SecurityMonitor.Policy
{
    /// <summary>
    /// Provides a factory that creates and keeps an instance of the ILogAnalizerRepository implementation.
    /// The type of the implementation is specified via the configuration.
    /// </summary>
    public static class LogAnalizerFactory
    {
        private static ILogAnalizerRepository _analyzer;

        /// <summary>
        /// Gets or sets an instance of the class implementing the <see cref="ILogAnalizerRepository"/> interface.
        /// </summary>
        public static ILogAnalizerRepository Analyzer
        {
            get
            {
                if (_analyzer == null)
                {
                    throw new MetraTech.SecurityFramework.Core.Common.Configuration.ConfigurationException(
                        "Events log analyzer is not configured.");
                }

                return _analyzer;
            }
            internal set
            {
                _analyzer = value;
            }
        }
    }
}
