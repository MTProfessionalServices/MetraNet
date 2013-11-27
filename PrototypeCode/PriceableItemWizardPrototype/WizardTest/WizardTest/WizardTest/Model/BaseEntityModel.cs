using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml.Serialization;

namespace WizardTest.Model
{
  public class BaseEntityModel
  {
    [XmlElementAttribute("ElementName")]
    public string Name { get; set; }

    [XmlElementAttribute("Descrption")]
    public string Description { get; set; }

    [XmlElementAttribute("Configuration")]
    public string Configuration { get; set; }

    [XmlElementAttribute("Element")]
    public string Element { get; set; }
  }
}
