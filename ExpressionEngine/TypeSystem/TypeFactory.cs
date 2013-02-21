using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    public static class TypeFactory
    {
        #region Create Methods

        public static Type CreateAny()
        {
            return new Type(BaseType.Any);
        }

        public static Type CreateBinary()
        {
            return new Type(BaseType.Binary);
        }

        public static Type CreateBoolean()
        {
            return new Type(BaseType.Boolean);
        }

        public static Type CreateCharge()
        {
            return new Type(BaseType.Charge);
        }

        public static Type CreateDateTime()
        {
            return new Type(BaseType.DateTime);
        }

        public static Type CreateDecimal(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Decimal, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateDouble(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Double, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static EnumerationType CreateEnumumeration(string enumSpace, string enumType)
        {
            return new EnumerationType(enumSpace, enumType);
        }

        public static ComplexTypeType CreateComplexType(ComplexTypeType.ComplexTypeEnum entityType, string subtype, bool isEntity)
        {
            return new ComplexTypeType(entityType, subtype, isEntity);
        }

        public static Type CreateFloat(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Float, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateGuid()
        {
            return new Type(BaseType.Guid);
        }

        public static Type CreateInteger(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateIntege32(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer32, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateInteger64(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer64, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateMoney()
        {
            return new Type(BaseType.Money);
        }

        public static Type CreateNumeric(Type.UnitOfMeasureModeType unitOfMeasureMode, string unitOfMeasureQualifier)
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

        public static Type CreateUniqueId()
        {
            return new Type(BaseType.UniqueIdentifier);
        }

        public static Type CreateUnkownn()
        {
            return new Type(BaseType.Unknown);
        }

        #endregion
    }
}
