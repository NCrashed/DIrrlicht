// Copyright (C) 2002-2013 Nikolaus Gebhardt
// This file is part of the "Irrlicht Engine" for the D programming language.
// For conditions of distribution and use, see copyright notice in irrlicht.d module.
module irrlicht.CTimer;

import irrlicht.ITimer;
import irrlicht.os;

class CTimer : ITimer
{
	this(bool usePerformanceTimer = true)
	{
		Timer.initTimer(usePerformanceTimer);
	}

	/// Returns current real time in milliseconds of the system.
	/**
	* This value does not start with 0 when the application starts.
	* For example in one implementation the value returned could be the
	* amount of milliseconds which have elapsed since the system was started.
	*/
	uint getRealTime() const
	{
		return Timer.getRealTime();
	}

	ITimer.RealTimeDate getRealTimeAndDate() const
	{
		return Timer.getRealTimeAndDate();
	}

	/// Returns current virtual time in milliseconds.
	/**
	* This value starts with 0 and can be manipulated using setTime(),
	* stopTimer(), startTimer(), etc. This value depends on the set speed of
	* the timer if the timer is stopped, etc. If you need the system time,
	* use getRealTime() 
	*/
	uint getTime() const
	{
		return Timer.getTime();
	}

	/// sets current virtual time
	void setTime(uint time)
	{
		return Timer.setTime(time);
	}

	/// Stops the virtual timer.
	/**
	* The timer is reference counted, which means everything which calls
	* stop() will also have to call start(), otherwise the timer may not
	* start/stop correctly again. 
	*/
	void stop()
	{
		Timer.stopTimer();
	}

	/// Starts the virtual timer.
	/**
	* The timer is reference counted, which means everything which calls
	* stop() will also have to call start(), otherwise the timer may not
	* start/stop correctly again. 
	*/
	void start()
	{
		Timer.startTimer();
	}

	/// Sets the speed of the timer
	/**
	* The speed is the factor with which the time is running faster or
	* slower then the real system time. 
	*/
	void setSpeed(float speed = 1.0f)
	{
		Timer.setSpeed = speed;
	}

	/// Returns current speed of the timer
	/**
	* The speed is the factor with which the time is running faster or
	* slower then the real system time. 
	*/
	float getSpeed() const
	{
		return Timer.getSpeed();
	}

	/// Returns if the virtual timer is currently stopped
	bool isStopped() const
	{
		return Timer.isStopped();
	}

	/// Advances the virtual time
	/**
	* Makes the virtual timer update the time value based on the real
	* time. This is called automatically when calling IrrlichtDevice::run(),
	* but you can call it manually if you don't use this method. 
	*/
	void tick()
	{
		Timer.tick();
	}
}