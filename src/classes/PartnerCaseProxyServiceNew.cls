//Generated by wsdl2apex

public class PartnerCaseProxyServiceNew {
    public class CreatePartnerCaseResponse_element {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class ArrayOfSalesforceCase {
        public PartnerCaseProxyServiceNew.SalesforceCase[] SalesforceCase;
        private String[] SalesforceCase_type_info = new String[]{'SalesforceCase','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceCase'};
    }
    public class UpdatePartnerCaseResponse_element {
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{};
    }
    public class PartnerCaseCommentUpdate {
        public DateTime UpdateDateTime;
        public String VendorTicketNumber;
        public String Comment;
        public String AccountName;
        private String[] UpdateDateTime_type_info = new String[]{'UpdateDateTime','http://tempuri.org/',null,'1','1','false'};
        private String[] VendorTicketNumber_type_info = new String[]{'VendorTicketNumber','http://tempuri.org/',null,'0','1','false'};
        private String[] Comment_type_info = new String[]{'Comment','http://tempuri.org/',null,'0','1','false'};
        private String[] AccountName_type_info = new String[]{'AccountName','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'UpdateDateTime','VendorTicketNumber','Comment','AccountName'};
    }
    public class UpdatePartnerCase_element {
        public PartnerCaseProxyServiceNew.ArrayOfPartnerCaseCommentUpdate caseUpdates;
        public String partnerId;
        private String[] caseUpdates_type_info = new String[]{'caseUpdates','http://tempuri.org/',null,'0','1','false'};
        private String[] partnerId_type_info = new String[]{'partnerId','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'caseUpdates','partnerId'};
    }
    public class CreatePartnerCase_element {
        public PartnerCaseProxyServiceNew.ArrayOfSalesforceCase newCases;
        public String partnerId;
        private String[] newCases_type_info = new String[]{'newCases','http://tempuri.org/',null,'0','1','false'};
        private String[] partnerId_type_info = new String[]{'partnerId','http://tempuri.org/',null,'0','1','false'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'newCases','partnerId'};
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
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'SalesforceId','Number_x','Comment','Description','ContactName','ContactPhone','OwnerName','OwnerPhone','CadebillAccountNumber','EventTime','Country','AccountName','Priority','Product','RequestType','Reason','ReasonDetails','EtmsTroubleType','TroubleTypeDescription'};
    }
    public class ArrayOfPartnerCaseCommentUpdate {
        public PartnerCaseProxyServiceNew.PartnerCaseCommentUpdate[] PartnerCaseCommentUpdate;
        private String[] PartnerCaseCommentUpdate_type_info = new String[]{'PartnerCaseCommentUpdate','http://tempuri.org/',null,'0','-1','true'};
        private String[] apex_schema_type_info = new String[]{'http://tempuri.org/','true','false'};
        private String[] field_order_type_info = new String[]{'PartnerCaseCommentUpdate'};
    }
    public class PartnerCaseProxySoap {
        public String endpoint_x = 'https://labproxy.ucn.net/PartnerProxyService/PartnerCaseProxy.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public Map<String,String> outputHttpHeaders_x;
        public String clientCertName_x;
        public String clientCert_x;
        public String clientCertPasswd_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'PartnerCaseProxyServiceNew'};
        public void UpdatePartnerCase(PartnerCaseProxyServiceNew.ArrayOfPartnerCaseCommentUpdate caseUpdates,String partnerId) {
            PartnerCaseProxyServiceNew.UpdatePartnerCase_element request_x = new PartnerCaseProxyServiceNew.UpdatePartnerCase_element();
            request_x.caseUpdates = caseUpdates;
            request_x.partnerId = partnerId;
            PartnerCaseProxyServiceNew.UpdatePartnerCaseResponse_element response_x;
            Map<String, PartnerCaseProxyServiceNew.UpdatePartnerCaseResponse_element> response_map_x = new Map<String, PartnerCaseProxyServiceNew.UpdatePartnerCaseResponse_element>();
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
              'PartnerCaseProxyServiceNew.UpdatePartnerCaseResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
        public void CreatePartnerCase(PartnerCaseProxyServiceNew.ArrayOfSalesforceCase newCases,String partnerId) {
            PartnerCaseProxyServiceNew.CreatePartnerCase_element request_x = new PartnerCaseProxyServiceNew.CreatePartnerCase_element();
            request_x.newCases = newCases;
            request_x.partnerId = partnerId;
            PartnerCaseProxyServiceNew.CreatePartnerCaseResponse_element response_x;
            Map<String, PartnerCaseProxyServiceNew.CreatePartnerCaseResponse_element> response_map_x = new Map<String, PartnerCaseProxyServiceNew.CreatePartnerCaseResponse_element>();
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
              'PartnerCaseProxyServiceNew.CreatePartnerCaseResponse_element'}
            );
            response_x = response_map_x.get('response_x');
        }
    }
}