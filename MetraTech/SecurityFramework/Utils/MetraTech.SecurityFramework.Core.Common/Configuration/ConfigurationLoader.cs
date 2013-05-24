/**************************************************************************
* Copyright 1997-2010 by MetraTech.SecurityFramework
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech.SecurityFramework MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech.SecurityFramework MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech.SecurityFramework, and USER
* agrees to preserve the same.
*
* Authors: Viktor Grytsay
*
* Your Name <vgrytsay@MetraTech.SecurityFramework.com>
*
* 
***************************************************************************/
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Common.Configuration.Logger;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Core.Common.Logging;
using MetraTech.SecurityFramework.Core.Common.Logging.Configuration;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Serialization.Attributes;

namespace MetraTech.SecurityFramework.Common.Configuration
{
	/// <summary>
	/// This class provides the system configuration
	/// </summary>
	public class ConfigurationLoader
	{
		#region Private Fields

		private static List<ISerializationError> _serializeExceptions = new List<ISerializationError>();
		private static ConfigurationLoader _configurationLoader;
		private LoadItem[] _items;
		private static Dictionary<Type, object> _loadedSubsystem;
		private bool _isInitialized = false;
		private static string _pathToSource;
		private static ISerializer _serializer;
		private static object _syncRoot;

		//TODO: change key-type to Guid
		private static Dictionary<Type, LoadItem> _availableSubsystems { get; set; }

		#endregion

		#region Public Fields

		/// <summary>
		/// Gets if smth is initialized
		/// </summary>
		public bool IsInitialized
		{
			get { return _isInitialized; }
		}

		/// <summary>
		/// Gets items available to initialize
		/// </summary>
		[SerializeCollectionAttribute(ElementName = "item", ElementType = typeof(LoadItem), DefaultType = typeof(LoadItem[]), IsRequired = true, MappedName = "Items")]
		public LoadItem[] Items
		{
			get { return _items; }
			set { _items = value; }
		}

		#endregion

		#region Constructor

		static ConfigurationLoader()
		{
			_syncRoot = new object();
		}

		private ConfigurationLoader()
		{
			_isInitialized = false;
		}

		#endregion

		#region Internal Methods

		/// <summary>
		/// Initializes the list of available subsystems
		/// </summary>
		/// <param name="serializer"></param>
		public static ConfigurationLoader Load(ISerializer serializer, string pathToSource, string configurationDirectory)
		{
			if (string.IsNullOrEmpty(pathToSource))
			{
				throw new ConfigurationException("Path to source file is empty.");
			}

			if (string.IsNullOrEmpty(configurationDirectory))
			{
				throw new ConfigurationException("Path to configuration directory is empty.");
			}

			if (serializer == null)
			{
				throw new ConfigurationException("Serializer for loading configuration is null.");
			}

			_pathToSource = pathToSource;
			_serializer = serializer;
			ExternalParameters.AddKey("ConfigurationPath", configurationDirectory);

			try
			{
				_configurationLoader = new ConfigurationLoader();
				_serializer.Deserialize(_configurationLoader, _serializeExceptions, _pathToSource);
			}
			catch (Exception e)
			{
				throw new ConfigurationException("Error when configuring the configuration system. Loading application is aborted.", e);
			}

			_configurationLoader._isInitialized = true;
			_loadedSubsystem = new Dictionary<Type, object>();
			return _configurationLoader;
		}

		public static void Initialize()
		{
			List<Exception> exceptions = new List<Exception>();

			lock (_syncRoot)
			{
				LoadItems(ref exceptions);
				// Assign the logger configuration.
				LoggingHelper.LoggerConfiguration = _loadedSubsystem[typeof(LoggerClassConfiguration)] as LoggerClassConfiguration;
			}

			if (_serializeExceptions.Count > 0)
			{
				foreach (Exception e in _serializeExceptions)
				{
					LoggingHelper.Log(e);
				}

				throw new ConfigurationException("Error when configuring the configuration system. Loading application is aborted.");
			}

			if (exceptions.Count > 0)
			{
				foreach (Exception e in exceptions)
				{
					LoggingHelper.Log(e);
				}

                // Compile the error message from all exceptions.
                StringBuilder sb = new StringBuilder("Errors occurred while configuring the project. For more information, see the error log.");
                for (int i = 0; i < exceptions.Count; i++)
                {
                    // Separator between exceptions
                    sb.Append(Environment.NewLine);
                    sb.Append(Environment.NewLine);
                    // Exception message
                    sb.Append(exceptions[i].StackTrace);
                }

				ConfigurationException exc = new ConfigurationException(sb.ToString());
				throw exc;
			}
		}

