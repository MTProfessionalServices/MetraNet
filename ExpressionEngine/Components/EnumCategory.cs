using System;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;
using System.IO;
using MetraTech.ExpressionEngine.Components.Enumerations;
using MetraTech.ExpressionEngine.Validations;

namespace MetraTech.ExpressionEngine.Components
{
    [DataContract (Namespace = "MetraTech")]
    public class EnumCategory : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The enum space to which the category belongs
        /// </summary>
        public EnumNamespace EnumNamespace { get; set; }

        /// <summary>
        /// The name that the user assigns the type. Must be unique within a space
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        public string FullName
        {
            get
            {
                if (String.IsNullOrEmpty(EnumNamespace.Name)) return Name;
            return EnumNamespace.Name + "." + Name;
        }}

        /// <summary>
        /// Indicates if the category is a basic enumeration, a unit of measure or a currency
        /// </summary>
        [DataMember]
        public EnumMode EnumMode { get; set; }

        /// <summary>
        /// The extension that the category was defined in. Only applies to MetraNet.
        /// </summary>
        [DataMember]
        public string Extension { get; set; }

        /// <summary>
        /// The description that the user provides
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The actual enumerated values
        /// </summary>
        [DataMember]
        public Collection<EnumValue> Values { get; private set; }

        /// <summary>
        /// The unique ID that is assigned by the database. It is only applicable to MetraNet
        /// and the acutal value will vary from machine to machine
        /// </summary>
        public int Id { get; set; }

        #endregion

        #region GUI Support Properties (should be moved in future)

        public string TreeNodeLabel { get { return Name; } }
        public virtual string Image { get
        {
            if (EnumMode == EnumMode.EnumValue)
                return "Enumeration.png";
            else if (EnumMode == EnumMode.UnitOfMeasure)
                return "UnitOfMeasureCategory.png";
            return "Currency.png";
        } }

        /// <summary>
        /// TOGO Localize
        /// </summary>
        public string ToolTip
        {
            get
            {
                var toolTip = "EnumType";
                if (!string.IsNullOrEmpty(Description))
                    toolTip += "\r\n" + Description;
                if (UserContext.Settings.ShowActualMappings)
                    toolTip += string.Format(CultureInfo.InvariantCulture, "\r\n[DatabaseId={0}]", Id);
                return toolTip;
            }
        }
        #endregion

        #region Constructor
        public EnumCategory(EnumNamespace parent, EnumMode enumMode, string name, int id, string description)
        {
            EnumNamespace = parent;
            EnumMode = enumMode;
            Name = name;
            Id = id;
            Description = description;

            Values =  new Collection<EnumValue>();
        }
        #endregion

        #region Methods
        public EnumValue AddEnumValue(string name, int id, string descripton)
        {
            var enumValue = EnumFactory.Create(this, name, id, descripton);
            Values.Add(enumValue);
            return enumValue;
        }

        public void AddEnumValue(EnumValue enumValue)
        {
            enumValue.EnumCategory = this;
            Values.Add(enumValue);
        }


        public EnumValue GetValue(string name)
        {
        if (string.IsNullOrEmpty(name))
            return null;

            foreach (var value in Values)
            {
                if (string.Equals(value.Name, name, StringComparison.OrdinalIgnoreCase))
                    return value;
            }
            return null;
        }

        public virtual string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", EnumNamespace.ToExpressionSnippet, Name);
            }
        }

        public void SetValueBackReferences()
        {
            foreach (var value in Values)
            {
                value.EnumCategory = this;
            }
        }

        public virtual void Validate(bool prefixMsg, ValidationMessageCollection messages, Context context)
        {
        }

        #endregion

        #region IO Methods

        public void SaveInExtension(string extensionsDir)
        {
            var dirPath = IOHelper.GetMetraNetConfigPath(extensionsDir, EnumNamespace.Extension, "Enumerations");
            Save(dirPath);
        }
        public void Save(string dirPath)
        {
            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.{2}.xml", dirPath, EnumNamespace.NameWithNoSlashes, Name);
            IOHelper.Save(filePath, this);
        }


        public static EnumCategory CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString<EnumCategory>(xmlContent);
        }

        public static EnumCategory CreateFromString<T>(string xmlContent)
        {
            var category = IOHelper.CreateFromString<EnumCategory>(xmlContent);
            var cat = (object) category;
            ((EnumCategory)cat).SetValueBackReferences();
            return category;
        }

        #endregion
    }
}
