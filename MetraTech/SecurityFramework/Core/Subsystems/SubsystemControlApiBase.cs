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
using MetraTech.SecurityFramework.Core.Common.Configuration;

namespace MetraTech.SecurityFramework
{
    internal class SubsystemControlApiBase : ISubsystemControlApi
    {
        private Dictionary<string, IEngine> _enginesById;
        private Dictionary<string, Category> _categories;
        private string _subsystemName;

        internal SubsystemControlApiBase(Dictionary<string, IEngine> enginesById, Dictionary<string, Category> categories, string subsystemName)
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

        #region *** Add Engine methods ***

        public void AddEngine(IEngine newEngine)
        {
            AddEngine(newEngine, false);
        }

        public void AddEngine(IEngine newEngine, bool isDefaultEngine)
        {
            if (String.IsNullOrEmpty(newEngine.Id))
                throw new SubsystemInputParamException("The engine does not set the Id.");

            if (String.IsNullOrEmpty(newEngine.CategoryName))
                throw new SubsystemInputParamException("The engine does not set the properties CategoryName.");

            if (!(newEngine is EngineBase))
                throw new SubsystemInputParamException(String.Format("Engine with Id = \"{0}\" was already existed in \"{1}\" subsystem ", newEngine.Id, _subsystemName));

            if (!_categories.ContainsKey(newEngine.CategoryName))
                throw new SubsystemInputParamException(String.Format("\"{0}\" category does not exist in the \"{1}\" subsystem.", newEngine.CategoryName, _subsystemName));

            if (_subsystemName != newEngine.SubsystemName)
                throw new SubsystemInputParamException(String.Format("\"{0}\" engine's subsystem (\"{1}\") does not match.", newEngine.Id, newEngine.SubsystemName));

			if (_enginesById.ContainsKey(newEngine.Id))
			{
				string mes = string.Format("Engine with id {0} already initialized. Check configuration file for {1} subsystem.", newEngine.Id, _subsystemName);
				throw new ConfigurationException(mes);
			}

			_enginesById.Add(newEngine.Id, newEngine);
			
            //sets as default
            if (isDefaultEngine)
                _categories[newEngine.CategoryName].DefaultEngine = newEngine;
        }

        #endregion *** Add Engine methods ***

        #region *** Generate Id for Engine ***

        private static string GenIdEngine()
        {
            return Guid.NewGuid().ToString();
        }

        public string GenerateIdEngine()
        {
            string id = GenIdEngine();

            while (_enginesById.ContainsKey(id))
            {
                id = GenIdEngine();
            }
            return id;
        }

        #endregion *** Generate Id for Engine ***

        /// <summary>
        /// Sets an engine with idEngene as default for category.
        /// </summary>
        /// <param name="idEngine">Engine Id</param>
        /// <exception cref="SubsystemInputParamException"></exception>
        public void SetDefault(string idEngine)
        {
             if (_enginesById.ContainsKey(idEngine))
                throw new SubsystemInputParamException(String.Format("Can't set an engine as default. Engine with Id = \"{0}\" does not exist into \"{1}\" subsystem.",
                        idEngine, _subsystemName));

            _categories[_enginesById[idEngine].CategoryName].DefaultEngine = _enginesById[idEngine];
        }

        #region *** Remove Engines methods ***

        protected void RemoveEngineById(string idEngine)
        {
            IEngine removingEngine = _enginesById[idEngine];
            _enginesById.Remove(idEngine);
            removingEngine.Dispose();
        }

        public void RemoveEngine(string idEngine)
        {
            if (!_enginesById.ContainsKey(idEngine))
                throw new SubsystemInputParamException(
                    String.Format(
                        "Can't remove an engine. Engine with Id = \"{0}\" does not exist into \"{1}\" subsystem.",
                        idEngine, _subsystemName));

            if (_categories.Values.Count(category => category.DefaultEngine == null
                                                         ? false
                                                         : category.DefaultEngine.Id == idEngine) > 0)
                throw new SubsystemInputParamException(String.Format("Can't remove an engine. Engine with Id = \"{0}\" sets as default for \"{1}\" subsystem.",
                        idEngine, _subsystemName));
           

            RemoveEngineById(idEngine);
        }

        public void RemoveAllEnginesForCategory(string categoryName)
        {
            RemoveAllEnginesForCategory(categoryName, false);
        }

        public void RemoveAllEnginesForCategory(string categoryName, bool keepDefault)
        {
            if (String.IsNullOrEmpty(categoryName))
                throw new SubsystemInputParamException("Category name can't be empty.");

            if (!_categories.ContainsKey(categoryName))
                throw new SubsystemInputParamException(String.Format("\"{0}\" category does not exist in the \"{1}\" subsystem.", categoryName, _subsystemName));

            // gets id for categoryName arg
            var enginesId = from pairIdEngine in _enginesById
                            where pairIdEngine.Value.CategoryName == categoryName
                            select pairIdEngine.Key;

            if (keepDefault)
            {
                bool isSetDefaultEngine = _categories[categoryName].DefaultEngine == null ? false : true; 
                
                foreach (string idEngine in enginesId)
                {
                    if (isSetDefaultEngine && _categories[categoryName].DefaultEngine.Id == idEngine)
                    { // found Default Engine and keep it.
                        isSetDefaultEngine = false;
                    }
                    else
                    {
                        RemoveEngineById(idEngine);
                    }
                }
            }
            else
            {
                // remove engines
                foreach (string idEngine in enginesId)
                {
                    RemoveEngineById(idEngine);
                }

                // remove ref to engines
                foreach (KeyValuePair<string, Category> keyValuePair in _categories)
                {
                    keyValuePair.Value.DefaultEngine = null;
                }
            }
        }

        public void RemoveAllEngines()
        {
            RemoveAllEngines(false);
        }

        public void RemoveAllEngines(bool keepDefault)
        {
           if (keepDefault)
           {
               string[] engineIds = _enginesById.Keys.ToArray();

               foreach (string idEngine in engineIds)
               {
                   if (_categories[_enginesById[idEngine].CategoryName].DefaultEngine != _enginesById[idEngine])
                       _enginesById.Remove(idEngine);
               }
           }
           else
           {
               _enginesById.Clear();

               // remove ref to engines
               foreach (KeyValuePair<string, Category> keyValuePair in _categories)
               {
                   keyValuePair.Value.DefaultEngine = null;
               }
           }
        }

        #endregion *** Remove Engines methods ***
    }
    
}
