public class ToDoListService {
    
    public static String getProjectStatus(List<Task__c> tasks, Date projectPlanedEndDate){

        Integer completedStatusCount    = 0;
        Boolean taskCompletedWithDelay  = false;
        Boolean isInProgress            = false;

        for(Task__c task : tasks){

            if(task.Status__c == 'Started'){
                
                isInProgress = true;
                break;

            }else if(task.Status__c == 'Completed'){
                
                completedStatusCount += 1;

                if(task.End_Date__c > projectPlanedEndDate){
                    taskCompletedWithDelay = true;    
                } 
            }
        }


        if(isInProgress){
            return 'In Progress';
        }else if(tasks.size() == completedStatusCount){
            return taskCompletedWithDelay ? 'Finished with Delay' : 'Finished in Time';
        }else{
            return 'Draft';   
        }

    }

    public static void createPerson(String fName, String lName){

        Person__c person = New Person__c(First_Name__c = fName, Last_Name__c = lName);

        insert Person__c;
    }

    public static startNewTask(Id projectId, Id personId){

        Task__c task = new Task__c( 
                                    Project__c = projectId,
                                    Person__c  = personId,
                                    Status__c = 'Draft',
                                    Start_Date__c = System.today());

    }

    public static updateTaskStatusesForProject(Id projectId, String newStatus){
        
        List<Task__c> tasks = [SELECT Id, Status__c FROM Task__c WHERE Project__c =: projectId];
        for(Task__c task : tasks){
            task.Status__c = newStatus;    
        }

        update tasks;

    }

    public status deleteProjects(Set<Id> projectIds){

        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Id IN : projectIds];

        delete projects;

    }
 

}
