#include "AggregateExpression.h"
#include <boost/algorithm/string.hpp>

IncrementalInitializeAlgorithm::IncrementalInitializeAlgorithm()
{
}

IncrementalInitializeAlgorithm::~IncrementalInitializeAlgorithm()
{
}

void IncrementalInitializeAlgorithm::generate(boost::spirit::classic::tree_parse_info<>& info, 
                                              const std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >& parameterToInputVariable,
                                              const std::string & outputCounterName)
{
  mParameterToInputVariable = parameterToInputVariable;
  mOutputCounterName = outputCounterName;

//   if (info.full)
//   {
//     // dump parse tree as XML
//     std::map<boost::spirit::classic::parser_id, std::string> rule_names;
//     rule_names[AggregateExpressionParser::aggregateFunctionID] = "aggregateFunction";
//     rule_names[AggregateExpressionParser::functionArgID] = "functionArg";
//     rule_names[AggregateExpressionParser::expressionID] = "expression";
//     boost::spirit::classic::tree_to_xml(std::cout, info.trees, "<program not available>", rule_names);
//   }  

  // Now generate the update program
  evaluate(info);

  // update cumulative counter level stuff
  mCounterDeclarations += (boost::format(" @Table_%1% DECIMAL") % mOutputCounterName).str();
  mCounterInitializers += (boost::format("SET @Table_%1% = 0.0\n") % mOutputCounterName).str();

  mInitializerProgram = (boost::format ("CREATE PROCEDURE initializer %1% \n"
                                        "%2%\n"
                                        "AS\n"
                                        "%3%"
                                        "%4%"
                           ) % mTableDeclarations % mCounterDeclarations % mInitializers % mCounterInitializers).str();
  
}


void IncrementalInitializeAlgorithm::evaluate(boost::spirit::classic::tree_parse_info<>& info)
{
  eval_expression(info.trees.begin());
}

void IncrementalInitializeAlgorithm::eval_expression(AggregateExpressionParser::iter_t const& i)
{
  if (i->value.id() == AggregateExpressionParser::functionArgID)
  {
    assert(i->children.size() == 0);

    // extract argument (not always delimited by '\0').  Note that we are only doing
    // this to make note of whether we are processing this countable.
    std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >::const_iterator it = 
      mParameterToInputVariable.find(std::string(i->value.begin(), i->value.end()));
    if (it != mParameterToInputVariable.end())
    {
      mArg = (boost::format("@Probe_%1%") % it->second.first).str();
    }
    else
    {
      mArg = "";
    }
  }
  else if (i->value.id() == AggregateExpressionParser::aggregateFunctionID)
  {
    // TODO: Understand boost::iterator_range enough to use it here.
    std::string fun(i->value.begin(), i->value.end());
    boost::to_upper(fun);
      
      
    eval_expression(i->children.begin());

    // We are not processing this countable.
    if (mArg.size() == 0) return;

    // Name the variable by the address of the tree node.
    int localVar = reinterpret_cast<int>(&*i->value.begin());

    // Allocate a temporary(ies), create the update logic for it
    // and build the total update.
    if (fun == "SUM")
    {
      mTableDeclarations += (boost::format(" @Table_SUM_%1% DECIMAL") % localVar).str();
      mInitializers += (boost::format("SET @Table_SUM_%1% = 0.0\n") % localVar).str();
    }
    else if (fun == "COUNT")
    {
      mTableDeclarations += (boost::format(" @Table_COUNT_%1% DECIMAL") % localVar).str();
      mInitializers += (boost::format("SET @Table_COUNT_%1% = 0.0\n") % localVar).str();
    }
    else if (fun == "AVG")
    {
      mTableDeclarations += (boost::format(" @Table_AVG_%1% DECIMAL") % localVar).str();
      mInitializers += (boost::format("SET @Table_AVG_%1% = 0.0\n") % localVar).str();
      boost::format decl2 (" @Table_AVG_CNT_%1% DECIMAL");
      decl2 % localVar;
      mTableDeclarations += decl2.str();
      mInitializers += (boost::format("SET @Table_AVG_CNT_%1% = 0.0\n") % localVar).str();
    }
  }
  else if (i->value.id() == AggregateExpressionParser::expressionID)
  {
    if (*i->value.begin() == '+')
    {
      assert(i->children.size() == 2);
      eval_expression(i->children.begin());
      eval_expression(i->children.begin()+1);
    }
    else if (*i->value.begin() == '-')
    {
      assert(i->children.size() == 2);
      eval_expression(i->children.begin());
      eval_expression(i->children.begin()+1);
    }
    else
    {
      assert(0);
    }
  }
}

