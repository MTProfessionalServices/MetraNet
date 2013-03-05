using System;
using System.Collections.ObjectModel;
using System.Globalization;
using System.Runtime.Serialization;

namespace MetraTech.ExpressionEngine.Components
{
    [DataContract (Namespace = "MetraTech")]
    [KnownType(typeof(UnitOfMeasure))]
    public class EnumValue : IExpressionEngineTreeNode
    {
        #region Properties

        /// <summary>
        /// The EnumType to which the value belongs; this is externally setable because we need to manually set it post
        /// deserilization (vs. adding via code)
        /// </summary>
        public EnumCategory EnumCategory { get; set; }

        /// <summary>
        /// The name of the enum value. Must be unique within the enum type
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        public bool IsUnitOfMeasure { get { return EnumCategory.IsUnitOfMeasure; } }

        /// <summary>
        /// Aliased values when integrating with an external system. Used by MetraNet for metering usage data
        /// </summary>
        [DataMember]
        public Collection<string> Aliases { get; private set; }

        /// <summary>
        /// The description of the value. TODO: Localize
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// MetraNet enums are repreesnted by an ID that will vary by installation
        /// </summary>
        public int Id { get; set; }

        #endregion

        #region GUI Support Properties (should be moved)
        /// <summary>
        /// TOGO Localize
        /// </summary>
        public virtual string ToolTip
        {
            get
            {
                var toolTip = "EnumValue";
                if (!string.IsNullOrEmpty(Description))
                    toolTip += Environment.NewLine + Description;
                if (UserContext.Settings.ShowActualMappings)
                    toolTip += string.Format(CultureInfo.InvariantCulture, "\r\n[DatabaseId: {0}]", Id);
                return toolTip;
            }
        }

        public string TreeNodeLabel { get { return Name; } }

        /// <summary>
        /// The 16x16 image associated with the value
        /// </summary>
        public virtual string Image { get { return "EnumValue.png"; } }

        #endregion 

        #region Constructor
        public EnumValue(EnumCategory parent, string name, string description, int id)
        {
            EnumCategory = parent;
            Name = name;
            Description = description;
            Id = id;

            Aliases = new Collection<string>();
        }
        #endregion

        #region Methods
        /// <summary>
        /// Returns the value in a MTSQL format which is used by MVM, MTSQL Pipeline plug-ins and MetraFlow
        /// </summary>
        public string ToMtsql()
        {
            return string.Format(CultureInfo.InvariantCulture, "#{0}/{1}/{2}#", EnumCategory.EnumNamespace.Name, EnumCategory.Name, Name);
        }

        /// <summary>
        /// Returns the value in the proposed future MVM format
        /// </summary>
        public string ToExpressionSnippet
        {
            get
            {
                if (UserContext.Settings.NewSyntax)
                {
                    var enumSpace = EnumCategory.EnumNamespace.Name.Replace('.', '_');
                    return string.Format(CultureInfo.InvariantCulture, "ENUM.{0}.{1}.{2}", enumSpace, EnumCategory.Name, Name);
                }
                return ToMtsql();
            }
        }

        #endregion
    }

}
