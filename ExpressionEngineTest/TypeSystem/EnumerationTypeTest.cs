using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class EnumerationTypeTest
    {
        [TestMethod()]
        public void CreateEnumerationTest()
        {
            var eType = TypeFactory.CreateEnumeration("Global.Country");
            Assert.AreEqual(BaseType.Enumeration, eType.BaseType);
            Assert.IsFalse(eType.IsNumeric, "IsNumeric");
            Assert.AreEqual("Enumeration", eType.ToString(false));
            Assert.AreEqual("Enumeration.Global.Country", eType.ToString(true));
        }

        [TestMethod()]
        public void ValidationTest()
        {
            var context = new Context(ProductType.MetraNet);
            var enumerationType = TypeFactory.CreateEnumeration("");
            var messages = new ValidationMessageCollection();

            //Expect Namespace not specifed
            enumerationType.Validate(null, messages, context);
            TestHelper.AssertValidation(messages, 1, 0, 0, "Namespace not specified");

            //Expect FixedCategory not spcefied
            messages = new ValidationMessageCollection();
            enumerationType.Validate(null, messages, context);
            TestHelper.AssertValidation(messages, 1, 0, 0, "FixedCategory not specified");

            //Expect FixedCategory not found
            enumerationType.Category = "Country";
            messages = new ValidationMessageCollection();
            enumerationType.Validate(null, messages, context);
            TestHelper.AssertValidation(messages, 1, 0, 0, "FixedCategory not found");

            //Set a real FixedCategory
            var enumCategory = new EnumCategory(EnumMode.Item, "Global", "Country", 0, null);
            context.AddEnumCategory(enumCategory);
            messages = new ValidationMessageCollection();
            enumerationType.Category = "Global.Country";
            enumerationType.Validate(null, messages, context);
            TestHelper.AssertValidation(messages, 0, 0, 0, "Everything should work at this point");
        }
    }
}
