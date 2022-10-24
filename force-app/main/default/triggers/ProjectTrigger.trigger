trigger ProjectTrigger on Project__c (before delete, after delete) {

    if (Trigger.isBefore){ 

        if(Trigger.isDelete){
            
            ProjectTriggerHandler.onBeforeDelete(Trigger.old);
            
        }

    }else if (Trigger.isAfter){

        if(Trigger.isDelete){
            
            ProjectTriggerHandler.onAfterDelete();

        }

    }


}