@isTest
public with sharing class ToDoListDAOTest {
    
    
    static final String Person_Name_For_Overdue_Task = 'PersonForOverdueTask';
    static final String Person_Name_For_Five_Biggest_Projects = 'PersonForFiveBiggestProjects';
    static final String Overdue_Project_Name = 'OverdueProject';
    static final String Biggest_Project_Name = 'BiggestProjects';
    static final Date DATE_TODAY                 = System.today();

    @testSetup
    static void setup() {

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Person__c> persons = new List<Person__c>();
        
        for (Integer i=0; i<4; i++) {
            persons.add(
                TestDataFactory.createPerson(Person_Name_For_Overdue_Task)
            );
        }

        for (Integer i=0; i<14; i++) {
            persons.add(
                TestDataFactory.createPerson(Person_Name_For_Five_Biggest_Projects)
            );
        }
        insert persons;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        List<Person__c> personsForOverdueTasks = [SELECT Id FROM Person__c WHERE First_Name__c =: Person_Name_For_Overdue_Task];
        List<Person__c> personsForBiggestProjects = [SELECT Id FROM Person__c WHERE First_Name__c =: Person_Name_For_Five_Biggest_Projects];

        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Project__c> projects = new List<Project__c>();

        for (Integer i=0; i<4; i++) {
            projects.add( 
                TestDataFactory.createProject(Overdue_Project_Name + i)
            );
        }

        for (Integer i=0; i<7; i++) {
            projects.add(
                TestDataFactory.createProject(Biggest_Project_Name + i)
            );
        }
        insert projects;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Task__c> tasks = new List<Task__c>();
        //create Overdue Tasks for Overdue Project
        for(Project__c project : [SELECT Id FROM Project__c WHERE Name LIKE :(Overdue_Project_Name +'%')]){

            for(Person__c person : personsForOverdueTasks){ 
                tasks.add(
                    TestDataFactory.createOverdueTask(project.Id, person.Id)
                );
            }    
        }

        //create Tasks for Biggest Projects
        Integer numberOfTasksForTheProject = personsForBiggestProjects.size();
        for(Project__c project : [SELECT Id FROM Project__c WHERE Name LIKE :(Biggest_Project_Name + '%')]){

            for(Integer i = 0; i < numberOfTasksForTheProject; i++){
                tasks.add(
                    TestDataFactory.createStandardTask(project.Id, personsForBiggestProjects[i].Id, ToDoListService.Task_Status_Started, DATE_TODAY.addMonths(1))
                );    
            }
    
            numberOfTasksForTheProject -= 2;
        }
        insert tasks;
    }

    @isTest
    public static void testGetPerson(){

        ID personId = [SELECT Id FROM Person__c LIMIT 1].Id;

        Test.startTest();
            Person__c person = ToDoListDAO.getPerson(personId);
        Test.stopTest();    

        System.assertNotEquals(null, person, 'Object not found');
        System.assertEquals(personId, person.Id, 'Found object is not correct');
    }

    @isTest
    public static void testGetOverdueTasksByProjectIds(){

        Set<Id> personIds = new Map<Id, Person__c>([SELECT ID FROM Person__c WHERE First_Name__c = :Person_Name_For_Overdue_Task]).keyset();

        Test.startTest();
            Map<Id, List<Task__c>> tasksByProjectIds = ToDoListDAO.getOverdueTasksByProjectIds(personIds);
        Test.stopTest();    

        System.assert(tasksByProjectIds.size() > 0, 'Method did not return any data');


        Map<Id, Set<Id>> expectedTaskIdsByProjectIds = new Map<Id, Set<Id>>();
        for(Project__c project: [SELECT Id, (SELECT Id, Name, Project__c  FROM Tasks__r 
                                                                            WHERE Person__c IN : personIds 
                                                                                AND Status__c =: ToDoListService.Task_Status_Started  
                                                                                    AND End_Date__c <= TODAY)
                                                                FROM Project__c
                                                                WHERE Name LIKE 'OverdueProject%'] ){

            if(project.Tasks__r.size() > 0) {
                Set<Id> taskIds = new Map<Id, Task__c>(project.Tasks__r).keyset();
                
                expectedTaskIdsByProjectIds.put(project.Id, taskIds);
            }                                                     
        } 
        System.assert(expectedTaskIdsByProjectIds.size() > 0, 'We did not find any data to compare');


        Set<Id> projectsIds         = tasksByProjectIds.keyset();
        Set<Id> expectedProjectsIds = expectedTaskIdsByProjectIds.keyset();

        System.assertEquals(true, expectedProjectsIds.equals(projectsIds), 'Project IDs are different');

        
        for(ID projectKey : expectedTaskIdsByProjectIds.keySet()){
            
            Set<Id> taskIds         = new Map<Id, Task__c>(tasksByProjectIds.get(projectKey)).keyset();
            Set<Id> expectedTaskIds = expectedTaskIdsByProjectIds.get(projectKey);
            
            System.assertEquals(true, expectedTaskIds.equals(taskIds), 'Project with ID = ' + projectKey + ' has different task IDs');
        }

    }

    @isTest
    public static void testGetProjectsByPersonsIds(){

        Set<Id> personIdsOfOverdueTasks = new Map<Id, Person__c>([SELECT ID FROM Person__c WHERE First_Name__c = : Person_Name_For_Overdue_Task]).keyset();
        
        Test.startTest();
            Map<Id, Set<Id>> projectsByPersonsIds = ToDoListDAO.getProjectsByPersonsIds(personIdsOfOverdueTasks);
        Test.stopTest();    

        System.assert(projectsByPersonsIds.size() > 0, 'Method did not return any data');


        Map<Id, Set<Id>> expectedProjectsIdsByPersonsIds = new Map<Id, Set<Id>>();
        for(Task__c task: [SELECT Id, Project__c, Person__c FROM Task__c WHERE Person__c IN : personIdsOfOverdueTasks]){
            
            Set<Id> projectsIds = expectedProjectsIdsByPersonsIds.get(task.Person__c);

            if(projectsIds == null){
                expectedProjectsIdsByPersonsIds.put(task.Person__c, new Set<Id>{task.Project__c});
            }else {
                projectsIds.add(task.Project__c);   
            }                                                         
        } 
        System.assert(expectedProjectsIdsByPersonsIds.size() > 0, 'We did not find any data to compare');

        System.assertEquals(true, expectedProjectsIdsByPersonsIds.equals(projectsByPersonsIds), 'Returned data is not equal to expected');

        /* Set<Id> personIds           = projectsByPersonsIds.keyset();
        Set<Id> expectedPersonIds   = expectedProjectsIdsByPersonsIds.keyset();

        System.assertEquals(true, expectedPersonIds.equals(personIds), 'Person IDs are different');

        for(ID personKey : expectedProjectsIdsByPersonsIds.keySet()){
            
            Set<Id> projectIds         = projectsByPersonsIds.get(personKey);
            Set<Id> expectedProjectIds = expectedProjectsIdsByPersonsIds.get(personKey);
            
            System.assertEquals(true, expectedProjectIds.equals(projectIds), 'Person with ID = ' + personKey + ' has different project IDs');
        } */
    }

    @isTest
    public static void testGetFiveBiggestProjects(){

        Test.startTest();
            List<Project__c> projects = ToDoListDAO.getFiveBiggestProjects();
        Test.stopTest();    
        
        System.assert(projects.size() == 5, 'Expected five projects');

        List<Project__c> expectedProjects = [SELECT Id, Status__c, Name FROM Project__c WHERE Name LIKE :(Biggest_Project_Name + '%') ORDER BY Name LIMIT 5];
        
        System.assert(expectedProjects.size() > 0, 'We did not find any data to compare');


        Set<Id> projectIds          = new Map<Id, Project__c>(projects).keyset();
        Set<Id> expectedProjectIds  = new Map<Id, Project__c>(expectedProjects).keyset();

        System.assertEquals(true, expectedProjectIds.equals(projectIds), 'Project IDs are different');
    }

    



}
