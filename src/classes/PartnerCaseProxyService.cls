//Generated by wsdl2apex

public class PartnerCaseProxyService {
    public class SendBulkUpdateComment_element {
        public PartnerCaseProxyService.ArrayOfString caseList;
        public String comment;
        public DateTime commentDateTime;
        public Integer retryCount;
        private String[] caseList_type_info = new String[]{'caseList','http://tempuri.org/',null,'0','1','false'};
        private String[] comment_type_info = new String[]{'comment','http://tempuri.org/',null,'0','1','false'};
        private String[] commentDateTime_type_info = new String[]{'commentDateTime','http://tempuri.org/',null,'1','1','false'};
        private String[] retryCount_type_info = new String[]{'retryCount','http://tempuri.org/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'caseList','comment','commentDateTime','retryCount'};
    }
    public class CreatePartnerCaseResponse_element {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class SendBulkUpdateCommentResponse_element {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ArrayOfPartnerCaseUpdate {
        public PartnerCaseProxyService.PartnerCaseUpdate[] PartnerCaseUpdate;
        private String[] PartnerCaseUpdate_type_info = new String[]{'PartnerCaseUpdate','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PartnerCaseUpdate'};
    }
    public class PartnerCaseUpdate {
        public DateTime UpdateDateTime;
        public String CaseNumber;
        public String Comment;
        public Integer TroubleReportStatus;
        public Integer TroubleReportState;
        public String PreferredPriority;
        private String[] UpdateDateTime_type_info = new String[]{'UpdateDateTime','http://tempuri.org/',null,'1','1','false'};
        private String[] CaseNumber_type_info = new String[]{'CaseNumber','http://tempuri.org/',null,'0','1','false'};
        private String[] Comment_type_info = new String[]{'Comment','http://tempuri.org/',null,'0','1','false'};
        private String[] TroubleReportStatus_type_info = new String[]{'TroubleReportStatus','http://tempuri.org/',null,'1','1','true'};
        private String[] TroubleReportState_type_info = new String[]{'TroubleReportState','http://tempuri.org/',null,'1','1','true'};
        private String[] PreferredPriority_type_info = new String[]{'PreferredPriority','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateDateTime','CaseNumber','Comment','TroubleReportStatus','TroubleReportState','PreferredPriority'};
    }
    public class ArrayOfSalesforceCase {
        public PartnerCaseProxyService.SalesforceCase[] SalesforceCase;
        private String[] SalesforceCase_type_info = new String[]{'SalesforceCase','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceCase'};
    }
    public class ArrayOfString {
        public String[] string_x;
        private String[] string_x_type_info = new String[]{'string','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'string_x'};
    }
    public class UpdatePartnerCaseResponse_element {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class UpdatePartnerCase_element {
        public PartnerCaseProxyService.ArrayOfPartnerCaseUpdate caseUpdates;
        public String partnerId;
        public Integer retryCount;
        private String[] caseUpdates_type_info = new String[]{'caseUpdates','http://tempuri.org/',null,'0','1','false'};
        private String[] partnerId_type_info = new String[]{'partnerId','http://tempuri.org/',null,'0','1','false'};
        private String[] retryCount_type_info = new String[]{'retryCount','http://tempuri.org/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'caseUpdates','partnerId','retryCount'};
    }
    public class CreatePartnerCase_element {
        public PartnerCaseProxyService.ArrayOfSalesforceCase newCases;
        public String partnerId;
        public Integer retryCount;
        private String[] newCases_type_info = new String[]{'newCases','http://tempuri.org/',null,'0','1','false'};
        private String[] partnerId_type_info = new String[]{'partnerId','http://tempuri.org/',null,'0','1','false'};
        private String[] retryCount_type_info = new String[]{'retryCount','http://tempuri.org/',null,'1','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'newCases','partnerId','retryCount'};
    }
    public class SalesforceCase {
        public String SalesforceId;
        public String Number_x;
        public String Comment;
        public String Description;
        public String ContactName;
        public String ContactPhone;
        public String OwnerName;
        public String OwnerPhone;
        public Integer CadebillAccountNumber;
        public DateTime EventTime;
        public String Country;
        public String AccountName;
        public String Priority;
        public String Product;
        public String RequestType;
        public String Reason;
        public String ReasonDetails;
        public String EtmsTroubleType;
        public String TroubleTypeDescription;
        public String DialFrom;
        public String DialTo;
        public String NEID;
        public String ServiceId;
        private String[] SalesforceId_type_info = new String[]{'SalesforceId','http://tempuri.org/',null,'0','1','false'};
        private String[] Number_x_type_info = new String[]{'Number','http://tempuri.org/',null,'0','1','false'};
        private String[] Comment_type_info = new String[]{'Comment','http://tempuri.org/',null,'0','1','false'};
        private String[] Description_type_info = new String[]{'Description','http://tempuri.org/',null,'0','1','false'};
        private String[] ContactName_type_info = new String[]{'ContactName','http://tempuri.org/',null,'0','1','false'};
        private String[] ContactPhone_type_info = new String[]{'ContactPhone','http://tempuri.org/',null,'0','1','false'};
        private String[] OwnerName_type_info = new String[]{'OwnerName','http://tempuri.org/',null,'0','1','false'};
        private String[] OwnerPhone_type_info = new String[]{'OwnerPhone','http://tempuri.org/',null,'0','1','false'};
        private String[] CadebillAccountNumber_type_info = new String[]{'CadebillAccountNumber','http://tempuri.org/',null,'1','1','false'};
        private String[] EventTime_type_info = new String[]{'EventTime','http://tempuri.org/',null,'1','1','false'};
        private String[] Country_type_info = new String[]{'Country','http://tempuri.org/',null,'0','1','false'};
        private String[] AccountName_type_info = new String[]{'AccountName','http://tempuri.org/',null,'0','1','false'};
        private String[] Priority_type_info = new String[]{'Priority','http://tempuri.org/',null,'0','1','false'};
        private String[] Product_type_info = new String[]{'Product','http://tempuri.org/',null,'0','1','false'};
        private String[] RequestType_type_info = new String[]{'RequestType','http://tempuri.org/',null,'0','1','false'};
        private String[] Reason_type_info = new String[]{'Reason','http://tempuri.org/',null,'0','1','false'};
        private String[] ReasonDetails_type_info = new String[]{'ReasonDetails','http://tempuri.org/',null,'0','1','false'};
        private String[] EtmsTroubleType_type_info = new String[]{'EtmsTroubleType','http://tempuri.org/',null,'0','1','false'};
        private String[] TroubleTypeDescription_type_info = new String[]{'TroubleTypeDescription','http://tempuri.org/',null,'0','1','false'};
        private String[] DialFrom_type_info = new String[]{'DialFrom','http://tempuri.org/',null,'0','1','false'};
        private String[] DialTo_type_info = new String[]{'DialTo','http://tempuri.org/',null,'0','1','false'};
        private String[] NEID_type_info = new String[]{'NEID','http://tempuri.org/',null,'0','1','false'};
        private String[] ServiceId_type_info = new String[]{'ServiceId','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceId','Number_x','Comment','Description','ContactName','ContactPhone','OwnerName','OwnerPhone','CadebillAccountNumber','EventTime','Country','AccountName','Priority','Product','RequestType','Reason','ReasonDetails','EtmsTroubleType','TroubleTypeDescription','DialFrom','DialTo','NEID','ServiceId'};
    }
    public class PartnerCaseProxySoap {
        public String endpoint_x = 'http://localhost:32164/PartnerCaseProxy.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'PartnerCaseProxyService'};
        public void SendBulkUpdateComment(PartnerCaseProxyService.ArrayOfString caseList,String comment,DateTime commentDateTime,Integer retryCount) {
            PartnerCaseProxyService.SendBulkUpdateComment_element request_x = new PartnerCaseProxyService.SendBulkUpdateComment_element();
            request_x.caseList = caseList;
            request_x.comment = comment;
            request_x.commentDateTime = commentDateTime;
            request_x.retryCount = retryCount;
            PartnerCaseProxyService.SendBulkUpdateCommentResponse_element response_x;
            Map<String, PartnerCaseProxyService.SendBulkUpdateCommentResponse_element> response_map_x = new Map<String, PartnerCaseProxyService.SendBulkUpdateCommentResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            'http://tempuri.org/SendBulkUpdateComment',
                            'http://tempuri.org/',
                            'SendBulkUpdateComment',
                            'http://tempuri.org/',
                            'SendBulkUpdateCommentResponse',
                            'PartnerCaseProxyService.SendBulkUpdateCommentResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
        public void UpdatePartnerCase(PartnerCaseProxyService.ArrayOfPartnerCaseUpdate caseUpdates,String partnerId,Integer retryCount) {
            PartnerCaseProxyService.UpdatePartnerCase_element request_x = new PartnerCaseProxyService.UpdatePartnerCase_element();
            request_x.caseUpdates = caseUpdates;
            request_x.partnerId = partnerId;
            request_x.retryCount = retryCount;
            PartnerCaseProxyService.UpdatePartnerCaseResponse_element response_x;
            Map<String, PartnerCaseProxyService.UpdatePartnerCaseResponse_element> response_map_x = new Map<String, PartnerCaseProxyService.UpdatePartnerCaseResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            'http://tempuri.org/UpdatePartnerCase',
                            'http://tempuri.org/',
                            'UpdatePartnerCase',
                            'http://tempuri.org/',
                            'UpdatePartnerCaseResponse',
                            'PartnerCaseProxyService.UpdatePartnerCaseResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
        public void CreatePartnerCase(PartnerCaseProxyService.ArrayOfSalesforceCase newCases,String partnerId,Integer retryCount) {
            PartnerCaseProxyService.CreatePartnerCase_element request_x = new PartnerCaseProxyService.CreatePartnerCase_element();
            request_x.newCases = newCases;
            request_x.partnerId = partnerId;
            request_x.retryCount = retryCount;
            PartnerCaseProxyService.CreatePartnerCaseResponse_element response_x;
            Map<String, PartnerCaseProxyService.CreatePartnerCaseResponse_element> response_map_x = new Map<String, PartnerCaseProxyService.CreatePartnerCaseResponse_element>();
            response_map_x.put('response_x', response_x);
            WebServiceCallout.invoke(
                    this,
                    request_x,
                    response_map_x,
                    new String[]{endpoint_x,
                            'http://tempuri.org/CreatePartnerCase',
                            'http://tempuri.org/',
                            'CreatePartnerCase',
                            'http://tempuri.org/',
                            'CreatePartnerCaseResponse',
                            'PartnerCaseProxyService.CreatePartnerCaseResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
    }
}