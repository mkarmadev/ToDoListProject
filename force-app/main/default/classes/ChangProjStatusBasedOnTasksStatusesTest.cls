
@isTest
public class ChangProjStatusBasedOnTasksStatusesTest {
    
    static final String Maintest_Project_Name    = 'MainTestProject';
    static final Date DATE_TODAY                 = System.today();

    @testSetup
    static void setup() {

        Project__c project = TestDataFactory.createProject(Maintest_Project_Name);    
        project.Planned_End_Date__c = DATE_TODAY;
        project.Status__c = '';

        insert project;
    }    

    @isTest
    public static void testAllStatusesDraft(){

        Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];
        
        System.assert(String.isBlank(project.Status__c), 'Project status must be empty');


        List<Task__c> tasks = TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Draft, DATE_TODAY);

        Test.startTest();
            Database.SaveResult[] srList = Database.insert(tasks, false);
        Test.stopTest();


        project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];


        System.assertEquals(ToDoListService.Project_Status_Draft, 
                                project.Status__c, 'Wrong project status when all tasks statuses are equal to Draft');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedInTime(){

        Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];
        
        System.assert(String.isBlank(project.Status__c), 'Project status must be empty');


        List<Task__c> tasks = TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Completed, DATE_TODAY);

        Test.startTest();
            Database.SaveResult[] srList = Database.insert(tasks, false);
        Test.stopTest();


        project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];

        System.assertEquals(ToDoListService.Project_Status_FinishedInTime, 
                                project.Status__c, 'Wrong project status when all tasks are finished in time');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedWithDelay(){

        Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];
        
        System.assert(String.isBlank(project.Status__c), 'Project status must be empty');


        List<Task__c> tasks = TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Completed, DATE_TODAY);
            tasks.add(
                TestDataFactory.createStandardTask(project.Id, null, ToDoListService.Task_Status_Completed, DATE_TODAY.addDays(10))
            );

        Test.startTest();
            Database.SaveResult[] srList = Database.insert(tasks, false);
        Test.stopTest();


        project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];

    
        System.assertEquals(ToDoListService.Project_Status_FinishedWithDelay, 
                                project.Status__c, 'Wrong project status when one task is finished with delay');
    }

    @isTest
    public static void testOneTaskStatusStarted(){

        Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];
        
        System.assert(String.isBlank(project.Status__c), 'Project status must be empty');

        List<Task__c> tasks = TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Draft, DATE_TODAY);

            tasks.addAll(
                TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Completed, DATE_TODAY)
            );
            
            tasks.add(
                TestDataFactory.createStandardTask(project.Id, null, ToDoListService.Task_Status_Started, DATE_TODAY)
            );

        
        Test.startTest();
            Database.SaveResult[] srList = Database.insert(tasks, false);
        Test.stopTest();


        project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];    

        System.assertEquals(ToDoListService.Project_Status_InProgress, 
                                project.Status__c, 'Wrong project status when any task is Started');
    }

    @isTest
    public static void testOtherCases(){

        Project__c project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];
        
        System.assert(String.isBlank(project.Status__c), 'Project status must be empty');


        List<Task__c> tasks = TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Draft, DATE_TODAY);

            tasks.addAll(
                TestDataFactory.createTasksForProject(project.Id, null, 5, ToDoListService.Task_Status_Completed, DATE_TODAY)
            );

            tasks.add(
                TestDataFactory.createStandardTask(project.Id, null, ToDoListService.Task_Status_Completed, DATE_TODAY.addDays(10))
            );


        Test.startTest();
            Database.SaveResult[] srList = Database.insert(tasks, false);
        Test.stopTest();    


        project = [SELECT Id, Status__c FROM Project__c WHERE Name =: Maintest_Project_Name LIMIT 1];

        System.assertEquals(ToDoListService.Project_Status_Draft, 
                                project.Status__c, 'Wrong project status by default');
    }

}