IncrementalUpdateAlgorithm::IncrementalUpdateAlgorithm()
{
}

IncrementalUpdateAlgorithm::~IncrementalUpdateAlgorithm()
{
}

void IncrementalUpdateAlgorithm::generate(boost::spirit::classic::tree_parse_info<>& info, 
                                          const std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >& parameterToInputVariable,
                                          const std::string & outputCounterName)
{
  mParameterToInputVariable = parameterToInputVariable;
  mOutputCounterName = outputCounterName;

//   if (info.full)
//   {
//     // dump parse tree as XML
//     std::map<boost::spirit::classic::parser_id, std::string> rule_names;
//     rule_names[AggregateExpressionParser::aggregateFunctionID] = "aggregateFunction";
//     rule_names[AggregateExpressionParser::functionArgID] = "functionArg";
//     rule_names[AggregateExpressionParser::expressionID] = "expression";
//     boost::spirit::classic::tree_to_xml(std::cout, info.trees, "<program not available>", rule_names);
//   }  

  // Now generate the update program
  evaluate(info);

  // update cumulative counter level stuff
  mCounterDeclarations += (boost::format(" @Table_%1% DECIMAL") % mOutputCounterName).str();
  mCounterUpdates += (boost::format("SET @Table_%1% = %2%\n") % mOutputCounterName % mFinalUpdate).str();

  // update the programs
  mUpdateProgram = (boost::format ("CREATE PROCEDURE updater %1% \n"
                                   "%2%\n"
                                   "%3%\n"
                                   "AS\n"
                                   "%4%"
                                   "%5%") % mProbeDeclarations % mTableDeclarations % mCounterDeclarations % mIncrementalUpdates % mCounterUpdates).str();

}


void IncrementalUpdateAlgorithm::evaluate(boost::spirit::classic::tree_parse_info<>& info)
{
  // Clear mFinalUpdate for the next counter added.
  mFinalUpdate = "";

  eval_expression(info.trees.begin());
  // HACK!  The parser won't generate an expression node for a single aggregate function,
  // so in those cases mFinalUpdate isn't set.  Do so here.
  if (mTemporaryCounterUpdate.size() > 0)
  {
    mFinalUpdate += mTemporaryCounterUpdate;
    mTemporaryCounterUpdate = "";
  }
}

