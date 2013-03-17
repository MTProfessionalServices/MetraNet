using System;
using System.Collections.Generic;
using System.Globalization;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Components
{
    public class EnumManager
    {
        #region Properties
        public IEnumerable<EnumCategory> Categories { get { return _categories.Values; } }
        private Dictionary<string, EnumCategory> _categories = new Dictionary<string, EnumCategory>(StringComparer.InvariantCultureIgnoreCase);
        #endregion

        #region Methods
        public void AddCategory(EnumCategory enumCategory)
        {
            if (enumCategory == null)
                throw new ArgumentException("enumCategory is null");

            if (_categories.ContainsKey(enumCategory.FullName))
                throw new Exception(string.Format(CultureInfo.InvariantCulture, "Duplicate EnumCategory '{0}'", enumCategory.FullName));

            _categories.Add(enumCategory.FullName, enumCategory);
        }
        public EnumCategory GetCategory(string categoryFullName)
        {
            if (string.IsNullOrEmpty(categoryFullName))
                return null;

            EnumCategory enumCategory;
            if (!_categories.TryGetValue(categoryFullName, out enumCategory))
                return null;
            return enumCategory;
        }
        public EnumCategory GetCategory(EnumerationType enumerationType)
        {
            if (enumerationType == null)
                throw new ArgumentException("enumerationType is null");
            return GetCategory(enumerationType.Category);
        }

        public EnumCategory GetCurrencyCategory()
        {
            return GetCategory("MetraTech.Currency");
        }

        public List<EnumCategory> GetUnitOfMeasureCategories()
        {
            var uoms = new List<EnumCategory>();
            foreach (var category in Categories)
            {
                if (category.EnumMode == EnumMode.UnitOfMeasure)
                    uoms.Add(category);
            }
            return uoms;
        }


        /// <summary>
        /// Returns a dictionary of enum categories with simplified names. If a category has no name
        /// conflict just the category is returned. Other wise, the conflicting categories have their 
        /// namespace appended.
        /// </summary>
        public List<KeyValuePair<string, EnumCategory>> GetCategoryDropDownList(bool showItems, bool showUoms, bool showCurrency)
        {
            var names = new Dictionary<string, bool>();
            var nameOverlaps = new List<string>();

            //Find name overlaps
            foreach (var category in Categories)
            {
                if (!showItems && category.EnumMode == EnumMode.Item)
                    continue;
                if (!showUoms && category.EnumMode == EnumMode.UnitOfMeasure)
                    continue;
                if (!showCurrency && category.EnumMode == EnumMode.Currency)
                    continue;

                if (names.ContainsKey(category.Name))
                    nameOverlaps.Add(category.Name);
                else
                    names.Add(category.Name, false);
            }

            var categories = new List<KeyValuePair<string, EnumCategory>>();
            foreach (var category in Categories)
            {
                string label;
                if (nameOverlaps.Contains(category.Name))
                    label = string.Format(CultureInfo.InvariantCulture, "{0} ({1})", category.Name, category.Namespace);
                else
                    label = category.Name;

                categories.Add(new KeyValuePair<string, EnumCategory>(label, category));
            }
            return categories;
        }

        #endregion
    }
}
