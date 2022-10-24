@isTest
public class CheckEnteredValuesForTaskTest {

    @isTest static void testCanNotChangePersonInCompletedTasks() {

        Person__c person1 = TestDataFactory.createPerson('TestPerson');
        insert person1;

        Person__c person2 = TestDataFactory.createPerson('TestPerson');
        insert person2;

        List<Task__c> tasks = TestDataFactory.createProjectsWithTasks(1, 100, person1.id, ToDoListService.Task_Status_Completed);

        System.assert(tasks.size() == 100, 'Expected 100 tasks');


        tasks = TestDataUtils.changePersonInTasks(tasks, person2.Id);


        Test.startTest();
            Database.SaveResult[] srList = Database.update(tasks, false);
        Test.stopTest();


        for (Database.SaveResult sr : srList) {
            
            System.assert(!sr.isSuccess());
            System.assert(sr.getErrors().size() > 0);
            System.assertEquals('Сan\'t change the personа of a completed task',
                                sr.getErrors()[0].getMessage());
        }

    }

    
    @isTest static void testChangePersonInNotCompletedTasks() {

        Person__c person1 = TestDataFactory.createPerson('TestPerson');
        insert person1;

        Person__c person2 = TestDataFactory.createPerson('TestPerson');
        insert person2;

        List<Task__c> tasks = TestDataFactory.createProjectsWithTasks(1, 100, person1.id, ToDoListService.Task_Status_Draft);

        System.assert(tasks.size() == 100, 'Expected 100 tasks');

        
        tasks = TestDataUtils.changePersonInTasks(tasks, person2.Id);


        Test.startTest();
            Database.SaveResult[] srList = Database.update(tasks, false);
        Test.stopTest();


        for (Database.SaveResult sr : srList) {
            System.assert(sr.isSuccess());
        }
    }
    
}
