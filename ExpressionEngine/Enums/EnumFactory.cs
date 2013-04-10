using System;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;


namespace MetraTech.ExpressionEngine.Components
{
    public static class EnumFactory
    {
        public static EnumItem Create(EnumCategory enumCategory, string name, int id, string description)
        {
            switch (enumCategory.BaseType)
            {
                case BaseType.Currency:
                    return new Currency(enumCategory, name, id, description);
                case BaseType.Enumeration:
                    return new EnumItem(enumCategory, name, id, description);
                case BaseType.UnitOfMeasure:
                    return new UnitOfMeasure(enumCategory, name, id, description, null);
                default:
                    throw new ArgumentException("unexpected enumMode");
            }
        }
    }
}
