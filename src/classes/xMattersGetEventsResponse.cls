//
// Generated by JSON2Apex http://json2apex.herokuapp.com/
// Many thanks to those guys
// 
public class xMattersGetEventsResponse {

	public class Records {
		public String href;
	}

	public Integer total;
	public Object nextRecordsUrl;
	public List<Records> records;

	
	public static xMattersGetEventsResponse parse(String json) {
		return (xMattersGetEventsResponse) System.JSON.deserialize(json, xMattersGetEventsResponse.class);
	}
	
}