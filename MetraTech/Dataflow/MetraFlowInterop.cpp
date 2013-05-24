/**************************************************************************
* METRAFLOWINTEROP
*
* Copyright 2008 by MetraTech Corp.
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
* Created by: David Blair
*
* $Date: 10/23/2002 9:55:13 AM$
* $Author: Boris$
* $Revision: 3$
***************************************************************************/

#include <sstream>
#include "MetraFlowInterop.h"
#include "ScriptInterpreter.h"
#include "UsageLoader.h"
#include "NTLogger.h"
#include "loggerconfig.h"
#include "DiscountAdapter.h"

#using <System.dll>

namespace MetraTech
{
  namespace Dataflow
  {

    MetraFlowProgramBase::MetraFlowProgramBase()
    {
    }

    void MetraFlowProgramBase::Convert(System::Data::DataTable^ table, LogicalRecord& q)
    {
      System::Type^ int32Type = System::Type::GetType("System.Int32");
      System::Type^ decimalType = System::Type::GetType("System.Decimal");
      System::Type^ datetimeType = System::Type::GetType("System.DateTime");
      System::Type^ booleanType = System::Type::GetType("System.Boolean");
      System::Type^ stringType = System::Type::GetType("System.String");
      System::Type^ int64Type = System::Type::GetType("System.Int64");

      int i = 0; 
      for each(System::Data::DataColumn^ col in table->Columns) {
        // Pin name and create std::wstring.
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(col->ColumnName);
        // Translate data types
        // TODO: Handle nullable types.
        if (col->DataType == int32Type)
        {
          q.push_back(tmpName, LogicalFieldType::Integer(col->AllowDBNull));
        }
        else if (col->DataType == decimalType)
        {
          q.push_back(tmpName, LogicalFieldType::Decimal(col->AllowDBNull));
        }
        else if (col->DataType == datetimeType)
        {
          q.push_back(tmpName, LogicalFieldType::Datetime(col->AllowDBNull));
        }
        else if (col->DataType == booleanType)
        {
          q.push_back(tmpName, LogicalFieldType::Boolean(col->AllowDBNull));
        }
        else if (col->DataType == stringType)
        {
          q.push_back(tmpName, LogicalFieldType::String(col->AllowDBNull));
        }
        else if (col->DataType == int64Type)
        {
          q.push_back(tmpName, LogicalFieldType::BigInteger(col->AllowDBNull));
        }
        else
        {
          throw gcnew System::ApplicationException("Unsupported MetraFlow data type specified in data table");
        }
        i += 1;
      }
    }

