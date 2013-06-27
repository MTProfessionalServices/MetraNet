using System;
using System.Collections.Generic;
using System.Globalization;
using System.Text.RegularExpressions;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.Infrastructure;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Constants;
using MetraTech.ExpressionEngine.Validations;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    public class PropertyBagManager
    {
        #region Properties
        public IEnumerable<PropertyBag> PropertyBags { get { return _propertyBags.Values; } } 
        private readonly Dictionary<string, PropertyBag> _propertyBags = new Dictionary<string, PropertyBag>(StringComparer.InvariantCultureIgnoreCase);
        #endregion

        #region Methods
        public void Add(PropertyBag propertyBag)
        {
            if (propertyBag == null)
                throw new ArgumentNullException("propertyBag");

            if (_propertyBags.ContainsKey(propertyBag.FullName))
                throw new Exception(string.Format(CultureInfo.CurrentCulture, "Duplicate PropertyBag '{0}'", propertyBag.FullName));

            _propertyBags.Add(propertyBag.FullName, propertyBag);
        }

        public PropertyBag Get(string fullName)
        {
            if (string.IsNullOrEmpty(fullName))
                return null;

            PropertyBag propertyBag;
            _propertyBags.TryGetValue(fullName, out propertyBag);
            return propertyBag;
        }

        public List<PropertyBag> GetPropertyBags(string type)
        {
            var types = new List<string>();
            types.Add(type);
            return GetPropertyBags(null, types, null, null);
        }

        public List<PropertyBag> GetPropertyBags(string propertyBagNameFilter, List<string> propertyBagTypeFilter, string propertyNameFilter, Type propertyTypeFilter)
        {
            var results = new List<PropertyBag>();

            Regex entityRegex = string.IsNullOrEmpty(propertyBagNameFilter) ? null : new Regex(propertyBagNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in PropertyBags)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (propertyBagTypeFilter != null && !propertyBagTypeFilter.Contains(PropertyBagConstants.AnyFilter) && !propertyBagTypeFilter.Contains(((PropertyBagType)entity.Type).Name))
                    continue;

                if (!entity.HasPropertyMatch(propertyRegex, propertyTypeFilter))
                    continue;

                results.Add(entity);
            }
            return results;
        }

        public List<string> GetPropertyBagTypes()
        {
            var types = new List<string>();
            foreach (var propertyBag in PropertyBags)
            {
                var pbType = (PropertyBagType)propertyBag.Type;
                if (!types.Contains(pbType.Name))
                    types.Add(pbType.Name);
            }
            return types;
        }

        public void Validate(ValidationMessageCollection messages, Context context)
        {
            foreach (var propertyBag in PropertyBags)
            {
                propertyBag.Validate(messages, context);
            }
        }

        public void Save(string dirPath, ProductType product)
        {
            dirPath.EnsureDirectoryExits();

            foreach (var propertyBag in PropertyBags)
            {
                if (product == ProductType.MetraNet)
                    propertyBag.SaveInExtensionsDirectory(dirPath);
                else
                    propertyBag.Save(string.Format(CultureInfo.InvariantCulture, @"{0}\PropertyBags\{1}.xml", dirPath, propertyBag.Name));
            }
        }

        #endregion
    }
}
