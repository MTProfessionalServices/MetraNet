using System;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Components
{ 
    [DataContract (Namespace = "MetraTech")]
    public class EnumNamespace : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The name of the Enumeration namespace. Used to prevent naming collisions
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        //I'm not sure if this is needed due to bad data or real data
        public string NameWithNoSlashes
        {
            get
            {
                return Name.Replace('/', '_');
            }
        }

        /// <summary>
        /// The description the user enters
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The data enumerated typs
        /// </summary>
        public Collection<EnumCategory> Categories {
            get { return _categories; }
        }
        private Collection<EnumCategory> _categories = new Collection<EnumCategory>();


        /// <summary>
        /// The Extension that defined the EnumNamespace
        /// </summary>
        public string Extension { get; set; }

        #endregion

        #region GUI Helper Properties (move in future)
        public string TreeNodeLabel { get { return Name; } }
        public string ToolTip { get { return Description; } }
        public string Image { get { return "EnumNamespace.png"; } }
        #endregion

        #region Constructor
        public EnumNamespace(string name, string description)
        {
            Name = name;
            Description = description;
            //Categories =  new Collection<EnumCategory>();
        }
        #endregion

        #region Methods

        public EnumCategory AddCategory(string name, int id, string description)
        {
            var category = new EnumCategory(this, name, id, description);
            Categories.Add(category);
            return category;
        }
        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "Enum.{0}", Name);
            }
        }


        public bool TryGetEnumType(string name, out EnumCategory type)
        {
            foreach (var _type in Categories)
            {
                if (_type.Name.Equals(name, StringComparison.Ordinal))
                {
                    type = _type;
                    return true;
                }
            }
            type = null;
            return false;
        }


        public static EnumValue AddEnum(Context context, string enumSpace, string enumType, int enumTypeId,  string enumValue, int enumValueId)
        {
            if (context == null)
                throw new ArgumentNullException("context");

            EnumNamespace space;
            if (!context.EnumNamespaces.TryGetValue(enumSpace, out space))
            {
                space = new EnumNamespace(enumSpace, null);
                context.AddEnum(space);
            }

            EnumCategory type;
            if (!space.TryGetEnumType(enumType, out type))
            {
                type = new EnumCategory(space, enumType, enumTypeId, null);
                space.Categories.Add(type);
            }

            var enumValueObj = type.AddValue(enumValue, enumValueId);
            return enumValueObj;
        }

        public void SaveInExtension(string extensionsDir)
        {
            var dirPath = IOHelper.GetMetraNetConfigPath(extensionsDir, Extension, "Enumerations");
            Save(dirPath);
        }

        #endregion

        #region IO Methods

        public void Save(string dirPath)
        {
            //A underscore is used so that when alpha sorted (i.e., file system) the namespace occurs before the categories
            var file = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}._.xml", dirPath, NameWithNoSlashes);
            IOHelper.Save(file, this);

            foreach (var category in Categories)
            {
                category.Save(dirPath);
            }
        }

        /// <summary>
        /// Assumes proper naming!!!! Could do better checking!!!!
        /// </summary>
        public static List<EnumNamespace> LoadDirectory(DirectoryInfo dirInfo, string extension)
        {
            if (dirInfo == null)
                throw new ArgumentException("dirInfo");

            var namespaces = new List<EnumNamespace>();
            EnumNamespace ns = null;
            var fileInfos = dirInfo.GetFiles("*.xml");
            var sortedFileInfos = fileInfos.OrderBy(f => f.Name);

            foreach (var fileInfo in sortedFileInfos)
            {
                if (fileInfo.FullName.EndsWith("._.xml"))
                {
                    ns = CreateFromFile(fileInfo.FullName);
                    ns.Extension = extension;
                    namespaces.Add(ns);
                }
                else //it's a type
                {
                    var category = EnumCategory.CreateFromFile(fileInfo.FullName);
                    ns.Categories.Add(category);
                }
            }

            return namespaces;
        }

        public static EnumNamespace CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString(xmlContent);
        }

        public static EnumNamespace CreateFromString(string xmlContent)
        {
            return IOHelper.CreateFromString<EnumNamespace>(xmlContent);
        }
    

        #endregion
    }
}
