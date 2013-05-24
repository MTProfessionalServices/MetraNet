using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using MetraTech.SecurityFramework;
using MetraTech.SecurityFramework.Serialization.Attributes;
using MetraTech.SecurityFramework.Common.Configuration.Logger;

namespace MetraTech.SecurityFramework.Core
{
    /// <summary>
    /// This class is for the configuration of the subsystem
    /// </summary>
    public class SubsystemProperties : IConfigurationLogger
    {
        #region Private Fields

        public string _mSignature;

        #endregion

        #region Public Properties
        
		[SerializePropertyAttribute]
        public string Signature
        {
            get { return _mSignature; }
            set { _mSignature = value; }
        }

		[SerializeCollectionAttribute(ElementName = "Engine")]
		public IEngine[] Engines
		{
			get;
			set;
		}

		[SerializePropertyAttribute(IsRequired = true)]
        public bool IsRuntimeApiEnabled
        {
            get;
            set;
        }

		[SerializePropertyAttribute(IsRequired = true)]
        public bool IsRuntimeApiPublic
        {
            get;
            set;
        }

		[SerializePropertyAttribute(IsRequired = true)]
        public bool IsControlApiEnabled
        {
            get;
            set;
        }

		[SerializePropertyAttribute(IsRequired = true)]
        public bool IsControlApiPublic
        {
            get;
            set;
        }

		//[SerializePropertyAttribute(IsRequired = false)]
		public IConfigurationLogProvider LogProvider
		{
			get;
			set;
		}

        #endregion

		public void ReconfigurationLog()
		{

		}
	}
}
