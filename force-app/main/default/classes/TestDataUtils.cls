public class TestDataUtils {
    
    public static void deleteTasksFromProjects(Integer numProjects, Integer numTasksOfProj, Id personId){

        List<Task__c> tasks = new List<Task__c>();

        for(Project__c project : [SELECT Id, (SELECT Id FROM Tasks__r WHERE Person__c =: personId LIMIT :numTasksOfProj) 
                                    FROM Project__c 
                                    LIMIT : numProjects]){

            tasks.addAll(project.Tasks__r);
        }

        delete tasks;
    }

    public static void deletePersonsFromTasks(Id personId){

        List<Task__c> tasks = [SELECT Id, Person__c FROM Task__c WHERE Person__c =: personId];


        for(Task__c task : tasks){
            task.Person__c = null;    
        }

        update tasks;
    }

    public static List<Task__c> changePersonInTasks(List<Task__c> tasks, Id newPersonId){

        for(Task__c task : tasks){
            task.Person__c = newPersonId;    
        }

        return tasks;
    }

    


}
