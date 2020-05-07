trigger Sales_Order on Sales_Order__c (
//  before insert, 
//  before update, 
//  before delete, 
    after insert, 
    after update
//    after delete, 
//    after undelete
    ) {

    Set<Id> soSet = new Set<Id>();
    set<Id> acctSet = new Set<Id>();
    List<Sales_Order__c> soList = new List<Sales_Order__c>();
    for (Sales_Order__c so:trigger.new) {
        if (Trigger.isAfter) {
            Sales_Order__c oldSO = new Sales_Order__c();
            if (!Trigger.isInsert) {
                oldSO = Trigger.oldMap.get(so.Id);
            }
            if (so.name != oldSO.name) {
                soSet.add(so.Id);
                soList.add(so);
            }
            if (so.BOM_Processing_Hours__c!=oldSO.BOM_Processing_Hours__c) {
                acctSet.add(so.Account__c);
            }
        }
    }

    if (soSet.size()>0) {
        List<Bus__c> changeBus = [select Id, Name, Sales_Order__c from Bus__c where Sales_Order__c in:soSet];
        if (changeBus.size()>0) {
            changeBus = bus.changeName(soList, changeBus);
            update changeBus;            
        }
    }

    if (acctSet.size()>0) {
        List<Account> bomAvg = [select id, AVG_BOM_Processing_Hours__c from Account where Id in:acctSet];
        AggregateResult[] avgBOMtime = [SELECT Account__c, AVG(BOM_Processing_Hours__c)abt
            FROM Sales_Order__c
            Where BOM_Processing_Hours__c!=Null
            GROUP BY Account__c];
        for (AggregateResult abt : avgBOMtime)  {
            for (Account thisAccoout:bomAvg) {
                if (thisAccoout.Id==abt.get('Account__c')) {
                    thisAccoout.AVG_BOM_Processing_Hours__c = (decimal)abt.get('abt');
                    break;
                }
            }
        }
        update bomAvg;
    }
}