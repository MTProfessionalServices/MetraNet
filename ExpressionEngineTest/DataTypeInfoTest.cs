using MetraTech.ExpressionEngine;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using System;

namespace ExpressionEngineTest
{


    /// <summary>
    ///This is a test class for DataTypeInfoTest and is intended
    ///to contain all DataTypeInfoTest Unit Tests
    ///</summary>
    [TestClass()]
    public class DataTypeInfoTest
    {
        /// <summary>
        ///A test for ListSuffix
        ///</summary>
        [TestMethod()]
        public void ListSuffixTest()
        {
            var dtInfo = DataTypeInfo.CreateBoolean();

            dtInfo.ListType = DataTypeInfo.ListTypeEnum.None;
            Assert.AreEqual("", dtInfo.ListSuffix);

            dtInfo.ListType = DataTypeInfo.ListTypeEnum.List;
            Assert.AreEqual("[]", dtInfo.ListSuffix);

            dtInfo.ListType = DataTypeInfo.ListTypeEnum.KeyList;
            Assert.AreEqual("<>", dtInfo.ListSuffix);
        }

        /// <summary>
        ///A test for ToAnything: to check the return values we'd have to replicate the exact same code.
        ///Essentially we're looking to not get an exception. This is helpful when a new BaseType is added
        ///because we'll get an exception.
        ///</summary>
        [TestMethod()]
        public void ToUserStringTest()
        {
            foreach (var type in Enum.GetValues(typeof(BaseType)))
            {
                var dtInfo = new DataTypeInfo((BaseType)type);

                var nonRobust = dtInfo.ToUserString(false);
                var robust = dtInfo.ToUserString(true);
                var defaultString = dtInfo.ToString();

                //We should drive the other types here
            }
        }


        [TestMethod()]
        public void GetDataTypeEnumTest()
        {
            GetDataTypeEnum(BaseType.String, "string");
            GetDataTypeEnum(BaseType.Integer32, "id");
            GetDataTypeEnum(BaseType.Integer32, "int32");
            GetDataTypeEnum(BaseType.Integer32, "integer32");
            GetDataTypeEnum(BaseType.Integer32, "integer");
            GetDataTypeEnum(BaseType.Integer64, "bigint");
            GetDataTypeEnum(BaseType.Integer64, "long");
            GetDataTypeEnum(BaseType.Integer64, "bigint");
            GetDataTypeEnum(BaseType.Integer64, "int64");
            GetDataTypeEnum(BaseType.Integer64, "integer64");
            GetDataTypeEnum(BaseType.DateTime, "timestamp");
            GetDataTypeEnum(BaseType.DateTime, "datetime");
            GetDataTypeEnum(BaseType._Enum, "enum");
            GetDataTypeEnum(BaseType.Decimal, "decimal");
            GetDataTypeEnum(BaseType.Double, "double");
            GetDataTypeEnum(BaseType.Boolean, "boolean");
            GetDataTypeEnum(BaseType.Boolean, "bool");
            GetDataTypeEnum(BaseType.Any, "any");
            GetDataTypeEnum(BaseType.String, "varchar");
            GetDataTypeEnum(BaseType.String, "nvarchar");
            GetDataTypeEnum(BaseType.String, "decimal");
            GetDataTypeEnum(BaseType.Decimal, "characters");
            GetDataTypeEnum(BaseType.Binary, "binary");
            GetDataTypeEnum(BaseType.Unknown, "unknown");
            GetDataTypeEnum(BaseType.Numeric, "numeric");
            GetDataTypeEnum(BaseType.UniqueIdentifier, "uniqueidentifier");
            GetDataTypeEnum(BaseType.Guid, "guid");
            GetDataTypeEnum(BaseType.ComplexType, "entity");
        }
        private void GetDataTypeEnum(BaseType expectedType, string dataTypeStr)
        {
            Assert.AreEqual(expectedType, dataTypeStr);
            Assert.AreEqual(expectedType, dataTypeStr.ToLower());
            Assert.AreEqual(expectedType, dataTypeStr.ToUpper());
        }
    }
}
