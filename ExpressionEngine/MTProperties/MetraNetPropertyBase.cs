using Type = MetraTech.ExpressionEngine.TypeSystem.Type;

namespace MetraTech.ExpressionEngine.MTProperties
{
    public abstract class MetraNetPropertyBase : Property
    {
        #region Properties
        public override string DatabaseName
        {
            get
            {
                if (string.IsNullOrEmpty(DatabaseNameMapping))
                    return "c_" + Name;
                return DatabaseNameMapping;
            }
        }

        /// <summary>
        /// Used to override the default "c_" prefix. This is used when you want to use a more user friendly 
        /// term and you can't refactor that acutal database name.
        /// </summary>
        public string DatabaseNameMapping { get; set; }

        #endregion

        #region Constructor
        public MetraNetPropertyBase(string name, Type type, bool isRequired, string description)
            : base(name, type, isRequired, description)
        {
            
        }

        #endregion
    }
}
