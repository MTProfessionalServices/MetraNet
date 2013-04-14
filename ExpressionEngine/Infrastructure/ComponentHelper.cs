using System;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    public static class ComponentHelper
    {
        public static string GetUserName(ComponentType type)
        {
            switch (type)
            {
                case ComponentType.Currency:
                    return Localization.Currency;
                case ComponentType.CurrencyCategory:
                    return Localization.CurrencyCategory;
                case ComponentType.Enumeration:
                    return Localization.Enumeration;
                case ComponentType.EnumerationCategory:
                    return Localization.EnumerationCategory;
                case ComponentType.PropertyBag:
                    return Localization.PropertyBag;
                case ComponentType.PropertyBagProperty:
                    return Localization.PropertyBagProperty;
                case ComponentType.UnitOfMeasure:
                    return Localization.UnitOfMeasure;
                case ComponentType.UnitOfMeasureCategory:
                    return Localization.UnitOfMeasureCategory;
                default:
                    throw new ArgumentException("unexpected type");
            }
        }
    }
}
