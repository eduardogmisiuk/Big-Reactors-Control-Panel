-- Big Reactors Control Panel - a simple and easy to use automation and informational panel for Big Reactors.
-- Copyright (C) 2018  Eduardo Garcia Misiuk

-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.

-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.

-- You should have received a copy of the GNU General Public License
-- along with this program.  If not, see <https://www.gnu.org/licenses/>.

-- Periphericals
local mon = peripheral.find ("monitor")
local reactor = peripheral.find ("BigReactors-Reactor")
-- Interface Variables
local status = window.create (mon, 1, 1, 14, 3, true)
local production = window.create (mon, 1, 4, 14, 3, true)
local rods = window.create (mon, 1, 7, 14, 9, true)
local fuel = window.create (mon, 15, 1, 12, 4, true)
local waste = window.create (mon, 15, 5, 12, 4, true)
local stored_energy = window.create (mon, 15, 12, 12, 3, true)
-- Variables
local automation
local automation_function
local loop = true
local on_energy = 100
local off_energy = 9000000
local limit_fuel = 0.9

-- Automation Functions

-- Stored energy automation
function switch_reactor_state_energy_stored ()
	if reactor.getEnergyStored () <= on_energy then
		reactor.setActive (true)
	end

	if reactor.getEnergyStored () >= off_energy then
		reactor.setActive (false)
	end
end
-- Fuel automation
function switch_reactor_state_fuel ()
	if reactor.getFuelAmount ()/reactor.getFuelAmountMax () >= limit_fuel then
		reactor.setActive (true)
	else
		reactor.setActive (false)
	end
end
-- Initializes the automation
function automation_init ()
	while true do
		if automation == 0 then
			switch_reactor_state_fuel ()
		elseif automation == 1 then
			switch_reactor_state_energy_stored ()
		end

		sleep(0.2)
	end
end

-- Interface Functions

-- Reactor status
function print_status ()
	status.clear ()
	status.setCursorPos(7, 2)
	if reactor.getActive () then
		status.setBackgroundColor (colors.green)
		status.write("ON")
	else
		status.setBackgroundColor (colors.red)
		status.write("OFF")
	end
end
-- Reactor production
function print_production ()
	production.setBackgroundColor (colors.gray)
	production.clear ()
	production.setCursorPos (3, 2)
	production.write (string.format ("%d", reactor.getEnergyProducedLastTick ()) .. "RF/t")
end
-- Rod control interface
function print_rod_control ()
	rods.setBackgroundColor (colors.gray)
	rods.clear ()
	rods.setCursorPos (2, 2)
	rods.write ("Rod Control")

	rods.setCursorPos (2, 4)
	rods.write ("+100%")

	rods.setCursorPos (8, 4)
	rods.write ("-100%")

	rods.setCursorPos (3, 6)
	rods.write ("+10%")

	rods.setCursorPos (9, 6)
	rods.write ("-10%")

	rods.setCursorPos (4, 8)
	rods.write ("+1%")

	rods.setCursorPos (10, 8)
	rods.write ("-1%")
end
-- Fuel view
function print_fuel ()
	-- Title
	fuel.setBackgroundColor (colors.gray)
	fuel.clear ()
	fuel.setCursorPos (5, 2)
	fuel.write ("Fuel")

	-- Fuel percentage
	local fuel_percentage = reactor.getFuelAmount ()/reactor.getFuelAmountMax ()*100
	if fuel_percentage < 100 then
		fuel.setCursorPos (6, 3)
	else
		fuel.setCursorPos (5, 3)
	end
	fuel.write (string.format ("%d", fuel_percentage) .. "%")

	-- Percentage bar
	fuel.setBackgroundColor (colors.yellow)
	fuel.setCursorPos (2, 4)
	for i = 0, fuel_percentage, 10 do
		fuel.write (" ")
	end
end
-- Waste view
function print_waste ()
	-- Title
	waste.setBackgroundColor (colors.gray)
	waste.clear ()
	waste.setCursorPos (4, 2)
	waste.write ("Waste")

	-- Fuel percentage
	local waste_percentage = reactor.getWasteAmount ()/reactor.getFuelAmountMax ()*100
	if waste_percentage < 100 then
		waste.setCursorPos (6, 3)
	else
		waste.setCursorPos (5, 3)
	end
	waste.write (string.format ("%d", waste_percentage) .. "%")

	-- Percentage bar
	waste.setBackgroundColor (colors.blue)
	waste.setCursorPos (2, 4)
	for i = 0, waste_percentage, 10 do
		waste.write (" ")
	end
end
-- Stored energy view
function print_stored_energy ()
	stored_energy.setBackgroundColor (colors.gray)
	stored_energy.clear ()

	-- Title
	stored_energy.setCursorPos (4, 1)
	stored_energy.write ("Stored")

	-- Energy stored percentage
	if 1000000/reactor.getEnergyStored ()*100 < 100 then
		stored_energy.setCursorPos (6, 2)
	else
		stored_energy.setCursorPos (5, 2)
	end
	stored_energy.write (string.format ("%d", reactor.getEnergyStored ()/100000) .. "%")

	-- Percentage bar
	stored_energy.setCursorPos (2, 3)
	stored_energy.setBackgroundColor (colors.yellow)
	if reactor.getEnergyStored () >= 1000000 then
		for i = 0, reactor.getEnergyStored ()/1000000 do
			stored_energy.write (" ")
		end
	end
