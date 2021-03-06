/**
 * Created by arnab.karsarkar on 1/9/2018.
 */

public with sharing class CSOOrderActionCompController {

	public String currentCaseId{get;set;}
	public List<Case> caseDet{get; set;}
	public List<CSOOrderResolutionColumnMapping__c> retMappings {get; set;}
	public string thresholdMessage{get;set;}


	public CSOOrderActionCompController(){
		if (currentCaseId == null) {
			currentCaseId = System.currentPageReference().getParameters().get('id');
		}
		thresholdMessage = '';
		caseDet = getCurrentCase(currentCaseId);
		if(!caseDet.isEmpty()){
			retMappings = getMappings(caseDet[0].CSO_Resolution_Type__c);
			if(retMappings != null)
				thresholdMessage = retMappings[0].Threshold_Exceeds_Message__c;

		}




	}

	final static set<string> lineItemColumns = new set<string>{
		'Id',
		'Name',
		'Item Status',
		'Last Comment',
		'RelatedLineItem__c',
		'Parent Line Item'

	};

	static set<string> lineItemFields = new set<string>{
			'Id',
			'Name',
			'ItemStatus__c',
			'Last_Comment__c',
			'RelatedLineItem__c',
			'RelatedLineItem__r.Name'

	};

	static set<string> stConstantCols = new set<string>{
		'Name~Name',
		'ItemStatus__c~Item Status',
		'Last_Comment__c~Last Comment'
	};

	static set<string> columnTitles = new set<string>();
	static map<string,string> columnNameTitleMap = new map<string, string>();
	static Case currentCase;


	public string ItemStatus
	{
		get
		{
			String[] statusList = new String[]{};
			list<case> cases = getCurrentCase(currentCaseId);
			if(cases.isEmpty() || cases == null)
				return 'NONE';
			list<CSOOrderResolutionColumnMapping__c> mappings = getMappings(cases[0].CSO_Resolution_Type__c);
			if(mappings != null && !mappings.isEmpty()){
				statusList = mappings[0].Line_Item_Status__c.split(';');
			}else{
				statusList = new string[]{};
			}
			statusList.sort();
			system.debug('statusList ==>' + statusList);
			return JSON.Serialize(statusList);
		}
	}

	public string POPSite
	{
		get
		{
			String[] popsiteList = new String[]{};
			list<case> cases = getCurrentCase(currentCaseId);
			if(cases.isEmpty() || cases == null)
				return 'NONE';
			list<CSOOrderResolutionColumnMapping__c> mappings = getMappings(cases[0].CSO_Resolution_Type__c);
			if(!mappings.isEmpty()){
				if(mappings[0].POP_Site__c != null)
					popsiteList = mappings[0].POP_Site__c.split(';');
			}
			popsiteList.sort();

			return JSON.Serialize(popsiteList);
		}
	}


	@RemoteAction
	public static string getCurrentOrderDetails(string caseId){
		try{
			list<case> cases = getCurrentCase(caseId);
			if(cases == null || cases.isEmpty())
				return 'Error occured while loading the order line items grid. Case information is incomplete.';

			currentCase = cases[0];

			list<CSOOrderResolutionColumnMapping__c> mappings = getMappings(currentCase.CSO_Resolution_Type__c);

			List<OrderLineGeneralItems__c> lineGeneralItems = getAllLineItems(currentCase, mappings);
			if(lineGeneralItems == null || lineGeneralItems.isEmpty())
				return '';

			list<string> buttons = getButtons(mappings);

			if(lineGeneralItems.size() > 0){
				string jsonString = generateJSONString(lineGeneralItems, buttons);
				System.debug('JSONstring ==>' + jsonString);
				return jsonString;
			}

			return null;
		}Catch(Exception ex){
			return 'Error occured while loading the order line items grid. - ' + ex.getMessage();
		}

	}

	private static list<Case> getCurrentCase(string caseId){
		return [select CustomerOrder__c, SubProductorService__c,CSO_Resolution_Type__c, Origin from Case where Id = : caseId and CSO_Resolution_Type__c != null Limit 1];

	}

	private static list<OrderLineGeneralItems__c> getAllLineItems(case currentCase, list<CSOOrderResolutionColumnMapping__c> mappings){
		string orderId = currentCase.CustomerOrder__c;
		decimal instrumentId = mappings == null ? 0 : mappings[0].Instrument_Id__c;

		columnTitles.addAll(mappings[0].DisplayColumns__c.split(';'));
		columnTitles.addAll(lineItemColumns);
		set<string> columnTitleLocal = new set<string>();
		
		Map <String, Schema.SObjectType> schemaMap = Schema.getGlobalDescribe();
		Map <String, Schema.SObjectField> fieldMap = schemaMap.get('OrderLineGeneralItems__c').getDescribe().fields.getMap();
		for(Schema.SObjectField sfield : fieldMap.Values())
		{
			schema.describefieldresult dfield = sfield.getDescribe();
			if(columnTitles.contains(dfield.getLabel())){
				lineItemFields.add(dfield.getName());
				columnNameTitleMap.put(dfield.getName(), dfield.getLabel());
				columnTitleLocal.add(dfield.getLabel());

			}

		}

		for(string title : columnTitles ){
			if(!columnTitleLocal.contains(title)){
				string key = title.replaceAll( '\\s+', '');
				columnNameTitleMap.put(key, title);
			}
		}
		columnNameTitleMap.put('ParentLineItem', 'Parent Line Item Name');

		system.debug('columnNameTitleMap ==> ' + columnNameTitleMap);

		List<String> fieldList = new List<String>(lineItemFields);
		
		String columns = String.join(fieldList, ',');

		system.debug('getAllLineItems(): columns - ' + columns);

		String soql = 'Select ' + columns + ', (select Id, SpecificItem__c, ItemValue__c from Order_Line_Specific_Items__r) From OrderLineGeneralItems__c where  CustomerOrder__c = : orderId '
					 + ' and (InstrumentType__c = :instrumentId OR RelatedLineItem__r.InstrumentType__c = :instrumentId) '
				     + ' and ItemStatus__c not in(\'Canceled\', \'Completed\') order by CreatedDate desc';

		system.debug('getAllLineItems(): soql - ' + soql);

		List<OrderLineGeneralItems__c> lineItems = Database.query(soql);

		return lineItems;
	}

	private static list<CSOOrderResolutionColumnMapping__c> getMappings(string CSOCaseType){
        System.debug('CSOCaseType =>>' + CSOCaseType);
			return [Select DisplayColumns__c, CSO_Resolution_Type__c, Line_Item_Status__c ,POP_Site__c, Display_Buttons__c, Instrument_Id__c, Threshold_Exceeds_Message__c from CSOOrderResolutionColumnMapping__c where  CSO_Resolution_Type__c = :CSOCaseType Limit 1];
	}


	
	private static list<string> getButtons(list<CSOOrderResolutionColumnMapping__c> mappings){
		if(mappings == null || mappings.isEmpty())
			return new list<string>();

		list<string> buttons = mappings[0].Display_Buttons__c.split(';');
		return buttons;
	}



	private static string generateJSONString(list<OrderLineGeneralItems__c> lineItems, list<string> buttons){

		System.debug('generate JSON => lineItems : ' + lineItems);
		JSONGenerator gen = JSON.createGenerator(true);
		gen.writeStartObject();

			gen.writeFieldName('data');
			gen.writeStartArray();
				for(OrderLineGeneralItems__c li : lineItems){
					gen.writeStartObject();
					set<string> stCols = new set<string>();
					for(string columnName : lineItemFields){
						if(!columnName.contains('RelatedLineItem__r.Name')){
							string value = String.valueOf(li.get(columnName));
							gen.writeStringField(columnName, value == null ? '' : value);
							stCols.add(columnName);
						}else if(columnName.contains('RelatedLineItem__r.Name')){
							gen.writeStringField('ParentLineItem', li.RelatedLineItem__r.Name == null ? '' : li.RelatedLineItem__r.Name);
							stCols.add('ParentLineItem');
						}
					}
					for(OrderLineSpecificItem__c si : li.Order_Line_Specific_Items__r){
						string col = si.SpecificItem__c.replaceAll( '\\s+', '');
						System.debug('JSON ++> ' + col);
							if(columnNameTitleMap.containsKey(col)){
								gen.writeStringField(col, si.ItemValue__c);
								stCols.add(col);
							}

					}
					for(string col : columnNameTitleMap.keySet()) {
						if(!stCols.contains(col) && !lineItemColumns.contains(col)){
							gen.writeStringField(col, '');
						}
					}
					gen.writeEndObject();
				}
			gen.writeEndArray();

		list<string> colName= new list<string>();
		colName.addAll(stConstantCols);
		for(string col : columnNameTitleMap.keySet()){
			string formatColName = col + '~' + columnNameTitleMap.get(col);
			if(!stConstantCols.contains(formatColName))
				colName.add(formatColName);
		}

		gen.writeObjectField('columns', colName);
		gen.writeObjectField('buttons', buttons);

		gen.writeEndObject();

		return gen.getAsString();
	}

	@RemoteAction
	public static string saveComment(string comment,boolean isPublic, string lineItemId, string caseId){
		try{
			if(comment == '' || comment == null)
				return 'Empty comments are not allowed to save.';
			list<case> cases = getCurrentCase(caseId);
			Id customerOrderId = cases[0].CustomerOrder__c;
			LineItemComment__c lineItemComment = new LineItemComment__c(
					Comment__c = comment,
					OrderLineGeneralItem__c = lineItemId,
					CustomerOrder__c = customerOrderId,
					Case__c = caseId,
					Public__c = isPublic
			);

			insert lineItemComment;
			return 'Success';
		}catch (Exception ex){
			return 'Error while saving comment. Technical error message -  ' + ex.getMessage();
		}
	}

	@RemoteAction
	public static string updateStatus(string status, string lineItemId, string caseId, boolean updateAll){
		try{
			if(status == '' || status == null)
				return 'Invalid Staus.';
			List<OrderLineGeneralItems__c> orderLineItemList = new List<OrderLineGeneralItems__c>();
			list<case> cases = getCurrentCase(caseId);
			currentCase = cases[0];
			if(updateAll){

				list<CSOOrderResolutionColumnMapping__c> mappings = getMappings(currentCase.CSO_Resolution_Type__c);
				List<OrderLineGeneralItems__c> lineGeneralItems = getAllLineItems(currentCase, mappings);
				for(OrderLineGeneralItems__c li : lineGeneralItems){
					li.ItemStatus__c = status;
				}
				update lineGeneralItems;
			}else{
				orderLineItemList.add(new OrderLineGeneralItems__c(
						Id = lineItemId,
						ItemStatus__c = status
				));


				List<OrderLineGeneralItems__c> childOrderLineItemList = new List<OrderLineGeneralItems__c>(
					[Select Id from OrderLineGeneralItems__c where RelatedLineItem__c =: lineItemId]
				);

				if(currentCase.CSO_Resolution_Type__c == 'DID - Add - Manual Process'){
					for(OrderLineGeneralItems__c childOrderLineItem: childOrderLineItemList){
						orderLineItemList.add(new OrderLineGeneralItems__c(
								Id = childOrderLineItem.Id,
								ItemStatus__c = status
						));
					}
				}

				update orderLineItemList;
			}
			return 'Success';
		}catch (Exception ex){
			return 'Error while updating Status change. Technical error message -  ' + ex.getMessage();
		}
	}

    @RemoteAction
    public static string updatePOPSite(string POP, string lineItemId){
        try{
            if(POP == '' || POP == null)
                return 'Invalid POP.';

            list<OrderLineSpecificItem__c> specificItems = new list<OrderLineSpecificItem__c>();
            for(OrderLineSpecificItem__c specificItem : [select Id, ItemValue__c, SpecificItem__c
                                                        from OrderLineSpecificItem__c where OrderLineGeneralItem__c = :lineItemId and SpecificItem__c like '%POP%']){
                specificItems.add(new OrderLineSpecificItem__c(
                        Id = specificItem.Id,
                        ItemValue__c = POP
                        ));
            }
            update specificItems;
            return 'Success';
        }catch (Exception ex){
            return 'Error while updating POP Site change. Technical error message -  ' + ex.getMessage();
        }
    }
}