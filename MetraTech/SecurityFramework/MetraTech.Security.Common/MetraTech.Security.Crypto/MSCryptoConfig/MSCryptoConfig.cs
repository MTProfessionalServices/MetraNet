using System;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	/// 
	/// </summary>
	[XmlRoot("xmlconfig")]
	[ComVisible(false)]
	public sealed class MSCryptoConfig
	{
		#region Private fields
		private static volatile MSCryptoConfig instance;
		private static object root = new Object();
		private MSSessionKeyConfig _sessionKeyConfig;
		#endregion

		#region Public Properties
		/// <summary>
		///    SessionKeyConfig
		/// </summary>
		public MSSessionKeyConfig SessionKeyConfig
		{
			get { return _sessionKeyConfig; }
			set { _sessionKeyConfig = value; }
		}

		#endregion

		#region Public Methods

		/// <summary>
		///   Return the singleton RSACryptoConfig
		/// </summary>
		/// <returns></returns>
		public static MSCryptoConfig GetInstance()
		{
			if (instance == null)
			{
				lock (root)
				{
					if (instance == null)
					{
						instance = new MSCryptoConfig();
						instance.Initialize();
					}
				}
			}

			return instance;
		}


		#endregion

		#region Private Methods

		/// <summary>
		///  Constructor
		/// </summary>
		private MSCryptoConfig()
		{
		}

		/// <summary>
		///   Initialize
		/// </summary>
		private void Initialize()
		{
			try
			{
				_sessionKeyConfig = MSSessionKeyConfig.GetInstance();
				_sessionKeyConfig.Initialize();
				//if (sessionKeyConfig.KeyClasses == null || sessionKeyConfig.KeyClasses.Length == 0)
				//{
				//  throw new ApplicationException(String.Format("No session keys found in '{0}'", sessionKeyConfig.KeyFile));
				//}
			}
			catch (Exception e)
			{
				LoggingHelper.Log(e);
				throw;
			}

			LoggingHelper.LogDebug("[MetraTech.Security.CryptoConfig]", "Finished initializing MSCryptoConfig");
		}

		#endregion
	}
}
