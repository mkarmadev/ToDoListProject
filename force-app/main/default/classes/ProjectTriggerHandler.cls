public class ProjectTriggerHandler {
   
    private static Set<Id> personsIds;

    public static void onBeforeDelete(List<Project__c> oldProjects){

        Set<Id> projectsIds = new Set<Id>();

        for(Project__c project : oldProjects){
            projectsIds.add(project.Id);    
        }
        
        Set<Id> personsIds = new Set<Id>();
        for(Task__c task : [SELECT Person__c FROM Task__c WHERE Project__c IN : projectsIds]){
            personsIds.add(task.Person__c);    
        }

        ProjectTriggerHandler.personsIds = personsIds;

    }

    public static void onAfterDelete(){

        TaskTriggerHandler.calculatTotalTasksAndTotalProjectsOfPerson(personsIds);

    }

    



}
