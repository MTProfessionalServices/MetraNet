using System.Collections.Generic;
using System.Linq;
using System.Xml.Linq;

namespace MetraNet.Charts
{
  /// <summary>
  /// 
  /// </summary>
  public class Styles
  {
    /// <summary>
    /// 
    /// </summary>
    public IEnumerable<Style> Definition { get; set; }
    /// <summary>
    /// 
    /// </summary>
    public IEnumerable<Apply> Application { get; set; }

    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    public XElement Render()
    {
      var root = new XElement(NodeAndAttributeName.StylesNodeName);
      if(Definition != null && Definition.Any())
      {
        var definition = new XElement(NodeAndAttributeName.DefinitionNodeName);
        Definition.ToList().ForEach(x => definition.Add(x.Render()));
        root.Add(definition);
      }
      if (Application != null && Application.Any())
      {
        var application = new XElement(NodeAndAttributeName.ApplicationNodeName);
        Application.ToList().ForEach(x => application.Add(x.Render()));
        root.Add(application);
      }
      return root;
    }
  }
}
