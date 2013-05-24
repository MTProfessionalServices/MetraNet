#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>

#include "SerializationTest.h"
#include "Scheduler.h"
#include "DatabaseSelect.h"
#include "DatabaseInsert.h"
// Grrr...  Need this to make sure that serialization impls are generated.
#include "RunTimeDatabaseSelect.h"

#include <fstream>
#include <string>
#include <boost/lexical_cast.hpp>
#include <boost/test/test_tools.hpp>

// void SerializationTest::TestRunTimePlanSerialization()
// {
//   DesignTimePlan plan;
//   DesignTimeDatabaseSelect * select = new DesignTimeDatabaseSelect();
//   select->SetBaseQuery(L"SELECT id_acc, nm_login, nm_space FROM t_account_mapper");
//   plan.push_back(select);
//   DesignTimeDevNull * insert = new DesignTimeDevNull();
//   plan.push_back(insert);
//   plan.push_back(new DesignTimeChannel(select->GetOutputPorts()[0], insert->GetInputPorts()[0]));
//   plan.type_check();
//   ParallelPlan pplan(2);
//   plan.code_generate(pplan);
//   BOOST_REQUIRE(1 == pplan.GetDomains().size());
//   {
//     ParallelDomain & domain(*pplan.GetDomains()[0]);
//     // create and open a character archive for output
//     std::ofstream ofs("TestRunTimePlanSerialization.out");
//     boost::archive::xml_oarchive oa(ofs);
//     oa << BOOST_SERIALIZATION_NVP(domain);
//   }
//   {
//     ParallelDomain * domain;
//     // create and open a character archive for output
//     std::ifstream ifs("TestRunTimePlanSerialization.out");
//     boost::archive::xml_iarchive ia(ifs);
//     ia >> BOOST_SERIALIZATION_NVP(domain); 
//     delete domain;
//   }
// }

// void SerializationTest::TestPortSerialization()
// {
//   const Port p(NULL, L"probe", false);
//   {
//     // create and open a character archive for output
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     // write class instance to archive
//     oa << BOOST_SERIALIZATION_NVP(p);
//     // archive and stream closed when destructors are called
//   }

//   {
//     // create and open an archive for input
//     std::ifstream ifs("filename", std::ios::binary);
//     boost::archive::xml_iarchive ia(ifs);
//     // read class state from archive
//     Port newp;
//     ia >> BOOST_SERIALIZATION_NVP(newp);
//   }
// }
// void SerializationTest::TestPortCollectionSerialization()
// {
//   PortCollection a;
//   a.insert(NULL, 0, L"A", false);
//   a.insert(NULL, 1, L"B", true);
//   {
//     // create and open a character archive for output
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     // write class instance to archive
//     oa << BOOST_SERIALIZATION_NVP(a);
//     // archive and stream closed when destructors are called
//   }

//   {
//     // create and open an archive for input
//     std::ifstream ifs("filename", std::ios::binary);
//     boost::archive::xml_iarchive ia(ifs);
//     // read class state from archive
//     PortCollection b;
//     ia >> BOOST_SERIALIZATION_NVP(b);
//     BOOST_REQUIRE(2 == b.size());
//     BOOST_REQUIRE(std::wstring(L"A") == b[0]->GetName());
//     BOOST_REQUIRE(std::wstring(L"B") == b[1]->GetName());
//     BOOST_REQUIRE(std::wstring(L"A") == b[L"A"]->GetName());
//     BOOST_REQUIRE(std::wstring(L"B") == b[L"B"]->GetName());
//   }
// }

// class TestSerializationOperator : public DesignTimeOperator
// {
// private:
//   uint32_t mBlah;
  
//   //
//   // Serialization support
//   //
//   friend boost::serialization::access;
//   template<class Archive>
//   void serialize(Archive & ar, const unsigned int version)
//   {
//     ar & BOOST_SERIALIZATION_BASE_OBJECT_NVP(DesignTimeOperator);
//     ar & BOOST_SERIALIZATION_NVP(mBlah);
//   } 

