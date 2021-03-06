/**
 * Created by arnab.karsarkar on 3/2/2017.
 */

/**
*	Holds information for the date range being viewed on a calendar
*
*/
public with sharing class CalendarHandler {

    private static final integer NUMBER_OF_DAYS_IN_WEEK = 7;

    private static final String[] weekdays = new String[]{
            'Sunday',
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday',
            'Saturday'
    };

    // can't make this Time[] because VF won't render it properly
    private static final DateTime[] DAY_HOUR_BLOCKS;

    public String[] WeekdayNames {
        get {
            return weekdays;
        }
    }

    public DateTime[] DayHourBlocks {
        get {
            return DAY_HOUR_BLOCKS;
        }
    }

    public Date ActiveDate { get; private set; }

    public Date StartOfWeek {
        get {
            return this.ActiveDate.toStartOfWeek();
        }
    }

    public Date EndOfWeek {
        get {
            return this.StartOfWeek.addDays(6);
        }
    }

    public Date StartOfMonth {
        get {
            return this.ActiveDate.toStartOfMonth();
        }
    }

    public Date EndOfMonth {
        get {
            return this.StartOfMonth.addMonths(1).addDays(-1);
        }
    }

    public integer DayOfWeek {
        get {
            return -1 * (this.ActiveDate.daysBetween(this.StartOfWeek) - 1);
        }
    }

    public String Weekday {
        get {
            return weekdays[this.DayOfWeek - 1];
        }
    }

    public integer WeekOfMonth {
        get {
            for (integer i=0; i<Weeks.size(); i++) {
                if (Weeks[i].isInWeek(ActiveDate)) {
                    return i+1;
                }
            }
            throw new CalendarException('The active date does not fall within any week.');
        }
    }

    public CalendarWeek ActiveWeek {
        get {
            return Weeks[WeekOfMonth-1];
        }
    }

    public List<CalendarWeek> Weeks {get; private set;}
    public List<CalendarItem> Items {get; private set;}
    public List<CalendarItem> SplitItems {get; private set;}	// Items split for multiple day events

    private CalendarItemRetriever calendarItemRetriever;

    static {
        // set up day hour blocks
        DAY_HOUR_BLOCKS = new DateTime[24];
        Date d = Date.today();
        Time t = Time.newInstance(0, 0, 0, 0);
        Time startDay = Time.newInstance(0, 0, 0, 0);
        integer hourIndex = 0;
        do {
            DAY_HOUR_BLOCKS[hourIndex] = DateTime.newInstanceGmt(d, t);
            t = t.addMinutes(60);
            hourIndex++;
        } while (t != startDay);
    }

    public CalendarHandler(CalendarItemRetriever calendarItemRetriever) {
        this(calendarItemRetriever, Date.today());
    }

    public CalendarHandler(CalendarItemRetriever calendarItemRetriever, Date activeDate) {
        this.calendarItemRetriever = calendarItemRetriever;
        setDate(activeDate);
    }

	/**
	*	Go to the next day
	*/
    public void goToNextDay() {
        this.addDays(1);
    }

	/**
	*	Go to the previous day
	*/
    public void goToPreviousDay() {
        this.addDays(-1);
    }

	/**
	*	Go to the next week
	*/
    public void goToNextWeek() {
        this.addWeeks(1);
    }

	/**
	*	Go to the previous week
	*/
    public void goToPreviousWeek() {
        this.addWeeks(-1);
    }

	/**
	*	Go to the next month
	*/
    public void goToNextMonth() {
        this.addMonths(1);
    }

	/**
	*	Go to the previous month
	*/
    public void goToPreviousMonth() {
        this.addMonths(-1);
    }

	/**
	*	Go to the next year
	*/
    public void goToNextYear() {
        this.addYears(1);
    }

	/**
	*	Go to the previous year
	*/
    public void goToPreviousYear() {
        this.addYears(-1);
    }

	/**
	*	Add days to the active calendar date
	*
	*	@param	numberOfDays	The number of days to add to the active date
	*/
    public void addDays(integer numberOfDays) {
        setDate(this.ActiveDate.addDays(numberOfDays));
    }

	/**
	*	Add weeks to the active calendar date
	*
	*	@param	numberOfWeeks	The number of weeks to add to the active date
	*/
    public void addWeeks(integer numberOfWeeks) {
        setDate(this.ActiveDate.addDays(numberOfWeeks * NUMBER_OF_DAYS_IN_WEEK));
    }

	/**
	*	Add months to the active calendar date
	*
	*	@param	numberOfMonths	The number of months to add to the active date
	*/
    public void addMonths(integer numberOfMonths) {
        setDate(this.ActiveDate.addMonths(numberOfMonths));
    }

	/**
	*	Add years to the active calendar date
	*
	*	@param	numberOfYears	The number of years to add to the active date
	*/
    public void addYears(integer numberOfYears) {
        setDate(this.ActiveDate.addYears(numberOfYears));
    }

	/**
	*	Set the active calendar date
	*
	*	@param	activeDate	The new active calendar date
	*/
    public void setDate(Date activeDate) {
        boolean isNewMonth = true;
        if (this.ActiveDate != null) {
            isNewMonth = activeDate.month() != this.ActiveDate.month()
                    || activeDate.year() != this.ActiveDate.year();
        }
        this.ActiveDate = activeDate;
        if (isNewMonth) {
            updateCalendarWeeks();
            setCalendarWeekItems();
        }
    }

    private void updateCalendarWeeks() {
        Weeks = new List<CalendarWeek>();
        Date d = this.ActiveDate.toStartOfMonth().toStartOfWeek();
        Date endMonth = this.ActiveDate.addMonths(1).toStartOfMonth();
        while (d < endMonth) {
            Weeks.add( new CalendarWeek(d) );
            d = d.addDays(NUMBER_OF_DAYS_IN_WEEK);
        }
    }

    private void setCalendarWeekItems() {
        Date startDate = this.Weeks[0].Days[0].CalendarDate;
        Date endDate =
                this.Weeks[this.Weeks.size()-1]
                        .Days[NUMBER_OF_DAYS_IN_WEEK-1]
                        .CalendarDate;
        system.debug('startDate =>' + startDate);
        system.debug('endDate =>' + endDate);
        this.Items = getCalendarItems(startDate, endDate);

        this.SplitItems = getSplitCalendarItems(this.Items);
        for (CalendarWeek week : Weeks) {
            List<CalendarItem> weekItems = new List<CalendarItem>();
            for (CalendarItem monthItem : SplitItems) {
                if (monthItem.StartDate >= week.StartDate && monthItem.EndDate <= week.EndDate) {
                    weekItems.add(monthItem);
                }
            }
            week.Items = weekItems;
        }
    }

    private List<CalendarItem> getCalendarItems(Date startDate, Date endDate) {
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
            //calItem.Actions.add( new SwitchCalendarItemTypeAction(calItem) );
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
         //   calItem.Actions.add( new SwitchCalendarItemTypeAction(calItem) );
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

    private List<CalendarItem> getSplitCalendarItems(List<CalendarItem> retrievedItems) {
        List<CalendarItem> calItems = new List<CalendarItem>();
        // split items that span across multiple days
        for (CalendarItem calItem : retrievedItems) {
            if (calItem.StartDate != calItem.EndDate) {
                calItems.addAll( splitCalendarItem(calItem) );
            } else {
                calItems.add(calItem);
            }
        }
        return calItems;
    }

    private List<CalendarItem> splitCalendarItem(CalendarItem calItem) {
        List<CalendarItem> calItems = new List<CalendarItem>();

        CalendarItem firstDayItem = calItem.clone();
        CalendarItem lastDayItem = calItem.clone();

        firstDayItem.EndDateTime = DateTime.newInstance(
                firstDayItem.StartDate.addDays(1),
                Time.newInstance(0, 0, 0, 0)
        );

        lastDayItem.StartDateTime = DateTime.newInstance(
                lastDayItem.EndDate,
                Time.newInstance(0, 0, 0, 0)
        );

        calItems.add(firstDayItem);

        Date d = firstDayItem.StartDate.addDays(1);
        Date endDate = lastDayItem.EndDate;
        while (d < endDate) {
            CalendarItem clonedItem = calItem.clone();
            clonedItem.StartDateTime = DateTime.newInstance(d, Time.newInstance(0,0,0,0));
            clonedItem.EndDateTime = DateTime.newInstance(d.addDays(1), Time.newInstance(0,0,0,0));
            calItems.add(clonedItem);
            d = d.addDays(1);
        }

        calItems.add(lastDayItem);

        return calItems;
    }

	/**
	*	Get a calendar item by ID
	*
	*	@param	itemId	The ID of the calendar item to retrieve
	*
	*	@return	Returns the calendar item matching the ID
	*/
    public CalendarItem getCalendarItem(String itemId) {
        for (CalendarItem item : Items) {
            if (item.ItemId == itemId) {
                return item;
            }
        }
        throw new CalendarException('Could not find Calendar Item with ID: ' + itemId);
    }

    private class CalendarWeek {
        public CalendarDay[] Days {get; private set;}
        public Date StartDate {get; private set;}
        public Date EndDate {
            get {
                return StartDate.addDays(6);
            }
        }
        public List<CalendarItem> Items {
            get;
            set {
                Items = value;
                setCalendarDayItems();
            }
        }

        public CalendarWeek(Date startDate) {
            this.StartDate = startDate;
            updateCalendarDays();
            this.Items = new List<CalendarItem>();
        }

		/**
		*	Determine if a date falls in the week
		*
		*	@param	d	The date to check
		*
		*	@return Returns true if the date falls in the week
		*/
        public boolean isInWeek(Date d) {
            return StartDate <= d && d <= EndDate;
        }

        private void updateCalendarDays() {
            Days = new CalendarDay[NUMBER_OF_DAYS_IN_WEEK];
            Date d=this.StartDate;
            for (integer i=0; i<Days.size(); i++) {
                Days[i] = new CalendarDay(d);
                d = d.addDays(1);
            }
        }

        private void setCalendarDayItems() {
            for (CalendarDay day : Days) {
                for (CalendarItem item : Items) {
                    if (item.StartDate == day.CalendarDate) {
                        day.Items.add(item);
                    }
                }
                day.setupHalfHourEvents();
            }
        }
    }

    private class CalendarDay {
        public Date CalendarDate {get; private set;}
        public List<CalendarItem> Items {get; set;}
        public List<HalfHourItem> HalfHourItems {get; private set;}

        public CalendarDay(Date day) {
            this.CalendarDate = day;
            this.Items = new List<CalendarItem>();
        }

		/**
		*	Setup the half hour event list for the day
		*/
        public void setupHalfHourEvents() {
            HalfHourItems = new List<HalfHourItem>();
            for (integer i=0; i<DAY_HOUR_BLOCKS.size(); i++) {
                HalfHourItem hourItem = new HalfHourItem(DAY_HOUR_BLOCKS[i].time());
                HalfHourItem halfHourItem = new HalfHourItem(DAY_HOUR_BLOCKS[i].time().addMinutes(30));
                putItemsInHalfHour(hourItem);
                putItemsInHalfHour(halfHourItem);
                HalfHourItems.add(hourItem);
                HalfHourItems.add(halfHourItem);
            }
            HalfHourItems.sort();
        }

        private void putItemsInHalfHour(HalfHourItem hhItem) {
            hhItem.Items = new List<CalendarItem>();
            for (CalendarItem item : Items) {
                Time itemTime = item.StartDateTime.time();
                if (hhItem.HalfHourTime <= itemTime && itemTime < hhItem.HalfHourTime.addMinutes(30)) {
                    hhItem.Items.add(item);
                }
            }
        }
    }

    private class HalfHourItem implements Comparable {
        public Time HalfHourTime {get; private set;}
        public List<CalendarItem> Items {get; set;}
        public boolean IsOnHour {
            get {
                return HalfHourTime.minute() == 0;
            }
        }

        public HalfHourItem(Time halfHourTime) {
            this.HalfHourTime = halfHourTime;
        }

		/**
		*	Compare two half hour items
		*
		*	@param	halfHourObject	A half hour item to compare to
		*
		*	@return	Returns 1 if this is greater, -1 if this is less, 0 if they are equal
		*/
        public integer compareTo(Object halfHourObject) {
            HalfHourItem hhItem = (HalfHourItem)halfHourObject;
            if (this.HalfHourTime > hhItem.HalfHourTime) {
                return 1;
            } else if (this.HalfHourTime < hhItem.HalfHourTime) {
                return -1;
            }
            return 0;
        }
    }
}