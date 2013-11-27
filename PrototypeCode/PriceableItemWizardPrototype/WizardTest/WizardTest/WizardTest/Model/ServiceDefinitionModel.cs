using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;
using WizardTest.Interfaces;

namespace WizardTest.Model
{
  public class ServiceDefinitionModel :BaseEntityModel, IServiceDefinition
    {

      #region IServiceDefinition Members

      [XmlElementAttribute("TableName")]
      public string TableName { get; set; }

      #endregion
    }
}
