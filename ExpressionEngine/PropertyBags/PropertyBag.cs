using System;
using System.Text.RegularExpressions;
using System.Globalization;
using System.Runtime.Serialization;
using MetraTech.ExpressionEngine.MTProperties.Enumerations;
using MetraTech.ExpressionEngine.MTProperty;
using MetraTech.ExpressionEngine.TypeSystem;
using MetraTech.ExpressionEngine.TypeSystem.Enumerations;
using System.IO;
using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.PropertyBags
{
    /// <summary>
    /// Implements a ComplexType, esentially something that PropertyCollection which may include properties and
    /// other complex types. Note that DataTypeInfo.IsEntity determines if it's deemed an Entity (an important destinction for Metanga)
    /// </summary>
    [DataContract (Namespace = "MetraTech")]
    public class PropertyBag : IProperty, IExpressionEngineTreeNode
    {
        #region Properties
        [DataMember]
        public string Name { get; set; }

        [DataMember]
        public bool Required { get; set; }

        [DataMember]
        public bool IsCore { get; set; }

        [DataMember]
        public PropertyBagMode PropertyBagMode { get; set; }

        [DataMember]
        public Type Type { get; set; }

        public PropertyBagType VectorType { get { return (PropertyBagType)Type; } }

        [DataMember]
        public PropertyCollection Properties { get; private set; }

        public PropertyBag ParentEntity { get; set; }

        [DataMember]
        public string Description { get; set; }

        [DataMember]
        public Direction Direction { get; set; }

        /// <summary>
        /// Used for end-user-drive testing etc. 
        /// </summary>
        public string Value { get; set; }

        public string CompatibleKey { get { return string.Format(CultureInfo.InvariantCulture, "{0}|{1}", Name, Type.CompatibleKey); } }

        /// <summary>
        /// The actual database table name. Used in MetraNet which has a prefix on all table names.
        /// Not sure what to do for Metanga here.
        /// </summary>
        public virtual string DBTableName
        {
            get { return Name; }
        }

        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name + Type.ListSuffix; } }
        public string ToolTip
        {
            get
            {
                var tip = VectorType.ComplexType.ToString();
                if (!string.IsNullOrEmpty(Description))
                    tip += Environment.NewLine + Description;
                if (UserSettings.ShowActualMappings)
                    tip += string.Format(CultureInfo.InvariantCulture, "\r\n[TableName={0}]", DBTableName);
                return tip;
            }
        }

        public string Image
        {
            get
            {
                if (VectorType.ComplexType == ComplexType.Metanga)
                {
                    if (VectorType.IsEntity)
                        return "Entity.png";
                    return "ComplexType.png";
                }

                return VectorType.ComplexType + ".png";
            }
        }


        public string ImageDirection
        {
            get
            {
                switch (Direction)
                {
                    case MTProperties.Enumerations.Direction.InOut:
                        return "EntityInOut.png";
                    case Direction.Input:
                        return "EntityInput.png";
                    case Direction.Output:
                        return "EntityOutput.png";
                    default:
                        return null;
                }
            }
        }
        #endregion

        #region Constructor

        public PropertyBag(string name, ComplexType type, string subtype, bool isEntity, string description)
        {
            Name = name;
            Type = TypeFactory.CreateComplexType(type, subtype, isEntity);
            Description = description;
            Properties = new PropertyCollection(this);
        }
        #endregion

        #region Methods

        /// <summary>
        /// Determines if the Properties collection exactly matches the nameFilter or the typeFilter. Useful
        /// for filtering in the GUI.
        /// TODO: Add recursive option to look sub entities
        /// </summary>
        public bool HasPropertyMatch(Regex nameFilter, Type typeFilter)
        {
            foreach (var property in Properties)
            {
                if (nameFilter != null && !nameFilter.IsMatch(property.Name))
                    continue;
                if (typeFilter != null && !property.Type.IsBaseTypeFilterMatch(typeFilter))
                    continue;
                return true;
            }
            return false;
        }

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", GetPrefix(), Name);
            }
        }

        public string GetPrefix()
        {
            switch (VectorType.ComplexType)
            {
                case ComplexType.ProductView:
                    return UserSettings.NewSyntax? "EVENT": "USAGE";
                case ComplexType.AccountView:
                    return "ACCOUNT";
                default:
                    return String.Empty;
            }
        }

        public object Clone()
        {
            throw new NotImplementedException();
            //var newEntity = new ComplexType(Name, Type.ComplexType, Description);
            //newEntity.Properties = Properties.Clone();
            //return newEntity;
        }

        public ValidationMessageCollection Validate(bool prefixMsg)
        {
            return Validate(prefixMsg, null);
        }

        public ValidationMessageCollection Validate(bool prefixMsg, ValidationMessageCollection messages)
        {
            if (messages == null)
                messages = new ValidationMessageCollection();

            var prefix = string.Format(CultureInfo.InvariantCulture, Localization.PropertyMessagePrefix, Name);

            //if (NameRegex.IsMatch(Name))
            //    messages.Error(prefix + Localization.InvalidName);

            Type.Validate(prefix, messages);

            foreach (var property in Properties)
            {
                property.Validate(prefixMsg, messages);
            }

            return messages;
        }


        public void Save(string file)
        {
            if (string.IsNullOrEmpty(file))
                throw new ArgumentException("file not specified");

            var dirInfo = new DirectoryInfo(Path.GetDirectoryName(file));
            if (!dirInfo.Exists)
                dirInfo.Create();

            using (var writer = new FileStream(file, FileMode.Create))
            {
                var ser = new DataContractSerializer(typeof (PropertyBag));
                ser.WriteObject(writer, this);
            }
        }
        #endregion
    }
}
