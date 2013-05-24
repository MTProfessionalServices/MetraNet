/**************************************************************************
* Copyright 1997-2006 by MetraTech
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
* $Header$
* 
***************************************************************************/

#include <metra.h>
#include <propids.h>
#include <mtprogids.h>
#include <ProductViewCollection.h>
#include <MSIXDefinition.h>

#include <autoptr.h>

#include "OdbcSessionMapping.h"
#include "OdbcSessionRouter.h"

#include "OdbcConnection.h"
#include "OdbcStatementGenerator.h"
#include "OdbcException.h"
#include "OdbcMetadata.h"
#include "OdbcStatement.h"
#include "OdbcResultSet.h"
#include "OdbcIdGenerator.h"
#include "OdbcSessionTypeConversion.h"
#include "DistributedTransaction.h"
#include "OdbcSessionWriterSession.h"
#include <OdbcStagingTable.h>

COdbcBcpSessionWriter::COdbcBcpSessionWriter(int aMaxBatchSize, 
																						 const COdbcConnectionInfo& aOdbcConnectionInfo,
																						 COdbcLongIdGenerator* aGenerator,
																						 CMSIXDefinition* apProductView,
																						 MTPipelineLib::IMTNameIDPtr aNameID,
																						 SharedSessionHeader* apHeader)
	:
	COdbcSessionWriter(aGenerator, apHeader),
	mMaxBatchSize(aMaxBatchSize)
{
	COdbcBcpSessionAccUsageWriter* accUsage = new COdbcBcpSessionAccUsageWriter(aOdbcConnectionInfo);
	accUsage->SetUp(aOdbcConnectionInfo);
	AddWriter(accUsage);

  std::vector<boost::shared_ptr<COdbcPreparedBcpStatementCommand> > bcpStatements;
  std::vector<boost::shared_ptr<COdbcPreparedArrayStatementCommand> > arrayStatements;
  std::vector<boost::shared_ptr<COdbcPreparedInsertStatementCommand> > insertStatements;
  accUsage->GetStatementCommands(bcpStatements, arrayStatements, insertStatements);
	mAccUsageConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(aOdbcConnectionInfo, 
                               COdbcConnectionCommand::TXN_AUTO, 
                               bcpStatements.size() > 0, 
                               bcpStatements,
                               arrayStatements,
                               insertStatements));
  mOdbcManager->RegisterResourceTree(mAccUsageConnectionCommand);

	COdbcBcpSessionProductViewWriter* pv = new COdbcBcpSessionProductViewWriter(apProductView, aNameID, aOdbcConnectionInfo);
	pv->SetUp(aOdbcConnectionInfo, apProductView, aNameID);
	AddWriter(pv);

  bcpStatements.clear();
  arrayStatements.clear();
  insertStatements.clear();
  accUsage->GetStatementCommands(bcpStatements, arrayStatements, insertStatements);
	mProductViewConnectionCommand = boost::shared_ptr<COdbcConnectionCommand>(
    new COdbcConnectionCommand(aOdbcConnectionInfo, 
                               COdbcConnectionCommand::TXN_AUTO, 
                               bcpStatements.size() > 0, 
                               bcpStatements,
                               arrayStatements,
                               insertStatements));
	
  mOdbcManager->RegisterResourceTree(mProductViewConnectionCommand);
}

COdbcBcpSessionWriter::~COdbcBcpSessionWriter()
{
}

int COdbcBcpSessionWriter::GetMaxBatchSize() const
{
	return mMaxBatchSize;
}

// EOF
