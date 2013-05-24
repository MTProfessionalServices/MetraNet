using System;
using System.Runtime.InteropServices;

[assembly: GuidAttribute ("e2aac24c-6079-4a7b-91f6-f39bb9355332")]


namespace MetraTech.Accounts.PlugIns
{
	using MetraTech.Interop.MTPipelineLib;
	using PC = MetraTech.Interop.MTProductCatalog;
	using MetraTech.Pipeline;

	internal struct PipelinePropIDs
	{
		public int mlTruncateSubsID;
		public int mlOperationID;
		public int mlAccountStartDateID;
		public int mlAccountEndDateID;
		public int mlAccountIDID;
		public int mlAncestorAccountIDID;
		public int mlAccountTypeID;
		public int mlUserNameID;
		public int mlNameSpaceID;
		public int mlOldAncestorAccountIDID;
		public int mlHierarchyStartDateID;
		public int mlHierarchyEndDateID;
		public int mlCorporateAccountIDID;
	}

	internal struct Interfaces
	{
		public IEnumConfig EnumConfig;
		public Logger Logger;
		public PC.IMTProductCatalog ProdCat;
		public IServiceDefinition ServiceDefinition;
		public IMTNameID NameID;
	}

}
