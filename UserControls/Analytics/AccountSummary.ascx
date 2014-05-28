<%@ Control Language="C#" AutoEventWireup="true" Inherits="UserControls_Analytics_AccountSummary" CodeFile="AccountSummary.ascx.cs" %>
<%@ OutputCache Duration="1200" VaryByParam="none" %>
<%@ Register Assembly="MetraTech.UI.Controls.CDT" Namespace="MetraTech.UI.Controls.CDT" TagPrefix="MTCDT" %>
<%@ Register Assembly="MetraTech.UI.Controls" Namespace="MetraTech.UI.Controls" TagPrefix="MT" %>

 <%-- <img src="/Res/Images/Mockup/MetangaAccountSummaryAnalytic.png" width="720px;" style="padding: 15px;"/>--%>
 
 			<div class="section-wrapper dashboard">
				<section class="widgets">
						<!--/.widget-->
						<div class="widget">
								<div class="container front pop rounded-med">
										<section class="content">
												<div class="inner clearfix">
														<div class="widget-secondary  grid_12">
																<div class="grid_4">
																		<div class="title text-autosize-title">
																				<span class="small-metric-name">LTV:</span>
																		</div>
																		<div class="value last-small-amt text-autosize-secondary">
																				<span class="symbol-sm">$</span>
																				<span href="#LTVToolTip" class="show-tooltip-html">1,400,365</span>
																		</div>
																</div>
																<div class="grid_5">
																		<div class="title text-autosize-title">
																				<span class="small-metric-name">MRR:</span>
																		</div>
																		<div class="value delta-amounts text-autosize-secondary">
																				<span class="delta-currency positive-arrow"></span>
																				<span class="symbol-sm">$</span>
																				<span  href="#MRRToolTip" class="show-tooltip-html">5308</span>
																				<span class="separator dim symbol-sm">|</span>
																				<span class="delta-percentage"><span class="green symbol-sm">+</span><span class="symbol-sm">33.87</span><span class="symbol-sm">%</span></span>
																		</div>
																</div>
																<div class="grid_3">
																		<div class="title text-autosize-title">
																				<span class="small-metric-name">Balance:</span>
																		</div>
																		<div class="value last-small-amt text-autosize-secondary">
																				<span class="symbol-sm red">$</span>
																				<span class="red">-10,365</span>
																		</div>
																</div>
														</div>
												</div>
										</section>
								</div>
								<!--/.front-->
						</div>
						<!--/.widget-->
				</section>
        </div>
