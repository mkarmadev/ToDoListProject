@isTest
public class TestDataFactory {

    public static Project__c createProject(String projectName){

        return new Project__c(
                                Name = projectName, 
                                Status__c = 'In Progress');
    }

    public static Task__c createStandardTask(Id projectId, Id personId, String status, Date endDate){

        return new Task__c(
                            Label__c = 'Standart Task', 
                            Status__c = status, 
                            Project__c = projectId,
                            Person__c  = personId, 
                            End_Date__c = endDate);                           
    }

    public static Task__c createOverdueTask(Id projectId, Id personId){

        return new Task__c(
                            Label__c = 'Overdue Task', 
                            Status__c = 'Started', 
                            Project__c = projectId,
                            Person__c  = personId, 
                            End_Date__c = System.today().addDays(-10));                           
    }

    public static Person__c createPerson(String firsName){

        return New Person__c(
                            First_Name__c = firsName);
    }

    public static List<Task__c> createProjectsWithTasks(Integer numProjects, Integer numTasksOfProj, Id personId, String taskStatus){

        List<Project__c> projects = new List<Project__c>();
        
        for(Integer i=0; i < numProjects; i++) {
            projects.add(
                createProject('Test')
            );
        }

        insert projects;

        List<Task__c> tasks = new List<Task__c>();
        

        for (Integer j=0;j<numProjects;j++) {
            
            Project__c project = projects[j];
            
            for (Integer k=0; k<numTasksOfProj; k++) {
                tasks.add(
                    TestDataFactory.createStandardTask(project.Id, 
                                                        personId, 
                                                        taskStatus == null ? 'Started' : taskStatus, 
                                                        System.today().addMonths(1))
                );
            }
        }
        
        insert tasks;
        
        return tasks;
    }

    public static List<Task__c> createTasksForProject(Id projectId, Id personId, Integer numTasksOfProj, String status, Date endDate){

        List<Task__c> tasks = new List<Task__c>();
        
        for(Integer i=0; i < numTasksOfProj; i++) {
            tasks.add(
                createStandardTask(projectId, personId, status, endDate)
            );
        }

        return tasks;
    }

    


}
