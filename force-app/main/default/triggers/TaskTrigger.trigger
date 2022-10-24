trigger TaskTrigger on Task__c (before update, after insert, after update, after delete) {

    if (Trigger.isBefore){ 

        if (Trigger.isInsert) {
         
        } else if (Trigger.isUpdate) {
            TaskTriggerHandler.onBeforeUpdate(Trigger.new, Trigger.oldMap);
        } 

    }else if (Trigger.isAfter){ 

        if (Trigger.isInsert) {
            
            TaskTriggerHandler.onAfterInsert(Trigger.new);

        } else if(Trigger.isUpdate){
           
            TaskTriggerHandler.onAfterUpdate(Trigger.new, Trigger.old);

        } else if(Trigger.isDelete){
            
            TaskTriggerHandler.onAfterDelete(Trigger.old);

        }    
    }

}