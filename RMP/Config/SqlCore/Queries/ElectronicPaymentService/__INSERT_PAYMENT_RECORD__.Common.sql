
				 p:import_queue[queueName="%%PARENT_QUEUE%%"];
				 c:import_queue[queueName="%%CHILD_QUEUE%%"];
				 m:meter[service="metratech.com/Payment", key="PaymentID", service="metratech.com/PaymentDetails", key="PaymentID", generateSummaryTable=false];
				 p -> m(0);
				 c -> m(1);
			