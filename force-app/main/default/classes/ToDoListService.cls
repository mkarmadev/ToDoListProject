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

}
