public class PersonController {
  
    @AuraEnabled(cacheable=true)
    public static List<PersonWrapper> getBestPersonsWhoFinishedInTime(Integer personsNumber) {
        
        List<PersonWrapper> personWrappers = new List<PersonWrapper>();


        AggregateResult[] groupedFiveBiggestProjects = [SELECT Person__c personId, Person__r.First_Name__c firstName, Person__r.Last_Name__c lastName, COUNT_DISTINCT(Project__c)projectCount  
                                    	                FROM Task__c
                                                		WHERE Project__r.Status__c =: ToDoListService.Project_Status_FinishedInTime
                                    	                GROUP BY Person__c, Person__r.First_Name__c, Person__r.Last_Name__c  
                                    	                ORDER BY COUNT_DISTINCT(Project__c) DESC 
                                    	                LIMIT :personsNumber];
        for (AggregateResult ar : groupedFiveBiggestProjects)  {
            personWrappers.add(
                new PersonWrapper(String.valueOf(ar.get('personId')),
                                  String.valueOf(ar.get('firstName')) + ' ' + String.valueOf(ar.get('lastName')),
                                  Integer.valueOf(ar.get('projectCount')))
                );
        }

        return personWrappers;   
    }

    @AuraEnabled(cacheable=true)
    public static List<TaskWrapper> getUpcomingPersonTasks(ID personId) {
        
        List<TaskWrapper> taskWrappers = new List<TaskWrapper>();

        for(Task__c task: [SELECT Id, Project__r.Name, Label__c, Start_Date__c, End_Date__c, Status__c 
                           FROM Task__c 
                           WHERE Person__c =: personId
                                AND Status__c =: ToDoListService.Task_Status_Draft
                           ORDER BY Start_Date__c]){

            taskWrappers.add(
                new TaskWrapper(task.Id,
                                task.Project__r.Name,
                                task.Label__c,
                                task.Start_Date__c,
                                task.End_Date__c,
                                task.Status__c)
            );
        }

        return taskWrappers;
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


    public class TaskWrapper{

        @AuraEnabled
        public Id taskId{get;set;}

        @AuraEnabled
        public String projectName{get;set;}
        
        @AuraEnabled
        public String taskLabel{get;set;}
        
        @AuraEnabled
        public Date taskStartDate{get;set;}

        @AuraEnabled
        public Date taskEndDate{get;set;}

        @AuraEnabled
        public String taskStatus{get;set;}

        public TaskWrapper(Id taskId, String projectName, String taskLabel, Date taskStartDate, Date taskEndDate, String taskStatus) {
            this.taskId         = taskId;
            this.projectName    = projectName;
            this.taskLabel      = taskLabel;
            this.taskStartDate  = taskStartDate;
            this.taskEndDate    = taskEndDate;
            this.taskStatus     = taskStatus;
        }
    }
    
}
