@isTest
private class Sales_OrderTest
{
   	@testSetup static void init () {
        TestData.init();
        TestData.createAcct();
        TestData.createOpp();
        TestData.createContract();
        TestData.createOppLine(10, 10);
        TestData.createSO();
    }

	@isTest
	static void itShouldMergeOrder()
	{

        Schema.DescribeSObjectResult soSchema = Schema.SObjectType.Sales_Order__c;
        Map<String,Schema.RecordTypeInfo> soMap = soSchema.getRecordTypeInfosByName();
        Schema.RecordTypeInfo soMergedRecordType = soMap.get('Merged');

		// Given 2 Sales Orders
        List<Sales_Order__c> soList = [select id, name from Sales_Order__c];

        Sales_Order__c fromSalesOrder = [select id, name from Sales_Order__c where Id =:soList[0].Id];
        Sales_Order__c toSalesOrder = [select id, name from Sales_Order__c where Id =:soList[1].Id];
        List<Bus__c> fromSObusses = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c=:fromSalesOrder.Id];
        List<Bus__c> toSObusses = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c=:toSalesOrder.Id];
        integer totalBusses = fromSObusses.size()+toSObusses.size();

        ApexPages.StandardController sc = new ApexPages.StandardController(fromSalesOrder);
        Sales_Order testSOMerge = new Sales_Order(sc);
        testSOMerge.toSaleOrder = toSalesOrder.name;
        
		// When the merge button is envoked

        testSOMerge.mergeTo();

		// Then the original Sales Order should be of record type merged

        Sales_Order__c originalSo = [select Id, Name, RecordTypeId from Sales_Order__c where Id=:fromSalesOrder.Id];
        system.assertEquals(soMergedRecordType.getRecordTypeId(), originalSo.RecordTypeId);

        // and there should be no busses on the original order

        List<Bus__c> noBusses = [select Id, Name from Bus__c where Sales_Order__c=:originalSo.Id];
        system.assertEquals(0, noBusses.size());

        // and the merged Sales Order has the combined quanity
        List<Bus__c> combinedBusses = [select Id, Name from Bus__c where Sales_Order__c=:toSalesOrder.Id];
        system.assertEquals(totalBusses, combinedBusses.size());

	}

    @isTest
    static void itShouldSplitOrder()
    {
        // Given a sales order

        List<Sales_Order__c> soList = [select id, name from Sales_Order__c];

        ApexPages.StandardController sc = new ApexPages.StandardController(soList[0]);
        Sales_Order scext = new Sales_Order(sc);

        scext.toSaleOrder = '123456';
        scext.toSalesOrderQty = 2;

        // When the Split button is invoked

        scext.splitTo();

        // Then the second sales order should exist and the original should reduce qty

        Sales_Order__c splitToSalesOrder = [select Id, Name from Sales_Order__c where Name=:scext.toSaleOrder];
        system.assertEquals(scext.toSaleOrder, splitToSalesOrder.Name);

        Opportunity_Sales_Order__c toSplitOSO = [select Id, Name, Opportunity_Line__c, Sales_Order__c, Quantity__c from Opportunity_Sales_Order__c where Sales_Order__c =:splitToSalesOrder.Id];
        system.assertEquals(scext.toSalesOrderQty, toSplitOSO.Quantity__c);

    }
}