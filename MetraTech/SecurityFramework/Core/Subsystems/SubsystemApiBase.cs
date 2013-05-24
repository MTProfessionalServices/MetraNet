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
using System.Diagnostics;
using System.Linq;

namespace MetraTech.SecurityFramework
{
    internal class SubsystemApiBase : ISubsystemApi
    {
        private Dictionary<string, IEngine> _enginesById;
        private Dictionary<string, Category> _categories;
        private string _subsystemName;

        internal SubsystemApiBase(Dictionary<string, IEngine> enginesById, Dictionary<string, Category> categories, string subsystemName)
        {
            Debug.Assert(!(enginesById == null));
            Debug.Assert(!(categories == null));
            Debug.Assert(!(String.IsNullOrEmpty(subsystemName)));
            
            _enginesById = enginesById;
            _categories = categories;
            _subsystemName = subsystemName;
        }

        #region *** ISubsystemInfo interfase implementation ***

        public string[] EngineIds
        {
            get { return _enginesById.Keys.ToArray(); }
        }

        public string[] CategoryNames
        {
            get { return _categories.Keys.ToArray(); }
        }

        public IEngine[] Engines
        {
            get { return _enginesById.Values.ToArray(); }
        }

        public bool HasEngine(string idEngine)
        {
            return _enginesById.ContainsKey(idEngine);
        }

        /// <summary>
        /// Determines if an engine is registered for a specified category.
        /// </summary>
        /// <param name="categoryName">A name of the category to search an ingine for.</param>
        /// <returns>true if an engine is registered and false otherwise.</returns>
        /// <exception cref="SubsystemInputParamException">
        /// If a category with the specified name does not exist within the subsystem.
        /// </exception>
        public bool HasEngineForCategory(string categoryName)
        {
            if (!_categories.ContainsKey(categoryName))
                throw new SubsystemInputParamException(String.Format("\"{0}\" category does not exist in the \"{1}\" subsystem.", categoryName, _subsystemName));

            return _enginesById.Values.Any(engine => engine.CategoryName == categoryName);
        }

        #endregion *** ISubsystemInfo interfase implementation ***

        public ApiOutput Execute(string idEngine, ApiInput context)
        {
            if (!_enginesById.ContainsKey(idEngine))
                throw new SubsystemInputParamException(String.Format("Can't execute an engine. Engine with Id = \"{0}\" does not exist into \"{1}\" subsystem.",
                        idEngine, _subsystemName));

            return _enginesById[idEngine].Execute(context);
        }

        /// <summary>
        /// Executes a default engine for the specified category.
        /// </summary>
        /// <param name="categoryName">A name of the category to look for a default engine within.</param>
        /// <param name="input">Data to be processed.</param>
        /// <returns>Execution result.</returns>
        /// <exception cref="SubsystemInputParamException">
        /// When either category not found in the subsystem or the category has no default engine specified.
        /// </exception>
        public ApiOutput ExecuteDefaultByCategory(string categoryName, ApiInput input)
        {
            IEngine engine = this.GetDefaultEngine(categoryName);

            if (engine == null)
            {
                throw new SubsystemInputParamException(
                    string.Format("Category \"{0}\" has no default engine specified.", categoryName));
            }

            return engine.Execute(input);
        }

        #region *** Get Engine methods ***

        public IEngine GetEngine(string idEngine)
        {
            if (_enginesById.ContainsKey(idEngine) == false)
                throw new SubsystemInputParamException(String.Format("Can't execute an engine. Engine with Id = \"{0}\" does not exist into \"{1}\" subsystem.",
                        idEngine, _subsystemName));

            return _enginesById[idEngine];
        }

        public IEngine GetDefaultEngine(string categoryName)
        {
            if (String.IsNullOrEmpty(categoryName))
                throw new SubsystemInputParamException("Category name can't be empty.");

            if (!_categories.ContainsKey(categoryName))
                throw new SubsystemInputParamException(String.Format("\"{0}\" category does not exist in the \"{1}\" subsystem.", categoryName, _subsystemName));

            return _categories[categoryName].DefaultEngine;
        }

        public IEngine[] GetEnginesForCategory(string categoryEngine)
        {
            return _enginesById.Values.Where(engine => engine.CategoryName == categoryEngine).ToArray();
        }

        #endregion *** Get Engine methods ***
    }
}
