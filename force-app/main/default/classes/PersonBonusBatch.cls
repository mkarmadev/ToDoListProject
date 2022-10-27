public with sharing class PersonBonusBatch implements Database.Batchable<sObject>,
                                                        Schedulable {
    
    public Database.QueryLocator start(Database.BatchableContext bc) {
        
        return Database.getQueryLocator([SELECT Id, Bonus__c FROM Person__c]);
    }

    public void execute(Database.BatchableContext bc, List<Person__c> persons){

        Set<Id> personIds = new Map<Id, Person__c>(persons).keyset();

        AggregateResult[] groupedPersonsCompletedTasks = [SELECT Person__c personId, COUNT(Id) numberOfTasks
                                                          FROM Task__c 
                                                          WHERE Person__c IN : personIds
                                                            AND Status__c =: ToDoListService.Task_Status_Completed 
                                                                AND End_Date__c = N_MONTHS_AGO:1
                                                          GROUP BY Person__c];

        Map<Id, Decimal> personsIdsToBonus = new Map<Id, Decimal>();
        for (AggregateResult ar : groupedPersonsCompletedTasks)  {

            personsIdsToBonus.put(String.valueOf(ar.get('personId')), 
                                  Integer.valueOf(ar.get('numberOfTasks')) * ToDoListService.Person_Task_Bonus);    
        } 
        
        
        List<Person__c> updatePersons = new List<Person__c>();
        for(Person__c person: persons){

            if (personsIdsToBonus.containsKey(person.Id)) {
                person.Bonus__c = personsIdsToBonus.get(person.Id);
                updatePersons.add(person);
            }
        }


        if(updatePersons.size() > 0){
            update updatePersons;
        }
        
    }

    public void finish(Database.BatchableContext bc){
        System.debug('Person Bonus Batch job completed: ' + System.Date.today());   
    }

    public void execute(SchedulableContext ctx) {
        
        /* PersonBonusBatch personBonus = new PersonBonusBatch();
        Id batchId = Database.executeBatch(personBonus); */

        Database.executeBatch(this);

        //String cron = '0 0 3 1 * ?';
        //PersonBonusBatch personBonus = new PersonBonusBatch();
        //String jobID = System.schedule('Person Bonus Batch job', cron, personBonus);
    }

}
