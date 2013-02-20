using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Text.RegularExpressions;
using System.Data;
using System.IO;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// Provides a "context" to the editor so that it knows what's available to the user. A global context is stored in _DemoLoader.GlobalContext.
    /// "sub copies" are created for eachinteractive context.entered a more restricted context. Since the sub copies only have refences (and keys), 
    /// a lot of space isn't consumed.
    /// 
    /// This class has been thrown together to prototype ideas and to support the GUI prototype. That said, I believe the general concept has merit.
    /// 
    /// </summary>
    public class Context
    {
        #region Enums
        public enum ProductTypeEnum { MetraNet, Metanga }
        public enum ConfigurationTypeEnum { Expression, Email, Sms, PageLayout, GridLayout }
        #endregion

        #region Properties
        public static ProductTypeEnum ProductType;
        public static bool IsMetraNet { get { return ProductType == ProductTypeEnum.MetraNet; } }
        public static bool IsMetanga { get { return ProductType == ProductTypeEnum.Metanga; } }

        public readonly Expression Expression;
        public readonly EmailInstance EmailInstance;

        public Dictionary<string, Function> Functions = new Dictionary<string, Function>();
        public Dictionary<string, ComplexType> Entities = new Dictionary<string, ComplexType>();            //Entities may not have unique names across types... need to deal with that, perhaps a composite key
        public Dictionary<string, AQG> AQGs = new Dictionary<string, AQG>();
        public Dictionary<string, UQG> UQGs = new Dictionary<string, UQG>();
        public Dictionary<string, EnumSpace> EnumSpaces = new Dictionary<string, EnumSpace>();
        public Dictionary<string, Expression> Expressions = new Dictionary<string, Expression>();
        public Dictionary<string, UnitOfMeasureCategory> UoMs = new Dictionary<string, UnitOfMeasureCategory>();
        public Dictionary<string, EmailTemplate> EmailTemplates = new Dictionary<string, EmailTemplate>();
        public Dictionary<string, EmailInstance> EmailInstances = new Dictionary<string, EmailInstance>();

        //These are updated by UpdateContext()
        public List<EnumType> EnumTypes = new List<EnumType>();
        public List<IProperty> AllProperties = new List<IProperty>();
        public Dictionary<string, IProperty> UniqueProperties = new Dictionary<string, IProperty>();
        public List<EnumType> RelevantEnums = new List<EnumType>();
        #endregion

        #region Constructors

        public Context(ProductTypeEnum product)
        {
            ProductType = product;
        }

        public Context(Expression expression):this(expression, null)
        {
        }
        public Context(Expression expression, EmailInstance emailInstance)
        {
            Expression = expression;
            EmailInstance = emailInstance;

            foreach (var entity in DemoLoader.GlobalContext.Entities.Values)
            {
                if (Expression.Info.SupportedEntityTypes.Contains(entity.DataTypeInfo.ComplexType))
                    Entities.Add(entity.Name, entity);
            }

            foreach (var entityParameterName in Expression.EntityParameters)
            {
                ComplexType rootEntity;
                if (DemoLoader.GlobalContext.Entities.TryGetValue(entityParameterName, out rootEntity))
                    Entities.Add(rootEntity.Name, rootEntity);
            }

            if (expression.Info.SupportsAqgs)
                AQGs = DemoLoader.GlobalContext.AQGs;

            if (expression.Info.SupportsUqgs)
                UQGs = DemoLoader.GlobalContext.UQGs;

            EnumSpaces = DemoLoader.GlobalContext.EnumSpaces;
            Functions = DemoLoader.GlobalContext.Functions;
            UoMs = DemoLoader.GlobalContext.UoMs;

            UpdateContext();
        }
        #endregion

        public ExpressionParseResults GetExpressionParseResults()
        {
            ExpressionParseResults results;
            if (Expression.Type == Expression.ExpressionTypeEnum.Email)
                results = EmailInstance.Parse();
            else
                results = Expression.Parse();

            results.BindResultsToContext(this);
            return results;
        }

        /// <summary>
        /// Searches for a property with the specified name. If not found, null is returned. Order N search. 
        /// </summary>
        public IProperty GetRecursive(string name)
        {
            if (string.IsNullOrEmpty(name))
                return null;

            return _getRecursive(name, (IEnumerable<IProperty>)Entities.Values);
        }

        private IProperty _getRecursive(string name, IEnumerable<IProperty> properties)
        {
            if (name == null || properties == null)
                throw new ArgumentNullException("Arguments can't be null");

            var parts = name.Split('.');
            var firstName = parts[0];

            foreach (var property in properties)
            {
                if (firstName == property.Name)
                {
                    //If the length is one, then we're at the leaf!
                    if (parts.Length == 1)
                    {
                        return property;
                    }
                    else  //We're not there yet, it should be ComplexType
                    {
                        if (property.DataTypeInfo.BaseType != BaseType.ComplexType)
                            return null;

                        //Get the complex property
                        var secondProperty = ((ComplexType)property).Properties.Get(parts[1]);
                        if (secondProperty == null)
                            return null;

                        if (secondProperty.DataTypeInfo.BaseType != BaseType.ComplexType && parts.Length == 2)
                            return secondProperty;

                        //var secondName = parts[1];
                        var complexTypeName = secondProperty.DataTypeInfo.ComplexSubtype;
                        if (complexTypeName == null)
                            return null;

                        ComplexType complexType;
                        if (!DemoLoader.GlobalContext.Entities.TryGetValue(complexTypeName, out complexType))
                           return null;

                        if (parts.Length == 2)
                            return complexType;

                        var remainder = name.Substring(firstName.Length + parts[1].Length + 2);
                        return _getRecursive(remainder, complexType.Properties);
                    }
                }
            }
            return null;
        }

        #region Property Methods

        public List<IProperty> GetProperties(DataTypeInfo typeFilter, IEnumerable<ComplexType> entities=null)
        {
            if (entities == null)
                entities = Entities.Values;

            var results = new List<IProperty>();
            foreach (var entity in entities)
            {
                foreach (var property in entity.Properties)
                {
                    if (property.DataTypeInfo.IsBaseTypeFilterMatch(typeFilter))
                        results.Add(property);
                }
            }
            return results;
        }

        public List<IProperty> GetProperties(DataTypeInfo dtInfo, DataTypeInfo.MatchType minimumMatchLevel, bool uniqueProperties)
        {
            var properties = new List<IProperty>();
            IEnumerable<IProperty> list;

            if (uniqueProperties)
                list = UniqueProperties.Values;
            else
                list = AllProperties;

            foreach (var property in list)
            {
                if (property.DataTypeInfo.IsMatch(dtInfo, minimumMatchLevel))
                    properties.Add(property);
            }
            return properties;
        }
        
        public bool TryGetPropertyFromAllProperties(string name, out IProperty result)
        {
            foreach (var property in AllProperties)
            {
                if (property.ToExpressionSnippet == name)
                {
                    result = property;
                    return true;
                }
            }
            result = null;
            return false;
        }

        #endregion

        #region Methods

        public void UpdateContext()
        {
            AllProperties.Clear();
            UniqueProperties.Clear();
            RelevantEnums.Clear();
            foreach (var entity in Entities.Values)
            {
                foreach (var property in entity.Properties)
                {
                    AllProperties.Add(property);

                    IProperty uniqueProperty;
                    var key = property.CompatibleKey;
                    if (!UniqueProperties.TryGetValue(key, out uniqueProperty))
                        UniqueProperties.Add(key, property);

                    if (property.DataTypeInfo.IsEnum)
                    {
                        EnumType enumType;
                        if (TryGetEnumType(property.DataTypeInfo, out enumType))
                        {
                            if (!RelevantEnums.Contains(enumType))
                                RelevantEnums.Add(enumType);
                        }
                    }
                }
            }

            EnumTypes.Clear();
            RelevantEnums.Clear();
            foreach (var enumSpace in EnumSpaces.Values)
            {
                EnumTypes.AddRange(enumSpace.EnumTypes);
            }
        }

        #endregion

        #region Entities
        public void AddEntity(ComplexType entity)
        {
            Entities.Add(entity.Name, entity);
        }

        public List<ComplexType> GetEntities(string entityNameFilter, List<ComplexType.ComplexTypeEnum> entityTypeFilter, string propertyNameFilter, DataTypeInfo propertyTypeFilter)
        {
            var results = new List<ComplexType>();

            Regex entityRegex = string.IsNullOrEmpty(entityNameFilter) ? null : new Regex(entityNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in Entities.Values)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (entityTypeFilter != null && !entityTypeFilter.Contains(entity.DataTypeInfo.ComplexType))
                    continue;

                if (!entity.HasPropertyMatch(propertyRegex, propertyTypeFilter))
                    continue;

                results.Add(entity);
            }
            return results;
        }
        #endregion

        #region Functions
        public Function TryGetFunction(string name)
        {
            Function func;
            Functions.TryGetValue(name, out func);
            return func;
        }
        public Function AddFunction(string name, string category, string description)
        {
            var function = new Function(name, category, description);
            Functions.Add(function.Name, function);
            return function;
        }

        /// <summary>
        /// Returns a unique list of function categories
        /// </summary>
        public List<string> GetFunctionCategories(bool includeAllChoice)
        {
            var categories = new List<string>();
            if (includeAllChoice)
                categories.Add(Localization.AllChoice);
            foreach (var func in Functions.Values)
            {
                if (!categories.Contains(func.Category))
                    categories.Add(func.Category);
            }
            return categories;
        }
        #endregion

        #region Enums

        public void AddEnum(EnumSpace enumSpace)
        {
            EnumSpaces.Add(enumSpace.Name, enumSpace);
        }

        public bool TryGetEnumType(DataTypeInfo dataType, out EnumType enumType)
        {
            EnumSpace space;
            if (!EnumSpaces.TryGetValue(dataType.EnumSpace, out space))
            {
                enumType = null;
                return false;
            }

            if (!space.TryGetEnumType(dataType.EnumType, out enumType))
            {
                enumType = null;
                return false;
            }

            return true;
        }
        #endregion

    }
}
