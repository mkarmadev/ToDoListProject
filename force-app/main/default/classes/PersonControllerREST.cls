@RestResource(urlMapping='/Person/highestNumberOfAssignedProjects')
global  with sharing class PersonControllerREST {
    
    @HttpGet
    global static List<Person__c> getHighestNumberOfAssignedProjects() {
        
        List<Person__c> result = [SELECT First_Name__c, Last_Name__c, Total_Amount_of_Projects__c  
                                  FROM Person__c 
                                  ORDER BY Total_Amount_of_Projects__c DESC 
                                  LIMIT 5];
        
        return result;
    }

}
