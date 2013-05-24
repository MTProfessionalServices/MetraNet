using System;
using System.Runtime.InteropServices;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;
using System.Reflection;
using System.Globalization;

namespace MetraTech.Security.Crypto
{
	/// <summary>
	///   CDATA
	/// </summary>
	[ComVisible(false)]
	public class CDATA : IXmlSerializable
	{
		private string base64Text;

		/// <summary>
		///   Text
		/// </summary>
		public string Text
		{
			get { return base64Text; }
		}

		#region Public methods

		/// <summary>
		///   Constructor
		/// </summary>
		public CDATA()
		{ }

		/// <summary>
		///   Decrypt
		/// </summary>
		/// <returns></returns>
		/*public byte[] Decrypt()
		{
			Assembly assembly = Assembly.Load(new AssemblyName("MetraTech.SecurityFramework"));
			
			Type UnprotectDataEngineType = assembly.GetType("MetraTech.SecurityFramework.Core.Encryptor.UnprotectDataEngine");
			
			object UnprotectDataEngine = assembly.CreateInstance("MetraTech.SecurityFramework.Core.Encryptor.UnprotectDataEngine", true);
			object ApiInput = assembly.CreateInstance("MetraTech.SecurityFramework.ApiInput", 
														true, 
														BindingFlags.CreateInstance, 
														null, 
														new object[] { base64Text }, 
														CultureInfo.InvariantCulture, 
														null);

			MethodInfo ExecuteInternal = UnprotectDataEngineType.GetMethod("ExecuteInternal", BindingFlags.Instance | BindingFlags.NonPublic | BindingFlags.Public);
			object ApiOutput = ExecuteInternal.Invoke(UnprotectDataEngine, new object[] { ApiInput });

			byte[] result = Convert.FromBase64String(ApiOutput.ToString());
			return result;
		}*/

		/// <summary>
		///  Constructor
		/// </summary>
		/// <param name="base64Text"></param>
		public CDATA(string base64Text)
		{
			this.base64Text = base64Text;
		}

		#endregion

		#region Private methods

		XmlSchema IXmlSerializable.GetSchema()
		{
			return null;
		}

		void IXmlSerializable.ReadXml(XmlReader reader)
		{
			this.base64Text = reader.ReadString();
			reader.Read();
		}

		void IXmlSerializable.WriteXml(XmlWriter writer)
		{
			writer.WriteCData(this.base64Text);
		}

		#endregion
	}
}
