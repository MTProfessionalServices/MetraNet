using System;
using System.IO;
using System.Linq;
using System.Runtime.InteropServices;
using System.Xml.Serialization;
using MetraTech.Interop.RCD;
using MetraTech.Security.Crypto;
using MetraTech.SecurityFramework.Core.Common.Logging;

namespace MetraTech.Security
{
	/// <summary>
	/// 
	/// </summary>
	[XmlRoot("PasswordConfig")]
	[ComVisible(false)]
	public sealed class PasswordConfig
	{
		private static PasswordConfig instance = null;

		#region Public properties
		/// <summary>
		/// Number of login attempts that are allowed to fail before account is locked.
		/// </summary>
		public int LoginAttemptsAllowed
		{
			get;
			set;
		}

		/// <summary>
		/// Number of minutes that must pass with no login attempts, before the account can be auto unlocked.
		/// </summary>
		public int MinutesBeforeAutoResetPassword
		{
			get;
			set;
		}

		/// <summary>
		/// Run the password strength code
		/// </summary>
		public bool EnsureStrongPasswords
		{
			get;
			set;
		}

		/// <summary>
		/// Regex that determines if a password is strong enough to be used.
		/// </summary>
		[XmlElement("PasswordStrengthRegex", Type = typeof(CDATA))]
		public CDATA PasswordStrengthRegex
		{
			get;
			set;
		}

		/// <summary>
		/// DaysOfInactivityBeforeAccountLocked is applied for System Account types.  Other account types use AccountState 
		/// property CanLoginToMetraView defined in rmp\extensions\core\config\account\accountstates.xml.  The account can
		/// be locked out based on this inactivity check.
		/// </summary>
		public int DaysOfInactivityBeforeAccountLocked
		{
			get;
			set;
		}

		/// <summary>
		/// The number of days to start warning about an expiring password, before it expires.
		/// </summary>
		public int DaysToStartWarningPasswordWillExpire
		{
			get;
			set;
		}

		/// <summary>
		/// This will not lock the account out, but will ask them to change their password (when within or past the warning period).
		/// </summary>
		public int DaysBeforePasswordExpires
		{
			get;
			set;
		}

		/// <summary>
		/// The number of lasts passwords that must be unique.
		/// </summary>
		public int NumberOfLastPasswordsThatAreUnique
		{
			get;
			set;
		}

    /// <summary>
    /// Gets or sets a password managers configuration for different authentication types.
    /// </summary>
    [XmlArray(ElementName = "AuthenticationTypes", IsNullable = false)]
    [XmlArrayItem(ElementName = "AuthenticationType")]
    public PasswordManagerConfig[] AuthenticationTypes
    {
      get;
      set;
    }

		#endregion

		#region Public methods

		public PasswordConfig()
		{
			LoginAttemptsAllowed = 6;
			MinutesBeforeAutoResetPassword = 30;
			EnsureStrongPasswords = true;
			DaysOfInactivityBeforeAccountLocked = 90;
			DaysToStartWarningPasswordWillExpire = 14;
			DaysBeforePasswordExpires = 90;
			NumberOfLastPasswordsThatAreUnique = 4;
		}


    /// <summary>
    /// Gets the password manager type name configuraed for the indicated authentication type.
    /// </summary>
    /// <param name="authenticationTypeName">The authentication type to find the password manager for.</param>
    /// <returns>A password manager type name.</returns>
    /// <exception cref="ArgumentNullException"><paramref name="authenticationTypeName"/> is null or empty string.</exception>
    /// <exception cref="ArgumentException">Value of <paramref name="authenticationTypeName"/> has no corresponding configuration.</exception>
    public string GetPasswordManagerTypeName(string authenticationTypeName)
    {
      if (string.IsNullOrEmpty(authenticationTypeName))
      {
        throw new ArgumentNullException("authenticationTypeName");
      }

      PasswordManagerConfig passwordManager =
        this.AuthenticationTypes.Where(p => string.Compare(p.AuthenticationTypeName, authenticationTypeName, StringComparison.InvariantCultureIgnoreCase) == 0).FirstOrDefault();

      if (passwordManager == null)
      {
        throw new ArgumentException("authenticationTypeName", string.Format("\"{0}\" authentication type not found in the mtpassword.xml", authenticationTypeName));
      }

      return passwordManager.PasswordManagerTypeName;
    }

		/// <summary>
		///   Read the mtpassword.xml file and initialize the singleton instance.
		/// </summary>
		public static PasswordConfig GetInstance()
		{
			if (instance == null)
			{
				// use double-check locking to avoid lock if we already have the single instance.  http://msdn.microsoft.com/en-us/library/ms954629.aspx
				lock (typeof(PasswordConfig))
				{
					if (instance == null)
					{
						try
						{
							IMTRcd rcd = new MTRcdClass();
							string configFile = rcd.ConfigDir + @"security\mtpassword.xml";

							using (FileStream fileStream = File.Open(configFile, FileMode.Open, FileAccess.Read, FileShare.ReadWrite))
							{
								XmlSerializer s = new XmlSerializer(typeof(PasswordConfig));
								instance = (PasswordConfig)s.Deserialize(fileStream);
							}
						}
						catch (Exception e)
						{
							LoggingHelper.Log(e);
							throw;
						}
					}
				}
			}
			return instance;
		}

		#endregion
	}
}
