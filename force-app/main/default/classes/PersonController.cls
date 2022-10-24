public class PersonController {
  
    @AuraEnabled(cacheable=true)
    public static List<PersonWrapper> getBestPersonsWhoFinishedInTime(Integer personsNumber) {
        
        List<PersonWrapper> personsData = new List<PersonWrapper>();


        AggregateResult[] groupedFiveBiggestProjects = [SELECT Person__c, Person__r.First_Name__c firstName, Person__r.Last_Name__c lastName, COUNT_DISTINCT(Project__c)ProjectCount  
                                    	                FROM Task__c
                                                		WHERE Project__r.Status__c =: ToDoListService.Project_Status_FinishedInTime
                                    	                GROUP BY Person__c, Person__r.First_Name__c, Person__r.Last_Name__c  
                                    	                ORDER BY COUNT_DISTINCT(Project__c) DESC 
                                    	                LIMIT :personsNumber];
        for (AggregateResult ar : groupedFiveBiggestProjects)  {
            personsData.add(
                new PersonWrapper(String.valueOf(ar.get('Person__c')),
                                  String.valueOf(ar.get('firstName')) + ' ' + String.valueOf(ar.get('lastName')),
                                  Integer.valueOf(ar.get('ProjectCount')))
                );
        }

        return personsData;   
    }


    public class PersonWrapper{
        
        @AuraEnabled
        public Id personId{get;set;}

        @AuraEnabled
        public String personFullName{get;set;}
        
        @AuraEnabled
        public Integer numberOfProjects{get;set;}

        public PersonWrapper(String personId, String personFullName, Integer numberOfProjects) {
            this.personId           = personId;
            this.personFullName     = personFullName;
            this.numberOfProjects  = numberOfProjects;
        }
    }
    
}
