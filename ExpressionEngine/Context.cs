using System;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;

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
        #region Properties
        public static ProductType ProductType;
        public static bool IsMetraNet { get { return ProductType == ProductType.MetraNet; } }
        public static bool IsMetanga { get { return ProductType == ProductType.Metanga; } }

        public readonly Expression Expression;
        public readonly EmailInstance EmailInstance;

        public Dictionary<string, Function> Functions = new Dictionary<string, Function>();
        public Dictionary<string, Entity> Entities = new Dictionary<string, Entity>();            //Entities may not have unique names across types... need to deal with that, perhaps a composite key
        public Dictionary<string, Aqg> AQGs = new Dictionary<string, Aqg>();
        public Dictionary<string, UQG> UQGs = new Dictionary<string, UQG>();
        public Dictionary<string, EnumSpace> EnumSpaces = new Dictionary<string, EnumSpace>();
        public Dictionary<string, Expression> Expressions = new Dictionary<string, Expression>();
        public Dictionary<string, UnitOfMeasureCategory> UoMs = new Dictionary<string, UnitOfMeasureCategory>();
        public Dictionary<string, EmailTemplate> EmailTemplates = new Dictionary<string, EmailTemplate>();
        public Dictionary<string, EmailInstance> EmailInstances = new Dictionary<string, EmailInstance>();

        //These are updated by UpdateContext()
        public List<EnumCategory> EnumTypes = new List<EnumCategory>();
        public List<IProperty> AllProperties = new List<IProperty>();
        public Dictionary<string, IProperty> UniqueProperties = new Dictionary<string, IProperty>();
        public List<EnumCategory> RelevantEnums = new List<EnumCategory>();
        #endregion

        #region Constructors

        public Context(ProductType product)
        {
            ProductType = product;
        }

        public Context(Expression expression)
            : this(expression, null)
        {
        }
        public Context(Expression expression, EmailInstance emailInstance)
        {
            if (expression == null)
                throw new ArgumentNullException("expression");

            Expression = expression;
            EmailInstance = emailInstance;

            foreach (var entity in DemoLoader.GlobalContext.Entities.Values)
            {
                //if (Expression.Info.SupportedEntityTypes.Contains(entity.DataTypeInfo.ComplexType))
                if (Expression.Info.SupportedEntityTypes.Contains(entity.VectorType.ComplexType))
                    Entities.Add(entity.Name, entity);
            }

            foreach (var entityParameterName in Expression.EntityParameters)
            {
                Entity rootEntity;
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
            if (Expression.Type == ExpressionTypeEnum.Email)
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
                        return property;

                    //We're not there yet, it should be ComplexType

                    if (property.Type.BaseType != BaseType.Entity)
                        return null;

                    //Get the complex property
                    var secondProperty = ((Entity)property).Properties.Get(parts[1]);
                    if (secondProperty == null)
                        return null;

                    if (secondProperty.Type.BaseType != BaseType.Entity && parts.Length == 2)
                        return secondProperty;

                    //var secondName = parts[1];
                    var complexTypeName = ((VectorType)secondProperty.Type).ComplexSubtype;
                    if (complexTypeName == null)
                        return null;

                    Entity complexType;
                    if (!DemoLoader.GlobalContext.Entities.TryGetValue(complexTypeName, out complexType))
                        return null;

                    if (parts.Length == 2)
                        return complexType;

                    var remainder = name.Substring(firstName.Length + parts[1].Length + 2);
                    return _getRecursive(remainder, complexType.Properties);
                }
            }
            return null;
        }

        #region Property Methods

        public List<IProperty> GetProperties(MtType typeFilter, IEnumerable<Entity> entities = null)
        {
            if (entities == null)
                entities = Entities.Values;

            var results = new List<IProperty>();
            foreach (var entity in entities)
            {
                foreach (var property in entity.Properties)
                {
                    if (property.Type.IsBaseTypeFilterMatch(typeFilter))
                        results.Add(property);
                }
            }
            return results;
        }

        public List<IProperty> GetProperties(MtType dtInfo, MatchType minimumMatchLevel, bool uniqueProperties)
        {
            var properties = new List<IProperty>();
            IEnumerable<IProperty> list;

            if (uniqueProperties)
                list = UniqueProperties.Values;
            else
                list = AllProperties;

            foreach (var property in list)
            {
                if (property.Type.IsMatch(dtInfo, minimumMatchLevel))
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

                    if (property.Type.IsEnum)
                    {
                        EnumCategory enumType;
                        if (TryGetEnumType((EnumerationType)property.Type, out enumType))
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
        public void AddEntity(Entity entity)
        {
            if (entity == null)
                throw new ArgumentNullException("entity");

            Entities.Add(entity.Name, entity);
        }

        public List<Entity> GetEntities(ComplexType type)
        {
            var types = new List<ComplexType>();
            types.Add(type);
            return GetEntities(null, types, null, null);
        }
        public List<Entity> GetEntities(string entityNameFilter, List<ComplexType> entityTypeFilter, string propertyNameFilter, MtType propertyTypeFilter)
        {
            var results = new List<Entity>();

            Regex entityRegex = string.IsNullOrEmpty(entityNameFilter) ? null : new Regex(entityNameFilter, RegexOptions.IgnoreCase);
            Regex propertyRegex = string.IsNullOrEmpty(propertyNameFilter) ? null : new Regex(propertyNameFilter, RegexOptions.IgnoreCase);

            foreach (var entity in Entities.Values)
            {
                if (entityRegex != null && !entityRegex.IsMatch(entity.Name))
                    continue;
                if (entityTypeFilter != null && !entityTypeFilter.Contains(entity.VectorType.ComplexType))
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
            if (enumSpace == null)
                throw new ArgumentNullException("enumSpace");

            EnumSpaces.Add(enumSpace.Name, enumSpace);
        }

        public bool TryGetEnumType(EnumerationType dataType, out EnumCategory enumType)
        {
            EnumSpace space;
            if (!EnumSpaces.TryGetValue(dataType.Namespace, out space))
            {
                enumType = null;
                return false;
            }

            if (!space.TryGetEnumType(dataType.Category, out enumType))
            {
                enumType = null;
                return false;
            }

            return true;
        }
        #endregion

    }

    public enum ConfigurationType { Expression, Email, Sms, PageLayout, GridLayout }

    public enum ProductType { MetraNet, Metanga }
}
