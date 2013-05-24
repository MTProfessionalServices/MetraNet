using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
	/// <summary>
	/// Profide a base functionality for performance monitoring.
	/// </summary>
	public static class PerformanceMonitor
	{
		#region Constants

		private const string CategoryName = "MetraTech:SecurityFramework";
		private const string CategoryHelp = "MetraTech Security Framework performance counters";

		private const string WorkTimePerSecondCounter = "WorkTimePerSecond";
		private const string WorkTimePerSecondHelp = "All engines work time per second";

		private const string MonitorTimePerSecondCounter = "MonitorTimePerSecond";
		private const string MonitorTimePerSecondHelp = "Security Monitor work time per second";

		private const string HandlersTimePerSecondCounter = "HandlersTimePerSecond";
		private const string HandlersTimePerSecondHelp = "Security event handlers work time per second";

		#endregion

		#region Private fields

		private static PerformanceCounter _workTimePerSecond;
		private static PerformanceCounter _monitorTimePerSecond;
		private static PerformanceCounter _handlersTimePerSecond;

		#endregion

		#region Public methods

		/// <summary>
		/// Registers performance counters if necessary.
		/// </summary>
		/// <remarks>A Windows account must have administrative right to execute this method!</remarks>
		public static void CheckCounters()
		{
			try
			{
				if (!PerformanceCounterCategory.Exists(CategoryName))
				{
					// Create counters data
					CounterCreationDataCollection counters = new CounterCreationDataCollection();

					AddCounter(WorkTimePerSecondCounter, WorkTimePerSecondHelp, PerformanceCounterType.RateOfCountsPerSecond64, counters);
					AddCounter(MonitorTimePerSecondCounter, MonitorTimePerSecondHelp, PerformanceCounterType.RateOfCountsPerSecond64, counters);
					AddCounter(HandlersTimePerSecondCounter, HandlersTimePerSecondHelp, PerformanceCounterType.RateOfCountsPerSecond64, counters);

					PerformanceCounterCategory.Create(CategoryName, CategoryHelp, PerformanceCounterCategoryType.SingleInstance, counters);
				}
			}
			catch (Exception)
			{
				// Hide exceptions here.
			}
		}

		/// <summary>
		/// Opens all performance counters.
		/// </summary>
		public static void CreateCounters()
		{
			if (_workTimePerSecond == null)
			{
				_workTimePerSecond = OpenCounter(WorkTimePerSecondCounter);
			}

			if (_monitorTimePerSecond == null)
			{
				_monitorTimePerSecond = OpenCounter(MonitorTimePerSecondCounter);
			}

			if (_handlersTimePerSecond == null)
			{
				_handlersTimePerSecond = OpenCounter(HandlersTimePerSecondCounter);
			}
		}

		#endregion

		#region Internal methods

		/// <summary>
		/// Increment Work time per second counter.
		/// </summary>
		/// <param name="ticks">A value to increment the counter by.</param>
		internal static void IncrementWorkTime(long ticks)
		{
			IncrementCounter(_workTimePerSecond, ticks);
		}

		/// <summary>
		/// Increment Security Monitor time per second counter.
		/// </summary>
		/// <param name="ticks">A value to increment the counter by.</param>
		internal static void IncrementMonitorTime(long ticks)
		{
			IncrementCounter(_monitorTimePerSecond, ticks);
		}

		/// <summary>
		/// Increment Security event handlers time per second counter.
		/// </summary>
		/// <param name="ticks">A value to increment the counter by.</param>
		internal static void IncrementHandlersTime(long ticks)
		{
			IncrementCounter(_handlersTimePerSecond, ticks);
		}

		#endregion

		#region Private methods

		private static void AddCounter(string counterName, string counterHelp, PerformanceCounterType counterType, CounterCreationDataCollection counters)
		{
			CounterCreationData creationData = new CounterCreationData(counterName, counterHelp, counterType);
			counters.Add(creationData);
		}

		private static PerformanceCounter OpenCounter(string counterName)
		{
			PerformanceCounter result;

			try
			{
				result =
					PerformanceCounterCategory.CounterExists(counterName, CategoryName) ? new PerformanceCounter(CategoryName, counterName, false) : null;
			}
			catch (Exception)
			{
				// Trying to open as many counters as possible.
				result = null;
			}

			return result;
		}

		private static void IncrementCounter(PerformanceCounter counter, long ticks)
		{
			if (counter != null)
			{
				counter.IncrementBy(ticks);
			}
		}

		#endregion
	}
}