		/// <summary>
		/// Gets initialized subsystem
		/// </summary>
		/// <typeparam name="T"></typeparam>
		public static T GetSubsystem<T>() where T : new()
		{
			object retObj = null;
			Type type = typeof(T);
			if (_loadedSubsystem.ContainsKey(type))
			{
				retObj = _loadedSubsystem[type];
			}
			return ((T)retObj);
		}

		public void SaveConfiguration(Type subsystemType)
		{
			if (!IsInitialized)
			{
				throw new ConfigurationException("ConfigurationLoader is not initialized, reconfiguration impossible.");
			}

			if (subsystemType == null)
			{
				throw new ConfigurationException("Subsystem type for reconfiguration is null, reconfiguration impossible.");
			}

			if (!_loadedSubsystem.ContainsKey(subsystemType))
			{
				throw new ConfigurationException(string.Format("Subsystem type {0} is not initialized, reconfiguration impossible.", subsystemType.Name));
			}

			ISubsystemInitialize subsystem = _loadedSubsystem[subsystemType] as ISubsystemInitialize;
			if (subsystem == null)
			{
				throw new ConfigurationException(string.Format("Subsystem type {0} is not initialized, reconfiguration impossible.", subsystemType.Name));
			}

			IConfigurationLogger confLogger = subsystem.GetConfiguration();

			LoadItem item = _availableSubsystems[subsystemType];
			string pathToSource = Path.Combine(Path.GetDirectoryName(_pathToSource), item.Path);
			_serializer.Serialize(confLogger, pathToSource);

			confLogger.ReconfigurationLog();
		}

		#endregion

		#region Private Methods

		private static void LoadItems(ref List<Exception> exceptions)
		{
			exceptions = new List<Exception>();
			_availableSubsystems = new Dictionary<Type, LoadItem>();
			foreach (LoadItem item in _configurationLoader._items)
			{
				if ((_serializeExceptions.Count == 0 && item.IsServiceSubsystem == true) || item.IsEnabled)
				{
					Type propsType = Type.GetType(item.Type);
					if (_availableSubsystems.ContainsKey(propsType))
					{
						ConfigurationException exc = new ConfigurationException(string.Format("Subsystem with same Id: {0} is already loaded", item.Id.ToString()));
						throw exc;
					}

					try
					{
						LoadItem(item, ref exceptions);
					}
					catch (Exception e)
					{
						//Depending on the priority oh the subsystem throws an exception immediately or adds to exception list
						if (item.IsServiceSubsystem == true)
						{
							string message = string.Format("Error when configuring the service-module: {0} Id: {1}", item.Name, item.Id.ToString());
							_loadedSubsystem.Clear();
							ConfigurationException exc = new ConfigurationException(message, e);
							throw exc;
						}
						else
						{
							string message = string.Format("Error when configuring the module: {0} Id: {1}", item.Name, item.Id.ToString());
							ConfigurationException exc = new ConfigurationException(message, e);
							exceptions.Add(exc);
						}
					}
				}
			}
		}

		private static void LoadItem(LoadItem item, ref List<Exception> exceptions)
		{
			string pathToSource = Path.Combine(Path.GetDirectoryName(_pathToSource), item.Path);
			Type propsType = Type.GetType(item.Type);
			if (propsType == null)
			{
				ConfigurationException exc = new ConfigurationException(string.Format("Not found or not specified the type of subsystem: {0}", item.Type));
				throw exc;
			}

			object props = _serializer.Deserialize(propsType, null, pathToSource);

			if (item.SubsystemType != null)
			{
				Type subsystemType = Type.GetType(item.SubsystemType);
				if (subsystemType == null)
				{
					ConfigurationException exc = new ConfigurationException(string.Format("Not found or not specified the type of subsystem: {0}", item.SubsystemType));
					throw exc;
				}

				object subsystem = subsystemType.InvokeMember(item.SubsystemType, System.Reflection.BindingFlags.CreateInstance, null, null, null);

				if (subsystem is ISubsystemInitialize && props is MetraTech.SecurityFramework.Core.SubsystemProperties)
				{
					((ISubsystemInitialize)subsystem).Initialize(((MetraTech.SecurityFramework.Core.SubsystemProperties)props));
				}

				_loadedSubsystem.Add(subsystem.GetType(), subsystem);
				_availableSubsystems.Add(subsystem.GetType(), item);
			}
			else
			{
				Type systemType = Type.GetType(item.Type);
				_loadedSubsystem.Add(systemType, props);
				_availableSubsystems.Add(systemType, item);
			}
		}

		#endregion
	}
}
