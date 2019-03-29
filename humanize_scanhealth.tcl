#!/usr/bin/tclsh

# Convert scanner_health.csv epoch time values to something more human readable.

# This script depends on a modern version of TCL/TK language (ideally 8.5 or later but may work with 8.3+). Refer to your system manual for installation of the tcl package.
# Tested and works under Ubuntu Linux 16.04


# ToDo Maybes
# 1 - Flag that outputs to other time locales. Currently defaults to GMT/UTC (although editable on line 49)
# 2 - Multi file processing
# 3 - Buffered processing style for the generally unlikely case of large multi-GB
# 4 - Tabbed-spaced output option cuz nobody likes to read CSVs in bunched up text

# Known Issues
# 1 - If file isnt consistent content (not a CSV or particularly if epoch column is not a convertible integer) it will straight write the line out rather than exception. 

set TZ ":GMT"
set version "0.1"
set author "Rudolph U"

if {$argc > 1} {
        puts "Use a single CSV file argument.\n Syntax: \'$argv0 EXAMPLE.csv\'"
        exit 1
                 }\
elseif {$argc == 0} {
        puts "No input file specified."
	exit 2
                      }\
else {
        set target [lindex $argv 0]
     }


set currdir [pwd]
set csvloc [string last ".csv" $target]

if { $csvloc > -1 } {
	set savefile [string replace $target $csvloc [expr $csvloc + 3] "-modified.csv"]
		   }\
else {
	set savefile [append $currdir $target "-modified.csv"]
     }


puts "humanize_scanhealth $version  by $author launching \n"
puts "Input file: $target"
puts "Output file: $savefile"

if [catch {open $target "r"} fd1 ] {
	puts "Failed to open file '$target'. No read permission."
	exit 3
}

if [catch {open $savefile "w"} fd2 ] {
	puts "Failed to open file '$savefile'. No write permission."
	exit 3
}


foreach line [split [read $fd1] \n] {

# This just does a quick and dirty glob match for digits in the lead, if not presume it's text line and spit it out direct. Quicker than regex.
if { ![string match "\[0-9\]\[0-9\]\[0-9\]\[0-9\]\[0-9\]*" $line] } { puts $fd2 $line }\
else {
	set k [split $line ,]
	set htime [clock format [lindex $k 0] -timezone $TZ]
	set line [join [lreplace $k 0 0 $htime] ,]
	puts $fd2 $line
     }

}

close $fd1
close $fd2

puts "\nScript Finished. Epoch values converted to  $TZ \n"
exit 0
