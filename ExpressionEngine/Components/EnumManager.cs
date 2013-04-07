using System;
using System.Collections.Generic;
using System.Globalization;
using System.IO;
using MetraTech.ExpressionEngine.Expressions.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.Validations;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.TypeSystem.Constants;

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

            //There can be only one currency
            if (enumCategory.BaseType == BaseType.Currency && enumCategory.FullName != PropertyBagConstants.MetraTechCurrencies)
                throw new Exception(string.Format(CultureInfo.InvariantCulture, "The only valid currency category is '{0}'", PropertyBagConstants.MetraTechCurrencies));


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
                if (category.BaseType == BaseType.UnitOfMeasure)
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
                if (!showItems && category.BaseType == BaseType.Enumeration)
                    continue;
                if (!showUoms && category.BaseType == BaseType.UnitOfMeasure)
                    continue;
                if (!showCurrency && category.BaseType == BaseType.Currency)
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

        public void Validate(ValidationMessageCollection messages)
        {
            foreach (var category in Categories)
            {
                category.Validate(true, messages);
            }
        }

        public void Save(string dirPath, ProductType productType)
        {
            dirPath.EnsureDirectoryExits();

            foreach (var enumCategory in Categories)
            {
                if (productType == ProductType.MetraNet)
                    enumCategory.SaveInExtension(dirPath);
                else
                    enumCategory.Save(Path.Combine(dirPath, "Enumerations"));
            }
        }

        /// <summary>
        /// Determines if the specified enum value is valid. If the type isn't found, false is returned
        /// </summary>
        /// <param name="type"></param>
        /// <param name="value"></param>
        /// <returns></returns>
        public bool ValueIsValid(EnumerationType type, string name)
        {
            var enumCategory = GetCategory(type);
            if (enumCategory == null)
                return false;
            return enumCategory.ItemExists(name);
        }
        #endregion
    }
}
