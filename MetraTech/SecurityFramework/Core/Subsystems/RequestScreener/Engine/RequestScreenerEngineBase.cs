using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework
{
	public abstract class RequestScreenerEngineBase : EngineBase
	{
        protected override Type SubsystemType
        {
            get
            {
                return typeof(MetraTech.SecurityFramework.RequestScreener);
            }
        }

        protected RequestScreenerEngineCategory Category { get; private set; }

				protected RequestScreenerEngineBase(RequestScreenerEngineCategory category)
        {
            Category = category;
            this.CategoryName = Convert.ToString(Category);
        }
	}
}
