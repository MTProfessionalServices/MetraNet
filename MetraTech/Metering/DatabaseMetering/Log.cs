using System;
using System.Diagnostics;
using System.IO;

namespace MetraTech.Metering.DatabaseMetering
{
	/// <summary>
	/// Summary description for Log.
	/// </summary>
	public class Log
	{
		/// <summary>
		/// Name of the log file.
		/// </summary>
		static private string strLogFileName;	

		/// <summary>
		/// //Log level set for logging.
		/// </summary>
		static private int iLogLevel;		

		/// <summary>
		/// Name of the program that is logging into this file.
		/// </summary>
		static private string strLogSource;		
			
		/// <summary>
		/// StreamWriter object used to log the message.
		/// </summary>
		static private StreamWriter objStreamWriter;

		/// <summary>
		/// Log object. Used to log the info.
		/// </summary>
		private static Log objLog = null;		
		
		public enum LogLevel
		{
			FATAL=1, ERROR=2, WARNING=3, INFO=4, DEBUG=5
		}
		/// <summary>
		/// Private constructor
		/// </summary>
		private Log()
		{
		}
		
		/// <summary>
		/// Returns the object of the Log.
		/// </summary>
		/// <returns>log object</returns>
		public static Log GetInstance()
		{
			return objLog;
		}


		/// <summary>
		/// Opens the log file in appending mode
		/// </summary>
		/// <param name="strFileName">Name of the log file</param>
		/// <param name="iLevel">Log Level</param>
		/// <param name="strSource">Name of the program that is logging into this file</param>
		public static void LogInit(string strFileName, int iLevel, string strSource)
		{
			strLogFileName = strFileName;
			iLogLevel = iLevel;
			strLogSource = strSource;
			try
			{
				
				objStreamWriter = new StreamWriter(strFileName,true, System.Text.Encoding.Default);
				objStreamWriter.AutoFlush = true;
			}
			catch(Exception ex)
			{
				throw ex;
			}

           if(objLog == null)
				objLog = new Log();
		}
	

		/// <summary>
		/// Writes the given string to the log file, if the severity of the message is less than the 
		/// log level.
		/// </summary>
		/// <param name="iErrorLevel">Log Level</param>
		/// <param name="strErrorMsg">Message to log</param>
		public void LogString(LogLevel iErrorLevel,string strErrorMsg)
		{
         lock(this) 
         {
            if( (int)iErrorLevel <= Log.iLogLevel)
            {
               Log.objStreamWriter.WriteLine(DateTime.Now.ToString("MM/dd/yy HH:mm:ss") + " [" + Log.strLogSource + "]" + " " + strErrorMsg);
            }
         }
		}
	

		/// <summary>
		/// Closes the file handle
		/// </summary>
		public void LogClose()
		{
			Log.objStreamWriter.Close();
		}
	}
}
