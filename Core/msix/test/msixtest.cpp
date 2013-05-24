/**************************************************************************
 * @doc MSIXTEST
 *
 * Copyright 1998 by MetraTech Corporation
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
 * Created by: Derek Young
 * $Header$
 ***************************************************************************/

// uncomment this line to test Microsoft XML DOM as well
#define TEST_DOM

#ifdef TEST_DOM
#include <mtcom.h>
#include <metra.h>

#import <msxml3.dll> 


ComInitialize gComInit;
#endif

#include <MSIX.h>
#include <stdio.h>




#ifdef WIN32
#include <strstream>
#else 
#include <strstream.h>
#endif

#include <iostream>

using namespace std;

#define READ_SIZE 1024

static void ParseString(XMLParser & arParser, const char * apStr, BOOL aPrintResults);
static BOOL TimeTest(XMLParser & arParser, const char * apInput, int aParses);
static BOOL ParserTest(const char * apFilename, int aXMLParses, int aMSIXParses);



/******************************************** MSIXTestParser ***/

class MSIXTestParser : public XMLParser
{
private:
	void PrintError();

public:
	MSIXTestParser()
	{
		SetObjectFactory(&mFactory);
	}

	int ProcessStream(FILE * aIn);

	BOOL TestReadWrite(XMLObject * obj);

	MSIXObjectFactory mFactory;
};

/********************************************* MSIXUidTester ***/

class MSIXUidTester : public MSIXUidGenerator
{
public:
	static unsigned char * GetUid()
	{
		// TODO: this field was removed..
		ASSERT(0);
		return NULL;
		//return msUid;
	}
};



DWORD Ticks()
{
#ifdef WIN32
  return ::GetTickCount();
#endif
#ifdef UNIX
  struct timeb now;

  ftime(&now);

  return (DWORD) (now.millitm + 1000 * now.time);
#endif
}

void MSIXTestParser::PrintError()
{
	int code, line, column;
	long byteIndex;
	const char * message;

	GetErrorInfo(code, message, line, column, byteIndex);

	cerr << "error: " << message << ": line#" << line << " column#" << column << endl;
}


/******************************************** MSIXTestParser ***/

BOOL MSIXTestParser::TestReadWrite(XMLObject * obj)
{
#ifdef WIN32
	strstream buffer;
#else
	ostrstream buffer;
#endif

	// output to the buffer
//	buffer << *obj;

	// make a copy
	std::string output(buffer.str(), (unsigned int) buffer.pcount()); 
	//output.assign(buffer.str(), buffer.pcount());

	//cout << '{' << output.c_str() << '}';

	// parse the buffer again
	XMLObject * reparse;
	if (!ParseFinal(output.c_str(), output.length(), &reparse))
	{
		cerr << "could not reparse buffer." << endl;
		PrintError();
		return FALSE;
	}

	ASSERT(reparse);

	buffer.clear();

	// write it back to the buffer
//	buffer << *reparse;

	delete reparse;

	// make a copy
	std::string output2(buffer.str(), (unsigned int) buffer.pcount());

	// I'm not sure why this delete is necessary.
	// you would think strstream would delete its own buffer
	delete buffer.str();

	return (0 == output.compare(output2));
}


int MSIXTestParser::ProcessStream(FILE * aIn)
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
			result = ParseBufferFinal(nread, &results);
		else
			result = ParseBuffer(nread);
			
		if (!result)
		{
			PrintError();
			return 0;
		}

    if (nread == 0)
      break;
  }

	cout << endl << "Results: " << endl;
	cout << "Long tags: " << endl;
	MSIXObject::UseLongTags();
//	cout << *results << endl;

	cout << "Short tags: " << endl;
	MSIXObject::UseShortTags();
//	cout << *results << endl;


	MSIXObject::UseLongTags();
	Restart();
	if (TestReadWrite(results))
		cout << "Long tag read/write succeeded." << endl;
	else
		cout << "LONG TAG READ/WRITE FAILED!" << endl;


	MSIXObject::UseShortTags();
	Restart();
	if (TestReadWrite(results))
		cout << "Short tag read/write succeeded." << endl;
	else
		cout << "SHORT TAG READ/WRITE FAILED!" << endl;

	delete results;
	
  return 1;
}

/*************************************************** globals ***/

#include <objectpool.h>

typedef ObjectPool<class Temp, 10> TempPool;

class Temp
{
public:
	int aValue;

	Temp()
	{
		aValue = 10;
	}

	~Temp()
	{
		aValue = 100;
	}

public:
	void* operator new(unsigned int nSize);

	void operator delete(void* apObj);

};

static ObjectPool<Temp, 10> gTempObjectPool;

