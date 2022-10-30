@isTest
global class PersonSyncHttpCalloutMock implements HttpCalloutMock {

    Integer statusCode = 200;

    public PersonSyncHttpCalloutMock(Integer statusCode){
        this.statusCode = statusCode;
    }

    global HTTPResponse respond(HTTPRequest request) {
        
        HttpResponse response = new HttpResponse();
        response.setHeader('Content-Type', 'application/json');
        response.setStatusCode(statusCode);
        return response; 
    }
  
}