void IncrementalUpdateAlgorithm::eval_expression(AggregateExpressionParser::iter_t const& i)
{
  if (i->value.id() == AggregateExpressionParser::functionArgID)
  {
    assert(i->children.size() == 0);

    // extract argument (not always delimited by '\0')
    std::map<std::string,std::pair<std::string,MTPipelineLib::PropValType> >::const_iterator it = 
      mParameterToInputVariable.find(std::string(i->value.begin(), i->value.end()));
    if (it != mParameterToInputVariable.end())
    {
      mArg = (boost::format("@Probe_%1%") % it->second.first).str();
      if (it->second.first != "*")
      {
        // Check for valid datatype and cast to decimal (we assume all counters
        // have decimal type).
        switch(it->second.second)
        {
        case MTPipelineLib::PROP_TYPE_INTEGER:
          mProbeDeclarations += (boost::format(" %1% INTEGER") % mArg).str();
          mArg = (boost::format("CAST(%1% AS DECIMAL)") % mArg).str();
          break;
        case MTPipelineLib::PROP_TYPE_BIGINTEGER:
          mProbeDeclarations += (boost::format(" %1% BIGINT") % mArg).str();
          mArg = (boost::format("CAST(%1% AS DECIMAL)") % mArg).str();
          break;
        case MTPipelineLib::PROP_TYPE_DECIMAL:
          mProbeDeclarations += (boost::format(" %1% DECIMAL") % mArg).str();
          break;
        case MTPipelineLib::PROP_TYPE_DOUBLE:
          mProbeDeclarations += (boost::format(" %1% DOUBLE PRECISION") % mArg).str();
          mArg = (boost::format("CAST(%1% AS DECIMAL)") % mArg).str();
          break;
        default:
          std::runtime_error("Unsupported counter parameter type");
        }
      }
    }
    else
    {
      mArg = "";
    }
  }
  else if (i->value.id() == AggregateExpressionParser::aggregateFunctionID)
  {
    // TODO: Understand boost::iterator_range enough to use it here.
    std::string fun(i->value.begin(), i->value.end());
    boost::to_upper(fun);
      
      
    eval_expression(i->children.begin());

    int localVar = reinterpret_cast<int>(&*i->value.begin());

    // Allocate a temporary(ies), create the update logic for it
    // and build the total update.
    if (fun == "SUM")
    {
      mTableDeclarations += (boost::format(" @Table_SUM_%1% DECIMAL") % localVar).str();
      mTemporaryCounterUpdate += (boost::format(" @Table_SUM_%1% ") % localVar).str();
      if (mArg.size() > 0)
      {
        boost::format upd1 ("SET @Table_SUM_%1% = @Table_SUM_%1% + %2%\n");
        upd1 % localVar; upd1 % mArg;
        mIncrementalUpdates += upd1.str();
      }
    }
    else if (fun == "COUNT")
    {
      mTableDeclarations += (boost::format(" @Table_COUNT_%1% DECIMAL") % localVar).str();
      mTemporaryCounterUpdate += (boost::format(" @Table_COUNT_%1% ") % localVar).str();
      if (mArg.size() > 0)
      {
        boost::format upd1 ("SET @Table_COUNT_%1% = @Table_COUNT_%1% + 1.0\n");
        upd1 % localVar;
        mIncrementalUpdates += upd1.str();
      }
    }
    else if (fun == "AVG")
    {
      mTableDeclarations += (boost::format(" @Table_AVG_%1% DECIMAL") % localVar).str();
      mTemporaryCounterUpdate += (boost::format(" @Table_AVG_%1% ") % localVar).str();
      boost::format decl2 (" @Table_AVG_CNT_%1% DECIMAL");
      decl2 % localVar;
      mTableDeclarations += decl2.str();
      if (mArg.size() > 0)
      {
        boost::format upd1 ("SET @Table_AVG_%1% = @Table_AVG_%1% * (@Table_AVG_CNT_%2%/(@Table_AVG_CNT_%2% + 1.0)) + %3%/(@Table_AVG_CNT_%2% + 1.0)\n");
        upd1 % localVar; upd1 % localVar; upd1 % mArg;
        boost::format upd2 ("SET @Table_AVG_CNT_%1% = @Table_AVG_CNT_%1% + 1.0\n");
        upd2 % localVar;
        mIncrementalUpdates += upd1.str();
        mIncrementalUpdates += upd2.str();
      }
    }
  }
  else if (i->value.id() == AggregateExpressionParser::expressionID)
  {
    if (*i->value.begin() == '+')
    {
      assert(i->children.size() == 2);
      eval_expression(i->children.begin());
      std::string upd1 = mTemporaryCounterUpdate;
      mTemporaryCounterUpdate = "";
      eval_expression(i->children.begin()+1);
      std::string upd2 = mTemporaryCounterUpdate;
      mTemporaryCounterUpdate = "";

      mFinalUpdate += upd1;
      if (upd2.size() > 0)
      {
        mFinalUpdate += " + ";
        mFinalUpdate += upd2;
      }
    }
    else if (*i->value.begin() == '-')
    {
      assert(i->children.size() == 2);
      eval_expression(i->children.begin());
      std::string upd1 = mTemporaryCounterUpdate;
      mTemporaryCounterUpdate = "";
      eval_expression(i->children.begin()+1);
      std::string upd2 = mTemporaryCounterUpdate;
      mTemporaryCounterUpdate = "";

      mFinalUpdate += upd1;
      if (upd2.size() > 0)
      {
        mFinalUpdate += " - ";
        mFinalUpdate += upd2;
      }
    }
    else
    {
      assert(0);
    }
  }
}

