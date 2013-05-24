using System.Runtime.InteropServices;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	/// 
	/// </summary>
	[ComVisible(false)]
	public class KmsClientConfig
	{
		public string CertificateFile
		{
			get;
			set;
		}

		public string Server
		{
			get;
			set;
		}

		public string ServerPort
		{
			get;
			set;
		}

		public string LogLevel
		{
			get;
			set;
		}

		public string LogFile
		{
			get;
			set;
		}

		public string ConnectTimeout
		{
			get;
			set;
		}

		public string Retries
		{
			get;
			set;
		}

		public string RetryDelay
		{
			get;
			set;
		}

		public string CacheTimeToLive
		{
			get;
			set;
		}

		public string CacheFile
		{
			get;
			set;
		}

		public string MemoryCache
		{
			get;
			set;
		}
	}
}
