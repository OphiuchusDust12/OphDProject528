/**
 * Created by arnab.karsarkar on 3/3/2017.
 */

global class CalendarLightningController implements CalendarItemRetriever {



    @AuraEnabled
    public static string[] getdayHours(){
        list<string> dayHourStrings = new string[24];
        CalendarItemRetriever calendarItemRetriever;
        CalendarHandler CalHandler = new CalendarHandler(calendarItemRetriever);
        DateTime[] day_hours = calHandler.DayHourBlocks;
        system.debug('day_hours =' + day_hours);

        for(integer i = 0; i < day_hours.size(); i++){
            string formattedTime = day_hours.get(i).formatGMT('h a');
            dayHourStrings.add(i, formattedTime);
         }
        //dayHourStrings.sort();
        return dayHourStrings;
    }

    public List<CalendarItem> getCalendarItems(Date startDate, Date endDate) {
        List<CalendarItem> calendarItems = new List<CalendarItem>();

        // standard events
        List<Event> events = new List<Event>([
                SELECT Id, Subject, Description, StartDateTime,
                        EndDateTime, IsAllDayEvent
                FROM Event
                WHERE StartDateTime >= :startDate
                AND EndDateTime <= :endDate
        ]);
        for (Event e : events) {
            CalendarItem calItem = createCalendarItem(e);
            calItem.Actions.add( new SwitchCalendarItemTypeAction(calItem) );
            calendarItems.add(calItem);
        }

        // custom events
        List<CustomEvent__c> customEvents = new List<CustomEvent__c>([
                SELECT Id, Name, Description__c, StartDateTime__c,
                        EndDateTime__c, IsAllDay__c
                FROM CustomEvent__c
                WHERE StartDateTime__c >= :startDate
                AND EndDateTime__c <= :endDate
        ]);
        for (CustomEvent__c e : customEvents) {
            CalendarItem calItem = createCalendarItem(e);
            calItem.Actions.add( new SwitchCalendarItemTypeAction(calItem) );
            calendarItems.add(calItem);
        }

        return calendarItems;
    }

    private CalendarItem createCalendarItem(CustomEvent__c e) {
        CalendarItem calItem = new CalendarItem(e.Id);
        calItem.Name = e.Name;
        calItem.Description = e.Description__c;
        calItem.StartDateTime = e.StartDateTime__c;
        calItem.EndDateTime = e.EndDateTime__c;
        calItem.IsAllDay = e.IsAllDay__c;
        calItem.CssClass = 'custom-event';
        return calItem;
    }

    private CalendarItem createCalendarItem(Event e) {
        CalendarItem calItem = new CalendarItem(e.Id);
        calItem.Name = e.Subject;
        calItem.Description = e.Description;
        calItem.StartDateTime = e.StartDateTime;
        calItem.EndDateTime = e.EndDateTime;
        calItem.IsAllDay = e.IsAllDayEvent;
        calItem.CssClass = 'standard-event';
        return calItem;
    }

    private class SwitchCalendarItemTypeAction implements CalendarItemAction {

        private CalendarItem calItem;

        public SwitchCalendarItemTypeAction(CalendarItem calItem) {
            this.calItem = calItem;
        }

		/**
		*	Retrieve the label for the custom calendar action
		*
		*	@return	The String label for the calendar action
		*/
        public String getActionLabel() {
            return 'Switch Type';
        }

		/**
		*	Should the calendar reload after performing the action
		*
		*	@return	True if the calendar should reload following the custom action, false otherwise
		*/
        public boolean getInitOnComplete() {
            return true;
        }

		/**
		*	performAction	Calendar action logic
		*
		*	@return	Return a page to redirect to
		*/
        public PageReference performAction() {
            if (calItem.CssClass == 'standard-event') {
                calItem.CssClass = 'custom-event';
            } else {
                calItem.CssClass = 'standard-event';
            }
            return null;
        }

    }

    @RemoteAction
    global static list<CustomEvent__c> getEvents(){
        return [SELECT EndDateTime__c,Id,StartDateTime__c,Description__c FROM CustomEvent__c];
    }

}