IncrementalAggregateExpression::IncrementalAggregateExpression(const std::vector<AggregateExpressionSpec>& exprs)
  :
  mExprs(exprs)
{
  mInitializer = boost::shared_ptr<IncrementalInitializeAlgorithm>(new IncrementalInitializeAlgorithm());
  AggregateExpressionParser agg;
  std::map<std::string, boost::spirit::classic::tree_parse_info<> > asts;

  for(std::vector<AggregateExpressionSpec>::iterator outerIt = mExprs.begin();
      outerIt != mExprs.end();
      ++outerIt)
  {
    // This is the union of all bindings for all input data streams.
    std::map<std::string, std::pair<std::string, MTPipelineLib::PropValType> > exprParamToSourceProperty;

    for(std::map<std::string, std::map<std::string, std::pair<std::string, MTPipelineLib::PropValType> > >::iterator innerIt = outerIt->Binding.begin();
        innerIt != outerIt->Binding.end();
        ++innerIt)
    {
      if (mUpdater.find(innerIt->first) == mUpdater.end())
      {
        mUpdater[innerIt->first] = boost::shared_ptr<IncrementalUpdateAlgorithm>(new IncrementalUpdateAlgorithm());
      }
     
      for(std::map<std::string, std::pair<std::string, MTPipelineLib::PropValType> >::iterator propIt = innerIt->second.begin();
          propIt != innerIt->second.end();
          ++propIt)
      {
        if (exprParamToSourceProperty.find(propIt->first) != exprParamToSourceProperty.end())
          std::runtime_error("Multiple bindings specified for aggregate expression property");

        exprParamToSourceProperty[propIt->first] = propIt->second;
      }
    }
    
    // Parse each of the underlying aggregate expressions and update the initializer.
    asts[outerIt->Output] = boost::spirit::classic::ast_parse(outerIt->Expression.c_str(), 
                                                     agg, 
                                                     boost::spirit::classic::space_p);
    mInitializer->generate(asts[outerIt->Output], exprParamToSourceProperty, outerIt->Output);
  }

  
  for(std::vector<AggregateExpressionSpec>::iterator outerIt = mExprs.begin();
      outerIt != mExprs.end();
      ++outerIt)
  {
    for(std::map<std::string, std::map<std::string, std::pair<std::string,MTPipelineLib::PropValType> > >::iterator innerIt = outerIt->Binding.begin();
        innerIt != outerIt->Binding.end();
        ++innerIt)
    {
      if (innerIt->second.size() > 0)
        mUpdater[innerIt->first]->generate(asts[outerIt->Output], innerIt->second, outerIt->Output);
    }
  }
}  

IncrementalAggregateExpression::~IncrementalAggregateExpression()
{
}

std::string IncrementalAggregateExpression::initialize()
{
  return mInitializer->initialize();
}

std::string IncrementalAggregateExpression::update(const std::string& source)
{
  return mUpdater[source]->update();
}
