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

        public static EnumerationType CreateEnumumeration()
        {
            return CreateEnumumeration(null, null);
        }

        public static EnumerationType CreateEnumumeration(string enumSpace, string enumType)
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
        public static MtType Create<T>() where T : MtType, new()
        {
            return new T();
        }

        
        public static MtType Create(string type)
        {
            var baseType = TypeHelper.GetBaseType(type);
            var actualType = RetrieveType(baseType);
            var createMethod = typeof(TypeFactory).GetMethod("Create");
            var createOfTypeMethod = createMethod.MakeGenericMethod(new[] { actualType });
            var result = createOfTypeMethod.Invoke(null, new object[] { });
            return (MtType)result;
        }

        private static Type RetrieveType(BaseType baseType)
        {
            throw new NotImplementedException();
        }
        #endregion
    }
}
