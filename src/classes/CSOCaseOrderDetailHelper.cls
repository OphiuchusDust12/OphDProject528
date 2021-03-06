/**
 * Created by arnab.karsarkar on 1/8/2018.
 */

public class CSOCaseOrderDetailHelper {

	public Case currentCase;
	public List<CSOCaseOrderDetailController.CSOCaseComment> caseComments;

	//public list<CSOCaseHistoryModel> caseAssignedTo;

	static Set<String> caseFields = new Set<String>{
			'RecordType.Name'
	};

	// constructor
	public CSOCaseOrderDetailHelper(String idParam){

		caseComments = new List<CSOCaseOrderDetailController.CSOCaseComment>();

		String sObjType = getSObjectType(idParam);
		if(sObjType == 'Case'){
			currentCase = getCase(idParam);
			system.debug('getCase(): currentCase - ' + currentCase);

			if(currentCase == null){
				ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'No Case record found.'));
				return;
			}

			if(currentCase.CustomerOrder__c == null){
				String html = '<a href="/' + currentCase.Id + '"><b><u>Click here</u></b></a>';
				ApexPages.addMessage(
						new ApexPages.Message(ApexPages.Severity.INFO, 'This Case does not have a Customer Order placed via CSO.' + html + 'to return to the Case record.')
				);
				return;
			}

			getCaseComments(idParam);
		}
	}

	public String getSObjectType(String IdParam){
		if(idParam.left(3) == Schema.SObjectType.Case.getKeyPrefix()){
			return 'Case';
		}

		else{
			ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'URL: Invalid ID Parameter.'));
		}
		return null;
	}

	public Case getCase(string caseId){
		List<Schema.FieldSetMember> fsMembers = Schema.SobjectType.Case.fieldSets.CSO_Order_Resolution.getFields();
		for(Schema.FieldSetMember member : fsMembers){
			caseFields.add(member.getFieldPath());
		}
		List<String> fieldList = new List<String>(caseFields);
		String columns = String.join(fieldList, ',');
		system.debug('getCase(): columns - ' + columns);
		String soql = 'Select ' + columns + ' From Case where Id = \'' + caseId + '\'';
		system.debug('getCase(): soql - ' + soql);

		List<Case> cases = Database.query(soql);
		if(cases.isEmpty()){
			return null;
		}

		return cases[0];

	}

	private void getCaseComments(string caseId){

        for(CaseComment comment: [
				SELECT CommentBody,CreatedDate,CreatedBy.Name,Id,IsDeleted,IsPublished,ParentId
				FROM CaseComment
				where parentId =:caseId  order by CreatedDate desc
		]){
			CSOCaseOrderDetailController.CSOCaseComment csoCaseComment = new CSOCaseOrderDetailController.CSOCaseComment();
			csoCaseComment.CreatedDate = comment.CreatedDate.format('MM/dd/yy hh:mma');
			csoCaseComment.CreatedByName = comment.CreatedBy.Name;
			csoCaseComment.CommentBody = comment.CommentBody;
			caseComments.add(csoCaseComment);
        }

	}

//	public list<CSOCaseHistoryModel> getCaseHistory(string caseId){
//
//		List<CSOCaseHistoryModel> finalCaseHisList = new List<CSOCaseHistoryModel>();
//		caseAssignedTo = new List<CSOCaseHistoryModel>();
//		list<CaseHistory> retCaseHisList = new list<CaseHistory>();
//		retCaseHisList = [SELECT CreatedDate,CreatedBy.Name,Id, CreatedById, Field, IsDeleted, OldValue, NewValue FROM CaseHistory where CaseId =:caseId  order by CreatedDate desc];
//
//		System.debug(retCaseHisList);
//		for(CaseHistory test : retCaseHisList)
//		{
//			CSOCaseHistoryModel csoCaseHist = new CSOCaseHistoryModel();
//			csoCaseHist.UserName = test.CreatedBy.Name;
//			csoCaseHist.UserId = test.CreatedById;
//			//DateTime dT = test.CreatedDate;
//			System.debug(test.CreatedDate);
//			csoCaseHist.csoDateTime = test.CreatedDate.format('hh:mma MM/dd/yy');
//			System.debug(csoCaseHist.csoDateTime);
//			if(test.Field == 'Status')
//				csoCaseHist.Field = 'changed status';
//			if(test.Field == 'created')
//				csoCaseHist.Field = 'created';
//
//			if(test.Field == 'IsVisibleInSelfService')
//				csoCaseHist.Field = 'updated IsVisibleInSelfService';
//			if(test.Field == 'Last_Comment_Date_Time__c')
//				csoCaseHist.Field = 'updated Last Comment Date Time';
//			if(test.Field == 'ownerAssignment')
//			{
//				csoCaseHist.Field = 'changed Owner';
//				caseAssignedTo.Add(csoCaseHist);
//			}
//
//
//			finalCaseHisList.add(csoCaseHist);
//		}
//		return finalCaseHisList;
//	}

	public static list<string> getFieldList(){
		List<Schema.FieldSetMember> fsMembers = Schema.SobjectType.Case.fieldSets.CSO_Order_Resolution.getFields();
		list<string> caseFieldsToShow = new list<string>();
		for(Schema.FieldSetMember member : fsMembers){
			caseFieldsToShow.add(member.getFieldPath());
		}
		return caseFieldsToShow;

	}

}