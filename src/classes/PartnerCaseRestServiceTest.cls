@isTest
private class PartnerCaseRestServiceTest {

    static testMethod void updateIncidentTest(){

        Case testIncident = [Select Id, CaseNumber from Case Limit 1];
        String caseNumber = testIncident.CaseNumber;

        ETMS_Trouble_Report_State_Status__mdt[] mdtList = [
                Select Case_Status__c, Trouble_Report_State__c, Trouble_Report_Status__c
                From ETMS_Trouble_Report_State_Status__mdt
                where SF_Inbound__c = true
                order by Trouble_Report_State__c
        ];

        test.startTest();

        system.assert(mdtList.size() > 0, 'No records in ETMS_Trouble_Report_State_Status__mdt for SF Inbound.');

        PartnerCaseRestService.UpdateRequest updateRequest = new PartnerCaseRestService.UpdateRequest();
        updateRequest.troubleReportId = caseNumber;
        updateRequest.comments = new String[]{'comment 1', 'comment 2'};
        updateRequest.troubleReportStatus = mdtList[0].Trouble_Report_Status__c.toPlainString();
        updateRequest.troubleReportState = mdtList[0].Trouble_Report_State__c.toPlainString();


        RestRequest request = new RestRequest();
        request.requestURI = '/PartnerCase';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        request.headers.put('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        PartnerCaseRestService.updateIncident();

        test.stopTest();

        system.assertEquals(200, response.statusCode);
        system.assertEquals('SUCCESS', response.responseBody.toString());

        Case incident = [Select Status from Case where Id = :testIncident.Id];
        system.assertEquals(mdtList[0].Case_Status__c, incident.Status, 'Case status update failed.');

        CaseComment[] comments = [Select Id from CaseComment where ParentId = :testIncident.Id];
        system.assertEquals(updateRequest.comments.size(), comments.size(), 'Case comment update failed.');

        // make sure the proxy service callout didn't happen
        system.assertEquals(false, PartnerCaseProxyServiceHelper.isCasePushed);

    }

    static testMethod void longCommentTest(){

        Case testIncident = [Select Id, CaseNumber from Case Limit 1];
        String caseNumber = testIncident.CaseNumber;

        Integer commentMaxLength = CaseComment.CommentBody.getDescribe().getLength();

        String longComment = 'This comment is too long for Salesforce to handle';

        do{
            longComment = longComment + longComment;
        } while (longComment.length() <= commentMaxLength);

        PartnerCaseRestService.UpdateRequest updateRequest = new PartnerCaseRestService.UpdateRequest();
        updateRequest.troubleReportId = caseNumber;
        updateRequest.comments = new String[]{longComment};

        test.startTest();

        RestRequest request = new RestRequest();
        request.requestURI = '/PartnerCase';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        request.headers.put('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        PartnerCaseRestService.updateIncident();

        test.stopTest();

        system.assertEquals(200, response.statusCode);
        system.assertEquals('SUCCESS', response.responseBody.toString());

        CaseComment[] comments = [Select Id from CaseComment where ParentId = :testIncident.Id];
        system.assertEquals(updateRequest.comments.size(), comments.size(), 'Case comment update failed.');

    }

    static testMethod void invalidTroubleReportIdTest(){

        test.startTest();

        PartnerCaseRestService.UpdateRequest updateRequest = new PartnerCaseRestService.UpdateRequest();
        updateRequest.troubleReportId = 'XAQWER23432';
        updateRequest.comments = new String[]{'comment 1', 'comment 2'};

        RestRequest request = new RestRequest();
        request.requestURI = '/PartnerCase';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        request.headers.put('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        PartnerCaseRestService.updateIncident();

        test.stopTest();

        system.assertEquals(400, response.statusCode);
        system.assertEquals('INVALID_TROUBLE_REPORT_ID', response.responseBody.toString());

    }

    static testMethod void invalidTroubleReportStateTest(){

        Case testIncident = [Select Id, CaseNumber from Case Limit 1];
        String caseNumber = testIncident.CaseNumber;

        test.startTest();

        PartnerCaseRestService.UpdateRequest updateRequest = new PartnerCaseRestService.UpdateRequest();
        updateRequest.troubleReportId = caseNumber;
        updateRequest.comments = new String[]{'comment 1', 'comment 2'};
        updateRequest.troubleReportStatus = '18478';
        updateRequest.troubleReportState = '92457';

        RestRequest request = new RestRequest();
        request.requestURI = '/PartnerCase';
        request.requestBody = Blob.valueOf(JSON.serialize(updateRequest));
        request.headers.put('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        PartnerCaseRestService.updateIncident();

        test.stopTest();

        system.assertEquals(400, response.statusCode);
        system.assertEquals('INVALID_TROUBLE_REPORT_STATE_OR_STATUS', response.responseBody.toString());

    }

    static testMethod void exceptionHandlingTest(){

        test.startTest();

        // no body
        RestRequest request = new RestRequest();
        request.requestURI = '/PartnerCase';
        request.headers.put('Content-Type', 'application/json');
        request.httpMethod = 'POST';
        RestContext.request = request;

        RestResponse response = new RestResponse();
        RestContext.response = response;

        PartnerCaseRestService.updateIncident();

        test.stopTest();

        system.assertEquals(500, response.statusCode);

    }

    @TestSetup
    private static void createTestData(){

        SiteConfiguration__c siteConfig = new SiteConfiguration__c();
        siteConfig.Name = inContactBaseClass.OrgId15Digit; //UserInfo.getOrganizationId();
        siteConfig.AutoEventEmails__c = false;
        siteConfig.DaysToDisplayKnownIssues__c = 30;
        siteConfig.OrgId__c =  inContactBaseClass.OrgId15Digit; //UserInfo.getOrganizationId();
        siteConfig.EventResolvedPriorities__c = 'P1;P2;';
        siteConfig.EventResolvedEmails__c = false;

        insert siteConfig;


        Map<String,Schema.RecordTypeInfo> accountRecordTypeMap = Schema.SObjectType.Account.getRecordTypeInfosByName();
        Account verizonAccount = new Account(
                Name = 'Verizon Test Account',
                Billing_Group__c = PartnerCaseProxyServiceHelper.BILLING_GROUP_VERIZON,
                Type = 'Partner',
                RecordTypeId = accountRecordTypeMap.get('Partners').getRecordTypeId(),
                CadebillAccountNo__c = 877121,
                Partner_Customer_Account_ID__c = null
        );

        insert verizonAccount;

        Map<String,Schema.RecordTypeInfo> contactRecordTypeMap = Schema.SObjectType.Contact.getRecordTypeInfosByName();
        Contact verizonContact = new Contact(
                LastName = 'Test Contact',
                FirstName = 'Verizon',
                Email = 'contact1@test.com',
                RecordTypeId = contactRecordTypeMap.get('Partner Contact').getRecordTypeId(),
                AccountId = verizonAccount.Id
        );

        insert verizonContact;

        // create an incident
        Map<String,Schema.RecordTypeInfo> testIncidentTypeMap = Schema.SObjectType.Case.getRecordTypeInfosByName();
        Case testIncident = new Case(
                RecordTypeId = testIncidentTypeMap.get('Incident').getRecordTypeId(),
                Subject = 'Verizon Test',
                Status = 'New',
                AccountId = verizonAccount.Id,
                ContactId = verizonContact.Id,
                Request_Type__c = 'Connectivity',
                Product_or_Service__c = 'Local',
                X3rdPartyVendorTicket__c = '20170925'
        );

        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.AssignmentRuleHeader.useDefaultRule = true;
        testIncident.setOptions(dmo);
        insert testIncident;

    }

}