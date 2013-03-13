namespace MetraTech.ICE.ExpressionEngine
{
  using System;
  using System.Collections.Generic;
  using System.Linq;
  using System.Text;

  /// <summary>
  /// TODO: Update summary.
  /// </summary>
  public class Entity
  {
    #region Properties
    public ElementBase Element;
    public PropertyCollection Properties = new PropertyCollection();
    #endregion

    #region Constructor
    public Entity(ElementBase element)
    {
      Element = element;
      PropertyCollection copyProperties = null;
      switch (Element.ElementType)
      {
        case ElementType.AccountView:
          AppendPropertyReferences( ((AccountView)element).Properties);
          break;
        case ElementType.ParameterTable:
          AppendPropertyReferences(((ParameterTable)element).Conditions);
          AppendPropertyReferences(((ParameterTable)element).Actions);
          break;
        case ElementType.ProductView:
          AppendPropertyReferences( ((ProductView)element).Properties);
          break;
        case ElementType.ServiceDefinition:
          AppendPropertyReferences( ((ServiceDefinition)element).Properties);
          break;
      }
    }

    private void AppendPropertyReferences(PropertyCollection sourceProperties)
    {
      foreach (var property in sourceProperties)
      {
        Properties.Add(property);
      }
    }
    #endregion

    public override string ToString()
    {
      return string.Format("{0}: {1}", Element.ElementType, Element.Name);
    }
  }
}