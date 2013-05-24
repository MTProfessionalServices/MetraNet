/**************************************************************************
* @doc METRAFLOWINTEROP
*
* @module |
*
*
* Copyright 2008 by MetraTech Corporation
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
* $Date$
* $Author$
* $Revision$
*
* @index | METRAFLOWINTEROP
***************************************************************************/

#ifndef _METRAFLOWINTEROP_H
#define _METRAFLOWINTEROP_H

#ifdef WIN32
// only include this header one time
#pragma once
#endif

#include <vcclr.h>

#include "RecordModel.h"
#include "MetraFlowQueue.h"
#include "Taxware.h"

class DataflowPreparedPlan;
class MetraFlowQueueNamingService;
class DiscountAggregationScriptBuilder;

#using <System.Data.dll>

namespace MicrosoftOnline
{
  namespace Custom
  {
    namespace Taxware
    {
      [System::Runtime::InteropServices::ComVisible(false)]
      public ref class VeraZip
      {
      private:
        TaxwareUniversalTaxLink * mTaxware;
      public:
        VeraZip()
        {
          mTaxware = TaxwareUniversalTaxLink::GetInstance();
        }
        ~VeraZip()
        {
          TaxwareUniversalTaxLink::ReleaseInstance(mTaxware);
        }
        int VerifyZip(System::String^ stateCode, System::String^ zipCode, System::String^ cityCode)
        {
          char* stateCode2 = (char*) System::Runtime::InteropServices::Marshal::StringToHGlobalAnsi(stateCode).ToPointer();
          char* zipCode2 = (char*) System::Runtime::InteropServices::Marshal::StringToHGlobalAnsi(zipCode).ToPointer();
          char* cityCode2 = (char*) System::Runtime::InteropServices::Marshal::StringToHGlobalAnsi(cityCode).ToPointer();
          int ret = mTaxware->VerifyZip(stateCode2, zipCode2, cityCode2);
          System::Runtime::InteropServices::Marshal::FreeHGlobal((System::IntPtr)stateCode2);
          System::Runtime::InteropServices::Marshal::FreeHGlobal((System::IntPtr)zipCode2);
          System::Runtime::InteropServices::Marshal::FreeHGlobal((System::IntPtr)cityCode2);
          return ret;
        }
      };
    }
  }
}

