//Generated by wsdl2apex

public class AsyncPartnerCaseProxyService {
    public class UpdatePartnerCaseResponse_elementFuture extends System.WebServiceCalloutFuture {
        public void getValue() {
            System.WebServiceCallout.endInvoke(this);
        }
    }
    public class CreatePartnerCaseResponse_elementFuture extends System.WebServiceCalloutFuture {
        public void getValue() {
            System.WebServiceCallout.endInvoke(this);
        }
    }
    public class AsyncPartnerCaseProxySoap {
        public String endpoint_x = 'http://labproxy.ucn.net/PartnerProxyService/PartnerCaseProxy.asmx';
        public Map<String,String> inputHttpHeaders_x;
        public String clientCertName_x;
        public Integer timeout_x;
        private String[] ns_map_type_info = new String[]{'http://tempuri.org/', 'PartnerCaseProxyService'};
        public AsyncPartnerCaseProxyService.UpdatePartnerCaseResponse_elementFuture beginUpdatePartnerCase(System.Continuation continuation,PartnerCaseProxyService.ArrayOfSalesforceCase newCases,String partnerId) {
            PartnerCaseProxyService.UpdatePartnerCase_element request_x = new PartnerCaseProxyService.UpdatePartnerCase_element();
            request_x.newCases = newCases;
            request_x.partnerId = partnerId;
            return (AsyncPartnerCaseProxyService.UpdatePartnerCaseResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncPartnerCaseProxyService.UpdatePartnerCaseResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://tempuri.org/UpdatePartnerCase',
              'http://tempuri.org/',
              'UpdatePartnerCase',
              'http://tempuri.org/',
              'UpdatePartnerCaseResponse',
              'PartnerCaseProxyService.UpdatePartnerCaseResponse_element'}
            );
        }
        public AsyncPartnerCaseProxyService.CreatePartnerCaseResponse_elementFuture beginCreatePartnerCase(System.Continuation continuation,PartnerCaseProxyService.ArrayOfSalesforceCase newCases,String partnerId) {
            PartnerCaseProxyService.CreatePartnerCase_element request_x = new PartnerCaseProxyService.CreatePartnerCase_element();
            request_x.newCases = newCases;
            request_x.partnerId = partnerId;
            return (AsyncPartnerCaseProxyService.CreatePartnerCaseResponse_elementFuture) System.WebServiceCallout.beginInvoke(
              this,
              request_x,
              AsyncPartnerCaseProxyService.CreatePartnerCaseResponse_elementFuture.class,
              continuation,
              new String[]{endpoint_x,
              'http://tempuri.org/CreatePartnerCase',
              'http://tempuri.org/',
              'CreatePartnerCase',
              'http://tempuri.org/',
              'CreatePartnerCaseResponse',
              'PartnerCaseProxyService.CreatePartnerCaseResponse_element'}
            );
        }
    }
}