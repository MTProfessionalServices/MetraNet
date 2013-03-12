using System;
using MetraTech.ExpressionEngine.Components.Enumerations;


namespace MetraTech.ExpressionEngine.Components
{
    public static class EnumFactory
    {
        public static EnumItem Create(EnumCategory enumCategory, string name, int id, string description)
        {
            switch (enumCategory.EnumMode)
            {
                case EnumMode.Currency:
                    return new Currency(enumCategory, name, id, description);
                case EnumMode.Item:
                    return new EnumItem(enumCategory, name, id, description);
                case EnumMode.UnitOfMeasure:
                    return new UnitOfMeasure(enumCategory, name, id, description, null);
                default:
                    throw new ArgumentException("unexpected enumMode");
            }
        }
    }
}
