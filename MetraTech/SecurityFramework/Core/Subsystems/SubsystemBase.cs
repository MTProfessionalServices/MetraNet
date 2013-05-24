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
using System.ComponentModel;
using System.Diagnostics;
using System.Linq;
using System.Reflection;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Core.Common.Configuration;
using MetraTech.SecurityFramework.Common.Configuration.Logger;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Base abstract class fo all subsystems.
	/// </summary>
	/// <remarks>In the inherited class must be initialized protected property <see cref="FactoryEngines"/>. 
	/// This property used delegate <see cref="FactoryEngineCategoryDelegate"/></remarks>
	public abstract class SubsystemBase : ISubsystemInitialize, ISubsystem, IDisposable
	{
		#region Private fields

		/// <summary>
		/// True if subsystem already initialized
		/// </summary>
		private bool _initialized;

		/// <summary>
		/// Is ISubsystemControlApi public?
		/// </summary>
		private bool _isControlApiPublic;

		/// <summary>
		/// Is ISubsystemApi public?
		/// </summary>
		private bool _isRuntimeApiPublic;

		private bool _isRuntimeApiEnabled;

		private bool _isControlApiEnabled;

		private readonly Dictionary<string, IEngine> _enginesById = new Dictionary<string, IEngine>();
		private readonly Dictionary<string, Category> _categories = new Dictionary<string, Category>();

		#endregion

		#region Public properties

		public string SubsystemName { get; private set; }

		public ISubsystemApi Api
		{
			get
			{
				if (ApiInternal == null || !_isRuntimeApiPublic)
					throw new SubsystemApiAccessException();

				return ApiInternal;
			}
		}

		public ISubsystemControlApi ControlApi
		{
			get
			{
				if (ControlApiInternal == null || !_isControlApiPublic)
					throw new SubsystemApiAccessException();

				return ControlApiInternal;
			}
		}

		#endregion

		#region Internal properties

		internal ISubsystemControlApi ControlApiInternal { get; private set; }

		internal ISubsystemApi ApiInternal { get; private set; }

		#endregion

		#region Constructor

		protected SubsystemBase()
		{
			SubsystemName = GetType().Name;

			ApiInternal = null;
			ControlApiInternal = null;
		}

		#endregion

		#region Public methods

		public virtual void Initialize(MetraTech.SecurityFramework.Core.SubsystemProperties props)
		{
			if (_initialized)
				return;

			try
			{
				_isRuntimeApiPublic = props.IsRuntimeApiPublic;
				_isControlApiPublic = props.IsControlApiPublic;
				_isControlApiEnabled = props.IsControlApiEnabled;
				_isRuntimeApiEnabled = props.IsRuntimeApiEnabled;

				if (props.IsRuntimeApiEnabled)
					ApiInternal = new SubsystemApiBase(_enginesById, _categories, SubsystemName);

				if (props.IsControlApiEnabled)
					ControlApiInternal = new SubsystemControlApiBase(_enginesById, _categories, SubsystemName);

				if ((null != ControlApiInternal) && (null != props.Engines) && (props.Engines.Length > 0))
				{
					this.InitCategories();

					foreach (IEngine engine in props.Engines)
					{
						engine.Initialize();
						if (engine.IsInitialized)
						{
							ControlApiInternal.AddEngine(engine, engine.IsDefault);
						}
					}
				}

				_initialized = true;
			}
			catch (Exception x)
			{
				Trace.WriteLine(x.Message);
				throw;
			}
		}

		public void Shutdown()
		{
			if (null != ControlApiInternal)
			{
				ControlApiInternal.RemoveAllEngines();
				ControlApiInternal = null;
			}

			ApiInternal = null;

			_isRuntimeApiPublic = false;
			_isControlApiPublic = false;
			_initialized = false;
		}

		public abstract void InitCategories();

		/// <summary>
		/// Gets configuration for current subsystem
		/// </summary>
		public virtual IConfigurationLogger GetConfiguration()
		{
			MetraTech.SecurityFramework.Core.SubsystemProperties props = new Core.SubsystemProperties();
			props.IsControlApiPublic = this._isControlApiPublic;
			props.IsRuntimeApiPublic = this._isRuntimeApiPublic;
			props.IsControlApiEnabled = this._isControlApiEnabled;
			props.IsRuntimeApiEnabled = this._isRuntimeApiEnabled;

			props.Engines = ControlApi.Engines;
			return props;
		}

		#endregion

		#region Protected methods

		protected void InitCategories(Type type)
		{
			Array infos = type.GetEnumValues();

			foreach (object fInfo in infos)
			{
				_categories.Add(fInfo.ToString(), new Category(fInfo.ToString()));
			}

		}

		#endregion

		#region *** IDisposable interface Implementetion ***

		private bool _disposed = false;

		/// <summary>
		/// This method used in public void Dispose()
		/// </summary>
		/// <param name="disposing">true - to dispose managed code</param>
		protected virtual void Dispose(bool disposing)
		{
			if (!_disposed)
			{
				Shutdown();
				_disposed = true;
			}

		}

		public void Dispose()
		{
			Dispose(true);
			//GC.SuppressFinalize(this);
		}

		//~SubsystemBase()
		//{
		//    Dispose(false);
		//}

		#endregion *** IDisposable interface Implementetion ***
	}
}