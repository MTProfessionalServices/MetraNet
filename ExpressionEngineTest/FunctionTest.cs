using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
  /// <summary>
  ///This is a test class for FunctionTest and is intended
  ///to contain all FunctionTest Unit Tests
  ///</summary>
  [TestClass]
  public class FunctionTest
  {
    /// <summary>
    ///A test for Save
    ///</summary>
    [TestMethod]
    [Ignore]
    public void SaveTest()
    {
      var target1 = new Function
                     {
                       Category = "Text",
                       Name = "DisplayMonetaryAmount",
                       ReturnType = new DataTypeInfo(BaseType.String)
                     };
      target1.FixedParameters = new PropertyCollection(target1);
      target1.FixedParameters.AddString("Currency", "The currency code for the monetary amount", true);
      target1.FixedParameters.AddDecimal("Amount", "The monetary amount to be displayed", true);
      const string dirPath = @"C:\ExpressionEngine\Functions";
      target1.Save(dirPath);

      var target = new Function
      {
        Category = "Text",
        Name = "GetCurrency",
        ReturnType = new DataTypeInfo(BaseType.ComplexType)
      };
      target.ReturnType.ComplexSubtype = "Currency";
      target.ReturnType.ComplexType = ComplexType.ComplexTypeEnum.Metanga;
      target.FixedParameters = new PropertyCollection(target);
      target.FixedParameters.AddString("Currency", "The code of the currency to be retrieved", true);
      target.Save(dirPath);
    }
  }
}
