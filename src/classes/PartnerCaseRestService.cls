@RestResource(urlMapping = '/PartnerCase/*')
global with sharing class PartnerCaseRestService {

    public class UpdateRequest{
        public String troubleReportId;
        public String troubleReportState;
        public String troubleReportStatus;
        public String[] comments;
    }

    @HttpPost
    global static void updateIncident(){

        RestRequest req = RestContext.request;
        RestResponse response = RestContext.response;

        system.debug('updateIncident(): RestRequest - ' + req);

        UpdateRequest request;
        Case incident = null;

        try{
            String requestBody = req.requestBody.toString();
            request = (UpdateRequest) JSON.deserialize(requestBody, UpdateRequest.Class);

            system.debug('updateIncident(): request - ' + request);

            // retrieve incident
            if(String.isNotBlank(request.troubleReportId)){

                Case[] incidentList = [
                        Select Id, Status, ETMS_Trouble_Report_State__c, ETMS_Trouble_Report_Status__c, X3rdPartyVendorTicket__c,
                                Reason__c, Database__c, Releases__c
                        from Case Where CaseNumber = :request.troubleReportId
                        and AccountBillingGroup__c = :PartnerCaseProxyServiceHelper.BILLING_GROUP_VERIZON
                        and RecordType.Name = 'Incident'
                        and X3rdPartyVendorTicket__c != null
                ];
                if(incidentList.size() > 0){
                    incident = incidentList[0];
                }
                system.debug('updateIncident(): incidentList - ' + incidentList);
            }

            if(incident == null){
                response.statusCode = 400;
                response.responseBody = Blob.valueOf('INVALID_TROUBLE_REPORT_ID');
                return;
            }

            // get status mapped to trouble report state and status
            if(String.isNotBlank(request.troubleReportState) && String.isNotBlank(request.troubleReportStatus)){

                Decimal troubleReportState, troubleReportStatus = null;
                try{
                    troubleReportState = Decimal.valueOf(request.troubleReportState);
                    troubleReportStatus = Decimal.valueOf(request.troubleReportStatus);
                } catch(Exception ex){
                    system.debug('updateIncident(): Exception - ' + ex);
                }

                system.debug('updateIncident(): troubleReportState - ' + troubleReportState + ' , troubleReportStatus - ' + troubleReportStatus);

                ETMS_Trouble_Report_State_Status__mdt[] mdtList = [
                        Select Case_Status__c, Trouble_Report_State__c, Trouble_Report_Status__c
                        From ETMS_Trouble_Report_State_Status__mdt
                        where Trouble_Report_State__c = :troubleReportState
                        and Trouble_Report_Status__c = :troubleReportStatus
                        and SF_Inbound__c = true
                ];

                if(mdtList.size() == 0){
                    response.statusCode = 400;
                    response.responseBody = Blob.valueOf('INVALID_TROUBLE_REPORT_STATE_OR_STATUS');
                    return;
                }
                // change incident status
                if(incident.status != mdtList[0].Case_Status__c){
                    incident.status = mdtList[0].Case_Status__c;

                    //if resolved, then the Reason Category, Reason, and Reason Detail need to be updated
                    if(incident.status == 'Resolved') {
                        //Reason Category
                        if(incident.Reason__c == null) {
                            incident.Reason__c = 'Verizon Resolved';
                        }

                        //Reason
                        if(incident.Database__c == null) {
                            incident.Database__c = 'Verizon Resolved';
                        }

                        //Reason Detail
                        if(incident.Releases__c == null) {
                            incident.Releases__c = 'Verizon Resolved';
                        }
                    }

                    CaseTriggerHandler.bypassProxyService = true;
                    update incident;
                }

            }

            // add case comment
            if(request.comments != null && request.comments.size() > 0){

                CaseComment[] commentList = new CaseComment[]{};

                Integer commentMaxLength = CaseComment.CommentBody.getDescribe().getLength();

                for(String comment : request.comments){

                    comment = (String.isNotBlank(comment) && comment.length() > commentMaxLength)
                            ? comment.left(commentMaxLength) : comment;
                    CaseComment newCaseComment = new CaseComment(
                            CommentBody = comment,
                            IsPublished = false,
                            ParentId = incident.Id
                    );
                    commentList.add(newCaseComment);
                }

                CaseCommentTriggerHandler.bypassProxyService = true;
                insert commentList;
            }

            response.statusCode = 200;
            response.responseBody = Blob.valueOf('SUCCESS');

        } catch(Exception ex){
            system.debug('updateIncident(): Exception - ' + ex);

            response.statusCode = 500;
            response.responseBody = Blob.valueOf(ex.getTypeName());

            String subject = (incident != null) ? (String)incident.id : 'NONE';
            subject += (request != null) ? ' Trouble Report Id: ' + request.troubleReportId : '';
            inContactBaseClass.SendErrorEmail( ex, subject);
        }

    }

}