/**************************************************************************
 * ODBCARRAYSESSIONMAPPING
 *
 * Copyright 1997-2001 by MetraTech Corp.
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LICENSED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: 
 *
 * $Date$
 * $Author$
 * $Revision$
 ***************************************************************************/

#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>

#include <autoptr.h>

#include "OdbcSessionMapping.h"


COdbcArraySessionWriter::COdbcArraySessionWriter(int aMaxBatchSize, 
																								 COdbcConnection * apOdbcConnection,
																								 COdbcLongIdGenerator* aGenerator,
																								 CMSIXDefinition* apProductView,
																								 MTPipelineLib::IMTNameIDPtr,
																								 SharedSessionHeader* apHeader)
	:
	COdbcSessionWriter(aGenerator, apHeader),
	mMaxBatchSize(aMaxBatchSize)
{
	mpProductView = apProductView;

	MTPipelineLib::IMTNameIDPtr nameID(MTPROGID_NAMEID);

  COdbcArraySessionAccUsageWriter * accUsageWriter = new COdbcArraySessionAccUsageWriter(apOdbcConnection->GetConnectionInfo(), mMaxBatchSize);
	accUsageWriter->SetUp(apOdbcConnection->GetConnectionInfo());
	AddWriter(accUsageWriter);

	COdbcArraySessionProductViewWriter * pvWriter = new COdbcArraySessionProductViewWriter(mpProductView, apOdbcConnection->GetConnectionInfo(), mMaxBatchSize);
	pvWriter->SetUp(apOdbcConnection->GetConnectionInfo(), mpProductView, nameID);
	AddWriter(pvWriter);
}

void COdbcArraySessionWriter::Setup()
{
	BeginBatch();
}


COdbcArraySessionWriter::~COdbcArraySessionWriter()
{
}

int COdbcArraySessionWriter::GetMaxBatchSize() const
{
	return mMaxBatchSize;
}

