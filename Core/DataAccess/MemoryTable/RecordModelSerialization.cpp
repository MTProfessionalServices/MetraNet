#include <boost/archive/xml_iarchive.hpp>
#include <boost/archive/xml_oarchive.hpp>
#include <boost/archive/binary_iarchive.hpp>
#include <boost/archive/binary_oarchive.hpp>
#include <boost/serialization/export.hpp>

#include "RecordModel.h"

BOOST_CLASS_EXPORT(LogicalRecord);
BOOST_CLASS_EXPORT(LogicalFieldType);
BOOST_CLASS_EXPORT(RecordMember);
BOOST_CLASS_EXPORT(ConstantPoolFactory);
BOOST_CLASS_EXPORT(ConstantPoolFactoryBase);
BOOST_CLASS_EXPORT(GlobalConstantPoolFactory);
BOOST_CLASS_EXPORT(FieldAddress);
BOOST_CLASS_EXPORT(RunTimeDataAccessor);
BOOST_CLASS_EXPORT(DataAccessor);
BOOST_CLASS_EXPORT(DatabaseColumn);
BOOST_CLASS_EXPORT(RecordMetadata);
BOOST_CLASS_EXPORT(RecordMerge);
BOOST_CLASS_EXPORT(RecordSerializerInstruction);
BOOST_CLASS_EXPORT(RecordDeserializerInstruction);
BOOST_CLASS_EXPORT(RecordPrinter);
