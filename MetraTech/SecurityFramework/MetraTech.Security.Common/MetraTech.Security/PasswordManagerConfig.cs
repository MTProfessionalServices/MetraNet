using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace MetraTech.Security
{
  /// <summary>
  /// Represents a configuration for the password manager specific for the authentication type.
  /// </summary>
  public class PasswordManagerConfig
  {
    /// <summary>
    /// Gets or sets a name of the Authentication type
    /// </summary>
    [XmlAttribute(AttributeName = "type")]
    public string AuthenticationTypeName
    {
      get;
      set;
    }

    /// <summary>
    /// Gets or sets a type name of the password manager responsible for the authentication type.
    /// </summary>
    [XmlAttribute(AttributeName = "passwordManager")]
    public string PasswordManagerTypeName
    {
      get;
      set;
    }
  }
}
