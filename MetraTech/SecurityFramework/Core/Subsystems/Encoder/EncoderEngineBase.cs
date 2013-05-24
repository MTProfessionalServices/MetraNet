/**************************************************************************
* Copyright 1997-2010 by MetraTech
* All rights reserved.
*
* THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech MAKES NO
* REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
* example, but not limitation, MetraTech MAKES NO REPRESENTATIONS OR
* WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY PARTICULAR PURPOSE
* OR THAT THE USE OF THE LICENCED SOFTWARE OR DOCUMENTATION WILL NOT
* INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER
* RIGHTS.
*
* Title to copyright in this software and any associated
* documentation shall at all times remain with MetraTech, and USER
* agrees to preserve the same.
*
* Authors: 
*
* Anatoliy Lokshin <alokshin@metratech.com>
*
* 
***************************************************************************/

using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace MetraTech.SecurityFramework.Core.Encoder
{
    /// <summary>
    /// Provides a base class for all engines in the Encoder subsystem.
    /// </summary>
    public abstract class EncoderEngineBase : EngineBase
    {
        /// <summary>
        /// Gets a type of the subsystem the engine belongs to.
        /// </summary>
        protected override Type SubsystemType
        {
            get
            {
                return typeof(MetraTech.SecurityFramework.Encoder);
            }
        }

        /// <summary>
        /// Encoder category enum
        /// </summary>
        protected EncoderEngineCategory Category { get; private set; }

        protected EncoderEngineBase(EncoderEngineCategory category)
        {
            Category = category;
            this.CategoryName = Convert.ToString(Category);
        }
    }
}
