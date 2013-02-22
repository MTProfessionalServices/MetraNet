using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using MetraTech.ExpressionEngine;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class NumberTypeTest
    {
        /// <summary>
        /// Very simple constructor tests.
        /// </summary>
        [TestMethod()]
        public void CreateNumbersTest()
        {
            var uomMode = UnitOfMeasureModeType.Fixed;
            var uomQualifier = "hello";

            var intType = TypeFactory.CreateInteger(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer, intType);

            Assert.AreEqual(uomMode, ((NumberType)intType).UnitOfMeasureMode);
            //Assert.AreEqual(uomMode, 

            Assert.IsTrue(intType.IsInteger);

            var int32 = TypeFactory.CreateInteger32(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer32, int32);
            Assert.IsTrue(int32.IsInteger32);

            var int64 = TypeFactory.CreateInteger64(uomMode, uomQualifier);
            AssertBasics(BaseType.Integer64, int64);
            Assert.IsTrue(int64.IsInteger64);

            var dec = TypeFactory.CreateDecimal(uomMode, uomQualifier);
            AssertBasics(BaseType.Decimal, dec);
            Assert.IsTrue(dec.IsDecimal);

            var dble = TypeFactory.CreateDouble(uomMode, uomQualifier);
            AssertBasics(BaseType.Double, dble);
            Assert.IsTrue(dble.IsDouble);

            var flt = TypeFactory.CreateFloat(uomMode, uomQualifier);
            AssertBasics(BaseType.Float, flt);
            Assert.IsTrue(flt.IsFloat);

            var numeric = TypeFactory.CreateNumeric(uomMode, uomQualifier);
            AssertBasics(BaseType.Numeric, numeric);
            Assert.IsTrue(numeric.IsNumeric);
        }

        public void AssertBasics(BaseType baseType, MetraTech.ExpressionEngine.TypeSystem.MtType type)
        {
            Assert.AreEqual(baseType, type.BaseType);
            Assert.IsTrue(type.IsNumeric);
        }



    }
}