    void MetraFlowProgramBase::Convert(boost::shared_ptr<MetraFlowQueue> q, System::Data::DataTable^ table)
    {
      System::Type^ int32Type = System::Type::GetType("System.Int32");
      System::Type^ decimalType = System::Type::GetType("System.Decimal");
      System::Type^ datetimeType = System::Type::GetType("System.DateTime");
      System::Type^ booleanType = System::Type::GetType("System.Boolean");
      System::Type^ stringType = System::Type::GetType("System.String");
      System::Type^ int64Type = System::Type::GetType("System.Int64");

      const RecordMetadata& m = q->GetMetadata();
      
      std::vector<std::pair<DatabaseColumn*, int> > nativeCols;

      for (int i=0; i< table->Columns->Count; ++i) {
        System::Data::DataColumn^ col = table->Columns[i];        
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(col->ColumnName);
        DatabaseColumn * nativeCol = m.GetColumn(tmpName);
          if (col->DataType == int32Type)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 0));
          }
          else if (col->DataType == decimalType)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 1));
          }
          else if (col->DataType == datetimeType)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 2));
          }
          else if (col->DataType == booleanType)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 3));
          }
          else if (col->DataType == stringType)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 4));
          }
          else if (col->DataType == int64Type)
          {
            nativeCols.push_back(std::make_pair(nativeCol, 5));
          }
      }

      while(q->Top() != NULL)
      {
        record_t nativeRow;
        q->Pop(nativeRow);
        if (m.IsEOF(nativeRow)) 
        {
          m.Free(nativeRow);
          return;
        }
        System::Data::DataRow^ row = table->NewRow();
        for (int i=0; i< table->Columns->Count; ++i) {
          System::Data::DataColumn^ col = table->Columns[i];        
          DatabaseColumn * nativeCol = nativeCols[i].first;
          switch(nativeCols[i].second)
          {
          case 0:
          {
            row->default[col->ColumnName] = nativeCol->GetLongValue(nativeRow);
            break;
          }
          case 1:
          {
            VARIANT decVal;
            V_DECIMAL(&decVal) = *nativeCol->GetDecimalValue(nativeRow);
            V_VT(&decVal) = VT_DECIMAL;
            row->default[col->ColumnName] = System::Runtime::InteropServices::Marshal::GetObjectForNativeVariant(System::IntPtr(&decVal));
            break;
          }
          case 2:
          {
            VARIANT dtVal;
            V_DATE(&dtVal) = nativeCol->GetDatetimeValue(nativeRow);
            V_VT(&dtVal) = VT_DATE;
            row->default[col->ColumnName] = System::Runtime::InteropServices::Marshal::GetObjectForNativeVariant(System::IntPtr(&dtVal));
            break;
          }
          case 3:
          {
            row->default[col->ColumnName] = nativeCol->GetBooleanValue(nativeRow);
            break;
          }
          case 4:
          {
            row->default[col->ColumnName] = gcnew System::String(nativeCol->GetStringValue(nativeRow));
            break;
          }
          case 5:
          {
            row->default[col->ColumnName] = nativeCol->GetBigIntegerValue(nativeRow);
            break;
          }
          }
        }
        m.Free(nativeRow);
        table->Rows->Add(row);
      }
    }

    void MetraFlowProgramBase::Convert(System::Data::DataTable^ table, boost::shared_ptr<MetraFlowQueue> q)
    {
      System::Type^ int32Type = System::Type::GetType("System.Int32");
      System::Type^ decimalType = System::Type::GetType("System.Decimal");
      System::Type^ datetimeType = System::Type::GetType("System.DateTime");
      System::Type^ booleanType = System::Type::GetType("System.Boolean");
      System::Type^ stringType = System::Type::GetType("System.String");
      System::Type^ int64Type = System::Type::GetType("System.Int64");

      const RecordMetadata& m = q->GetMetadata();

      std::vector<std::pair<DatabaseColumn*, int> > nativeCols;

      for (int i=0; i< table->Columns->Count; ++i) {
        System::Data::DataColumn^ col = table->Columns[i];        
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(col->ColumnName);
        DatabaseColumn * nativeCol = m.GetColumn(tmpName);
        if (col->DataType == int32Type)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 0));
        }
        else if (col->DataType == decimalType)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 1));
        }
        else if (col->DataType == datetimeType)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 2));
        }
        else if (col->DataType == booleanType)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 3));
        }
        else if (col->DataType == stringType)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 4));
        }
        else if (col->DataType == int64Type)
        {
          nativeCols.push_back(std::make_pair(nativeCol, 5));
        }
      }

      for each(System::Data::DataRow^ row in table->Rows) {
        record_t nativeRow = m.Allocate();
        for (int i=0; i< table->Columns->Count; ++i) {
          System::Data::DataColumn^ col = table->Columns[i];        
          System::Object^ obj = row->default[col->ColumnName];
          DatabaseColumn * nativeCol = nativeCols[i].first;
          if (System::Convert::IsDBNull(obj))
          {
            nativeCol->SetNull(nativeRow);
          }
          else
          {
            switch(nativeCols[i].second)
            {
            case 0:
            {
              System::Int32^ ptr = safe_cast<System::Int32^>(obj);
              nativeCol->SetLongValue(nativeRow, *ptr);
              break;
            }
            case 1:
            {
              // Use the marshalling interfaces to convert to VARIANT, then to RuntimeValue...
              System::IntPtr pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
              System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(obj, pVariant);
              DECIMAL decVal = (DECIMAL)_variant_t(*((VARIANT *)pVariant.ToPointer()));
              System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);
              nativeCol->SetDecimalValue(nativeRow, &decVal);
              break;
            }
            case 2:
            {
              System::IntPtr pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
              System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(obj, pVariant);
              DATE dtVal = (DATE)_variant_t(*((VARIANT *)pVariant.ToPointer()));
              System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);
              nativeCol->SetDatetimeValue(nativeRow, dtVal);
              break;
            }
            case 3:
            {
              System::Boolean^ ptr = safe_cast<System::Boolean^>(obj);
              nativeCol->SetBooleanValue(nativeRow, *ptr);
              break;
            }
            case 4:
            {
              pin_ptr<const wchar_t> ptr = PtrToStringChars(safe_cast<System::String^>(obj));
              nativeCol->SetStringValue(nativeRow, ptr);
              break;
            }
            case 5:
            {
              System::Int64^ ptr = safe_cast<System::Int64^>(obj);
              nativeCol->SetBigIntegerValue(nativeRow, *ptr);
              break;
            }
            }
          }
        }
        q->Push(nativeRow);
      }

      // Terminate with EOF.
      q->Push(m.AllocateEOF());
    }

    MetraFlowProgram::MetraFlowProgram(System::String^ program, System::Data::DataSet^ inputs, System::Data::DataSet^ outputs)
    {
      mProgram = program;
      mInputDataSet = inputs;
      mOutputDataSet = outputs;
    }

    void MetraFlowProgram::Run()
    {
        NTLogger alogger;
        LoggerConfigReader configReader;
        alogger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");

      MetraFlowQueueNamingService & queueService = MetraFlowQueueNamingService::Get(); 
      // Create queues for each input dataset.
      for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
        LogicalRecord tmpLogical;
        Convert(table, tmpLogical);
        RecordMetadata tmpMetadata(tmpLogical);
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = queueService.Create(tmpName, tmpMetadata);
        // Push data from each input dataset into corresponding queue
        Convert(table, q);
      }
      
      // Create queues for each output dataset.
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        LogicalRecord tmpLogical;
        Convert(table, tmpLogical);
        RecordMetadata tmpMetadata(tmpLogical);
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = queueService.Create(tmpName, tmpMetadata);
      }

      // Execute the program.
      DataflowScriptInterpreter dsi;
      std::string utf8Program;
      {
        pin_ptr<const wchar_t> tmpProgram = PtrToStringChars(mProgram);
        ::WideStringToUTF8(tmpProgram, utf8Program);
      }
      std::istringstream programStream(utf8Program.c_str());
      std::map<std::wstring, std::vector<boost::int32_t> > partitionListDefinitions;

      try
      {
        dsi.Run(programStream, CP_UTF8, 1, false, partitionListDefinitions);
      }
      catch(std::exception& e)
      {
        NTLogger logger;
        LoggerConfigReader configReader;
        logger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");
        logger.LogThis(LOG_ERROR, e.what());
      }
      catch(...)
      {
        NTLogger logger;
        LoggerConfigReader configReader;
        logger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");
        logger.LogThis(LOG_ERROR, "Unhandled MetraFlow exception");
      }

      // Check if a parse or type-check error occurred.
      std::wstring msg;
      int lineNumber, columnNumber;
      if (dsi.didParseErrorOccur(msg, lineNumber, columnNumber))
      {
        throw gcnew MetraFlowParseException(gcnew System::String(msg.c_str()), lineNumber, columnNumber);
      }

      // Pull data from each output queue into the corresponding table.
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = queueService.Open(tmpName);
        Convert(q, table);
      }

      // Remove the queues from the naming service.
      for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        queueService.Delete(tmpName);
      }
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        queueService.Delete(tmpName);
      }
      
      // TODO: Make sure we don't leak when an exception is thrown.
      MetraFlowQueueNamingService::Release(queueService);
    }

    void MetraFlowProgram::Clear()
    {
    }

    MetraFlowPreparedProgram::MetraFlowPreparedProgram(System::String^ program, System::Data::DataSet^ inputs, System::Data::DataSet^ outputs)
    {
      mPlan = NULL;
      mProgram = program;
      mInputDataSet = inputs;
      mOutputDataSet = outputs;
      mQueueService = &MetraFlowQueueNamingService::Get(); 

      // Create queues for each input dataset.
      for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
        LogicalRecord tmpLogical;
        Convert(table, tmpLogical);
        RecordMetadata tmpMetadata(tmpLogical);
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = mQueueService->Create(tmpName, tmpMetadata);
      }
      
      // Create queues for each output dataset.
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        LogicalRecord tmpLogical;
        Convert(table, tmpLogical);
        RecordMetadata tmpMetadata(tmpLogical);
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = mQueueService->Create(tmpName, tmpMetadata);
      }

      // Prepare the program.
      std::string utf8Program;
      {
        pin_ptr<const wchar_t> tmpProgram = PtrToStringChars(mProgram);
        ::WideStringToUTF8(tmpProgram, utf8Program);
      }
      std::istringstream programStream(utf8Program.c_str());

      bool didErrorOccur;
      std::wstring errMsg;
      int lineNumber;
      int columnNumber;

      try
      {
        mPlan = new DataflowPreparedPlan(programStream, CP_UTF8, 1, false, 
                                         didErrorOccur, errMsg, lineNumber, columnNumber);
      }
      catch(std::exception& e)
      {
        // We don't expect DataflowPreparedPlan to throw an exception, but just in case...
        didErrorOccur = true;
        NTLogger logger;
        LoggerConfigReader configReader;
        logger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");
        logger.LogThis(LOG_ERROR, e.what());
      }
      catch(...)
      {
        // We don't expect DataflowPreparedPlan to throw an exception, but just in case...
        didErrorOccur = true;
        NTLogger logger;
        LoggerConfigReader configReader;
        logger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");
        logger.LogThis(LOG_ERROR, "Unhandled MetraFlow exception");
      }

      // Check if a parse or type-check error occurred.
      if (didErrorOccur)
      {
        throw gcnew MetraFlowParseException(gcnew System::String(errMsg.c_str()), lineNumber, columnNumber);
      }
    }

    MetraFlowPreparedProgram::~MetraFlowPreparedProgram()
    {
      if (mQueueService != NULL)
      {
      // Remove the queues from the naming service.
      for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        mQueueService->Delete(tmpName);
      }
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        mQueueService->Delete(tmpName);
      }
      
      MetraFlowQueueNamingService::Release(*mQueueService);
      }

      delete mPlan;
    }

    void MetraFlowPreparedProgram::Close()
    {
      if (mQueueService != NULL)
      {
        // Remove the queues from the naming service.
        for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
          pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
          mQueueService->Delete(tmpName);
        }
        for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
          pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
          mQueueService->Delete(tmpName);
        }
        MetraFlowQueueNamingService::Release(*mQueueService);
        mQueueService = NULL;
      }

      delete mPlan;
      mPlan = NULL;
    }

    void MetraFlowPreparedProgram::Run()
    {
      int result = RunVerbose();
    }

    // Runs the prepared program and 
    // returns 0 on success.
    int MetraFlowPreparedProgram::RunVerbose()
    {
      NTLogger logger;
      LoggerConfigReader configReader;
      logger.Init(configReader.ReadConfiguration("logging"), "[MetraFlowInterop]");

      for each(System::Data::DataTable^ table in mInputDataSet->Tables) {
        // Push data from each input dataset into corresponding queue
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = mQueueService->Open(tmpName);
        Convert(table, q);
      }
      
      // Assume the result of the MetraFlow run will be an error (=1).
      // If MetraFlow is successful, result will be set to 0.
      int result = 1;

      try
      {
        logger.LogThis(LOG_DEBUG, "Beginning MetraFlow script execution.");
        result = mPlan->Execute();
      }
      catch(std::exception& e)
      {
        logger.LogThis(LOG_ERROR, e.what());
      }
      catch(...)
      {
        logger.LogThis(LOG_ERROR, "Unhandled MetraFlow exception");
      }

      if (result)
      {
        logger.LogThis(LOG_ERROR, "The MetraFlow script failed.");
        return(result);
      }

      // Pull data from each output queue into the corresponding table.
      for each(System::Data::DataTable^ table in mOutputDataSet->Tables) {
        pin_ptr<const wchar_t> tmpName = PtrToStringChars(table->TableName);
        boost::shared_ptr<MetraFlowQueue> q = mQueueService->Open(tmpName);
        Convert(q, table);
      }

      return(0);
    }

    System::String^ UsageLoader::GetLoaderScript(System::String^ inputFilename,
                                                 System::String^ productViewName,
                                                 int commitSize,
                                                 int batchSize,
                                                 bool useMerge)
    {
      std::string utf8InputFilename;
      pin_ptr<const wchar_t> tmpName = PtrToStringChars(inputFilename);
      ::WideStringToUTF8(tmpName, utf8InputFilename);
      std::string utf8ProductViewName;
      tmpName = PtrToStringChars(productViewName);
      ::WideStringToUTF8(tmpName, utf8ProductViewName);
      
      std::string utf8Program = GenerateLoader(utf8InputFilename, utf8ProductViewName, commitSize, batchSize, useMerge);
      std::wstring program;
      ::ASCIIToWide(program, utf8Program);
      return gcnew System::String(program.c_str());
    }

    DiscountScriptGenerator::DiscountScriptGenerator(int usageIntervalID, int billingGroupID, int runID)
    {
      mLogger = new NTLogger();
      LoggerConfigReader configReader;
      mLogger->Init(configReader.ReadConfiguration("logging"), "[DiscountAdapter]");
      // Not currently supporting single discount mode.
      mBuilder = new DiscountAggregationScriptBuilder(*mLogger, usageIntervalID, false, -1);
      mExtractString = gcnew System::String(mBuilder->GetSubscriptionExtract(usageIntervalID, billingGroupID, runID).c_str());
    }

    DiscountScriptGenerator::DiscountScriptGenerator(System::DateTime^ startDate, System::DateTime^ endDate)
    {
      System::IntPtr pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
      System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(startDate, pVariant);
      DATE oleStartDate = (DATE)_variant_t(*((VARIANT *)pVariant.ToPointer()));
      System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);

      pVariant = System::Runtime::InteropServices::Marshal::AllocCoTaskMem(sizeof(VARIANT));
      System::Runtime::InteropServices::Marshal::GetNativeVariantForObject(endDate, pVariant);
      DATE oleEndDate = (DATE)_variant_t(*((VARIANT *)pVariant.ToPointer()));
      System::Runtime::InteropServices::Marshal::FreeCoTaskMem(pVariant);

      mLogger = new NTLogger();
      LoggerConfigReader configReader;
      mLogger->Init(configReader.ReadConfiguration("logging"), "[DiscountAdapter]");
      // Not currently supporting single discount mode.
      mBuilder = new DiscountAggregationScriptBuilder(*mLogger, -1, false, -1);
      mExtractString = gcnew System::String(mBuilder->GetSubscriptionExtract(oleStartDate, oleEndDate).c_str());
    }

    DiscountScriptGenerator::~DiscountScriptGenerator()
    {
      delete mBuilder;
      delete mLogger;
    }

    System::String^ DiscountScriptGenerator::GetExtractScript()
    {
      return mExtractString;
    }

    System::String^ DiscountScriptGenerator::GetGenerateToFileScript(System::String^ tempDir, 
                                                                     System::Collections::Generic::Dictionary<System::String^, System::String^>^ outputFiles)
    {
      pin_ptr<const wchar_t> tmpName = PtrToStringChars(tempDir);
      std::wstring wstrTempDir(tmpName);
      std::map<std::wstring, std::wstring> tmpOutputFiles;
      std::wstring counterCalculationProgram = (mBuilder->GetCounterBuilder().ReadUsage() + mBuilder->GetCounterBuilder().RouteUsage() + mBuilder->GetCounterBuilder().WriteUsage(wstrTempDir, tmpOutputFiles));
      for(std::map<std::wstring, std::wstring>::iterator it = tmpOutputFiles.begin();
          it != tmpOutputFiles.end();
          ++it)
      {
        outputFiles->Add(gcnew System::String(it->first.c_str()), gcnew System::String(it->second.c_str()));
      }
      return gcnew System::String(counterCalculationProgram.c_str());
    }

    System::String^ DiscountScriptGenerator::GetGenerateMeterScript()
    {
      return gcnew System::String(L"");
    }
  }
}