void* Temp::operator new(unsigned int nSize)
{
	ASSERT(nSize == sizeof(Temp));
	// allocate from the pool
	Temp * obj = gTempObjectPool.CreateElement();

	if (!obj)
	{
		// pool is full - allocate from global heap
		obj = (Temp *) ::operator new(nSize);
		ASSERT(obj);
	}

	// explicitly call the constructor
	// TODO: do this?
//	obj->Temp::Temp();

	return obj;
}

void Temp::operator delete(void* apObj)
{
	Temp * obj = (Temp *) apObj;

	// explicitly call the destructor
	// TODO: do this?
//	obj->Temp::~Temp();

	if (!gTempObjectPool.DeleteElement(obj))
	{
		// release from global heap
		::operator delete(obj);
	}
}


static BOOL TestObjectPool()
{
	Temp * t[2];
	for (int i = 0; i < sizeof(t) / sizeof(t[0]); i++)
	{
		t[i] = new Temp;
	}

	for (i = 0; i < sizeof(t) / sizeof(t[0]); i++)
	{
		delete t[i];
	}

	return TRUE;
}

static BOOL TimeTest(XMLParser & arParser, const char * apInput, int aParses)
{
	if (!arParser.Init())
	{
		cerr << "Unable to initialize." << endl;
		return FALSE;
	}


	DWORD ticks = Ticks();
	for (int i = 0; i < aParses; i++)
		// only print the output if they run the test once
		ParseString(arParser, apInput, aParses == 1);

	DWORD end = Ticks();

	cout << "Test complete." << endl;
	cout << "parses: " << aParses << endl;
	cout << "ticks: " << (end - ticks) << endl;
	cout << "seconds: " << ((end - ticks) / 1000.0) << endl;
	cout << "parses/sec: " << (((double)aParses) / ((end - ticks) / 1000.0)) << endl;
	return TRUE;
}

