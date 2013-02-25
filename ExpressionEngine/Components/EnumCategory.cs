using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;
using System.IO;

namespace MetraTech.ExpressionEngine.Components
{
    [DataContract]
    public class EnumCategory : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The enum space to which the type belongs
        /// </summary>
        public EnumNamespace EnumNamespace { get; private set; }

        /// <summary>
        /// The name that the user assigns the type. Must be unique within a space
        /// </summary>
        [DataMember]
        public string Name { get; set; }

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
        public string Image { get { return "EnumType.png"; } }

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
                if (UserSettings.ShowActualMappings)
                    toolTip += string.Format(CultureInfo.InvariantCulture, "\r\n[DatabaseId={0}]", Id);
                return toolTip;
            }
        }
        #endregion

        #region Constructor
        public EnumCategory(EnumNamespace parent, string name, int id, string description)
        {
            EnumNamespace = parent;
            Name = name;
            Id = id;
            Description = description;

            Values =  new Collection<EnumValue>();
        }
        #endregion

        #region Methods
        public EnumValue AddValue(string value, int id)
        {
            var enumValue = new EnumValue(this, value, id);
            Values.Add(enumValue);
            return enumValue;
        }

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}.{1}", EnumNamespace.ToExpressionSnippet, Name);
            }
        }

        public void SaveInExtension(string extensionsDir)
        {
            var dirPath = Helper.GetMetraNetConfigPath(extensionsDir, EnumNamespace.Extension, "Enumerations");
            Save(dirPath);
        }
        public void Save(string dirPath)
        {
            Helper.EnsureDirectoryExits(dirPath);

            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.{2}.xml", dirPath, EnumNamespace.Name, Name);
            using (var writer = new FileStream(filePath, FileMode.Create))
            {
                var ser = new DataContractSerializer(typeof(Function));
                ser.WriteObject(writer, this);
            }
        }

        #endregion
    }
}
