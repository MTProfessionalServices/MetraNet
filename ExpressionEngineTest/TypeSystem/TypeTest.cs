using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;
using MetraTech.ExpressionEngine;
using System.Globalization;

namespace ExpressionEngineTest
{
    [TestClass()]
    public class TypeTest
    {
        /// <summary>
        /// Creation tests for types without sub classes
        ///</summary>
        [TestMethod()]
        public void CreateAnyTest()
        {
            var any = TypeFactory.CreateAny();
            Assert.AreEqual(BaseType.Any, any.BaseType);
            Assert.IsTrue(any.IsAny);
            Assert.IsFalse(any.IsNumeric);
            Assert.AreEqual("Any", any.ToString(false));
            Assert.AreEqual("Any", any.ToString(true));
        }

        [TestMethod()]
        public void CreateBinaryTest()
        {
            var binary = TypeFactory.CreateBinary();
            Assert.AreEqual(BaseType.Binary, binary.BaseType);
            Assert.IsTrue(binary.IsBinary);
            Assert.IsFalse(binary.IsNumeric);
            Assert.AreEqual("Binary", binary.ToString(false));
            Assert.AreEqual("Binary", binary.ToString(true));
        }

        [TestMethod()]
        public void CreateBooleanTest()
        {
            var boolean = TypeFactory.CreateBoolean();
            Assert.AreEqual(BaseType.Boolean, boolean.BaseType);
            Assert.IsTrue(boolean.IsBoolean);
            Assert.IsFalse(boolean.IsNumeric);
            Assert.AreEqual("Boolean", boolean.ToString(false));
            Assert.AreEqual("Boolean", boolean.ToString(true));
        }

        [TestMethod()]
        public void CreateDateTimeTest()
        {
            var dt = TypeFactory.CreateDateTime();
            Assert.AreEqual(BaseType.DateTime, dt.BaseType);
            Assert.IsTrue(dt.IsDateTime);
            Assert.IsFalse(dt.IsNumeric);
            Assert.AreEqual("DateTime", dt.ToString(false));
            Assert.AreEqual("DateTime", dt.ToString(true));
        }

        [TestMethod()]
        public void CreateDateGuidTest()
        {
            var guid = TypeFactory.CreateGuid();
            Assert.AreEqual(BaseType.Guid, guid.BaseType);
            Assert.IsTrue(guid.IsGuid);
            Assert.IsFalse(guid.IsNumeric);
            Assert.AreEqual("Guid", guid.ToString(false));
            Assert.AreEqual("Guid", guid.ToString(true));
        }

        [TestMethod()]
        public void CreateUniqueIdTest()
        {
            var uniqueId = TypeFactory.CreateUniqueId();
            Assert.AreEqual(BaseType.UniqueIdentifier, uniqueId.BaseType);
            Assert.IsTrue(uniqueId.IsUniqueIdentifier);
            Assert.AreEqual("UniqueIdentifier", uniqueId.ToString(false));
            Assert.AreEqual("UniqueIdentifier", uniqueId.ToString(true));
        }

        [TestMethod()]
        public void CreateUnknownTest()
        {
            var unknown = TypeFactory.CreateUnknown();
            Assert.AreEqual(BaseType.Unknown, unknown.BaseType);
            Assert.IsTrue(unknown.IsUnknown);
            Assert.IsFalse(unknown.IsNumeric);
            Assert.AreEqual("Unknown", unknown.ToString(false));
            Assert.AreEqual("Unknown", unknown.ToString(true));
        }

        [TestMethod()]
        public void GetDataTypeEnumTest()
        {
            AssertCreateFromBaseType(BaseType.Any, "any");
            AssertCreateFromBaseType(BaseType.Boolean, "boolean");
            AssertCreateFromBaseType(BaseType.Boolean, "bool");
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
            AssertCreateFromBaseType(BaseType.String, "varchar");
            AssertCreateFromBaseType(BaseType.String, "nvarchar");
            AssertCreateFromBaseType(BaseType.Decimal, "decimal");
            AssertCreateFromBaseType(BaseType.String, "characters");
            AssertCreateFromBaseType(BaseType.Binary, "binary");
            AssertCreateFromBaseType(BaseType.Unknown, "unknown");
            AssertCreateFromBaseType(BaseType.Unknown, "   ");
            AssertCreateFromBaseType(BaseType.Unknown, "   \t");
            AssertCreateFromBaseType(BaseType.Unknown, null);
            AssertCreateFromBaseType(BaseType.Numeric, "numeric");
            AssertCreateFromBaseType(BaseType.UniqueIdentifier, "uniqueidentifier");
            AssertCreateFromBaseType(BaseType.Guid, "guid");
            AssertCreateFromBaseType(BaseType.PropertyBag, "entity");
        }

        private void AssertCreateFromBaseType(BaseType expectedType, string dataTypeStr)
        {
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr), FormatMsg(dataTypeStr));

            if (dataTypeStr == null)
                return;

            dataTypeStr = dataTypeStr.ToLower();
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr), FormatMsg(dataTypeStr));

            dataTypeStr = dataTypeStr.ToUpper();
            Assert.AreEqual(expectedType, TypeHelper.GetBaseType(dataTypeStr), FormatMsg(dataTypeStr));
        }

        private string FormatMsg(string dataTypeStr)
        {
            return string.Format("Converting '{0}'", dataTypeStr);
        }

        [TestMethod()]
        public void ListTypeTest()
        {
            var type = TypeFactory.CreateInteger();

            type.ListType = ListType.None;
            Assert.AreEqual(null, type.ListSuffix);

            type.ListType = ListType.List;
            Assert.AreEqual("[]", type.ListSuffix);

            type.ListType = ListType.KeyList;
            Assert.AreEqual("<>", type.ListSuffix);
        }

    }
}
