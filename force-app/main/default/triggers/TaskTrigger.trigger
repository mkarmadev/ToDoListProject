trigger TaskTrigger on Task__c (after insert, after update) {

    if (Trigger.isBefore){ 

    }else if (Trigger.isAfter){ 

        if (Trigger.isInsert) {
            //ContactTriggerHandler.onAfterInsert(Trigger.new);
        }

    }

}