// public:
//   TestSerializationOperator(const std::wstring& name, Mode mode, port_t numInputs, port_t numOutputs, uint32_t blah)
//     :
//     DesignTimeOperator(name, mode),
//     mBlah(blah)
//   {
//     for (port_t i = 0; i<numInputs; i++)
//     {
//       mInputPorts.insert(this, i, boost::lexical_cast<std::wstring, port_t>(i), false);
//     } 
//     for (port_t i = 0; i<numOutputs; i++)
//     {
//       mOutputPorts.insert(this, i, boost::lexical_cast<std::wstring, port_t>(i), false);
//     } 
//   }

//   uint32_t GetBlah() const { return mBlah; }

//   void type_check() {}
//   RunTimeOperator *DesignTimeOperator::code_generate(Reactor *,partition_t,partition_t) { return NULL; }
// };

// void SerializationTest::TestOperatorSerialization()
// {
//   TestSerializationOperator tsoa(L"TestSerializationOperator", DesignTimeOperator::SEQUENTIAL, 3, 2, 88);
//   {
//     // create and open a character archive for output
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     // write class instance to archive
//     oa << BOOST_SERIALIZATION_NVP(tsoa);
//     // archive and stream closed when destructors are called
//   }

//   {
//     // create and open an archive for input
//     std::ifstream ifs("filename", std::ios::binary);
//     boost::archive::xml_iarchive ia(ifs);
//     // read class state from archive
//     TestSerializationOperator tsob(L"", DesignTimeOperator::PARALLEL, 0, 0, 0);
//     ia >> BOOST_SERIALIZATION_NVP(tsob);
//     BOOST_REQUIRE(std::wstring(L"TestSerializationOperator") == tsob.GetName());

//     BOOST_REQUIRE(DesignTimeOperator::SEQUENTIAL == tsob.GetMode());
//     BOOST_REQUIRE(3 == tsob.GetInputPorts().size());
//     BOOST_REQUIRE(2 == tsob.GetOutputPorts().size());
//     BOOST_REQUIRE(88 == tsob.GetBlah());
//   }
// }

void SerializationTest::TestMetadataSerialization()
{
  GlobalConstantPoolFactory cpf;

//   {
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     oa << BOOST_SERIALIZATION_NVP(cpf);
//   }
//   {
//     GlobalConstantPoolFactory cpf2;
//     std::ifstream ifs("filename");
//     boost::archive::xml_iarchive ia(ifs);
//     ia >> BOOST_SERIALIZATION_NVP(cpf2);
//   }
//   {
//     GlobalConstantPoolFactory * cpf2 = &cpf;
//     std::ofstream ofs("filename");
//     boost::archive::xml_oarchive oa(ofs);
//     oa << BOOST_SERIALIZATION_NVP(cpf2);
//   }
//   {
//     GlobalConstantPoolFactory * cpf2;
//     std::ifstream ifs("filename");
//     boost::archive::xml_iarchive ia(ifs);
//     ia >> BOOST_SERIALIZATION_NVP(cpf2);
//     delete cpf2;
//   }
  {
    FieldAddress fa (&cpf, 3, 10);
    // create and open a character archive for output
    std::ofstream ofs("filename");
    boost::archive::xml_oarchive oa(ofs);
    oa << BOOST_SERIALIZATION_NVP(fa);
  }
  {
    FieldAddress fa (&cpf, 3, 10);
    // create and open a character archive for output
    std::ifstream ifs("filename");
    boost::archive::xml_iarchive ia(ifs);
    ia >> BOOST_SERIALIZATION_NVP(fa);
  }

  LogicalRecord logicalA;
  logicalA.push_back(L"a", LogicalFieldType::Integer(false));
  logicalA.push_back(L"b", LogicalFieldType::Integer(false));
  logicalA.push_back(L"c", LogicalFieldType::String(false));
  RecordMetadata recordA(logicalA);
  {
    // create and open a character archive for output
    std::ofstream ofs("filename");
    boost::archive::xml_oarchive oa(ofs);
    // write class instance to archive
    oa << BOOST_SERIALIZATION_NVP(recordA);
    // archive and stream closed when destructors are called
  }
}

