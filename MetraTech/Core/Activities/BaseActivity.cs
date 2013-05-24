using System;
using System.ComponentModel;
using System.ComponentModel.Design;
using System.Collections;
using System.Drawing;
using System.Linq;
using System.Workflow.ComponentModel;
using System.Workflow.ComponentModel.Design;
using System.Workflow.ComponentModel.Compiler;
using System.Workflow.ComponentModel.Serialization;
using System.Workflow.Runtime;
using System.Workflow.Activities;
using System.Workflow.Activities.Rules;

namespace MetraTech.Core.Activities
{
	public class BaseActivity: Activity
	{

        #region Region Properties
        public Logger Logger
        {
            get
            {
                if (logger == null)
                {
                    logger = new Logger("Logging\\ActivityServices", "[" + this.GetType().Name + "]");
                }

                return logger;
            }
        }
        #endregion

        #region Data
        [NonSerialized]
        private Logger logger;

        #endregion

	}
}
