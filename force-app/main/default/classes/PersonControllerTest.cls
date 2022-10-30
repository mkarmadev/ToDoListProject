
@isTest
public  class PersonControllerTest {
    
    @testSetup
    static void setup() {

        Person__c person = TestDataFactory.createPerson('Test');
        insert person;
    }

    @isTest 
    static void testPostPersonSyncSuccessful() {

        Person__c person = [SELECT Id, Is_Synced__c FROM Person__c LIMIT 1];


        System.assertNotEquals(null, person, 'Person was not created');
        System.assert(person.Is_Synced__c == false, 'Person must not be synced');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PersonSyncHttpCalloutMock(200));

        HttpResponse response = PersonController.postPersonSync(person.Id);

        
        System.assertEquals(200, response.getStatusCode(), 'Status code is not 200');


        person = [SELECT Id, Is_Synced__c FROM Person__c LIMIT 1];

        System.assertEquals(true, person.Is_Synced__c, 'Person was synced');
        Test.stopTest();
    }


    @isTest 
    static void testPostPersonSyncFailed() {

        Person__c person = [SELECT Id, Is_Synced__c FROM Person__c LIMIT 1];


        System.assertNotEquals(null, person, 'Person was not created');
        System.assert(person.Is_Synced__c == false, 'Person must not be synced');

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new PersonSyncHttpCalloutMock(400));

        Boolean catchError = false;
        try{
            HttpResponse response = PersonController.postPersonSync(person.Id);
        } catch(Exception e) {
            catchError = true;    
        }
        
        System.assert(catchError == true, 'Waiting for an error');

        person = [SELECT Id, Is_Synced__c FROM Person__c LIMIT 1];

        System.assertEquals(false, person.Is_Synced__c, 'Person must not be synced');
        Test.stopTest();
}


}


