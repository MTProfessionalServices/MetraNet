using System.Linq;
using MetraTech.ExpressionEngine.PropertyBags;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
  public static class PropertyBagTestHelper
  {
    public static void VerifyIfCorePropertiesInEntityDuplicated(PropertyBag entity)
    {
      foreach (var coreProperty in entity.GetCoreProperties())
        if (entity.GetCoreProperties().Count(x => x.FullName == coreProperty.FullName) > 1)
          Assert.Fail("Property with name {0} added to {1} entity more then once", coreProperty.FullName, entity.GetType().Name);      
    }
  }
}
