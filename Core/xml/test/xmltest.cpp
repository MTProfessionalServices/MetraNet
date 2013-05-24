/**************************************************************************
 * @doc
 *
 * Copyright 1998 by MetraTech Corporation
 * All rights reserved.
 *
 * THIS SOFTWARE IS PROVIDED "AS IS", AND MetraTech Corporation MAKES
 * NO REPRESENTATIONS OR WARRANTIES, EXPRESS OR IMPLIED. By way of
 * example, but not limitation, MetraTech Corporation MAKES NO
 * REPRESENTATIONS OR WARRANTIES OF MERCHANTABILITY OR FITNESS FOR ANY
 * PARTICULAR PURPOSE OR THAT THE USE OF THE LISCENCED SOFTWARE OR
 * DOCUMENTATION WILL NOT INFRINGE ANY THIRD PARTY PATENTS,
 * COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 *
 * Title to copyright in this software and any associated
 * documentation shall at all times remain with MetraTech Corporation,
 * and USER agrees to preserve the same.
 *
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/
#include <metralite.h>
#pragma warning( disable : 4786 )
#include <mtcom.h>

#include <XMLParser.h>

#include <stdio.h>
#include <perf.h>
#include <errutils.h>

#include <genparser.h>
// for generate test
#include <mtprogids.h>
#include <pipelineconfig.h>
#include <generate.h>
#include <propids.h>

#define TEST_DOM

#ifdef TEST_DOM
#include <mtcom.h>
#include <metra.h>

#import <msxml3.dll> 


ComInitialize gComInit;
#endif


#include <string>
#include <list>

#include <strstream>
#include <iostream>

#ifdef WIN32
#include <expandfilelist.h>
#endif // WIN32

using namespace std;



#define READ_SIZE 1024

class XMLTest : public XMLParser
{
public:
	void PrintError();

	int ProcessStream(FILE * aIn);

	BOOL VerifyParser(const char * apTestFile);


	BOOL RunTestSuite(int argc, char * argv[]);

private:
	void GetFileList(list<string> & arFilenames, int argc, char * argv[]);
};

void XMLTest::PrintError()
{
	int code, line, column;
	long byteIndex;
	const char * message;

	GetErrorInfo(code, message, line, column, byteIndex);

	cerr << "error: " << message << ": line#" << line << " column#" << column << endl;
}

void XMLTest::GetFileList(list<string> & arFilenames, int argc, char * argv[])
{
	for (int i = 1; i < argc; i++)
	{
		const char * filename = argv[i];

#ifdef WIN32
		ExpandFileList(arFilenames, filename);
#else
		string name(filename);
		arFilenames.push_back(name);
#endif // WIN32
	}
}

BOOL XMLTest::VerifyParser(const char * apTestFile)
{
	Restart();

	FILE * in = fopen(apTestFile, "r");
	if (!in)
	{
		cerr << "Unable to open file " << apTestFile << endl;
		return FALSE;
	}

	string inputString;

	XMLObject * results;
	while (TRUE)
	{
		int nread;
		char *buf = GetBuffer(READ_SIZE);

		if (!buf)
		{
			cerr << "Unable to get buffer from parser." << endl;
			return FALSE;
		}

		nread = fread(buf, sizeof(char), READ_SIZE, in);
		if (nread < 0)
		{
			cerr << "Unable to read bytes from file." << endl;
			fclose(in);
			return FALSE;
		}

		inputString.append(buf, nread);

		BOOL result;
		if (nread == 0)
			result = ParseBufferFinal(nread, &results);
		else
			result = ParseBuffer(nread);

		if (!result)
		{
			cerr << "Parse error reading file." << endl;
			PrintError();
			fclose(in);
			return FALSE;
		}

		if (nread == 0)
			break;
	}

	fclose(in);

	//
	// test the in mem output writer
	//
	XMLWriter stringWrite;
	results->Output(stringWrite);
	const char * buffer;
	int bufferLen;
	stringWrite.GetData(&buffer, bufferLen);

	string memOutputString(buffer, bufferLen);

	// no longer need the output
	delete results;

	if (0 != memOutputString.compare(inputString))
	{
		cerr << "Input and memory output contents do not match." << endl;
		cerr << "INPUT: length = " << inputString.length() << endl;
		cerr << inputString.c_str() << endl;
		cerr << "OUTPUT: length = " << memOutputString.length() << endl;
		cerr << memOutputString.c_str() << endl;
		return FALSE;
	}

	return TRUE;
}

BOOL XMLTest::RunTestSuite(int argc, char * argv[])
{
	list<string> filenames;
	GetFileList(filenames, argc, argv);
	list<string>::const_iterator it;

	cout << "Verifying parser:" << endl;

	for (it = filenames.begin(); it != filenames.end(); it++)
	{
		const string & name = *it;
		cout << "File " << name.c_str() << " ... ";

		if (!VerifyParser(name.c_str()))
		{
			cout << "FAILED" << endl;
			cerr << "Parser verification failed on file " << name.c_str() << endl;
			return FALSE;
		}
		else
			cout << "passed." << endl;
	}

	return TRUE;
}

int XMLTest::ProcessStream(FILE * aIn)
{
	XMLObject * results;
	while (1)
	{
		int nread;
		char *buf = GetBuffer(READ_SIZE);

		if (!buf)
		{
			cerr << "out of memory" << endl;
			return 0;
		}

		nread = fread(buf, sizeof(char), READ_SIZE, aIn);
		if (nread < 0)
		{
			perror("reading");
			return 0;
		}

		BOOL result;
		if (nread == 0)
		{
			result = ParseBufferFinal(nread, &results);
		}
		else
		{
			result = ParseBuffer(nread);
		}

		if (!result)
		{
			PrintError();
			return 0;
		}

		if (nread == 0)
			break;
	}

	if (VerifyChecksum() == TRUE)
	{
		cout << "Checksum: " << GetChecksum() << endl;
	}
	else
	{
		cout << "Checksum does not match" << endl;
	}

//	cout << "results: " << endl << *results << endl;


	cout << "============" << endl;

	XMLWriter stringWrite;
	results->Output(stringWrite);

	const char * rawBuffer;
	int bufferLen;
	stringWrite.GetData(&rawBuffer, bufferLen);
	string buffer(rawBuffer, bufferLen);
	cout << buffer.c_str() << endl;

	delete results;

	return 1;
}


int speedtestit(XMLTest & test, const char * apFilename)
{
	cout << "Processing." << endl;

	int ourFile = 0;
	FILE * in = stdin;
	if (apFilename)
	{
		in = fopen(apFilename, "r");
		if (!in)
		{
			perror(apFilename);
			return 1;
		}
		ourFile = 1;
		cout << "Input file name: " << apFilename << endl;
	}


//	test.out = &cout;

	std::string buffer;
	while (1)
	{
		int nread;
		char *buf = test.GetBuffer(READ_SIZE);

		if (!buf)
		{
			cerr << "out of memory" << endl;
			return 0;
		}

		nread = fread(buf, sizeof(char), READ_SIZE, in);
		if (nread < 0)
		{
			perror("reading");
			return 0;
		}

		if (nread == 0)
			break;

		buf[nread] = '\0';
		buffer += buf;
	}

	if (ourFile)
		fclose(in);


	const int MTXML_REPEAT_COUNT = 0;
	const int MSXML_REPEAT_COUNT = 0;
	const int RAWXML_REPEAT_COUNT = 0;
	const int GENERATE_REPEAT_COUNT = 0;
	const int PIPELINEXML_REPEAT_COUNT = 100;
	const int PIPELINEXMLVALIDATE_REPEAT_COUNT = 100;

	long frequency;
	GetPerformanceTickCountFrequency(frequency);

	__int64 ticks;
	PerformanceTickCount initialTicks;
	PerformanceTickCount finalTicks;

	// --------------------------------------------------

	if (MTXML_REPEAT_COUNT > 0)
	{
		GetCurrentPerformanceTickCount(&initialTicks);

		for (int i = 0; i < MTXML_REPEAT_COUNT; i++)
		{
			XMLObject * results;
			BOOL result = test.ParseFinal(buffer.c_str(), buffer.length(), &results);

			if (!result)
			{
				test.PrintError();
				return 0;
			}
			delete results;
			test.Restart();
		}

		GetCurrentPerformanceTickCount(&finalTicks);

		ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("-------- MT XML parser --------\n");
		printf("transactions: %d\n", MTXML_REPEAT_COUNT);
		printf("ticks: %d\n", ticks);
		printf("TPS: %f\n", (((double) MTXML_REPEAT_COUNT / (double) ticks) * (double) frequency));
	}


	// --------------------------------------------------

	if (MSXML_REPEAT_COUNT > 0)
	{
		MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");

		GetCurrentPerformanceTickCount(&initialTicks);

		for (int i = 0; i < MSXML_REPEAT_COUNT; i++)
		{
			domdoc->PutvalidateOnParse(VARIANT_TRUE);
			domdoc->Putasync(FALSE);

			domdoc->loadXML(buffer.c_str());

			// verify that the XML is intact
			MSXML2::IXMLDOMParseErrorPtr aError = domdoc->GetparseError();
			if(aError->GeterrorCode() != 0) {
				_bstr_t aTempErrStr = "Error: ";
				aTempErrStr += aError->Getreason();
				aTempErrStr += " on line ";
				char buffer[20];
				ltoa(aError->Getline(),buffer,10);
				aTempErrStr += buffer;
				return FALSE;
			}
		}

		GetCurrentPerformanceTickCount(&finalTicks);

		ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("--------  MS XML parser --------\n");
		printf("transactions: %d\n", MSXML_REPEAT_COUNT);
		printf("ticks: %d\n", ticks);
		printf("TPS: %f\n", (((double) MSXML_REPEAT_COUNT / (double) ticks) * (double) frequency));
	}

	// --------------------------------------------------

	if (RAWXML_REPEAT_COUNT > 0)
	{
		GetCurrentPerformanceTickCount(&initialTicks);

		// @cmember reference to xmltok parser
		XML_Parser mParser;
		mParser = XML_ParserCreate(NULL);

		for (int i = 0; i < RAWXML_REPEAT_COUNT; i++)
		{
			// last param is is final
			BOOL res = XML_Parse(mParser, buffer.c_str(), buffer.length(), TRUE);

			XML_ParserFree(mParser);
			mParser = NULL;
			mParser = XML_ParserCreate(NULL);
		}

		GetCurrentPerformanceTickCount(&finalTicks);

		ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("--------  raw XML parser --------\n");
		printf("transactions: %d\n", RAWXML_REPEAT_COUNT);
		printf("ticks: %d\n", ticks);
		printf("TPS: %f\n", (((double) RAWXML_REPEAT_COUNT / (double) ticks) * (double) frequency));
	}

	// --------------------------------------------------

	ComInitialize cominit;
	if (PIPELINEXML_REPEAT_COUNT > 0)
	{
		PipelineMSIXParser<SharedMemorySessionBuilder> pipelineParser;
		if (!pipelineParser.InitForParse())
		{
			cout << "Unable to init" << endl;
			return 0;
		}

		GetCurrentPerformanceTickCount(&initialTicks);

		pipelineParser.SetupParser();


		std::vector<MTPipelineLib::IMTSessionPtr> sessions;
		for (int i = 0; i < PIPELINEXML_REPEAT_COUNT; i++)
		{
			sessions.clear();
			ValidationData validationData;
			SharedMemorySessionProduct * results = NULL;
			if (!pipelineParser.Parse(buffer.c_str(), buffer.length(), (ISessionProduct**) &results,
																validationData))
			{
				std::string errorBuffer;
				StringFromError(errorBuffer, "error", pipelineParser.GetLastError());
				printf("%s\n", errorBuffer.c_str());
				return 0;
			}

			delete results;

			pipelineParser.SetupParser();
		}

		GetCurrentPerformanceTickCount(&finalTicks);

		ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("-------- pipeline XML parser --------\n");
		printf("transactions: %d\n", PIPELINEXML_REPEAT_COUNT);
		printf("ticks: %d\n", ticks);
		printf("frequency: %d\n", frequency);
		printf("count / ticks = %f\n", (double) PIPELINEXML_REPEAT_COUNT / (double) ticks);
		printf("TPS: %f\n", (((double) PIPELINEXML_REPEAT_COUNT / (double) ticks) * (double) frequency));
	}

	if (PIPELINEXMLVALIDATE_REPEAT_COUNT > 0)
	{
		PipelineMSIXParser<SharedMemorySessionBuilder> pipelineParser;
		if (!pipelineParser.InitForValidate())
		{
			cout << "Unable to init" << endl;
			return 0;
		}

		GetCurrentPerformanceTickCount(&initialTicks);

		pipelineParser.SetValidateOnly(TRUE);
		pipelineParser.SetupParser();

		for (int i = 0; i < PIPELINEXML_REPEAT_COUNT; i++)
		{
			ValidationData validationData;
			ISessionProduct** results = NULL;
			if (!pipelineParser.Validate(buffer.c_str(), buffer.length(), results, validationData))
			{
				std::string errorBuffer;
				StringFromError(errorBuffer, "error", pipelineParser.GetLastError());
				printf("%s\n", errorBuffer.c_str());
				return 0;
			}

			pipelineParser.SetupParser();
		}

		GetCurrentPerformanceTickCount(&finalTicks);

		ticks = PerformanceCountTicks(&initialTicks, &finalTicks);
		printf("-------- pipeline XML validate --------\n");
		printf("transactions: %d\n", PIPELINEXML_REPEAT_COUNT);
		printf("ticks: %d\n", ticks);
		printf("frequency: %d\n", frequency);
		printf("count / ticks = %f\n", (double) PIPELINEXML_REPEAT_COUNT / (double) ticks);
		printf("TPS: %f\n", (((double) PIPELINEXML_REPEAT_COUNT / (double) ticks) * (double) frequency));
	}

	return 0;
}


int testit(XMLTest & test, const char * apFilename)
{
	cout << "Processing." << endl;

	int ourFile = 0;
	FILE * in = stdin;
	if (apFilename)
	{
		in = fopen(apFilename, "r");
		if (!in)
		{
			perror(apFilename);
			return 1;
		}
		ourFile = 1;
		cout << "Input file name: " << apFilename << endl;
	}

//	test.out = &cout;
	if (!test.ProcessStream(in))
	{
		cerr << "Input file name: " << apFilename << endl;
	}

	if (test.VerifyChecksum() == TRUE)
	{
		cout << "Checksum match" << endl;
		cout << "Checksum: " << test.GetChecksum() << endl;
	}
	else
	{
		cout << "Checksum does not match: test.GetChecksum()" << endl;
	}

	if (ourFile)
		fclose(in);

	return 0;
}

int main(int argc, char **argv)
{
	XMLTest test;
	if (!test.Init(NULL, TRUE))
		return FALSE;

	if (argc == 1)
	{
		cout << "usage: " << argv[0] << " filepattern" << endl;
		cout << "    or " << argv[0] << " -test filename" << endl;
		cout << "    or " << argv[0] << " -speedtest filename" << endl;
		cout << "    first usage runs the test suite validation on the given files" << endl;
		cout << "    second usage runs the parser and prints test output" << endl;
		return 1;
	}

	if (argc == 3 && 0 == strcmp(argv[1], "-test"))
	{
		testit(test, argv[2]);
		return 0;
	}
	else if (argc == 3 && 0 == strcmp(argv[1], "-speedtest"))
	{
		speedtestit(test, argv[2]);
		return 0;
	}

	if (!test.RunTestSuite(argc, argv))
		cerr << "Test suit failed" << endl;

	return 0;
}

