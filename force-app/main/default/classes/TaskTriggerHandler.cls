public class TaskTriggerHandler {

    public static void onBeforeUpdate(List<Task__c> newTasks, Map<Id, Task__c> oldTasksMap){

        checkPersonChangeInCompletedTasks(newTasks, oldTasksMap);    
    }

    public static void onAfterInsert(List<Task__c> newTasks){

        calculatTotalTasksAndTotalProjectsOfPerson(getPersonsIds(newTasks));

        setProjectStatusesBasedOnTasks(getProjectsIds(newTasks));
    }

    public static void onAfterUpdate(List<Task__c> newTasks, List<Task__c> oldTasks){
        
        Set<Id> personsIds = getPersonsIds(newTasks);
        personsIds.addAll(getPersonsIds(oldTasks));
        
        calculatTotalTasksAndTotalProjectsOfPerson(personsIds);

        setProjectStatusesBasedOnTasks(getProjectsIds(newTasks));    
    }

    public static void onAfterDelete(List<Task__c> oldTasks){

        calculatTotalTasksAndTotalProjectsOfPerson(getPersonsIds(oldTasks));

        setProjectStatusesBasedOnTasks(getProjectsIds(oldTasks));
    }

    public static void checkPersonChangeInCompletedTasks(List<Task__c> newTasks, Map<Id, Task__c> oldTasksMap){

        for (Task__c task : newTasks) {
            
            if(task.Status__c != ToDoListService.Task_Status_Completed)
                continue;
            

            Task__c oldTask = oldTasksMap.get(task.Id);
            if(task.Person__c <> oldTask.Person__c){
                task.Person__c.addError('Сan\'t change the personа of a completed task');
            }
        }
    }

    public static void calculatTotalTasksAndTotalProjectsOfPerson(Set<Id> personsIds) {

        if(personsIds.size() == 0){
            return;
        }
        
        List<Person__c> personsToUpdate = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c  
                                                                    FROM Person__c 
                                                                    WHERE Id IN : personsIds];

        
        Map<Id, Set<Id>> personsIdsToProjectsIds = new Map<Id, Set<Id>>();
        Map<Id, Set<Id>> personsIdsToTasksIds = new Map<Id, Set<Id>>();                                                            
        for(Task__c task : [SELECT Id, Person__c, Project__c FROM Task__c WHERE Person__c IN : personsIds]){

            if (personsIdsToProjectsIds.containsKey(task.Person__c)) {
                personsIdsToProjectsIds.get(task.Person__c).add(task.Project__c);
            } else {
                personsIdsToProjectsIds.put(
                    task.Person__c,
                    new Set<Id>{ task.Project__c }
                );
            }

            if (personsIdsToTasksIds.containsKey(task.Person__c)) {
                personsIdsToTasksIds.get(task.Person__c).add(task.Id);
            } else {
                personsIdsToTasksIds.put(
                    task.Person__c,
                    new Set<Id>{ task.Id }
                );
            } 
        }



        for(Person__c person : personsToUpdate){
            
            if (personsIdsToProjectsIds.containsKey(person.Id)) {
                person.Total_Amount_of_Projects__c = personsIdsToProjectsIds.get(person.Id).size();
            }else {
                person.Total_Amount_of_Projects__c = 0;        
            }

            if (personsIdsToTasksIds.containsKey(person.Id)) {
                person.Total_Amount_of_Tasks__c = personsIdsToTasksIds.get(person.Id).size();    
            }else {
                person.Total_Amount_of_Tasks__c = 0;   
            }
        }
        
        update personsToUpdate;        
    }

    public static void setProjectStatusesBasedOnTasks(Set<Id> projectsIds){
    
        if(projectsIds.size() == 0){
            return;
        }


        List<Project__c> projects = [SELECT Id, Planned_End_Date__c, Status__c, 
                                        (SELECT Id, Status__c, End_Date__c FROM Tasks__r) 
                                    FROM Project__c 
                                    WHERE Id IN : projectsIds];

        for(Project__c project : projects){
            project.Status__c = ToDoListService.getProjectStatus(project.Tasks__r, project.Planned_End_Date__c);        
        }
        
        update projects;
    }

    public static Set<Id> getPersonsIds(List<Task__c> tasks){
        
        Set<Id> personsIds = new Set<Id>();

        for(Task__c task : tasks){
            
            if(task.Person__c == null){
                continue;
            }

            personsIds.add(task.Person__c);    
        }

        return personsIds;    
    }

    public static Set<Id> getProjectsIds(List<Task__c> tasks){

        Set<Id> projectsIds = new Set<Id>();

        for(Task__c task : tasks){
            projectsIds.add(task.Project__c);    
        }

        return projectsIds;    
    }

}
