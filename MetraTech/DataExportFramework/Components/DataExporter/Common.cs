
namespace MetraTech.DataExportFramework.Components.DataExporter
{

	/// <summary>
	/// Summary description for Common.
	/// </summary>
	public class Common
	{
		private static MetraTech.Logger __logger = new MetraTech.Logger("[DATAEXPORT]");

		protected Common()
		{
			//HIDDEN CONSTRUCTOR
		}

		public static MetraTech.Logger LoggerInstance()
		{
			return __logger;
		}
				
		public static void MakeLogEntry(string slogEntry, string slogtype)
		{
			switch (slogtype.ToLower())
			{
				case "error":
					__logger.LogError(slogEntry);
					break;
				case "fatal":
					__logger.LogFatal(slogEntry);
					break;
				case "info":
					__logger.LogInfo(slogEntry);
					break;
				case "warning":
					__logger.LogWarning(slogEntry);
					break;
				default:
					__logger.LogDebug(slogEntry);
					break;
			}
		}

		public static void MakeLogEntry(string slogEntry)
		{
			__logger.LogDebug(slogEntry);
		}
        
	}
}

