using System;
using MetraTech.ExpressionEngine.Components.Enumerations;


namespace MetraTech.ExpressionEngine.Components
{
    public static class EnumFactory
    {
        public static EnumValue Create(EnumCategory enumCategory, string name, int id, string description)
        {
            switch (enumCategory.EnumMode)
            {
                case EnumMode.Currency:
                    return new Currency(enumCategory, name, id, description);
                case EnumMode.EnumValue:
                    return new EnumValue(enumCategory, name, id, description);
                case EnumMode.UnitOfMeasure:
                    return new UnitOfMeasure(enumCategory, name, id, description, null);
                default:
                    throw new ArgumentException("unexpected enumMode");
            }
        }
    }
}
