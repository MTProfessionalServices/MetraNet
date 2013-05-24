using System;
using System.Collections.Generic;
using System.IO;
using System.Reflection;
using System.Runtime.Serialization;
using MetraTech.BusinessEntity.Core.Exception;
using MetraTech.BusinessEntity.DataAccess.Persistence;
using NHibernate.Cfg.MappingSchema;
using log4net;

using MetraTech.Basic.Config;
using MetraTech.Basic;
using MetraTech.Basic.Exception;
using MetraTech.BusinessEntity.DataAccess.Exception;
using MetraTech.BusinessEntity.DataAccess.Common;
using MetraTech.BusinessEntity.Core;


namespace MetraTech.BusinessEntity.DataAccess.Metadata
{
  class InternalRelationshipData
  {
    public string JoinFullClassName { get; set; }
    public bool Cascade { get; set; }
  }
}
