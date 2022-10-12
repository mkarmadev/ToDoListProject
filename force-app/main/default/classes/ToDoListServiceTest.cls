@isTest
public class ToDoListServiceTest {
    
    @testSetup
    static void setup() {

        Project__c project = new Project__c(name = 'Main Test Project');
        insert project;


        List<Task__c> tasks = new List<Task__c>();

        for (Integer i=0; i<10; i++) {
            tasks.add(new Task__c(Project__c = project.id, Status__c = 'Draft'));
        }

        for (Integer i=0; i<5; i++) {
            tasks.add(new Task__c(Project__c = project.id, Status__c = 'Completed', End_Date__c = Date.today()));
        }
        tasks.add(new Task__c(Project__c = project.id, Status__c = 'Completed', End_Date__c = Date.today().addDays(10)));
        
        tasks.add(new Task__c(Project__c = project.id, Status__c = 'Started'));
        
        
        insert tasks;

    }

    @isTest
    public static void testAllStatusesDraft(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c FROM Task__c WHERE Status__c = 'Draft'];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals('Draft', status, 'Wrong project status when all tasks statuses are equal to Draft');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedInTime(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c FROM Task__c WHERE Status__c = 'Completed' AND End_Date__c <= TODAY];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals('Finished in Time', status, 'Wrong project status when all tasks are finished in time');
    }

    @isTest
    public static void testAllStatusCompletedAndFinishedWithDelay(){

        List<Task__c> tasks = [SELECT Id, Status__c, End_Date__c FROM Task__c WHERE Status__c = 'Completed'];
        
        String status = ToDoListService.getProjectStatus(tasks, Date.today());
    
        System.assertEquals('Finished with Delay', status, 'Wrong project status when one task is finished with delay');
    }

    @isTest
    public static void testOneTaskStatusStarted(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c FROM Task__c];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals('In Progress', status, 'Wrong project status when any task is Started');
    }

    @isTest
    public static void testOtherCases(){

        List<Task__c> tasks = [SELECT Id, Name, Status__c, End_Date__c FROM Task__c WHERE Status__c != 'Started'];

        String status = ToDoListService.getProjectStatus(tasks, Date.today());

        System.assertEquals('Draft', status, 'Wrong project status by default');
    }

}
