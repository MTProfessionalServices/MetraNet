using System;
using System.Collections.Generic;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	/// 
	/// </summary>
	[XmlRoot("keyData")]
	[ComVisible(false)]
	public sealed class MSSessionKeyConfig
	{
		#region Private fields
		private static volatile MSSessionKeyConfig instance;
		private static object root = new Object();
		private string keyFile;
		private List<KeyClass> keyClasses;
		#endregion

		#region Public Properties
		/// <summary>
		///    KeyClasses
		/// </summary>
		[XmlElement(ElementName = "keyClass", Type = typeof(KeyClass))]
		public KeyClass[] KeyClasses
		{
			get
			{
				if (keyClasses != null)
				{
					return keyClasses.ToArray();
				}

				return null;
			}
			set
			{
				if (value != null)
				{
					keyClasses = new List<KeyClass>();
					foreach (KeyClass keyClass in value)
					{
						keyClasses.Add(keyClass);
					}
				}
			}
		}

		/// <summary>
		///   KeyFile
		/// </summary>
		public string KeyFile
		{
			get
			{
				return keyFile;
			}
		}

		/// <summary>
		///   Machine.
		/// </summary>
		[XmlElement(ElementName = "machine", Type = typeof(string))]
		public string Machine
		{
			get;
			set;
		}

		/// <summary>
		///   Creation Date.
		/// </summary>
		[XmlElement(ElementName = "creationDate", Type = typeof(DateTime))]
		public DateTime CreationDate
		{
			get;
			set;
		}

		/// <summary>
		///   Process.
		/// </summary>
		[XmlElement(ElementName = "process", Type = typeof(string))]
		public string Process
		{
			get;
			set;
		}

		#endregion

		#region Public Methods

		/// <summary>
		///   Return the singleton RSACryptoConfig
		/// </summary>
		/// <returns></returns>
		public static MSSessionKeyConfig GetInstance()
		{
			if (instance == null)
			{
				lock (root)
				{
					if (instance == null)
					{
						instance = new MSSessionKeyConfig();
					}
				}
			}

			return instance;
		}

		/// <summary>
		///   Initialize
		/// </summary>
		public void Initialize()
		{
			try
			{
				MSSessionKeyConfig msSessionKeyConfig = null;

				if (File.Exists(keyFile))
				{
					using (FileStream fileStream = File.Open(keyFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
					{
						XmlSerializer serializer = new XmlSerializer(typeof(MSSessionKeyConfig));
						msSessionKeyConfig = (MSSessionKeyConfig)serializer.Deserialize(fileStream);

						this.Machine = msSessionKeyConfig.Machine;
						this.CreationDate = msSessionKeyConfig.CreationDate;
						this.Process = msSessionKeyConfig.Process;
						this.KeyClasses = msSessionKeyConfig.KeyClasses;

						// Verify checksum
						//string checksum = CreateChecksum();
						//if (msSessionKeyConfig.Checksum == null || checksum != msSessionKeyConfig.Checksum.Text)
						//{
						//  throw new ApplicationException("Unable to verify checksums");
						//}

						// this.Checksum = msSessionKeyConfig.Checksum;
					}
				}
			}
			catch (Exception e)
			{
				LoggingHelper.Log(e);
				throw;
			}

			LoggingHelper.LogDebug("[MetraTech.Security.MSSessionKeyConfig]", "Finished initializing MSSessionKeyConfig");
		}

		/// <summary>
		///   If the specified keyClass exists, it is removed before the specifed keyClass is added.
		/// </summary>
		/// <param name="keyClass"></param>
		public void AddKeyClass(KeyClass keyClass)
		{
			foreach (KeyClass lpKeyClass in keyClasses)
			{
				if (lpKeyClass.Name.ToLower() == keyClass.Name.ToLower())
				{
					keyClasses.Remove(lpKeyClass);
					break;
				}
			}

			keyClasses.Add(keyClass);
		}

		/// <summary>
		///   Return the KeyClass with the given keyClassName
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		public KeyClass GetKeyClass(string keyClassName)
		{
			KeyClass keyClass = null;

			if (KeyClasses != null)
			{
				foreach (KeyClass lpKeyClass in KeyClasses)
				{
					if (lpKeyClass.Name.ToLower() == keyClassName.ToLower())
					{
						keyClass = lpKeyClass;
						break;
					}
				}
			}
			return keyClass;
		}

		/// <summary>
		///   Write
		/// </summary>
		public void Write()
		{
			lock (root)
			{
				// this.Checksum = new CDATA(CreateChecksum());

				XmlSerializer serializer = new XmlSerializer(typeof(MSSessionKeyConfig));
				using (FileStream stream = File.Open(keyFile, FileMode.Create, FileAccess.Write, FileShare.ReadWrite))
				{
					// Suppress xmlns output
					XmlSerializerNamespaces ns = new XmlSerializerNamespaces();

					// Add an empty namespace and empty value
					ns.Add("", "");

					serializer.Serialize(stream, this, ns);

					stream.Close();
				}
			}
		}

		/// <summary>
		///   Return the current key for the given key class.
		/// </summary>
		/// <param name="keyClassName"></param>
		/// <returns></returns>
		public Key GetCurrentKey(string keyClassName)
		{
			Key key = null;

			foreach (KeyClass lpKeyClass in KeyClasses)
			{
				if (lpKeyClass.Name.ToLower() == keyClassName.ToLower())
				{
					key = lpKeyClass.GetCurrentKey();
					break;
				}
			}

			return key;
		}

		/// <summary>
		///   Get the Key for the given keyId by searching through all the KeyClass items.
		/// </summary>
		/// <param name="keyId"></param>
		/// <returns></returns>
		public Key GetKey(Guid keyId)
		{
			Key key = null;

			foreach (KeyClass keyClass in KeyClasses)
			{
				key = keyClass.GetKey(keyId);
				if (key != null)
				{
					break;
				}
			}

			return key;
		}

		/// <summary>
		///   Return false if this class is invalid. 
		/// </summary>
		/// <param name="error"></param>
		/// <returns></returns>
		public bool IsValid(out string error)
		{
			error = String.Empty;

			List<string> errors = new List<string>();
			if (keyClasses.Count == 0)
			{
				error = String.Format("No key classes found in '{0}'", keyFile);
				return false;
			}

			foreach (KeyClass keyClass in keyClasses)
			{
				if (!keyClass.IsValid(errors))
				{
					foreach (string err in errors)
					{
						error += Environment.NewLine;
						error += err;
					}

					return false;
				}
			}

			return true;
		}

		/// <summary>
		///   Make the given key id the current key.
		/// </summary>
		/// <param name="id"></param>
		public void MakeKeyCurrent(Guid id)
		{
			foreach (KeyClass keyClass in keyClasses)
			{
				if (keyClass.HasKey(id))
				{
					keyClass.MakeKeyCurrent(id);
					break;
				}
			}
		}

		#endregion

		#region Private Methods

		/// <summary>
		///  Constructor
		/// </summary>
		private MSSessionKeyConfig()
		{
			IMTRcd rcd = new MTRcdClass();
			keyFile = Path.Combine(rcd.ConfigDir, "security") +
					  Path.DirectorySeparatorChar +
					  "sessionkeys.xml";

			keyClasses = new List<KeyClass>();
		}

		#endregion
	}
}