end
-- Interface printing
function interface_init ()
	while true do
		print_status ()
		print_production ()
		print_rod_control ()
		print_fuel ()
		print_waste ()
		print_stored_energy ()
		sleep (0.2)
	end
end

-- Console
function console_init ()
	print ("Initialized the console!")
	print ("Welcome! Run \"help\" to show the commands.")

	-- Reading and executing the commands
	while loop do
		write ("Reactor~ ")
		command = read ()

		-- clear
		if command == "clear" then
			term.clear ()
			term.setCursorPos (1, 1)

		-- ca (BROKEN) TODO
		elseif command == "ca" then
			print ("Fuel (0) or Stored Energy (1)")
			write ("-> ")
			automation_aux = read ()*1
			if automation_aux == 0 or automation_aux == 1 then
				print ("Changed automation.")
			else
				print ("Option not recognized!")
			end

		-- exit
		elseif command == "exit" then
			loop = false
			print ("Closing the program...")
			mon.clear ()
			return

		-- help
		elseif command == "help" then
			print ("clear - clears the console")

			print ("ca - change automation type ")

			print ("exit - quits the program")

			print ("help - shows the commands")

			print ("rc - reactor conditions; changes the limits to the reactor's automation")

			print ("info - shows reactor's complementary information")

			print ("welcome - shows the initial message")

		elseif command == "rc" then
			if automation == 0 then
				print ("Fuel percentage new value:")
				write ("->")
				limit_fuel_aux = read ()*1

				if limit_fuel_aux >= 1 or limit_fuel_aux < 0 then
					print ("Invalid value!")
				else
					print ("Limit changed.")
					limit_fuel = limit_fuel_aux
				end

			else
				print ("These values must be: 0 < x < 10000000")
				print ("Turn on condition value:")
				write ("->")
				on_energy_aux = read ()*1
				print ("Turn off condition value:")
				write ("->")
				off_energy_aux = read ()*1

				if off_energy_aux < 0 or off_energy_aux > 10000000 or on_energy_aux < 0 or on_energy_aux > 10000000 then
					print ("At least one value is invalid!")
				else
					print ("Limits changed.")
					off_energy = off_energy_aux
					on_energy = on_energy_aux
				end
			end

		elseif command == "info" then
			print ("Rods level: " .. reactor.getControlRodLevel (0))
			print ("Number of rods: " .. reactor.getNumberOfControlRods ())

		-- welcome
		elseif command == "welcome" then
			term.clear ()
			term.setCursorPos (1, 1)
			print ("Welcome! Run \"help\" to show the commands.")

		else
			print ("Command not recognized!")

		end
	end
end

-- Touch screen
function touch_screen_init ()
	while true do
		-- Waiting the event monitor_touch
		local event, side, x, y = os.pullEvent ("monitor_touch")

		rods.setCursorPos (2, 4)
		rods.write ("+100%")

		rods.setCursorPos (8, 4)
		rods.write ("-100%")

		rods.setCursorPos (3, 6)
		rods.write ("+10%")

		rods.setCursorPos (9, 6)
		rods.write ("-10%")

		rods.setCursorPos (4, 8)
		rods.write ("+1%")

		rods.setCursorPos (10, 8)
		rods.write ("-1%")
		-- +1%
		if x >= 4 and x <= 6 and y == 14 then
			reactor.setAllControlRodLevels (reactor.getControlRodLevel (0) + 1)
		-- -1%
		elseif x >= 10 and x <= 12 and y == 14 then
			reactor.setAllControlRodLevels (reactor.getControlRodLevel (0) - 1)
		-- +10%
		elseif x >= 3 and x <= 6 and y == 12 then
			reactor.setAllControlRodLevels (reactor.getControlRodLevel (0) + 10)
		-- -10%
		elseif x >= 9 and x <= 12 and y == 12 then
			reactor.setAllControlRodLevels (reactor.getControlRodLevel (0) - 10)
		-- +100%
		elseif x >= 2 and x <= 6 and y == 10 then
			reactor.setAllControlRodLevels (100)
		-- -100%
		elseif x >= 8 and x <= 12 and y == 10 then
			reactor.setAllControlRodLevels (0)
		end
	end
end

-- Main function
function main ()
	mon.setBackgroundColor (colors.gray)
	mon.clear ()
	term.clear ()
	term.setCursorPos (1, 1)

	-- Initializations
	reactor.setAllControlRodLevels (0)

	-- Program begin
	print ("Welcome. What type of automation do you want? Fuel (0) or Stored Energy (1)")
	write ("Reactor~ ")
	automation = read()*1

	while not (automation == 1 or automation == 0) do
		print ("Option not recognized!")
		write ("Reactor~ ")
		automation = read()*1
	end

	parallel.waitForAny (interface_init, automation_init, console_init, touch_screen_init)
end

main ()
