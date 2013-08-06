// Copyright (C) 2002-2012 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine".
// For conditions of distribution and use, see copyright notice in irrlicht.h
module irrlicht.ITimer;

/// Interface for getting and manipulating the virtual time
interface ITimer 
{
	/// Returns current real time in milliseconds of the system.
	/**
	* This value does not start with 0 when the application starts.
	* For example in one implementation the value returned could be the
	* amount of milliseconds which have elapsed since the system was started.
	*/
	uint getRealTime() const;

	enum EWeekday
	{
		EWD_SUNDAY=0,
		EWD_MONDAY,
		EWD_TUESDAY,
		EWD_WEDNESDAY,
		EWD_THURSDAY,
		EWD_FRIDAY,
		EWD_SATURDAY
	}

	struct RealTimeDate
	{
		// Hour of the day, from 0 to 23
		uint Hour;
		// Minute of the hour, from 0 to 59
		uint Minute;
		// Second of the minute, due to extra seconds from 0 to 61
		uint Second;
		// Year of the gregorian calender
		int Year;
		// Month of the year, from 1 to 12
		uint Month;
		// Day of the month, from 1 to 31
		uint Day;
		// Weekday for the current day
		EWeekday Weekday;
		// Day of the year, from 1 to 366
		uint Yearday;
		// Whether daylight saving is on
		bool IsDST;		
	}

	RealTimeDate getRealTimeAndDate() const;

	/// Returns current virtual time in milliseconds.
	/**
	* This value starts with 0 and can be manipulated using setTime(),
	* stopTimer(), startTimer(), etc. This value depends on the set speed of
	* the timer if the timer is stopped, etc. If you need the system time,
	* use getRealTime() 
	*/
	uint getTime() const;

	/// sets current virtual time
	void setTime(uint time);

	/// Stops the virtual timer.
	/**
	* The timer is reference counted, which means everything which calls
	* stop() will also have to call start(), otherwise the timer may not
	* start/stop correctly again. 
	*/
	void stop();

	/// Starts the virtual timer.
	/**
	* The timer is reference counted, which means everything which calls
	* stop() will also have to call start(), otherwise the timer may not
	* start/stop correctly again. 
	*/
	void start();

	/// Sets the speed of the timer
	/**
	* The speed is the factor with which the time is running faster or
	* slower then the real system time. 
	*/
	void setSpeed(float speed = 1.0f);

	/// Returns current speed of the timer
	/**
	* The speed is the factor with which the time is running faster or
	* slower then the real system time. 
	*/
	float getSpeed() const;

	/// Returns if the virtual timer is currently stopped
	bool isStopped() const;

	/// Advances the virtual time
	/**
	* Makes the virtual timer update the time value based on the real
	* time. This is called automatically when calling IrrlichtDevice::run(),
	* but you can call it manually if you don't use this method. 
	*/
	void tick();
}
