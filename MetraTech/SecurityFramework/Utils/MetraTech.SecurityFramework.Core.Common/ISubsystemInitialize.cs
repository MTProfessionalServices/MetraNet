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
* Maksym Sukhovarov <msukhovarov@metratech.com>
*
* 
***************************************************************************/

using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core;
using MetraTech.SecurityFramework.Common.Configuration.Logger;
using System;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Required  for subsystems used by the Processor Subsystem.  It uses for correct initializing and finalizeing of any subsystem.
    /// </summary>
    public interface ISubsystemInitialize
	{
        /// <summary>
        /// Called at subsystem initializing. Uses the configuration loader to read subsystem’s settings. 
        /// </summary>
        /// <param name="fileConfigurationPath">Path of file configuration</param>
        void Initialize(MetraTech.SecurityFramework.Core.SubsystemProperties props);

        /// <summary>
        /// Called at subsystem finalizing. It intended for freeing resources used by the subsystem.
        /// </summary>
        void Shutdown();

		IConfigurationLogger GetConfiguration();
    }
}
