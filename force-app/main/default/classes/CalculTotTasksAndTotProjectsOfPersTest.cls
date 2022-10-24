@isTest
public class CalculTotTasksAndTotProjectsOfPersTest {
   
    static Id personId;
    
    @testSetup
    static void setup() {

        Person__c person = TestDataFactory.createPerson('TestPerson');
        insert person;

        List<Task__c> tasks = TestDataFactory.createProjectsWithTasks(10, 15, person.id, null);
    }

    @isTest
    public static void calculateTotalTasksAndTotalProjectsOnAfterInsert(){
        
        Person__c person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];

        System.assertNotEquals(null, person, 'Object not found');
        
        System.assertEquals(10, person.Total_Amount_of_Projects__c, 'The total number of projects does not match');

        System.assertEquals(150, person.Total_Amount_of_Tasks__c, 'The total number of tasks does not match');
    }

    @isTest
    public static void calculateTotalTasksAndTotalProjectsOnAfterUpdate(){
        
        Person__c person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];

        Test.startTest();
            //Create new projects and task
            List<Task__c> tasks = TestDataFactory.createProjectsWithTasks(5, 15, person.id, null);
        Test.stopTest();

        person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];


        System.assertNotEquals(null, person, 'Object not found');
        
        System.assertEquals(15, person.Total_Amount_of_Projects__c, 'The total number of projects does not match');

        System.assertEquals(225, person.Total_Amount_of_Tasks__c, 'The total number of tasks does not match');
    }

    @isTest
    public static void calculateTotalTasksAndTotalProjectsOnAfterUpdate_DeletePersonFromTask(){
        
        Person__c person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];

        //delete 10 tasks
        Test.startTest();
            TestDataUtils.deletePersonsFromTasks(person.id);
        Test.stopTest();

        person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];

        System.assertNotEquals(null, person, 'Object not found');
        
        System.assertEquals(0, person.Total_Amount_of_Projects__c, 'The total number of projects does not match');

        System.assertEquals(0, person.Total_Amount_of_Tasks__c, 'The total number of tasks does not match');
    }

    @isTest
    public static void calculateTotalTasksAndTotalProjectsOnAfterDelete(){
        
        Person__c person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];


        System.assertNotEquals(null, person, 'Object not found');
        
        System.assertEquals(10, person.Total_Amount_of_Projects__c, 'The total number of projects does not match');

        System.assertEquals(150, person.Total_Amount_of_Tasks__c, 'The total number of tasks does not match');


        //delete 10 tasks
        Test.startTest();
            TestDataUtils.deleteTasksFromProjects(2, 5, person.id);
        Test.stopTest();    

        person = [SELECT Id, Total_Amount_of_Projects__c, Total_Amount_of_Tasks__c FROM Person__c LIMIT 1];

        System.assertEquals(10, person.Total_Amount_of_Projects__c, 'The total number of projects does not match');

        System.assertEquals(140, person.Total_Amount_of_Tasks__c, 'The total number of tasks does not match');
    }

}
