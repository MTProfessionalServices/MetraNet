using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using WizardTest.Interfaces;

namespace WizardTest.Model
{
  public class ExtensionModel : BaseEntityModel, IExtension
    {
      #region IExtension Members

      [XmlElement("Namespace")]
      public string Namespace
      {
        get; set; 
      }

      [XmlElement("AuthorName")]
      public string AuthorName
      {
        get; set; 
      }

      public List<String> ExistingNamespaces { get; set; }

      #endregion
    }
}
