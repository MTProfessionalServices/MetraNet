using System.Globalization;
using System.Runtime.Serialization;
using System.IO;
using MetraTech.ExpressionEngine.MTProperties;
using MetraTech.ExpressionEngine.TypeSystem;

namespace MetraTech.ExpressionEngine.Components
{
    [DataContract(Namespace = "MetraTech")]
    public class Function : IExpressionEngineTreeNode
    {
        #region Properties
        /// <summary>
        /// The function's name
        /// </summary>
        [DataMember]
        public string Name { get; set; }

        public string FullName { get { return Name; } }


        /// <summary>
        /// The category. Used for filtering. Ensure that proper case is used.
        /// DO WE WANT TO SUPPORT MULTIPLE CATEGOREIS?
        /// TODO Localize
        /// </summary>
        [DataMember]
        public string Category { get; set; }

        /// <summary>
        /// The data type that the function returns
        /// </summary>
        [DataMember]
        public Type ReturnType { get; set; }

        /// <summary>
        /// The description. Used in tool tips, online help, etc.
        /// This should be localized in future.
        /// </summary>
        [DataMember]
        public string Description { get; set; }

        /// <summary>
        /// The parameters that are fixed.
        /// </summary>
        [DataMember]
        public PropertyCollection FixedParameters { get; set; }

        /// <summary>
        /// Some functions suport multiple arguments. For example, Min(a, b, c...). At this point, we require that they all be of the same 
        /// datatype which is set by this property. 
        /// </summary>
        [DataMember]
        public Property DynamicParameterPrototype { get; set; }

        /// <summary>
        /// The minimum number of dynamic parameters. Min, Max, Average would all be 2.
        /// </summary>
        [DataMember]
        public int DynamicParameterMin { get; set; }

        #endregion

        #region GUI Helper Properties (move in future)
        public string ToolTip { get { return Description; } }
        public string Image { get { return "Function.png"; } }
        #endregion

        #region Constructor
        public Function()
        {
        }

        public Function(string name, string category, string description)
        {
            Name = name;
            Category = category;
            Description = description;

            FixedParameters = new PropertyCollection(this);
            DynamicParameterPrototype = null;
        }
        #endregion
    
        #region Methods

        public string ToExpressionSnippet
        {
            get
            {
                return string.Format(CultureInfo.InvariantCulture, "{0}()", Name);
            }
        }
        #endregion

        #region IO Methods

        public void Save(string dirPath)
        {
            var dirInfo = new DirectoryInfo(dirPath);
            if (!dirInfo.Exists)
                dirInfo.Create();

            var filePath = string.Format(CultureInfo.InvariantCulture, @"{0}\{1}.xml", dirPath, Name);
            using (var writer = new FileStream(filePath, FileMode.Create))
            {
                var ser = new DataContractSerializer(typeof (Function));
                ser.WriteObject(writer, this);
            }
        }

        public static Function CreateFromFile(string file)
        {
            var xmlContent = File.ReadAllText(file);
            return CreateFromString(xmlContent);
        }

        public static Function CreateFromString(string xmlContent)
        {
            return IOHelper.CreateFromString<Function>(xmlContent);
        }
        #endregion
    }
}
