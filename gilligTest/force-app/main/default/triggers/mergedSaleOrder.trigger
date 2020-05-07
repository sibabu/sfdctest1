trigger mergedSaleOrder on Sales_Order__c (before update) {

    recordtype soMergeRecType = [select id from recordtype where DEVELOPERNAME = 'Merged' and SOBJECTTYPE = 'Sales_Order__c'];
    Id newOwner = '00515000005ylK7AAI';

    for (Sales_Order__c salesOrder:trigger.new) {
        if (salesOrder.recordtypeid == soMergeRecType.Id) {
            salesOrder.ownerid = newOwner;
        }
    }
}