
public class ToDoListService {
    
    public static final String Task_Status_Completed = 'Completed';
    public static final String Task_Status_Draft     = 'Draft';
    public static final String Task_Status_Started   = 'Started';

    public static final String Project_Status_Draft   = 'Draft';
    public static final String Project_Status_InProgress= 'In Progress';
    public static final String Project_Status_FinishedInTime   = 'Finished In Time';
    public static final String Project_Status_FinishedWithDelay   = 'Finished With Delay';
    

    public static String getProjectStatus(List<Task__c> tasks, Date projectPlanedEndDate){

        Integer completedStatusCount    = 0;
        Boolean taskCompletedWithDelay  = false;
        Boolean isInProgress            = false;

        for(Task__c task : tasks){

            if(task.Status__c == Task_Status_Started){
                
                isInProgress = true;
                break;

            }else if(task.Status__c == Task_Status_Completed){
                
                completedStatusCount += 1;

                if(task.End_Date__c > projectPlanedEndDate){
                    taskCompletedWithDelay = true;    
                } 
            }
        }


        if(isInProgress){
            return Project_Status_InProgress;
        }else if(tasks.size() > 0 && tasks.size() == completedStatusCount){
            return taskCompletedWithDelay ? Project_Status_FinishedWithDelay : Project_Status_FinishedInTime;
        }else{
            return Project_Status_Draft;   
        }

    }

    public static void createPerson(String fName, String lName){

        Person__c person = New Person__c(First_Name__c = fName, Last_Name__c = lName);

        try {
            
            insert person;

        }catch(DmlException e){

            System.debug('An unexpected error has occurred: ' + e.getMessage());

            throw e;
        }

    }

    public static Task__c startNewTask(Id projectId, Id personId){

        return new Task__c( 
                            Project__c = projectId,
                            Person__c  = personId,
                            Status__c = Task_Status_Draft,
                            Start_Date__c = System.today());

    }

    public static void updateTaskStatusesForProject(Id projectId, String newStatus){
        
        List<Task__c> tasks = [SELECT Id, Status__c FROM Task__c WHERE Project__c =: projectId];
        for(Task__c task : tasks){
            task.Status__c = newStatus;    
        }

        
        Database.SaveResult[] srList = Database.update(tasks, false);
        
        for (Database.SaveResult sr : srList) {
            if (sr.isSuccess()) {
                
                System.debug('Successfully updated task. Task ID: ' + sr.getId());
                
            }else {
                // Operation failed, so get all errors                
        		for(Database.Error err : sr.getErrors()) {
            		System.debug('The following error has occurred.');                    
            		System.debug(err.getStatusCode() + ': ' + err.getMessage());
            		System.debug('Account fields that affected this error: ' + err.getFields());
                } 
                    
            }
        }

    }

    public static void deleteProjects(Set<Id> projectIds){

        List<Project__c> projects = [SELECT Id FROM Project__c WHERE Id IN : projectIds];

    
        try {
            
            delete projects;

        }catch(DmlException e){

            System.debug('An unexpected error has occurred: ' + e.getMessage());

            throw e;    
        }

    }
 

}
