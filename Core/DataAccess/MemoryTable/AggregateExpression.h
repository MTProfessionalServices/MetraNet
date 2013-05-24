#ifndef __AGGREGATEEXPRESSION_H__
#define __AGGREGATEEXPRESSION_H__

// A Spirit parser for aggregate expressions (actually counter type specifications)
#include <string>
#include <boost/spirit/include/classic_core.hpp>
#include <boost/spirit/include/classic_ast.hpp>
#include <boost/spirit/include/classic_tree_to_xml.hpp>
#include <boost/format.hpp>

#include "MetraFlowConfig.h"

#if defined(WIN32)
#import <MTPipelineLib.tlb> rename("EOF", "EOFX")
#else
class MTPipelineLib
{
public:
  enum PropValType {
    PROP_TYPE_UNKNOWN = 0,
    PROP_TYPE_DEFAULT = 1,
    PROP_TYPE_INTEGER = 2,
    PROP_TYPE_DOUBLE = 3,
    PROP_TYPE_STRING = 4,
    PROP_TYPE_DATETIME = 5,
    PROP_TYPE_TIME = 6,
    PROP_TYPE_BOOLEAN = 7,
    PROP_TYPE_SET = 8,
    PROP_TYPE_OPAQUE = 9,
    PROP_TYPE_ENUM = 10,
    PROP_TYPE_DECIMAL = 11,
    PROP_TYPE_ASCII_STRING = 12,
    PROP_TYPE_UNICODE_STRING = 13,
    PROP_TYPE_BIGINTEGER = 14
  };
};
#endif

struct AggregateExpressionParser : public boost::spirit::classic::grammar<AggregateExpressionParser>
{
  typedef char const*         iterator_t;
  typedef boost::spirit::classic::tree_match<iterator_t> parse_tree_match_t;
  typedef parse_tree_match_t::tree_iterator iter_t;

  static const int aggregateFunctionID = 1;
  static const int functionArgID = 2;
  static const int expressionID = 3;

  template <typename ScannerT>
  struct definition
  {
    definition(AggregateExpressionParser const& /*self*/)
    {
      //  Start grammar definition
      functionArg
        = boost::spirit::classic::lexeme_d[boost::spirit::classic::token_node_d[*(~boost::spirit::classic::ch_p(')'))]];

      aggregateFunction 
        =  
        boost::spirit::classic::root_node_d[(boost::spirit::classic::as_lower_d["sum"] | boost::spirit::classic::as_lower_d["avg"] | boost::spirit::classic::as_lower_d["count"])] >>
        boost::spirit::classic::inner_node_d[boost::spirit::classic::ch_p('(') >> functionArg >> boost::spirit::classic::ch_p(')')];

      expression = 
        aggregateFunction >>
        *(  (boost::spirit::classic::root_node_d[boost::spirit::classic::ch_p('+')] >> aggregateFunction)
            | (boost::spirit::classic::root_node_d[boost::spirit::classic::ch_p('-')] >> aggregateFunction)
          );
      //  End grammar definition

      // turn on the debugging info.
      BOOST_SPIRIT_DEBUG_RULE(aggregateFunction);
      BOOST_SPIRIT_DEBUG_RULE(functionArg);
      BOOST_SPIRIT_DEBUG_RULE(expression);
    }

    boost::spirit::classic::rule<ScannerT, boost::spirit::classic::parser_context<>, boost::spirit::classic::parser_tag<expressionID> >   expression;
    boost::spirit::classic::rule<ScannerT, boost::spirit::classic::parser_context<>, boost::spirit::classic::parser_tag<functionArgID> >       functionArg;
    boost::spirit::classic::rule<ScannerT, boost::spirit::classic::parser_context<>, boost::spirit::classic::parser_tag<aggregateFunctionID> >      aggregateFunction;

    boost::spirit::classic::rule<ScannerT, boost::spirit::classic::parser_context<>, boost::spirit::classic::parser_tag<expressionID> > const&
    start() const { return expression; }
  };
};

////////////////////////////////////////////////////////////////////////////

class IncrementalInitializeAlgorithm
{
private:
  // Only process parameters that have a variable mapped to them.
  // In practice we process parameters attached to different product
  // views separately.
  std::map<std::string, std::pair<std::string,MTPipelineLib::PropValType> > mParameterToInputVariable;
  std::string mOutputCounterName;

  // Builder variables
  std::string mArg;
  std::string mTableDeclarations;
  std::string mCounterDeclarations;
  std::string mInitializers;
  std::string mCounterInitializers;

  // Output program
  std::string mInitializerProgram;
  
  void evaluate(boost::spirit::classic::tree_parse_info<>&);
  void eval_expression(AggregateExpressionParser::iter_t const& i);
public:
  METRAFLOW_DECL IncrementalInitializeAlgorithm();
  METRAFLOW_DECL ~IncrementalInitializeAlgorithm();

  METRAFLOW_DECL void generate(boost::spirit::classic::tree_parse_info<>& info, 
                          const std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >& parameterToInputVariable,
                          const std::string & outputCounterName);
  METRAFLOW_DECL std::string initialize() const { return mInitializerProgram; }
};


class IncrementalUpdateAlgorithm
{
private:
  // Only process parameters that have a variable mapped to them.
  // In practice we process parameters attached to different product
  // views separately.
  std::map<std::string, std::pair<std::string,MTPipelineLib::PropValType> > mParameterToInputVariable;
  std::string mOutputCounterName;

  // Builder variables
  std::string mArg;
  std::string mProbeDeclarations;
  std::string mTableDeclarations;
  std::string mCounterDeclarations;
  std::string mIncrementalUpdates;
  std::string mTemporaryCounterUpdate;
  std::string mFinalUpdate;
  std::string mCounterUpdates;

  // Output programs
  std::string mUpdateProgram;
  
  void evaluate(boost::spirit::classic::tree_parse_info<>& info);
  void eval_expression(AggregateExpressionParser::iter_t const& i);
public:
  METRAFLOW_DECL IncrementalUpdateAlgorithm();
  METRAFLOW_DECL ~IncrementalUpdateAlgorithm();

  METRAFLOW_DECL void generate(boost::spirit::classic::tree_parse_info<>& info, 
                          const std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >& parameterToInputVariable,
                          const std::string & outputCounterName);
  METRAFLOW_DECL std::string update() const { return mUpdateProgram; }
};

typedef struct tagAggregateExpressionSpec
{
public:
  // The parameterized aggregate function.
  std::string Expression;
  // The output value
  std::string Output;
  // For each product view/input record stream, a map from parameter to input product view property/record field.
  std::map<std::string, std::map<std::string, std::pair<std::string,MTPipelineLib::PropValType> > > Binding;
} AggregateExpressionSpec;

class IncrementalAggregateExpression
{
private:
  std::vector<AggregateExpressionSpec> mExprs;
  std::map<std::string, boost::shared_ptr<IncrementalUpdateAlgorithm> > mUpdater;
  boost::shared_ptr<IncrementalInitializeAlgorithm> mInitializer;
public:
  // exprs[aggExpr][source] gives the bindings from aggExpr properties to source properties (if any).
  METRAFLOW_DECL IncrementalAggregateExpression(const std::vector<AggregateExpressionSpec>& exprs);
  METRAFLOW_DECL ~IncrementalAggregateExpression();
  METRAFLOW_DECL std::string initialize();
  METRAFLOW_DECL std::string update(const std::string& source);
};

#endif
