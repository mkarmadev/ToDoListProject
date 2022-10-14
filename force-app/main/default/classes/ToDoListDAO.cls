public class ToDoListDAO {
    
    public static Person__c getPerson(Id personId){

        return [SELECT Id, First_Name__c, Last_Name__c, Is_Synced__c, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c
                FROM Person__c
                WHERE Id =:personId];

    }
    
    public static Map<Id, List<Task__c>> getOverdueTasksByProjectIds(Set<Id> personIds){

        Map<Id, List<Task__c>> tasksByProjectIds = new Map<Id, List<Task__c>>();

            for(Task__c task: [SELECT Id, Name, Project__c  FROM Task__c 
                                                                WHERE Person__c IN : personIds 
                                                                    AND Status__c = 'Started'  
                                                                        AND End_Date__c <= TODAY]){
                                    
        
                List<Task__c> tasks = tasksByProjectIds.get(task.Project__c);
                                        
                if(tasks == null) {
                    tasksByProjectIds.put(task.Project__c, new List<Task__c>{task});
                }else {
                    tasks.add(task);    
                }     
            }

       return tasksByProjectIds; 
    }

    public static Map<Id, Set<Id>> getProjectsByPersonsIds(Set<Id> personIds){

        Map<Id, Set<Id>> projectsByPersonsIds = new Map<Id, Set<Id>>();
        
        for(Task__c task: [SELECT Id, Project__c, Person__c FROM Task__c WHERE Person__c IN : personIds]){

            Set<Id> projectsIds = projectsByPersonsIds.get(task.Person__c);

            if(projectsIds == null){
                projectsByPersonsIds.put(task.Person__c, new Set<Id>{task.Project__c});
            }else {
                projectsIds.add(task.Project__c);   
            }
        }

        return projectsByPersonsIds;
    }

    public static List<Project__c> getFiveBiggestProjects(){

        AggregateResult[] groupedFiveBiggestProjects = [SELECT Project__c, COUNT_DISTINCT(Person__c)PersonCount  
                                    	                FROM Task__c 
                                    	                GROUP BY Project__c 
                                    	                ORDER BY COUNT_DISTINCT(Person__c) DESC 
                                    	                LIMIT 5];
        Set<Id> projectsIds = new Set<Id>();

        for (AggregateResult ar : groupedFiveBiggestProjects)  {
            
            //System.debug('Project:' + ar.get('Project__c') + ' ' + 'Person count:' + ar.get('PersonCount'));
            
			projectsIds.add(String.valueOf(ar.get('Project__c')));
        }

        return [SELECT Id, Name, Status__c FROM Project__c WHERE Id IN : projectsIds];
    }

}
