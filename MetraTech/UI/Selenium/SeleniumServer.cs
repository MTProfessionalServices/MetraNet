using System;
using System.Collections.Generic;
using System.Text;
using System.Threading;

using System.Diagnostics;

namespace MetraTech.UI.Test.Selenium
{
  /// <summary>
  /// Class that hosts a command to ensure the Selenium Java Server is running
  /// </summary>
  public class SeleniumServer
  {

	static Process seleniumServer = null;
	  
	/// <summary>
    /// Starts the Selenium Core java server if it is not already running.
    /// </summary>
    public static void StartSeleniumServer()
    {
      try
      {
        // Start Selenium Server
        ProcessStartInfo psi = new ProcessStartInfo();
		seleniumServer = System.Diagnostics.Process.Start("java", "-jar selenium-server.jar -multiWindow -ensureCleanSession");

        // Wait for Selenium Server to start
        System.Threading.Thread.Sleep(10000);
      }
      catch(Exception)
      {
        // Selenium may already be running... we just eat the error
      }
    }

	/// <summary>
	/// Starts the Selenium Core java server if it is not already running.
	/// </summary>
	public static void StartSeleniumServer(string profileDir)
	{
		try
		{
			// Start Selenium Server
			ProcessStartInfo psi = new ProcessStartInfo();
			seleniumServer = System.Diagnostics.Process.Start("java", "-jar selenium-server.jar -multiWindow -ensureCleanSession -firefoxProfileTemplate " + profileDir);

			// Wait for Selenium Server to start
			System.Threading.Thread.Sleep(10000);
		}
		catch (Exception)
		{
			// Selenium may already be running... we just eat the error
		}
	}

	/// <summary>Stop the Selenium Core java server </summary>
	public static void StopSeleniumServer()
	{
		Thread.Sleep(500);
		if (!seleniumServer.HasExited)
		{ seleniumServer.CloseMainWindow(); }

	}
  }
}
