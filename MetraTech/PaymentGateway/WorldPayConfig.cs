using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Configuration;
using System.Xml;
using RCD = MetraTech.Interop.RCD;
using System.IO;
using System.Net;
using System.Collections;
using MetraTech.Security.Crypto;
namespace MetraTech.MetraPay.PaymentGateway
{
	public class WorldPayConfig : ConfigurationSection
	{
		static private WorldPayConfig _wpConfig;
		#region Constructors
		static WorldPayConfig()
		{

			RCD.IMTRcd rcd = new RCD.MTRcd();
			ExeConfigurationFileMap map = new ExeConfigurationFileMap();
			map.ExeConfigFilename = Path.Combine(rcd.ExtensionDir, @"PaymentSvr\config\Gateway\WorldPayConfig.xml");

			Configuration config = ConfigurationManager.OpenMappedExeConfiguration(map, ConfigurationUserLevel.None);

			try
			{
				_wpConfig = (WorldPayConfig)config.GetSection("WorldPayConfig");
				_wpConfig.ConfigPath = map.ExeConfigFilename.Substring(0, map.ExeConfigFilename.LastIndexOf(@"\") + 1);
			}
			catch (Exception e)
			{
				string s = e.Message + " " + e.GetType();

			}


		}
		public WorldPayConfig()
		{
		}
		#endregion
		public static WorldPayConfig GetGlobalInstance()
		{
			if (_wpConfig == null)
			{
				_wpConfig = new WorldPayConfig();
			}
			return _wpConfig;
		}
        [ConfigurationProperty("returnIp")]
        public ConfigurationTextElement<string> ReturnIp
        {
            get { return (ConfigurationTextElement<string>)this["returnIp"]; }
            set { this["returnIp"] = value; }
        }

		[ConfigurationProperty("url")]
		public ConfigurationTextElement<string> Url
		{
			get { return (ConfigurationTextElement<string>)this["url"]; }
			set { this["url"] = value; }
		}
		[ConfigurationProperty("templatesfilename")]
		public ConfigurationTextElement<string> TemplatesPathElement
		{
			get
			{
				if (configpath != null)
				{
					return new ConfigurationTextElement<string>(configpath + ((ConfigurationTextElement<string>)this["templatesfilename"]).Value);

				}
				return (ConfigurationTextElement<string>)this["templatesfilename"];
			}
			set
			{
				this["templatesfilename"] = value;
			}

		}
		[ConfigurationProperty("credentials")]
		protected ConfigurationCredentialsCollection credentials
		{
			get
			{
				return (ConfigurationCredentialsCollection)this["credentials"];
			}
			set
			{ this["credentials"] = value; }
		}
		[ConfigurationProperty("invoiceStyle")]
		public ConfigurationTextElement<string> InvoiceStyle
		{
			get { return (ConfigurationTextElement<string>)this["invoiceStyle"]; }
			set { this["invoiceStyle"] = value; }
		}
		[ConfigurationProperty("paymentMethodMask")]
		public PaymentMaskEelementCollection PaymentMethodMasks
		{
			get { return (PaymentMaskEelementCollection)this["paymentMethodMask"]; }
			set
			{
				this["paymentMethodMask"] = value;
			}

		}
		private NetworkCredential _monitoringCredential;
		private NetworkCredential _recurringCredential;
		private object mutex = new object();
		public NetworkCredential MonitoringCredential
		{
			get
			{
				if (_monitoringCredential == null)
				{
					lock (mutex)
					{
						foreach (CredentialElement c in credentials)
						{
							if (c.Type.Equals("monitoring"))
							{
								_monitoringCredential = new NetworkCredential(c.Username, c.Password);
								break;
							}
						}
						if (_monitoringCredential == null)
						{
							_monitoringCredential = new NetworkCredential();
						}
					}
				}
				return (_monitoringCredential);
			}
		}
		public NetworkCredential RecurringCredential
		{
			get
			{
				if (_recurringCredential == null)
				{
					lock (mutex)
					{
						foreach (CredentialElement c in credentials)
						{
							if (c.Type.Equals("recurring"))
							{
								_recurringCredential = new NetworkCredential(c.Username, c.Password);
								break;
							}
						}
						if (_recurringCredential == null)
						{
							_recurringCredential = new NetworkCredential();
						}
					}
				}
				return (_recurringCredential);
			}
		}
		public XmlDocument TemplatesXmlDoc
		{
			set
			{
				TemplatesXmlDoc = value;
			}
			get
			{
				if (this["templatesfilename"] != null && templatesXml == null)
				{
					lock (mutex)
					{

						try
						{
							reader = new XmlTextReader(TemplatesPathElement.Value);
							templatesXml = new XmlDocument();
							templatesXml.Load(reader);
						}
						catch (Exception e)
						{
							Console.WriteLine(e.Message);
							throw new Exception("WorldPay : either the filename or the templatesXml is empty");
						}
					}
				}
				return templatesXml;

			}
		}
		public string ConfigPath
		{
			set
			{
				configpath = value;
			}
			get
			{
				return configpath;
			}
		}
		# region Private Properties
		private XmlDocument templatesXml;
		private XmlTextReader reader;
		private string configpath;
		#endregion
	}
	public class MaskElement : ConfigurationElement
	{
		[ConfigurationProperty("code")]
		public string Code
		{
			get
			{
				return (string)this["code"];
			}
			set
			{
				this["code"] = value;
			}

		}

	}
	public class PaymentMaskEelementCollection : ConfigurationElementCollection
	{

		public PaymentMaskEelementCollection() { }
		protected override ConfigurationElement CreateNewElement()
		{
			MaskElement mask = new MaskElement();
			return mask;
		}

		protected override object GetElementKey(ConfigurationElement element)
		{
			return ((MaskElement)element).Code;
		}
		protected override string ElementName
		{
			get
			{
				return "include";
			}
		}
		public override ConfigurationElementCollectionType CollectionType
		{
			get
			{
				return ConfigurationElementCollectionType.BasicMap;
			}
		}
		public override string ToString()
		{

			StringBuilder mask = new StringBuilder();
			mask.Append("<paymentMethodMask>");
			System.Collections.IEnumerator e = GetEnumerator();
			while (e.MoveNext())
			{
				MaskElement m = (MaskElement)e.Current;
				mask.Append("<include code=" + "\"" + m.Code + "\"/>");
			}
			return mask.ToString();
		}

	}
	public class ConfigurationTextElement<T> : ConfigurationElement
	{

		private T _value;
		public ConfigurationTextElement() { }
		public ConfigurationTextElement(T val)
		{
			_value = val;

		}
		protected override void DeserializeElement(XmlReader reader,
								bool serializeCollectionKey)
		{
			_value = (T)reader.ReadElementContentAs(typeof(T), null);
		}
		public T Value
		{
			get { return _value; }
			set { _value = value; }
		}

	}
	public class CredentialElement : ConfigurationElement
	{
		//SECENG: added instance of crypto manager for password decryption.
		private ICryptoManager _manager = new CryptoManager();

		[ConfigurationProperty("type")]
		public string Type
		{
			get { return (string)this["type"]; }
		}
		[ConfigurationProperty("username")]
		public string Username
		{
			get { return (string)this["username"]; }
		}
		[ConfigurationProperty("password")]
		public string Password
		{
			get
			{
				//SECENG: decrypt password if "ecrypted" attribute is true.
				return Encrypted != null && Encrypted.Equals("true") ? 
												_manager.Decrypt(CryptKeyClass.WorldPayPassword, (string)this["password"]) 
											:
												(string)this["password"];
			}
		}
		//SECENG: indicates if password in section already encrypted.
		[ConfigurationProperty("encrypted")]
		public string Encrypted
		{
			get
			{
				return (string)this["encrypted"];
			}
		}

	}
	public class ConfigurationCredentialsCollection : ConfigurationElementCollection
	{
		public ConfigurationCredentialsCollection() { }
		protected override ConfigurationElement CreateNewElement()
		{
			CredentialElement credential = new CredentialElement();
			return credential;
		}

		protected override object GetElementKey(ConfigurationElement element)
		{
			return ((CredentialElement)element).Type;
		}
		protected override string ElementName
		{
			get
			{
				return "credential";
			}
		}
		public override ConfigurationElementCollectionType CollectionType
		{
			get
			{
				return ConfigurationElementCollectionType.BasicMap;
			}
		}
	}

}
