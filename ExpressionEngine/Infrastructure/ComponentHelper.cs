using System;
using System.Collections.Generic;
using System.Globalization;
using MetraTech.ExpressionEngine.Components;
using MetraTech.ExpressionEngine.Components.Enumerations;

namespace MetraTech.ExpressionEngine.Infrastructure
{
    public static class ComponentHelper
    {
        public static List<KeyValuePair<string, IComponent>> GetNameWithTiebreaker(IEnumerable<IComponent> components)
        {
            if (components == null)
                throw new ArgumentException("components is null");

            var names = new Dictionary<string, int>(StringComparer.InvariantCultureIgnoreCase);
            foreach (var component in components)
            {
                var name = component.Name;
                if (string.IsNullOrEmpty(name))
                    continue;
                if (names.ContainsKey(name))
                    names[name]++;
                else
                    names.Add(name, 1);
            }

            var list = new List<KeyValuePair<string, IComponent>>();
            foreach (var component in components)
            {
                var name = component.Name;
                if (string.IsNullOrEmpty(name))
                    continue;
                string label = name;
                if (names[name] > 1)
                    label = string.Format(CultureInfo.CurrentCulture, "{0} ({1})", name, component.FullName.Substring(0, component.FullName.Length - name.Length - 1));

                list.Add(new KeyValuePair<string, IComponent>(label, component));
            }
            return list;
        }


        /// <summary>
        /// Returns a localizeable string for the provided ComponentType
        /// </summary>
        public static string GetUserName(ComponentType type)
        {
            switch (type)
            {
                case ComponentType.AccountQualificatonGroup:
                    return Localization.AccountQualificationGroup;
                case ComponentType.Currency:
                    return Localization.Currency;
                case ComponentType.CurrencyCategory:
                    return Localization.CurrencyCategory;
                case ComponentType.EmailInstance:
                    return Localization.EmailInstance;
                case ComponentType.EmailTemplate:
                    return Localization.EmailTemplate;
                case ComponentType.Enumeration:
                    return Localization.Enumeration;
                case ComponentType.EnumerationCategory:
                    return Localization.EnumerationCategory;
                case ComponentType.EventQualificationGroup:
                    return Localization.EventQualificationGroup;
                case ComponentType.Expression:
                    return Localization.Expression;
                case ComponentType.Function:
                    return Localization.Function;
                case ComponentType.PageLayout:
                    return Localization.PageLayout;
                case ComponentType.PropertyBag:
                    return Localization.PropertyBag;
                case ComponentType.PropertyBagProperty:
                    return Localization.PropertyBagProperty;
                case ComponentType.UnitOfMeasure:
                    return Localization.UnitOfMeasure;
                case ComponentType.UnitOfMeasureCategory:
                    return Localization.UnitOfMeasureCategory;
                case ComponentType.UnitTest:
                    return Localization.UnitTest;
                default:
                    throw new ArgumentException("unexpected type");
            }
        }
    }
}
