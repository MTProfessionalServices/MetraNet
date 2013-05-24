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
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace ContersRegistrator
{
	/// <summary>
	/// This utility exists just to be ran once on each computer running the Security Framework to register its performance counters.
	/// </summary>
	class Program
	{
		static void Main(string[] args)
		{
			Console.WriteLine("Registering the performance sounters...");

			try
			{
				MetraTech.SecurityFramework.PerformanceMonitor.CheckCounters();
				Console.WriteLine("Performance counters were registered successfully. Press Enter to exit.");
			}
			catch (Exception)
			{
				Console.WriteLine("The was a problem during the registration. Please make sure you have administrative permissions.");
				Console.WriteLine("Press Enter to exit.");
			}

			Console.ReadLine();
		}
	}
}
