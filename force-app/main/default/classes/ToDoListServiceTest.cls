@isTest
public class ToDoListServiceTest {
    
    static final String Delete_Project_Name      = 'DeleteProject';
    static final String Maintest_Project_Name    = 'MainTestProject';
    static final Date DATE_TODAY                 = System.today();


    @testSetup
    static void setup() {
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        List<Project__c> projects = new List<Project__c>();

        for (Integer i=0; i<10; i++) {
            projects.add( 
                TestDataFactory.createProject(Delete_Project_Name)
            );
        }
        
        projects.add(
            TestDataFactory.createProject(Maintest_Project_Name)
        );
        insert projects;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
        ID mainProjectId = [SELECT Id FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1].Id;

        List<Task__c> tasks = new List<Task__c>();
        for (Integer i=0; i<10; i++) {
            tasks.add(
                TestDataFactory.createStandardTask(mainProjectId, null, ToDoListService.Task_Status_Draft, DATE_TODAY)
            );
        }

        for (Integer i=0; i<5; i++) {
            tasks.add(
                TestDataFactory.createStandardTask(mainProjectId, null, ToDoListService.Task_Status_Completed, DATE_TODAY)                
            );
        }
        tasks.add(
            TestDataFactory.createStandardTask(mainProjectId, null, ToDoListService.Task_Status_Completed, DATE_TODAY.addDays(10))
        );
        
        tasks.add(
            TestDataFactory.createStandardTask(mainProjectId, null, ToDoListService.Task_Status_Started, DATE_TODAY)
        );


        for(Project__c project : [SELECT Id FROM Project__c WHERE Name = : Delete_Project_Name]){

            for (Integer i=0; i<5; i++) {
                tasks.add(
                    TestDataFactory.createStandardTask(project.Id, null, ToDoListService.Task_Status_Draft, DATE_TODAY)
                );
            }
        }

        insert tasks;
        //////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

        Person__c person = TestDataFactory.createPerson('TestPerson');
        insert person;

    }

    @isTest
    public static void testAllStatusesDraft(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c 
                                        FROM Task__c 
                                        WHERE Status__c =: ToDoListService.Task_Status_Draft 
                                            AND Project__r.Name =: Maintest_Project_Name];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals(ToDoListService.Project_Status_Draft, status, 'Wrong project status when all tasks statuses are equal to Draft');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedInTime(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c 
                                        FROM Task__c 
                                        WHERE Status__c =: ToDoListService.Task_Status_Completed  
                                            AND End_Date__c <= TODAY 
                                                AND Project__r.Name =:Maintest_Project_Name];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals(ToDoListService.Project_Status_FinishedInTime, status, 'Wrong project status when all tasks are finished in time');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedWithDelay(){

        List<Task__c> tasks = [SELECT Id, Status__c, End_Date__c 
                                        FROM Task__c 
                                        WHERE Status__c =: ToDoListService.Task_Status_Completed 
                                            AND Project__r.Name =: Maintest_Project_Name];
        
        String status = ToDoListService.getProjectStatus(tasks, Date.today());
    
        System.assertEquals(ToDoListService.Project_Status_FinishedWithDelay, status, 'Wrong project status when one task is finished with delay');
    }

    @isTest
    public static void testOneTaskStatusStarted(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c 
                                        FROM Task__c 
                                        WHERE Project__r.Name =: Maintest_Project_Name];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals(ToDoListService.Project_Status_InProgress, status, 'Wrong project status when any task is Started');
    }

    @isTest
    public static void testOtherCases(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c 
                                        FROM Task__c 
                                        WHERE Status__c != :ToDoListService.Task_Status_Started 
                                            AND Project__r.Name =: Maintest_Project_Name];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals(ToDoListService.Project_Status_Draft, status, 'Wrong project status by default');
    }

    @isTest
    public static void testCreatePerson(){

        String firstName = 'DjonDL';
        String lastName  = 'SongDL';

        List<Person__c> persons = [SELECT Id, First_Name__c, Last_Name__c 
                                        FROM Person__c 
                                        WHERE First_Name__c =: firstName 
                                            AND Last_Name__c =: lastName];
        
        System.assert(persons.size() == 0, 'Person record ' + firstName + ' ' + lastName + ' exists in the database');
        
        Test.startTest();
            ToDoListService.createPerson(firstName, lastName);
        Test.stopTest();    

        persons = [SELECT Id, First_Name__c, Last_Name__c 
                                        FROM Person__c 
                                        WHERE First_Name__c =: firstName 
                                            AND Last_Name__c =: lastName];

        System.assert(persons.size() == 1, 'Expected one person');

        Person__c person = persons[0];
        
        System.assert(person.First_Name__c == firstName 
                            && person.Last_Name__c == lastName, 'Person’s name is not correct');
    }

    @isTest
    public static void testStartNewTask(){

        ID projectId= [SELECT Id FROM Project__c LIMIT 1].Id;
        ID personId = [SELECT Id FROM Person__c LIMIT 1].Id;
        
        Task__c task = ToDoListService.startNewTask(projectId, personId);
        
        System.assertNotEquals(null, task, 'Object not create');

        System.assert(task.Id == null
                        && task.Status__c == ToDoListService.Task_Status_Draft 
                            && task.Start_Date__c == System.today(), 'Field values are not correct');
    }

    @isTest
    public static void testUpdateTaskStatusesForProject(){

        ID projectId= [SELECT Id FROM Project__c WHERE Name = : Delete_Project_Name LIMIT 1].Id;

        Integer expectedNumberOfTasks = [SELECT COUNT() FROM Task__c WHERE Project__c =: projectId AND Status__c =: ToDoListService.Task_Status_Draft];

        System.assert(expectedNumberOfTasks > 0, 'We did not find any tasks to update');

        Test.startTest();
            ToDoListService.updateTaskStatusesForProject(projectId, ToDoListService.Task_Status_Started);
        Test.stopTest();    

        System.assertEquals(expectedNumberOfTasks, 
                                [SELECT COUNT() FROM Task__c WHERE Project__c =: projectId AND Status__c =: ToDoListService.Task_Status_Started], 
                                    'Status was not updated');
    }

    @isTest
    public static void testDeleteProjects(){

        Set<Id> projectIds = new Map<Id, Project__c>([SELECT Id FROM Project__c WHERE Name =: Delete_Project_Name]).keyset();
        
        System.assert(projectIds.size() > 0, 'We did not find any projects to delete');

        Test.startTest();
            ToDoListService.deleteProjects(projectIds);
        Test.stopTest();    

        System.assertEquals(0, [SELECT COUNT() FROM Project__c WHERE Name =: Delete_Project_Name], 'Projects was not deleted');
    }

    

}
