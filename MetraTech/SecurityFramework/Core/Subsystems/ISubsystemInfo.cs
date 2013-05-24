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

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Provides an access to information about subsystem’s engines.
    /// </summary>
    public interface ISubsystemInfo
    {
        /// <summary>
        /// Gets a array of all subsystem’s engine ids.
        /// </summary>
        string[] EngineIds { get; }
        
        /// <summary>
        /// Gets a array of all subsystem’s categories.
        /// </summary>
        string[] CategoryNames { get; }
        
        /// <summary>
        /// Gets a array of all engines registered for the subsystem.
        /// </summary>
        IEngine[] Engines { get; }

        /// <summary>
        /// Determines whether an engine with the specified IdEngine was already registered for the subsystem.
        /// </summary>
        /// <param name="idEngine">Engine Id</param>
        /// <returns>true if it is and false otherwise.</returns>
        bool HasEngine(string idEngine);
        
        /// <summary>
        /// Determines whether some engine was registered for the specified category.
        /// </summary>
        /// <param name="categoryName">A name of the subsystem's category to find engines for.</param>
        /// <returns>true if it is registered and false otherwise</returns>
        bool HasEngineForCategory(string categoryName);
    }
}
