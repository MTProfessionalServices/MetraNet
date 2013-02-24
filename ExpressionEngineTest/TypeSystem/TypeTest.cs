using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class TypeTest
    {
        /// <summary>
        /// Creation tests for types without sub classes
        ///</summary>
        [TestMethod()]
        public void BasicTypeCreateTest()
        {
            var any = TypeFactory.CreateAny();
            Assert.AreEqual(BaseType.Any, any.BaseType);
            Assert.IsTrue(any.IsAny);

            var binary = TypeFactory.CreateBinary();
            Assert.AreEqual(BaseType.Binary, binary.BaseType);
            Assert.IsTrue(binary.IsBinary);

            var boolean = TypeFactory.CreateBoolean();
            Assert.AreEqual(BaseType.Boolean, boolean.BaseType);
            Assert.IsTrue(boolean.IsBoolean);

            var dt = TypeFactory.CreateDateTime();
            Assert.AreEqual(BaseType.Binary, dt.BaseType);
            Assert.IsTrue(dt.IsDateTime);

            var guid = TypeFactory.CreateGuid();
            Assert.AreEqual(BaseType.Guid, guid.BaseType);
            Assert.IsTrue(guid.IsGuid);
            
            var uniqueId = TypeFactory.CreateUniqueId();
            Assert.AreEqual(BaseType.UniqueIdentifier, uniqueId.BaseType);
            Assert.IsTrue(uniqueId.IsUniqueIdentifier);

            var unknown = TypeFactory.CreateUnknown();
            Assert.AreEqual(BaseType.Unknown, unknown.BaseType);
            Assert.IsTrue(unknown.IsUnknown);
        }

        [TestMethod()]
        public void GetDataTypeEnumTest()
        {
            AssertCreateFromBaseType(BaseType.String, "string");
            AssertCreateFromBaseType(BaseType.Integer32, "id");
            AssertCreateFromBaseType(BaseType.Integer32, "int32");
            AssertCreateFromBaseType(BaseType.Integer32, "integer32");
            AssertCreateFromBaseType(BaseType.Integer32, "integer");
            AssertCreateFromBaseType(BaseType.Integer64, "bigint");
            AssertCreateFromBaseType(BaseType.Integer64, "long");
            AssertCreateFromBaseType(BaseType.Integer64, "bigint");
            AssertCreateFromBaseType(BaseType.Integer64, "int64");
            AssertCreateFromBaseType(BaseType.Integer64, "integer64");
            AssertCreateFromBaseType(BaseType.DateTime, "timestamp");
            AssertCreateFromBaseType(BaseType.DateTime, "datetime");
            AssertCreateFromBaseType(BaseType.Enumeration, "enum");
            AssertCreateFromBaseType(BaseType.Decimal, "decimal");
            AssertCreateFromBaseType(BaseType.Double, "double");
            AssertCreateFromBaseType(BaseType.Boolean, "boolean");
            AssertCreateFromBaseType(BaseType.Boolean, "bool");
            AssertCreateFromBaseType(BaseType.Any, "any");
            AssertCreateFromBaseType(BaseType.String, "varchar");
            AssertCreateFromBaseType(BaseType.String, "nvarchar");
            AssertCreateFromBaseType(BaseType.String, "decimal");
            AssertCreateFromBaseType(BaseType.Decimal, "characters");
            AssertCreateFromBaseType(BaseType.Binary, "binary");
            AssertCreateFromBaseType(BaseType.Unknown, "unknown");
            AssertCreateFromBaseType(BaseType.Unknown, "   ");
            AssertCreateFromBaseType(BaseType.Unknown, "   \t");
            AssertCreateFromBaseType(BaseType.Unknown, null);
            AssertCreateFromBaseType(BaseType.Numeric, "numeric");
            AssertCreateFromBaseType(BaseType.UniqueIdentifier, "uniqueidentifier");
            AssertCreateFromBaseType(BaseType.Guid, "guid");
            AssertCreateFromBaseType(BaseType.Entity, "entity");
        }

        private void AssertCreateFromBaseType(BaseType expectedType, string dataTypeStr)
        {
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr));
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr.ToLower()));
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr.ToUpper()));
        }
    }
}
