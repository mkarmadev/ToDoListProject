@isTest
public with sharing class ToDoListDAOTest {
    
    @testSetup
    static void setup() {

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Person__c> persons = new List<Person__c>();
        
        for (Integer i=0; i<4; i++) {
            persons.add(
                        createPerson('PersonForOverdueTask'));
        }

        for (Integer i=0; i<14; i++) {
            persons.add(
                        createPerson('PersonForFiveBiggestProjects'));
        }
        insert persons;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        List<Person__c> personsForOverdueTasks = [SELECT Id FROM Person__c WHERE First_Name__c = 'PersonForOverdueTask'];
        List<Person__c> personsForBiggestProjects = [SELECT Id FROM Person__c WHERE First_Name__c = 'PersonForFiveBiggestProjects'];

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Project__c> projects = new List<Project__c>();

        for (Integer i=0; i<4; i++) {
            projects.add( 
                         createProject('OverdueProject ' + i, 'In Progress'));
        }

        for (Integer i=0; i<7; i++) {
            projects.add(
                        createProject('BiggestProjects ' + i, 'In Progress'));
        }
        insert projects;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Task__c> tasks = new List<Task__c>();
        //create Overdue Tasks for Overdue Project
        for(Project__c project : [SELECT Id FROM Project__c WHERE Name LIKE 'OverdueProject%']){

            for(Person__c person : personsForOverdueTasks){ 
                tasks.add(
                        createOverdueTask(project.Id, person.Id));
            }    
        }

        Integer numberOfTasksForTheProject = personsForBiggestProjects.size();
        for(Project__c project : [SELECT Id FROM Project__c WHERE Name LIKE 'BiggestProjects%']){

            for(Integer i = 0; i < numberOfTasksForTheProject; i++){
                    tasks.add(
                                createStandartTask(project.Id, personsForBiggestProjects[i].Id));    
            }
    
            numberOfTasksForTheProject -= 2;
        }
        insert tasks;
    }

    @isTest
    public static void testGetPerson(){

        ID personId = [SELECT Id FROM Person__c LIMIT 1].Id;

        Person__c person = ToDoListDAO.getPerson(personId);

        System.assertNotEquals(null, person, 'Object not found');
        System.assertEquals(personId, person.Id, 'Found object is not correct');
    }

    @isTest
    public static void testGetOverdueTasksByProjectIds(){

        Set<Id> personIds = new Map<Id, Person__c>([SELECT ID FROM Person__c WHERE First_Name__c = 'PersonForOverdueTask']).keyset();

        Map<Id, List<Task__c>> tasksByProjectIds = ToDoListDAO.getOverdueTasksByProjectIds(personIds);

        System.assert(tasksByProjectIds.size() > 0, 'Method did not return any data');


        Map<Id, Set<Id>> expectedTaskByProjectIds = new Map<Id, Set<Id>>();
        for(Project__c project: [SELECT Id, (SELECT Id, Name, Project__c  FROM Tasks__r 
                                                                            WHERE Person__c IN : personIds 
                                                                                AND Status__c = 'Started'  
                                                                                    AND End_Date__c <= TODAY)
                                                                FROM Project__c
                                                                WHERE Name LIKE 'OverdueProject%'] ){

            if(project.Tasks__r.size() > 0) {
                Set<Id> taskIds = new Map<Id, Task__c>(project.Tasks__r).keyset();
                
                expectedTaskByProjectIds.put(project.Id, taskIds);
            }                                                     
        } 
        System.assert(expectedTaskByProjectIds.size() > 0, 'We did not find data to compare');
        

        Set<Id> projectsIds         = tasksByProjectIds.keyset();
        Set<Id> expectedProjectsIds = expectedTaskByProjectIds.keyset();

        System.assertEquals(true, expectedProjectsIds.equals(projectsIds), 'Project IDs are different');

        
        for(ID projectKey : expectedTaskByProjectIds.keySet()){
            
            Set<Id> taskIds         = new Map<Id, Task__c>(tasksByProjectIds.get(projectKey)).keyset();
            Set<Id> expectedTaskIds = expectedTaskByProjectIds.get(projectKey);
            
            System.assertEquals(true, expectedTaskIds.equals(taskIds), 'Project with ID = ' + projectKey + ' has different task IDs');
        }

    }

    @isTest
    public static void testGetProjectsByPersonsIds(){

        Set<Id> personIdsOverdueTask = new Map<Id, Person__c>([SELECT ID FROM Person__c WHERE First_Name__c = 'PersonForOverdueTask']).keyset();
        
        Map<Id, Set<Id>> projectsByPersonsIds = ToDoListDAO.getProjectsByPersonsIds(personIdsOverdueTask);

        System.assert(projectsByPersonsIds.size() > 0, 'Method did not return any data');


        Map<Id, Set<Id>> expectedProjectsByPersonsIds = new Map<Id, Set<Id>>();
        for(Task__c task: [SELECT Id, Project__c, Person__c FROM Task__c WHERE Person__c IN : personIdsOverdueTask]){
            
            Set<Id> projectsIds = expectedProjectsByPersonsIds.get(task.Person__c);

            if(projectsIds == null){
                expectedProjectsByPersonsIds.put(task.Person__c, new Set<Id>{task.Project__c});
            }else {
                projectsIds.add(task.Project__c);   
            }                                                         
        } 
        System.assert(expectedProjectsByPersonsIds.size() > 0, 'We did not find data to compare');


        Set<Id> personIds           = projectsByPersonsIds.keyset();
        Set<Id> expectedPersonIds   = expectedProjectsByPersonsIds.keyset();

        System.assertEquals(true, expectedPersonIds.equals(personIds), 'Person IDs are different');

        for(ID personKey : expectedProjectsByPersonsIds.keySet()){
            
            Set<Id> projectIds         = projectsByPersonsIds.get(personKey);
            Set<Id> expectedProjectIds = expectedProjectsByPersonsIds.get(personKey);
            
            System.assertEquals(true, expectedProjectIds.equals(projectIds), 'Person with ID = ' + personKey + ' has different project IDs');
        }
    }

    @isTest
    public static void testGetFiveBiggestProjects(){

        List<Project__c> projects = ToDoListDAO.getFiveBiggestProjects();
        
        System.assert(projects.size() == 5, 'Method returned incorrect data');

        List<Project__c> expectedProjects = [SELECT Id, Status__c, Name FROM Project__c WHERE Name LIKE 'BiggestProjects%' ORDER BY Name LIMIT 5];
        
        System.assert(expectedProjects.size() > 0, 'We did not find data to compare');


        Set<Id> projectIds          = new Map<Id, Project__c>(projects).keyset();
        Set<Id> expectedProjectIds  = new Map<Id, Project__c>(expectedProjects).keyset();

        System.assertEquals(true, expectedProjectIds.equals(projectIds), 'Project IDs are different');
    }

    public static Task__c createOverdueTask(Id projectId, Id personId){

        return new Task__c(
                            Label__c = 'Overdue Task', 
                            Status__c = 'Started', 
                            Project__c = projectId,
                            Person__c  = personId, 
                            End_Date__c = System.today().addDays(-10));                           
    }

    public static Task__c createStandartTask(Id projectId, Id personId){

        return new Task__c(
                            Label__c = 'Standart Task', 
                            Status__c = 'Started', 
                            Project__c = projectId,
                            Person__c  = personId, 
                            End_Date__c = System.today().addMonths(1));                           
    }

    public static Project__c createProject(String projectName, String projectStatus){

        return new Project__c(
                                Name = projectName, 
                                Status__c = projectStatus);
    }

    public static Person__c createPerson(String firsName){

        return New Person__c(
                            First_Name__c = firsName);
    }



}
