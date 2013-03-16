using System;
using System.Collections.Generic;
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
        /// The namespace to which the category belongs
        /// </summary>
        [DataMember]
        public string Namespace { get; set; }

        /// <summary>
        /// The name that the user assigns the type. Must be unique within a space
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        /// <summary>
        /// The Name prefixed with with Namespace
        /// </summary>
        public string FullName
        {
            get { return Namespace + "." + Name; }
        }

        public string FullNameReversed { get { return string.Format("{0} ({1})", Name, Namespace); } }

        /// <summary>
        /// Returns the FullName replacing and /'s with _'s. Legacy MetraNet has slashes which causes issues when saving to file
        /// </summary>
        public string FullNameWithNoSlashes { get { return FullName.Replace('/', '_'); } }

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
        public Collection<EnumItem> Items { get; private set; }

        /// <summary>
        /// The unique ID that is assigned by the database. It is only applicable to MetraNet
        /// and the acutal value will vary from machine to machine
        /// </summary>
        public int Id { get; set; }

        #endregion

        #region GUI Support Properties (should be moved in future)

        public virtual string Image { get
        {
            if (EnumMode == EnumMode.Item)
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
        public EnumCategory(EnumMode enumMode, string _namespace, string name, int id, string description)
        {
            EnumMode = enumMode;
            Namespace = _namespace;
            Name = name;
            Id = id;
            Description = description;

            Items =  new Collection<EnumItem>();
        }
        #endregion

        #region Methods
        public EnumItem AddItem(string name, int id, string descripton)
        {
            var enumValue = EnumFactory.Create(this, name, id, descripton);
            Items.Add(enumValue);
            return enumValue;
        }

        public void AddItem(EnumItem enumValue)
        {
            enumValue.EnumCategory = this;
            Items.Add(enumValue);
        }


        public EnumItem GetItem(string name)
        {
        if (string.IsNullOrEmpty(name))
            return null;

            foreach (var value in Items)
            {
                if (string.Equals(value.Name, name, StringComparison.OrdinalIgnoreCase))
                    return value;
            }
            return null;
        }

        public override string ToString()
        {
            return string.Format(CultureInfo.InvariantCulture, "{0}: {1}", FullName, EnumMode);
        }
        public virtual string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", Namespace, Name);
            }
        }

        public void SetValueBackReferences()
        {
            foreach (var value in Items)
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
            var dirPath = IOHelper.GetMetraNetConfigPath(extensionsDir, Extension, "Enumerations");
            Save(dirPath);
        }
        public void Save(string dirPath)
        {
            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, FullNameWithNoSlashes);
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

        public static void LoadDirectoryIntoContext(string dirPath, string extension, Context context)
        {
            var enmuCategories = LoadDirectory(dirPath, extension, context.DeserilizationMessages);
            foreach (var enumCategory in enmuCategories)
            {
                context.AddEnumCategory(enumCategory);
            }
        }

        public static List<EnumCategory> LoadDirectory(string dirPath, string extension, ValidationMessageCollection messages = null)
        {
            var enmuCategories = new List<EnumCategory>();

            if (string.IsNullOrEmpty(dirPath))
                throw new ArgumentException("dirPath is null or empty");

            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                return enmuCategories;

            foreach (var fileInfo in dirInfo.GetFiles("*.xml"))
            {
                try
                {
                    var category = EnumCategory.CreateFromFile(fileInfo.FullName);
                    enmuCategories.Add(category);
                }
                catch (Exception exception)
                {
                    if (messages == null)
                        throw;
                    messages.Error(string.Format(CultureInfo.CurrentCulture, Localization.FileLoadError, fileInfo.FullName), exception);
                }               
            }

            return enmuCategories;
        }
        #endregion
    }
}
