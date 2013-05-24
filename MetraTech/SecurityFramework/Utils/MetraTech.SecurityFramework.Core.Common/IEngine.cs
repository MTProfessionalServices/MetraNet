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
using System.Collections.Generic;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Common interface for subsystem's  engines
    /// </summary>
    public interface IEngine : IDisposable
    {
        /// <summary>
        ///Engene Id
        /// </summary>
		string Id { get; }
       
		bool IsDefault
		{
			get;
		}
        
		/// <summary>
        /// Gets a name of the subsystem the engine belongs to.
        /// </summary>
		string SubsystemName { get; }

        /// <summary>
        /// Performs an action on an input value.
        /// </summary>
        /// <param name="input"></param>
        /// <returns>A result of the execution.</returns>
        ApiOutput Execute(ApiInput input);

		string CategoryName
		{
			get;
		}

        /// <summary>
        /// Gets or sets engine available to initialize
        /// </summary>
		bool IsInitialized { get; }

        void Initialize();
    }
}
