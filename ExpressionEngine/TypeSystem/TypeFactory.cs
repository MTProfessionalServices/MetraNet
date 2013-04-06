using System;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace MetraTech.ExpressionEngine.TypeSystem
{
    public static class TypeFactory
    {
        #region Create Type-Specific Methods

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
            return new ChargeType();
        }

        public static Type CreateCurrency()
        {
            return new EnumerationType(null, BaseType.Currency);
        }

        public static PropertyBagType CreatePropertyBag()
        {
            return CreatePropertyBag(null, PropertyBagMode.PropertyBag);
        }
        public static PropertyBagType CreatePropertyBag(string propertyBagTypeName, PropertyBagMode propertyBagMode)
        {
            return new PropertyBagType(propertyBagTypeName, propertyBagMode);
        }

        public static Type CreateDateTime()
        {
            return new Type(BaseType.DateTime);
        }

        public static NumberType CreateDecimal()
        {
            return new NumberType(BaseType.Decimal, UnitOfMeasureMode.None, null);
        }
        public static NumberType CreateDecimal(UnitOfMeasureMode unitOfMeasureMode, string unitOfMeasureQualifier=null)
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
          return new EnumerationType(null, BaseType.Enumeration);
        }

        public static EnumerationType CreateEnumeration(string category)
        {
            return new EnumerationType(category, BaseType.Enumeration);
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

        public static TaxType CreateTax()
        {
            return new TaxType();
        }

        public static Type CreateUniqueId()
        {
            return new Type(BaseType.UniqueIdentifier);
        }

        public static Type CreateUnknown()
        {
            return new Type(BaseType.Unknown);
        }

        public static Type CreateUnitOfMeasure()
        {
            return new EnumerationType(null, BaseType.UnitOfMeasure);
        }
        #endregion

        #region General Create Methods
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
                case BaseType.Currency:
                    return CreateCurrency();
                case BaseType.PropertyBag:
                    return CreatePropertyBag();
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
                case BaseType.Tax:
                    return CreateTax();
                case BaseType.UniqueIdentifier:
                    return CreateUniqueId();
                case BaseType.UnitOfMeasure:
                    return CreateUnitOfMeasure();
                case BaseType.Unknown:
                    return CreateUnknown();
                default:
                    throw new ArgumentException("Invalid baseType" + baseType);
            }
        }


        #endregion
    }
}