#ifdef TEST_DOM
static BOOL TimeXMLDOM(const char * apInput, int aParses)
{
	MSXML2::IXMLDOMDocumentPtr domdoc("Microsoft.XMLDOM");

	DWORD ticks = Ticks();
	for (int i = 0; i < aParses; i++)
	{

		domdoc->PutvalidateOnParse(VARIANT_TRUE);
		domdoc->Putasync(FALSE);


		// only print the output if they run the test once
		domdoc->loadXML(apInput);

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

	DWORD end = Ticks();

	cout << "Test complete." << endl;
	cout << "parses: " << aParses << endl;
	cout << "ticks: " << (end - ticks) << endl;
	cout << "seconds: " << ((end - ticks) / 1000.0) << endl;
	cout << "parses/sec: " << (((double)aParses) / ((end - ticks) / 1000.0)) << endl;



	// Set aXmlDoc= CreateObject("Microsoft.XMLDOM")
	// aXmlDoc.validateOnParse = true
	// aXmlDoc.async = false
	// wscript.echo wscript.arguments(0)
	// Result = aXmlDoc.Load(wscript.arguments(0))
	// wscript.echo "Load returned " & Result
	// if Result = False then
	//   wscript.echo aXmlDoc.parseError.reason
	// end if
	return TRUE;
}
#endif

static BOOL ParserTest(const char * apFilename, int aXMLParses, int aMSIXParses)
{
	cout << "Processing." << endl;

	BOOL ourFile = FALSE;
	FILE * in = NULL;
	if (apFilename)
	{
		in = fopen(apFilename, "r");
		if (!in)
		{
			perror(apFilename);
			return FALSE;
		}
		ourFile = TRUE;
		cout << "Input file name: " << apFilename << endl;
	}
	else
		in = stdin;
				

	std::string input;
	char buf[1024];
	while (1)
	{
		int nread = fread(buf, sizeof(char), sizeof(buf), in);
		if (nread == 0)
			break;
		input.append(buf, nread);
	}

	if (ourFile)
		fclose(in);


	if (aXMLParses > 0)
	{
		cout << "Running test with XML object factory..." << endl;

		XMLParser parser;
		if (!TimeTest(parser, input.c_str(), aXMLParses))
			return FALSE;
	}

	if (aMSIXParses > 0)
	{
		cout << "Running test with MSIX object factory..." << endl;

		MSIXTestParser test;
		if (!TimeTest(test, input.c_str(), aMSIXParses))
			return FALSE;
	}

#ifdef TEST_DOM
	if (aMSIXParses > 0)
	{
		cout << "Running test with MSXML DOM..." << endl;

		if (!TimeXMLDOM(input.c_str(), aMSIXParses))
			return FALSE;
	}
#endif

	return TRUE;
}


#if 0


int testparse(int argc, char * * argv)
{
	cout << "Processing." << endl;

	int ourFile = 0;
	FILE * in = stdin;
	if (argc > 1)
	{
		in = fopen(argv[1], "r");
		if (!in)
		{
			perror(argv[1]);
			return 1;
		}
		ourFile = 1;
		cout << "Input file name: " << argv[1] << endl;
	}
				

	std::string input;
	char buf[1024];
	while (1)
	{
		int nread = fread(buf, sizeof(char), sizeof(buf), in);
		if (nread == 0)
			break;
		input.append(buf, nread);
	}

	if (ourFile)
		fclose(in);



	DWORD ticks;
	int i;
	int parses = 100;
	DWORD end;

#if 0
	XMLParser parser;
	if (!parser.Init())
	{
		cerr << "Unable to initialize." << endl;
		return -1;
	}

	cout << "Running test with default object factory..." << endl;
	ticks = Ticks();
	for (i = 0; i < parses; i++)
		ParseString(parser, input);

	end = Ticks();

	cout << "Test complete." << endl;
	cout << "parses: " << parses << endl;
	cout << "ticks: " << (end - ticks) << endl;
	cout << "seconds: " << ((end - ticks) / 1000.0) << endl;
	cout << "parses/sec: " << (((double)parses) / ((end - ticks) / 1000.0)) << endl;
#endif	



	MSIXTestParser test;
	if (!test.Init())
	{
		cerr << "Unable to initialize." << endl;
		return -1;
	}

	cout << "Running test with MSIX object factory..." << endl;
	ticks = Ticks();
	for (i = 0; i < parses; i++)
		ParseString(test, input);

#ifdef WIN32
  end = Ticks();
#endif

	cout << "Test complete." << endl;
	cout << "parses: " << parses << endl;
	cout << "ticks: " << (end - ticks) << endl;
	cout << "seconds: " << ((end - ticks) / 1000.0) << endl;
	cout << "parses/sec: " << (((double)parses) / ((end - ticks) / 1000.0)) << endl;

	return 0;
}

#endif

void ParseString(XMLParser & arParser, const char * apStr, BOOL aPrintResults)
{
	arParser.Restart();

	XMLObject * results;
	BOOL result = arParser.ParseFinal(apStr, strlen(apStr), &results);

	ASSERT(results);

//	if (aPrintResults)
//		cout << *results;

	delete results;
}


int testit(int argc, char * * argv)
{
	MSIXTestParser test;
	cout << "Initializing." << endl;
	if (!test.Init())
	{
		cerr << "Unable to initialize." << endl;
		return -1;
	}

	cout << "Processing." << endl;

	int ourFile = 0;
	FILE * in = stdin;
	if (argc > 1)
	{
		in = fopen(argv[1], "r");
		if (!in)
		{
			perror(argv[1]);
			return 1;
		}
		ourFile = 1;
		cout << "Input file name: " << argv[1] << endl;
	}
				
//	test.out = &cout;
	test.ProcessStream(in);

	if (ourFile)
		fclose(in);

	return 0;
}

#if 0
void testuids()
{
	MSIXUidTester tester;
	for (int i = 0; i < 20; i++)
	{
		Sleep(500);

		string uid;
		tester.Generate(uid);

		unsigned char * bytes = tester.GetUid();

		printf("%d.%d.%d.%d\t", (int) bytes[0], (int) bytes[1],
					 (int) bytes[2], (int) bytes[3]);

		printf("%s\t", uid);

		for (int i = 0; i < 16; i++)
		{
			if (i % 4 == 0 && i != 0)
				printf("-");
			printf("%02X", (int) bytes[i]);
		}

		unsigned char decoded[16];

		tester.Decode(decoded, uid);
		printf("\t");
		
		for (i = 0; i < 16; i++)
			printf("%02X", (int) decoded[i]);

		if (memcmp(bytes, decoded, 16) == 0)
			printf("\tmatch\n");
		else
			printf("\tNO MATCH\n");

		fflush(stdout);
	}
}
#endif

void Usage()
{
	cout << "usage: msixtest [filename] [msixparsecount] [xmlparsecount]" << endl;
	cout << "       filename is the input file to read from.  stdin if not specified" << endl;
	cout << "       msixparsecount is the number of iterations of the msix parser to run" << endl;
	cout << "       xmlparsecount is the number of iterations of the xml parser to run" << endl;
}

int main(int argc, char **argv)
{
//	TestObjectPool();
//	return 0;

	//testit(argc, argv);

	//testuids();

	const char * filename = NULL;
	int xmlCount = 1;
	int msixCount = 1;
	if (argc > 1)
	{
		filename = argv[1];
		if (0 == strcmp(filename, "/?"))
		{
			Usage();
			return 1;
		}

		if (argc > 2)
		{
			msixCount = atoi(argv[2]);
			if (argc > 3)
				xmlCount = atoi(argv[3]);
			else
				xmlCount = 0;
		}
	}

	if (!ParserTest(filename, xmlCount, msixCount))
	{
		// nice verbose error message
		cout << "Error" << endl;
		return -1;
	}
	else
		return 0;
}
