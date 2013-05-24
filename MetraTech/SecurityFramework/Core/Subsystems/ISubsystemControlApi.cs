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

namespace MetraTech.SecurityFramework
{
    /// <summary>
    /// Provides an access to subsystem configuration
    /// </summary>
    public interface ISubsystemControlApi : ISubsystemInfo
    {
        /// <summary>
        /// Adds a new engine for the subsystem.
        /// First added engine become default engine for its category.
        /// </summary>
        /// <param name="newEngine">IEngine</param>
        void AddEngine(IEngine newEngine);

		/// <summary>
        /// Adds a new engine for the subsystem.
		/// </summary>
        /// <param name="newEngine">IEngine</param>
        /// <param name="isDefault">Specifies wether the engine is default for its category</param>
        void AddEngine(IEngine newEngine, bool isDefault);

        /// <summary>
        /// Generate unique Id fo engine (in scope subsystem)
        /// </summary>
        /// <returns>inique id</returns>
        string GenerateIdEngine();

        /// <summary>
        /// Sets an engine as default for curret category.
        /// </summary>
        /// <param name="idEngine">Engine Id</param>
        /// <exception cref="SubsystemInputParamException">Exception if a engine with the specified Id not found.</exception>
        void SetDefault(string idEngine);

        /// <summary>
        /// Removes an engine with the specified IdEngine
		/// </summary>
		/// <param name="idEngine">Engine id</param>
        /// <exception cref="SubsystemInputParamException">Throws an exception if a engine with the specified Id not found</exception>
        /// <exception cref="SubsystemInputParamException">Throws an exception if an sets as default. First need to sets another engine as default.</exception>
        void RemoveEngine(string idEngine);

        /// <summary>
        /// Removes all engines those belong to the specified category. 
        /// </summary>
        /// <param name="categoryName">Category Name</param>
        /// <exception cref="SubsystemInputParamException ">Throws an exception if a specified category not found for the subsystem.</exception>
        void RemoveAllEnginesForCategory(string categoryName);

        /// <summary>
        /// Removes all engines those belong to the specified category. 
        /// </summary>
        /// <param name="categoryName">Category Name</param>
        /// <param name="keepDefault">If keepDefault = true – remove all engines except those specified as default, If keepDefault = false - removes all engines those belong to the specified category.</param>
        /// <exception cref="SubsystemInputParamException ">Throws an exception if a specified category not found for the subsystem.</exception>
        void RemoveAllEnginesForCategory(string categoryName, bool keepDefault);

        /// <summary>
        /// Removes all endgines from the subsystem.
        /// </summary>
        void RemoveAllEngines();

        /// <summary>
        /// Removes all endgines from the subsystem.
        /// </summary>
        /// <param name="keepDefault">If keepDefault = true – remove all engines from the subsystem except those specified as default, If keepDefault = false - removes all endgines from the subsystem. </param>
        void RemoveAllEngines(bool keepDefault);
    }
}
