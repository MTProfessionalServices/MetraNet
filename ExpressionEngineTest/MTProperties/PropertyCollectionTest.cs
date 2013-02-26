using System.Collections.ObjectModel;
using MetraTech.ExpressionEngine.MTProperties;
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

    }
}
