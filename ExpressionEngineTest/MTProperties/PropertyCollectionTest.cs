using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class PropertyCollectionTest
    {

        /// <summary>
        ///A test for PropertyCollection Constructor
        ///</summary>
        [TestMethod()]
        public void PropertyCollectionConstructorTest()
        {
            var properties = new PropertyCollection(this);
            Assert.AreSame(this, properties.Parent);
            Assert.AreEqual(0, properties.Count);
        }

        /// <summary>
        ///A test for Get
        ///</summary>
        [TestMethod()]
        public void GetTest()
        {
            var properties = new PropertyCollection(null);
            properties.AddString("Foo", null, false);
            properties.AddInteger32("MyNumber", null, false);

            var property = properties.Get("Foo");
            Assert.IsNotNull(property, "correct case");
            Assert.AreEqual("Foo", property.Name);

            property = properties.Get("foo");
            Assert.IsNull(property, "incorrect case");

            property = properties.Get("doesnotexist");
            Assert.IsNull(property, "doesnotexist");

            property = properties.Get(null);
            Assert.IsNull(property, "null");

            property = properties.Get("");
            Assert.IsNull(property, "empty string");
        }

        [TestMethod()]
        public void GetHiearchyTest()
        {
            var properties = new PropertyCollection(null);
            properties.AddString("Foo", null, false);

            var parent = new PropertyBag(null, "PARENT", null, PropertyBagMode.PropertyBag, null);
            properties.Add(parent);
            Assert.AreEqual(parent, properties.Get("PARENT"), "Foo");
            
            parent.Properties.Add(PropertyFactory.Create("p1", TypeFactory.CreateInteger32(), true, null));
            var p2 = PropertyFactory.Create("p2", TypeFactory.CreateInteger32(), true, null);
            parent.Properties.Add(p2);
            Assert.AreEqual(p2, properties.Get("PARENT.p2"), "PARENT.p2");
        }

        [TestMethod()]
        public void GetNewSequentialPropertyNameTest()
        {
            var list = new PropertyCollection(null);
            Assert.AreEqual("Property1", list.GetNewSequentialPropertyName());

            list.AddString("Property1", null, true);

            Assert.AreEqual("Property2", list.GetNewSequentialPropertyName());
        }

        [TestMethod()]
        public void AddChargeTest()
        {
            var pc = new PropertyCollection(null);
            var charge = pc.AddCharge("EventAmount", null, true, null);
            Assert.AreEqual(BaseType.Charge, charge.Type.BaseType);
            Assert.IsTrue(charge.Type is ChargeType, "Is ChargeType");
        }

    }
}
