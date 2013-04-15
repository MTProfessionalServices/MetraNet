using MetraTech.ExpressionEngine;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
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
            //Need a bogus component to generate the correct validation message
            var component = PropertyBagFactory.Create("Bogus", "MetraTech", "MyEntity", null);
            var context = new Context(ProductType.MetraNet);
            var enumerationType = TypeFactory.CreateEnumeration("");
            var messages = new ValidationMessageCollection();

            //Expect Namespace not specified
            context.GlobalComponentCollection.Load();
            enumerationType.Validate(component, messages, context, null);
            TestHelper.AssertValidation(messages, 1, 0, 0, "Namespace not specified");

            //Expect FixedCategory not specified
            messages = new ValidationMessageCollection();
            context.GlobalComponentCollection.Load();
            enumerationType.Validate(component, messages, context, null);
            TestHelper.AssertValidation(messages, 1, 0, 0, "FixedCategory not specified");

            //Expect FixedCategory not found
            enumerationType.Category = "Country";
            messages = new ValidationMessageCollection();
            context.GlobalComponentCollection.Load();
            enumerationType.Validate(component, messages, context, null);
            TestHelper.AssertValidation(messages, 1, 0, 0, "FixedCategory not found");

            //Set a real FixedCategory
            var enumCategory = new EnumCategory(BaseType.Enumeration, "Global", "Country", 0, null);
            context.AddEnumCategory(enumCategory);
            messages = new ValidationMessageCollection();
            enumerationType.Category = "Global.Country";
            context.GlobalComponentCollection.Load();
            enumerationType.Validate(component, messages, context, null);
            TestHelper.AssertValidation(messages, 0, 0, 0, "Everything should work at this point");
        }
    }
}
