using System;
using System.Collections.Generic;
using System.Text;
using System.Xml.Serialization;

namespace MetraTech.UI.Controls.MTLayout
{
  [Serializable]
  public class GridDataBindingLayout
  {
    public string AccountID;

    [XmlArrayItem("Argument")]
    public List<DataBindingArgumentLayout> Arguments = new List<DataBindingArgumentLayout>();

    public string Binding;
    public string Operation;
    public string OutPropertyName;
    public string ProcessorID;
    public string ServiceMethodName;

    [XmlArrayItem("ServiceMethodParameter")]
    public List<ServiceMethodParameterLayout> ServiceMethodParameters = new List<ServiceMethodParameterLayout>();

    public string ServicePath;
  }
}
