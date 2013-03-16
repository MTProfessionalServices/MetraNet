using System;
using System.Collections.Generic;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.PropertyBags;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.MTProperties
{
    /// <summary>
    /// TO DO:
    /// *Should property names be case sensitive???
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    [KnownType(typeof(Property))]
    [KnownType(typeof(PropertyBag))]
    public class PropertyCollection : IEnumerable<Property>
    {
        #region Properties

        /// <summary>
        /// Refers to the parent, typically a PropertyBag or Function. It is not readonly
        /// because we need to set this after deserilization is performend (vs. via code)
        /// </summary>
        public object Parent { get; set; }

        /// <summary>
        /// The PropertyBag to which the collection belongs (may be null)
        /// </summary>
        public PropertyBag PropertyBag { get { return Parent == null || !(Parent is PropertyBag) ? null : (PropertyBag)Parent; } }

        /// <summary>
        /// The name of the PropertyBagType (may be null)
        /// </summary>
        public string PropertyBagTypeName
        {
            get 
            { 
                var propertyBag = PropertyBag;
                if (propertyBag == null)
                    return null;
                return ((PropertyBagType) propertyBag.Type).Name;
            }
        }

        /// <summary>
        /// The number of properties
        /// </summary>
        public int Count { get { return Properties.Count; } }

        /// <summary>
        /// Internal list. Kept private to reduce what a developer has access to
        /// </summary>
        [DataMember]
        private List<Property> Properties = new List<Property>();
        #endregion

        #region Constructors
        public PropertyCollection(object parent)
        {
            Parent = parent;
        }
        #endregion

        #region Methods

        public Property Get(string name)
        {
            if (string.IsNullOrEmpty(name))
                return null;

            foreach (var property in Properties)
            {
                if (name == property.Name)
                    return property;
            }
            return null;
        }

        /// <summary>
        /// Indicates if the property exists
        /// </summary>
        public bool Exists(string name)
        {
            return (GetValue(name) != null);
        }

        /// <summary>
        /// Returns the value for the specified property name. If the property isn't found, null is returned
        /// </summary>
        public string GetValue(string name)
        {
            var property = Get(name);
            if (property == null)
                return null;
            return property.Value;
        }

        public void ClearValues()
        {
            foreach (var property in Properties)
            {
                property.Value = null;
            }
        }

        public List<string> GetPropertyReferenceNames()
        {
            var references = new List<string>();
            foreach (var property in Properties)
            {
                references.AddRange(property.Type.GetPropertyReferenceNames());
            }
            return references;
        }

        /// <summary>
        /// Binds the KVP values to the properties.
        /// </summary>
        /// <param name="data"></param>
        public void BindValues(IEnumerable<KeyValuePair<string, string>> data)
        {
            if (data == null)
                throw new ArgumentException("data==null");

            foreach (var kvp in data)
            {
                var name = kvp.Key;
                var value = kvp.Value;

                var property = Get(name);
                if (property != null)
                    property.Value = value;
            }
        }
        /// <summary>
        /// Clears all of the properties
        /// </summary>
        public void Clear()
        {
            Properties.Clear();
        }
       
        public List<Property> GetFilteredProperties(MetraTech.ExpressionEngine.TypeSystem.Type type)
        {
            var properties = new List<Property>();
            foreach (var property in Properties)
            {
                if (property.Type.IsBaseTypeFilterMatch(type))
                    properties.Add(property);
            }
            return properties;
        }

        public ValidationMessageCollection Validate(ValidationMessageCollection messages, Context context)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var names = new Dictionary<string, bool>();
            foreach (var property in Properties)
            {
                //Ensure the that property names are unique
                if (names.ContainsKey(property.Name))
                {
                    messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.DuplicatePropertyName, property.Name));
                    continue;
                }
                names.Add(property.Name, false);

                //Validate each property and prefix with property identifier
                property.Validate(true, messages, context);

            }
            return messages;
        }

        /// <summary>
        /// Returns a sequential new property name (i.e., Property1, Property2, etc.)
        /// </summary>
        /// <returns></returns>
        public string GetNewSequentialPropertyName()
        {
            int index = 1;
            while (true)
            {
                var newName = string.Format(CultureInfo.InvariantCulture, Localization.DefaultNewPropertyName, index);
                if (Get(newName) == null)
                    return newName;
                index++;
            }
        }
        public PropertyCollection Clone()
        {
            var newCollection = new PropertyCollection(null);
            foreach (Property property in Properties)
            {
                var newProperty = property.Clone();
                newCollection.Add((Property)newProperty);
            }
            return newCollection;
        }

        public void SetPropertyParentReferences()
        {
            foreach (var property in Properties)
            {
                property.PropertyCollection = this;
            }
        }
        #endregion

        #region Add Methods
        public void Add(Property property)
        {
            if (property == null)
                throw new ArgumentNullException("property");

            if (property is Property)
                ((Property)property).PropertyCollection = this;
            Properties.Add(property);
        }
       
        public Property AddString(string name, string description, bool isRequired, string defaultValue=null, int length=0)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateString(length), isRequired, description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddEnum(string name, string description, bool isRequired, string category, string defaultValue = null)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateEnumeration(category), isRequired, description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddInteger32(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateInteger32(), isRequired, description);
            property.Required = isRequired;
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddDateTime(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateDateTime(), isRequired, description);
            property.Required = isRequired;
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddDecimal(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateDecimal(), isRequired, description);
            property.Required = isRequired;
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }


        public Property AddCharge(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = PropertyFactory.Create(PropertyBagTypeName, name, TypeFactory.CreateMoney(), isRequired, description);
            property.Required = isRequired;
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        #endregion

        #region IEnumerable Methods
        IEnumerator<Property> IEnumerable<Property>.GetEnumerator()
        {
            return Properties.GetEnumerator();
        }

        System.Collections.IEnumerator System.Collections.IEnumerable.GetEnumerator()
        {
            throw new NotImplementedException();
        }
        #endregion

        #region Static Methods

        /// <summary>
        /// Not finished....
        /// </summary>
        public PropertyCollection GetPropertyUnionAndAvailability(List<PropertyCollection> collections)
        {
            //Let's assume that all data types match for now
            //Let's not worry about if entites aren't found

            var propertyTracker = new Dictionary<string, int>(StringComparer.InvariantCultureIgnoreCase);
            var conflicts = new List<string>();
            var consolidatedCollection = new PropertyCollection(null);

            foreach (var collection in collections)
            {
                foreach (var property in collection.Properties)
                {
                    var compatibleKey = property.CompatibleKey;
                    if (!propertyTracker.ContainsKey(compatibleKey))
                    {
                        propertyTracker.Add(compatibleKey, 1);
                        consolidatedCollection.Add((Property)property.Clone());
                    }
                    else
                    {
                        propertyTracker[compatibleKey]++;
                    }

                    //Determine if there is a conflict
                }
            }

            //Now that
            foreach (var property in consolidatedCollection.Properties)
            {
                var compatibleKey = property.CompatibleKey;
                if (propertyTracker[compatibleKey] == consolidatedCollection.Properties.Count)
                    property.Availability = Availability.Always;
               
            }
            return consolidatedCollection;
        }

        #endregion
    }
}
