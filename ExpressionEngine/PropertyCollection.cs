﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Xml;

namespace MetraTech.ExpressionEngine
{
    /// <summary>
    /// TO DO:
    /// *Should property names be case sensitive???
    /// </summary>
    public class PropertyCollection : IEnumerable<Property>
    {
        #region Properties
        /// <summary>
        /// The parent, typically an Entity but might also be Function
        /// </summary>
        public readonly object Parent;

        /// <summary>
        /// The number of properties
        /// </summary>
        public int Count { get { return Properties.Count; } }

        /// <summary>
        /// Internal list. Kept private to reduce what a developer has access to
        /// </summary>
        private List<Property> Properties = new List<Property>();
        #endregion

        #region Constructors
        public PropertyCollection(object parent)
        {
            Parent = parent;
        }
        #endregion

        #region Methods
        
        /// <summary>
        /// Searches for a property with the specified name. If not found, null is returned. Order N search. 
        /// </summary>
        public Property Get(string name)
        {
            foreach (var property in Properties)
            {
                if (name == property.Name)
                    return property;
            }
            return null;
        }

        /// <summary>
        /// Clears all of the properties
        /// </summary>
        public void Clear()
        {
            Properties.Clear();
        }

        public ValidationMessageCollection Validate(ValidationMessageCollection messages=null)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var names = new Dictionary<string, bool>();
            foreach (var property in Properties)
            {
                //Ensure the that property names are unique
                if (names.ContainsKey(property.Name))
                {
                    messages.Error(string.Format(Localization.DuplicatePropertyName, property.Name));
                    continue;
                }
                names.Add(property.Name, false);

                //Validate each property and prefix with property identifier
                property.Validate(true, messages);

            }
            return messages;
        }

        public void Add(Property property)
        {
            property.Parent = this;
            Properties.Add(property);
        }
       
        public Property AddString(string name, string description, bool isRequired, string defaultValue=null, int length=0)
        {
            var property = new Property(name, DataTypeInfo.CreateString(length), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddEnum(string name, string description, bool isRequired, string enumSpace, string enumType, string defaultValue = null)
        {
            var property = new Property(name, DataTypeInfo.CreateEnum(enumSpace, enumType), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddInt32(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = new Property(name, new DataTypeInfo(BaseType.Integer32), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddDateTime(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = new Property(name, new DataTypeInfo(BaseType.DateTime), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }

        public Property AddDecimal(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = new Property(name, new DataTypeInfo(BaseType.Decimal), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }


        public Property AddCharge(string name, string description, bool isRequired, string defaultValue = null)
        {
            var property = new Property(name, new DataTypeInfo(BaseType.Charge), description);
            property.DefaultValue = defaultValue;
            Add(property);
            return property;
        }
        #endregion

        #region XmlMethods
        public void LoadFromXmlParentNode(XmlNode parentNode, string propertyCollectionNodeName = "Properties")
        {
            LoadFromXmlNode(parentNode.GetChildNode(propertyCollectionNodeName));
        }
        public void LoadFromXmlNode(XmlNode node, string propertyNodeName = "Property")
        {
            Properties.Clear();
            var nodes = node.SelectNodes(propertyNodeName);
            foreach (var propertyNode in nodes)
            {
                var property = Property.CreateFromXmlNode((XmlNode)propertyNode);
                Add(property);
            }
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
    }
}
