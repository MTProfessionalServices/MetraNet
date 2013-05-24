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
    /// Provides an access to configured subsystem engines.
    /// </summary>
    public interface ISubsystemApi : ISubsystemInfo
    {
        /// <summary>
        /// Executes an engine with the specified IdEngine
        /// </summary>
        /// <param name="idEngine">Engine id</param>
        /// <param name="context">ApiInput</param>
        /// <returns>ApiOutput</returns>
        /// <exception cref="SubsystemInputParamException ">Throws an exception if a specified category not found for the subsystem.</exception>
        ApiOutput Execute(string idEngine, ApiInput context);

        /// <summary>
        /// Executes a default engine for the specified category.
        /// </summary>
        /// <param name="categoryName">A name of the category to look for a default engine within.</param>
        /// <param name="input">Data to be processed.</param>
        /// <returns>Execution result.</returns>
        /// <exception cref="SubsystemInputParamException">
        /// When either category not found in the subsystem or the category has no default engine specified.
        /// </exception>
        ApiOutput ExecuteDefaultByCategory(string categoryName, ApiInput input);
       
        /// <summary>
        /// Gets Engine by idEngine
        /// </summary>
        /// <param name="idEngine">Engine id</param>
        /// <returns>If idEngine does not exist return null.</returns>
        IEngine GetEngine(string idEngine);
        
        /// <summary>
        /// Get default Engine for a category specified by categoryName. 
        /// </summary>
        /// <param name="categoryName">Category name</param>
        /// <returns>IEngine</returns>
        /// <exception cref="SubsystemInternalException">If category does not have any engines throw exception.</exception>
        /// <exception cref="SubsystemInputParamException">If category doesn’t exist throw exception.</exception>
        IEngine GetDefaultEngine(string categoryName);
        
        /// <summary>
        /// Gets a collection of Engines by categoryName
        /// </summary>
        /// <param name="categoryName">Category name</param>
        /// <returns></returns>
        IEngine[] GetEnginesForCategory(string categoryName);
    }
}