namespace MetraTech
{
  namespace Dataflow
  {
  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class MetraFlowProgramBase
    {
    protected:
      // Transform input and output DataTable metadata into MF record metadata.
      // Note that this does not support use of MetraTech enums.
      static void Convert(System::Data::DataTable^ table, LogicalRecord& q);
      // Read from the queue, convert to a System::Data::DataRow and add to table.
      static void Convert(boost::shared_ptr<MetraFlowQueue> q, System::Data::DataTable^ table);
      // Loop over rows in the data table, convert to MetraFlow and enqueue.
      static void Convert(System::Data::DataTable^ table, boost::shared_ptr<MetraFlowQueue> q);

      MetraFlowProgramBase();
    };   

  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class MetraFlowProgram : MetraFlowProgramBase
    {
    private:
      System::String^ mProgram;
      System::Data::DataSet^ mInputDataSet;
      System::Data::DataSet^ mOutputDataSet;
      
    public:
      /// <summary>
      /// Client must create both the input data tables and the output data tables.  The input data tables
      /// should have appropriate rows added to them prior to calling <c>Run()</c>
      /// </summary>
      MetraFlowProgram(System::String^ program, System::Data::DataSet^ inputs, System::Data::DataSet^ outputs);
      /// <summary>
      /// Run the program on the current inputs and generate outputs.
      /// </summary>
      void Run();
      /// <summary>
      /// The internal state of the program so that it may be <c>Run()</c> again.
      /// ???Should this clear the state of the data tables???
      /// </summary>
      void Clear();
      /// <summary>
      /// The input data set from which the program will access data.
      /// </summary>
      property System::Data::DataSet^ InputDataSet
      {
        System::Data::DataSet^ get() { return mInputDataSet; }
      }
      /// <summary>
      /// The output data set containing the System.Data.DataTable instance to which outputs will
      /// be written.
      /// </summary>
      property System::Data::DataSet^ OutputDataSet
      {
        System::Data::DataSet^ get() { return mOutputDataSet; }
      }
    };   

  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class MetraFlowPreparedProgram : MetraFlowProgramBase
    {
    private:
      System::String^ mProgram;
      System::Data::DataSet^ mInputDataSet;
      System::Data::DataSet^ mOutputDataSet;
      DataflowPreparedPlan * mPlan;
      MetraFlowQueueNamingService * mQueueService;
      
    public:
      /// <summary>
      /// Client must create both the input data tables and the output data tables.  The input and output data tables
      /// should have the same format as those called during <c>Run()</c>
      /// </summary>
      MetraFlowPreparedProgram(System::String^ program, System::Data::DataSet^ inputs, System::Data::DataSet^ outputs);
      ~MetraFlowPreparedProgram();
      void Close();

      /// <summary>
      /// Run the program on the current inputs and generate outputs.
      /// </summary>
      void Run();

      /// <summary>
      /// Run the program on the current inputs and generate outputs.
      /// Returns 0 on success.
      /// </summary>
      int RunVerbose();

      /// <summary>
      /// The input data set from which the program will access data.
      /// </summary>
      property System::Data::DataSet^ InputDataSet
      {
        System::Data::DataSet^ get() { return mInputDataSet; }
      }
      /// <summary>
      /// The output data set containing the System.Data.DataTable instance to which outputs will
      /// be written.
      /// </summary>
      property System::Data::DataSet^ OutputDataSet
      {
        System::Data::DataSet^ get() { return mOutputDataSet; }
      }
    };   

  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class UsageLoader
    {
    public:
      // Generate a MetraFlowProgram in MetraFlowScript for loading data into product views.
      static System::String^ GetLoaderScript(System::String^ inputFilename,
                                             System::String^ productViewName,
                                             int commitSize,
                                             int batchSize,
                                             bool useMerge);
    };   

  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class DiscountScriptGenerator
    {
    private:
      NTLogger * mLogger;
      DiscountAggregationScriptBuilder * mBuilder;
      System::String^ mExtractString;
    public:
      // Generate MetraFlow programs for generate, rating and loading discounts in billing modes.
      DiscountScriptGenerator(int usageIntervalID, int billingGroupID, int runID);
      // Generate MetraFlow programs for generate, rating and loading discounts in billing modes.
      DiscountScriptGenerator(System::DateTime^ startDate, System::DateTime^ endDate);
      ~DiscountScriptGenerator();
      // Get script for extracting subscription data from database.
      System::String^ GetExtractScript();
      // Get script for generating discounts and landing to file.
      System::String^ GetGenerateToFileScript(System::String^ tempDir, System::Collections::Generic::Dictionary<System::String^, System::String^>^ outputFiles);
      // Get script for generating discounts and metering to pipelines.
      System::String^ GetGenerateMeterScript();
    };   

    ///<summary>An exception reporting an MetraFlow error that occurred during
    ///         the parsing, or type-checking evaluation of the script.
    ///         To access the error message text use the property Message.
    ///</summary>
  	[System::Runtime::InteropServices::ComVisible(false)]
    public ref class MetraFlowParseException : System::ApplicationException
    {
    private:
      int mLineNumber;
      int mColumnNumber;

    private:
      MetraFlowParseException(){};
      
    public:
      MetraFlowParseException(System::String^ message, 
                              int lineNumber, 
                              int columnNumber) 
          : mLineNumber(lineNumber), 
            mColumnNumber(columnNumber), 
            ApplicationException(message){};

      ~MetraFlowParseException(){};

      ///<summary>The line number where the error occurred. Will be <= 0 if
      ///         the line is not known.
      ///</summary>
      property int LineNumber
      {
        int get() { return mLineNumber; }
      }

      ///<summary>The column number where the error occurred. Will be <= 0 if
      ///         the column is not known.
      ///</summary>
      property int ColumnNumber
      {
        int get() { return mColumnNumber; }
      }
      
    };   
  }
}


#endif /* METRAFLOWINTEROP_H */
