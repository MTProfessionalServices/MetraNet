using System;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

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

        public static PropertyBagType CreateComplexType()
        {
            return CreateComplexType(ComplexType.None);
        }
        public static PropertyBagType CreateComplexType(ComplexType entityType)
        {
            return CreateComplexType(entityType, null, true);
        }
        
        public static PropertyBagType CreateComplexType(ComplexType entityType, string subtype, bool isEntity)
        {
            return new PropertyBagType(entityType, subtype, isEntity);
        }

        public static Type CreateDateTime()
        {
            return new Type(BaseType.DateTime);
        }

        public static NumberType CreateDecimal()
        {
            return new NumberType(BaseType.Decimal, UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateDecimal(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Decimal, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static NumberType CreateDouble()
        {
            return CreateDouble(UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateDouble(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
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
            return CreateFloat(UnitOfMeasureMode.None, null);
        }

        public static NumberType CreateFloat(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Float, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static Type CreateGuid()
        {
            return new Type(BaseType.Guid);
        }

        public static NumberType CreateInteger()
        {
            return CreateInteger(UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateInteger(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static NumberType CreateInteger32()
        {
            return new NumberType(BaseType.Integer32, UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateInteger32(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer32, unitOfMeasureMode, unitOfMeasureQualifier);
        }
        public static NumberType CreateInteger64()
        {
            return CreateInteger64(UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateInteger64(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Integer64, unitOfMeasureMode, unitOfMeasureQualifier);
        }

        public static MoneyType CreateMoney()
        {
            return new MoneyType();
        }
        public static Type CreateNumeric()
        {
            return CreateNumeric(UnitOfMeasureMode.None, null);
        }
        public static Type CreateNumeric(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier)
        {
            return new NumberType(BaseType.Numeric, unitOfMeasureMode, unitOfMeasureQualifier);
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

        public static Type CreateUnknown()
        {
            return new Type(BaseType.Unknown);
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

        public static Type Create(string value)
        {
            var baseType = TypeHelper.GetBaseType(value);
            return Create(baseType);
        }

        public static Type Create(int internalMetraNetId)
        {
            var baseType = TypeHelper.PropertyTypeIdToBaseTypeMapping[internalMetraNetId];
            return Create(baseType);
        }

        public static Type Create(BaseType baseType)
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
                    return CreateUnknown();
                default:
                    throw new ArgumentException("Invalid baseType" + baseType);
            }
        }


        #endregion
    }
}
