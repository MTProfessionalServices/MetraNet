using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    public static class TypeFactory
    {
        #region Create Methods

        public static MtType CreateAny()
        {
            return new MtType(BaseType.Any);
        }

        public static MtType CreateBinary()
        {
            return new MtType(BaseType.Binary);
        }

        public static MtType CreateBoolean()
        {
            return new MtType(BaseType.Boolean);
        }

        public static MtType CreateCharge()
        {
            return new MtType(BaseType.Charge);
        }

        public static VectorType CreateComplexType()
        {
            return CreateComplexType(VectorType.ComplexTypeEnum.None);
        }
        public static VectorType CreateComplexType(VectorType.ComplexTypeEnum entityType)
        {
            return CreateComplexType(entityType, null, true);
        }
        
        public static VectorType CreateComplexType(VectorType.ComplexTypeEnum entityType, string subtype, bool isEntity)
        {
            return new VectorType(entityType, subtype, isEntity);
        }

        public static MtType CreateDateTime()
        {
            return new MtType(BaseType.DateTime);
        }

        public static NumberType CreateDecimal()
        {
            return new NumberType(BaseType.Decimal, MtType.UnitOfMeasureModeType.None, null);
        }
        public static NumberType CreateDecimal(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Decimal, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static NumberType CreateDouble()
        {
            return CreateDouble(MtType.UnitOfMeasureModeType.None, null);
        }
        public static NumberType CreateDouble(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Double, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static EnumerationType CreateEnumeration()
        {
            return CreateEnumeration(null, null);
        }

        public static EnumerationType CreateEnumeration(string enumSpace, string enumType)
        {
            return new EnumerationType(enumSpace, enumType);
        }

        public static NumberType CreateFloat()
        {
            return CreateFloat(MtType.UnitOfMeasureModeType.None, null);
        }

        public static NumberType CreateFloat(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Float, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static MtType CreateGuid()
        {
            return new MtType(BaseType.Guid);
        }

        public static NumberType CreateInteger()
        {
            return CreateInteger(MtType.UnitOfMeasureModeType.None, null);
        }
        public static NumberType CreateInteger(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static NumberType CreateInteger32()
        {
            return new NumberType(BaseType.Integer32, MtType.UnitOfMeasureModeType.None, null);
        }
        public static NumberType CreateInteger32(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer32, unitOfMeasureMode, unitOfMeasureQualifier);
        }
        public static NumberType CreateInteger64()
        {
            return CreateInteger64(MtType.UnitOfMeasureModeType.None, null);
        }
        public static NumberType CreateInteger64(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer64, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static MoneyType CreateMoney()
        {
            return new MoneyType();
        }
        public static MtType CreateNumeric()
        {
            return CreateNumeric(MtType.UnitOfMeasureModeType.None, null);
        }
        public static MtType CreateNumeric(MtType.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static StringType CreateString()
        {
            return new StringType(0);
        }

        public static StringType CreateString(int length)
        {
            return new StringType(length);
        }

        public static MtType CreateUniqueId()
        {
            return new MtType(BaseType.UniqueIdentifier);
        }

        public static MtType CreateUnkownn()
        {
            return new MtType(BaseType.Unknown);
        }

        #endregion

        #region General Create
        //public static MtType Create<T>() where T : MtType, new()
        //{
        //    return new T();
        //}

        //private static Type RetrieveType(BaseType baseType)
        //{
        //    throw new NotImplementedException();
        //}

        //public static MtType Create(string type)
        //{
        //    var baseType = TypeHelper.GetBaseType(type);
        //    var actualType = RetrieveType(baseType);
        //    var createMethod = typeof(TypeFactory).GetMethod("Create");
        //    var createOfTypeMethod = createMethod.MakeGenericMethod(new[] { actualType });
        //    var result = createOfTypeMethod.Invoke(null, new object[] { });
        //    return (MtType)result;
        //}

        public static MtType Create(string typeString)
        {
            var baseType = TypeHelper.GetBaseType(typeString);
            return Create(baseType);
        }

        public static MtType Create(int internalMetraNetId)
        {
            var baseType = TypeHelper.PropertyTypeId_BaseTypeMapping[internalMetraNetId];
            return Create(baseType);
        }

        public static MtType Create(BaseType baseType)
        {
            switch (baseType)
            {
                case BaseType.Any:
                    return CreateAny();
                case BaseType.Binary:
                    return CreateBinary();
                case BaseType.Boolean:
                    return CreateBoolean();
                case BaseType.Charge:
                    return CreateCharge();
                case BaseType.Entity:
                    return CreateComplexType();
                case BaseType.DateTime:
                    return CreateDateTime();
                case BaseType.Decimal:
                    return CreateDecimal();
                case BaseType.Double:
                    return CreateDouble();
                case BaseType.Enumeration:
                    return CreateEnumeration();
                case BaseType.Float:
                    return CreateFloat();
                case BaseType.Guid:
                    return CreateGuid();
                case BaseType.Integer:
                    return CreateInteger();
                case BaseType.Integer32:
                    return CreateInteger32();
                case BaseType.Integer64:
                    return CreateInteger64();
                case BaseType.Money:
                    return CreateMoney();
                case BaseType.Numeric:
                    return CreateNumeric();
                case BaseType.String:
                    return CreateString();
                case BaseType.UniqueIdentifier:
                    return CreateUniqueId();
                case BaseType.Unknown:
                    return CreateUnkownn();
                default:
                    throw new ArgumentException("baseType");
            }
        }


        #endregion
    }
}
