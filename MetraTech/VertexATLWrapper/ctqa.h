/*!
 * \file ctqa.h 
 *
 * \ingroup	api
 * \ingroup	ctq
 *
 * Vertex Communications Tax (CTQ) Q Series
 *
 * Copyright &copy; 2003-2004 by Vertex, Incorporated All Rights Reserved.
 *
 * \brief Application Programmer's Interface (API) Functions Public Header File
 *
 * \note This header file is provided to customers to intergrate their
 *       telecommunications bill processing system for purposes of calculating
 *       communication tax.
 */
/* History:
 * - 20030522 JLH: Initial shell.
 * - 20030609 JLH: Renamed and reorganized as part of the framework adoption.
 * - 20030618 WD:  Added support for destination buffer maximum size when retrieving
 *                 attributes.
 * - 20030625 WD:  Added support for CtqStrError() method.
 * - 20030627 JLH: Changed CtqStrError() to CtqInquireError() for naming consistency.
 * - 20030717 WD:  Hooked methods CtqgetAttrib(), CtqSetAttrib(), CtqResetAttribs(),
 *                 CtqEditFranchiseFee() and CtqInquireFranchises() to the
 *                 Franchise Fee Rate (CtzFfr) and Franchise Fee Decision (CtzFfd) objects.
 * - 20030806 JLH: Modified for to Doxygen Qt style documentation generation.
 * - 20030910 JLH: Added CtqReportAccumulatedMaxTierTax()
 * - 20031031 WD:  Add support for revised CtzFfr/CtzFfd structure and new CtzFfl object.
 * - 20040119 JLH: Added CtqInitCtq() & ctqDeinit().
 * - 20040211 LLH: Modified a parameter name for consistency with the source definition.
 * - 20040315 WD:  Changed all references of "Service Package" to "Bundled Service".
 * - 20040315 WD:  Changed all references of "Location Tax" to "Rate", "Location Tax Rule" to "Decision".
 * - 20100426 LLH: Suppress name mangling for C++ compilers.  (OSR #940314)
 * - 20100604 LLH: Added declarations for transaction control and reverse tax functions.
 */

#ifndef CTQA_H
#define CTQA_H

#ifdef __cplusplus
extern "C" {
#endif

#include "stda.h"

/* -------------------------------------------------------------------------
   System Configuration and Attribute Management Function Prototypes.
   Detailed documentation is contained in the programmer's reference.
   ------------------------------------------------------------------------- */

PREFIX tCtqResultCode POSTFIX CtqSetUpCtq
(
    void
);

PREFIX tCtqResultCode POSTFIX CtqCleanUpCtq
(
    void
);

PREFIX tCtqResultCode POSTFIX CtqAllocCtq
(
    tCtqHandle * pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqFreeCtq
(
    tCtqHandle * pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqSetAttrib
(
    tCtqHandle     pCtqHandle,
    tCtqAttrib     pAttrib,
    void *         pValue,
    tCtqAttribType pAttribType
);

PREFIX tCtqResultCode POSTFIX CtqGetAttrib
(
    tCtqHandle     pCtqHandle,
    tCtqAttrib     pAttrib,
    void *         pValue,
    tCtqAttribType pValueType,
    int            pValueMaxSize
);

PREFIX tCtqResultCode POSTFIX CtqResetAttribs
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqConnect
(
    tCtqHandle pCtqHandle,
    tCtqHandle pCfgHandle
);

PREFIX tCtqResultCode POSTFIX CtqDisconnect
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqBeginTransaction
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqCommitTransaction
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqRollbackTransaction
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireConfig
(
    tCtqHandle pCtqHandle
);

/* -------------------------------------------------------------------------
   Location Management Function Prototypes.
   Detailed documentation is contained in the programmer's reference.
   ------------------------------------------------------------------------- */

PREFIX tCtqResultCode POSTFIX CtqInquireLocations
(
    tCtqHandle pLocHandle
);

/* -------------------------------------------------------------------------
   Calculation Management Function Prototypes.
   Detailed documentation is contained in the programmer's reference.
   ------------------------------------------------------------------------- */

PREFIX tCtqResultCode POSTFIX CtqCalculateTax
(
    tCtqHandle pTrnHandle
);

PREFIX tCtqResultCode POSTFIX CtqReverseTax
(
    tCtqHandle pCtqHandle
);

/* -------------------------------------------------------------------------
   Customization and Data Management Function Prototypes.
   Detailed documentation is contained in the programmer's reference.
   ------------------------------------------------------------------------- */

PREFIX tCtqResultCode POSTFIX CtqEditCode
(
    tCtqAction pAction,
    tCtqHandle pCtzCdeHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditDecision
(
    tCtqAction pAction,
    tCtqHandle pCtzDecHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditMaxTax
(
    tCtqAction pAction,
    tCtqHandle pCtzMaxHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditRate
(
    tCtqAction pAction,
    tCtqHandle pCtzRteHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditBundledService
(
    tCtqAction pAction,
    tCtqHandle pBspHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditFranchiseFeeRate
(
    tCtqAction pAction,
    tCtqHandle pCtzFfrHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqEditFranchiseFeeDecision
(
    tCtqAction pAction,
    tCtqHandle pCtzFfdHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireCodes
(
    tCtqHandle pCtzCdeHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireDecisions
(
    tCtqHandle pCtzRteHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireMaxTaxes
(
    tCtqHandle pCtzMaxHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireRates
(
    tCtqHandle pRteHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireBundledServices
(
    tCtqHandle pCtzBspHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireFranchiseFeeRates
(
    tCtqHandle pCtzFfrHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireFranchiseFeeDecisions
(
    tCtqHandle pCtzFfdHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireTaxJournal
(
    tCtqHandle pRegJrnHandle,
    tCtqHandle pDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportCodes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportDecisions
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportMaxTaxes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportRates
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportBundledServices
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportFranchiseFees
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqExportJournal
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportCodes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportDecisions
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportMaxTaxes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportRates
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportBundledServices
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqImportFranchiseFees
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishMonthlyUpdate
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishCodes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishDecisions
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishMaxTaxes
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishRates
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishBundledServices
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPublishFranchiseFees
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPurgeJournal
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqPurgeAccumulator
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportBundledService
(
    tCtqHandle pCtqHandle,
    tCtqBool   pPublished
);

PREFIX tCtqResultCode POSTFIX CtqReportAccumulatedMaxTierTax
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportCustomerReference
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportInvoiceReference
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportLocationSummary
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportUserArea
(
    tCtqHandle pCtqHandle
);

PREFIX tCtqResultCode POSTFIX CtqReportReversed
(
    tCtqHandle pCtqHandle
);

/* -------------------------------------------------------------------------
   General System Support and Public Utility Function Prototypes.
   Detailed documentation is contained in the programmer's reference.
   ------------------------------------------------------------------------- */

PREFIX tCtqResultCode POSTFIX CtqInquireAdminLog
(
    tCtqHandle pCtqAdmPerHandle,
    tCtqHandle pCtqDbcPerHandle
);

PREFIX tCtqResultCode POSTFIX CtqInquireResultCode
(
    tCtqResultCode pCode,
    char *         pIdentifier,
    int            pIdentifierSize,
    char *         pDescription,
    int            pDescriptionSize
);

#ifdef __cplusplus
}
#endif

#endif /* CTQA_H */
