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

using System;
namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Required  for subsystems used by the Processor subsystem. It provides the interface to subsystem API. 
    /// </summary>
    public interface ISubsystem
    {
        /// <summary>
        /// Gets a subsystem name.
        /// </summary>
        string SubsystemName { get; }

        /// <summary>
        /// Provides an access to ISubsystemApi interface of the subsystem. If access denied throw SubsystemApiAccessException exception.
        /// </summary>
        ISubsystemApi Api { get; }

        /// <summary>
        /// Provides an access to ISubsystemControlApi interface of the subsystem. If access denied throw SubsystemApiAccessException exception.
        /// </summary>
        ISubsystemControlApi ControlApi { get; }
    }
}
