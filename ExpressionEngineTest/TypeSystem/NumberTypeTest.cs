using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class NumberTypeTest
    {
        private const UnitOfMeasureMode uomMode = UnitOfMeasureMode.Fixed;
        private const string uomQualifier = "hello";

        [TestMethod()]
        public void CreateIntTest()
        {
            var type = TypeFactory.CreateInteger(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer, type);
            Assert.IsTrue(type.IsInteger);
        }


        [TestMethod()]
        public void CreateInteger32()
        {
            var type = TypeFactory.CreateInteger32(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer32, type);
            Assert.IsTrue(type.IsInteger32);
        }

        [TestMethod()]
        public void CreateInteger64()
        {
            var type = TypeFactory.CreateInteger64(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer64, type);
            Assert.IsTrue(type.IsInteger64);
        }

        [TestMethod()]
        public void CreateDecimal()
        {
            var type = TypeFactory.CreateDecimal(uomMode, uomQualifier);
            AssertBasics(BaseType.Decimal, type);
            Assert.IsTrue(type.IsDecimal);
        }

        [TestMethod()]
        public void CreateDouble()
        {
            var type = TypeFactory.CreateDouble(uomMode, uomQualifier);
            AssertBasics(BaseType.Double, type);
            Assert.IsTrue(type.IsDouble);
        }

        [TestMethod()]
        public void CreateFloat()
        {
            var type = TypeFactory.CreateFloat(uomMode, uomQualifier);
            AssertBasics(BaseType.Float, type);
            Assert.IsTrue(type.IsFloat);
        }

        [TestMethod()]
        public void CreateNumeric()
        {
            var type = TypeFactory.CreateNumeric(uomMode, uomQualifier);
            AssertBasics(BaseType.Numeric, type);
            Assert.IsTrue(type.IsNumeric);
        }

        public void AssertBasics(BaseType baseType, MetraTech.ExpressionEngine.TypeSystem.Type type)
        {
            Assert.AreEqual(baseType, type.BaseType);
            Assert.IsTrue(type.IsNumeric);
        }



    }
}
