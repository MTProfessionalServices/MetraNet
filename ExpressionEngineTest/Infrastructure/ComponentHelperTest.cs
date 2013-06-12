using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine.Components;
using System.Collections.Generic;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class ComponentHelperTest
    {
        /// <summary>
        ///A test for GetNameWithTieBreaker
        ///</summary>
        [TestMethod()]
        public void GetNameWithTieBreakerTest()
        {
            var components = new List<IComponent>();
            components.Add(new PropertyBag(null, null, null, PropertyBagMode.Entity, null));
            components.Add(new PropertyBag("MetraTech.Cloud", "A", null, PropertyBagMode.Entity, null));
            components.Add(new PropertyBag("MetraTech.Cloud", "B", null, PropertyBagMode.Entity, null));
            components.Add(new PropertyBag("MetraTech.Cloud", "C", null, PropertyBagMode.Entity, null));
            components.Add(new PropertyBag("Hello", "A", null, PropertyBagMode.Entity, null));

            var results = ComponentHelper.GetNameWithTiebreaker(components);
            AssertTieKvp(results, 0, "A (MetraTech.Cloud)");
            AssertTieKvp(results, 1, "B");
            AssertTieKvp(results, 2, "C");
            AssertTieKvp(results, 3, "A (Hello)");
        }

        private void AssertTieKvp(List<KeyValuePair<string, IComponent>> list, int index, string expectedKey)
        {
            var msg = "Index " + index.ToString();
            Assert.AreEqual(expectedKey, list[index].Key, msg);
        }

        [TestMethod()]
        public void GetUserNameTest()
        {
            foreach (var type in Enum.GetValues(typeof (ComponentType)))
            {
                var userName = ComponentHelper.GetUserName((ComponentType)type);
                Assert.IsTrue(!string.IsNullOrWhiteSpace(userName), "ComponentType = " + type.ToString());
            }
        }
    }
}
