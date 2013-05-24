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
using System.ComponentModel;
using System.Diagnostics;
using System.Reflection;
using MetraTech.SecurityFramework.Serialization;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.SecurityFramework
{
	public abstract class EngineBase : IEngine
	{
		#region Properties

		/// <summary>
		/// Gets or sets an engine ID.
		/// </summary>
		[SerializePropertyAttribute(IsRequired = true)]
		public string Id
		{
			get;
			protected set;
		}

		[SerializePropertyAttribute]
		public bool IsDefault
		{
			get;
			protected set;
		}

		/// <summary>
		/// Gets a name of the subsystem the engine belongs to.
		/// </summary>
		public string SubsystemName
		{
			get
			{
				Type type = SubsystemType;
				if (type == null)
				{
					throw new SecurityFrameworkException(string.Format("Engine {0} does not provide its subsystem type.", GetType()));
				}
				string result = SubsystemType.Name;

				return result;
			}
		}

		/// <summary>
		/// Gets or sets a name of the category the engine belongs to.
		/// </summary>
		public virtual string CategoryName
		{
			get;
			protected set;
		}

		/// <summary>
		/// Gets or internally sets a value indicating the engine has already been initialized.
		/// </summary>
		public bool IsInitialized
		{
			get;
			private set;
		}

		/// <summary>
		/// Gets a value indicating the engine has its own performance monitoring.
		/// </summary>
		protected virtual bool HasOwnPerformanceMonitoring
		{
			[DebuggerStepThrough]
			get
			{
				return false;
			}
		}

		#endregion

		/// <summary>
		/// Processes input data.
		/// Logs and re-throws any exception heppened during execution.
		/// </summary>
		/// <param name="input">Data to be processed.</param>
		/// <returns>Processing result.</returns>
		public ApiOutput Execute(ApiInput input)
		{
			//LoggingHelper.LogDebug(string.Format("{0}.Execute", this.GetType()), string.Format("{0}: Started", this.Id));
			Stopwatch watch = null;
			if (!HasOwnPerformanceMonitoring)
			{
				// The engine uses inherited performance monitoring.
				watch = new Stopwatch();
				watch.Start();
			}

			try
			{
				return ExecuteInternal(input);
			}
			catch (Exception ex)
			{
				// Log an exception and re-throw it.
				LoggingHelper.Log(ex);
				throw;
			}
			finally
			{
				if (!HasOwnPerformanceMonitoring)
				{
					// Measure performance
					watch.Stop();
					PerformanceMonitor.IncrementWorkTime(watch.ElapsedTicks);
					decimal elapsed = watch.ElapsedTicks;

					LoggingHelper.LogDebug(string.Empty, string.Format("{0}: Completed in {1} ms", this.Id, Math.Round(elapsed * 1000m / (decimal)Stopwatch.Frequency, 4)));
				}
			}
		}

		#region *** Implemented IDisposable interface ***

		/// <summary>
		/// This method used in public void Dispose()
		/// </summary>
		/// <param name="disposing">true - to dispose managed code</param>
		protected virtual void Dispose(bool disposing)
		{
		}

		public void Dispose()
		{
			Dispose(true);
		}

		#endregion *** Implemented IDisposable interface ***

		public virtual void Initialize()
		{
			IsInitialized = true;
		}

		/// <summary>
		/// Gets a type of the subsystem the engine belongs to.
		/// </summary>
		protected abstract Type SubsystemType
		{
			get;
		}

		/// <summary>
		/// Performs data processing.
		/// </summary>
		/// <param name="input">Data to be processed.</param>
		/// <returns>Processing result.</returns>
		protected abstract ApiOutput ExecuteInternal(ApiInput input);
	}
}
