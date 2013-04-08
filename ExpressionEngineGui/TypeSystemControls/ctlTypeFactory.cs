using System;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

namespace PropertyGui.TypeSystemControls
{
    public static class ctlTypeFactory
    {
        public static ctlBaseType Create(BaseType baseType)
        {
            switch (baseType)
            {
                case BaseType.Charge:
                    return new ctlChargeType();
                case BaseType.Enumeration:
                    return new ctlEnumerationType();
                case BaseType.Money:
                    return new ctlMoneyType();
                case BaseType.String:
                    return new ctlStringType();
                case BaseType.Tax:
                    return new ctlTaxType();
            }

            if (TypeHelper.IsNumeric(baseType))
                return new ctlNumberType();
            
            //Some types don't support an editor (i.e., Boolean, GUID, etc.)
            return null;
        }
    }
}
