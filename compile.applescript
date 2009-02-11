# compile-applescript
# OS X 10.5.6
# AppleScript's version "2.0.1"
# Finder.app version "10.5.8"
# last: 2009-02-11.
script mycomplie
	
	on default_dialog(t, str, b)
		tell application "Finder"
			display dialog str buttons b default button 1 with title t
			set res to button returned of result
			return res
		end tell
	end default_dialog
	
	on giving_dialog(t, str, b)
		tell application "Finder" to display dialog str buttons b default button 1 with title t giving up after 3
	end giving_dialog
	
	on start_dialog()
		set str to "ALL .applescript Fils in choosed folder to .scpt Files. OK?"
		default_dialog("Start?", str, {"Start", "Cancel"})
	end start_dialog
	
	on error_save(new_path)
		set str to new_path & return & "Same FILE EXIST. Not Saved."
		default_dialog("Error", str, {"Done"})
	end error_save
	
	on get_dir(str)
		tell application "Finder"
			close windows
			choose folder with prompt str
		end tell
	end get_dir
	
	on get_orgfiles(dir)
		# ignore file type. check only file extension.
		tell application "Finder" to set files_as to every file in the folder dir whose name extension is "applescript"
		set ary to {}
		repeat with i from 1 to (count items of files_as)
			set end of ary to item i of files_as as text
		end repeat
		return ary
	end get_orgfiles
	
	on get_newfiles(org_files, new_fold)
		set ary to {}
		set cnt to 1
		repeat with i in org_files
			set n to get_name(i as alias)
			set w to (new_fold as text) & n
			set end of ary to w as text
			set cnt to cnt + 1
		end repeat
		return ary
	end get_newfiles
	
	on get_name(f)
		tell application "Finder"
			set n to name of f # file's fullname
			set ext to item 2 of words of n # file's extention
			set f_name to (item 1 of words of n) & ".scpt"
		end tell
	end get_name
	
	on exist_obj(str)
		tell application "Finder" to exists str
	end exist_obj
	
	on compile_sav(org_path, new_path)
		tell me
			set doc to open org_path as alias
			compile doc
			set name_doc to name of doc
			save doc in new_path
			set new_doc to alias new_path
			close the window 1
		end tell
	end compile_sav
	
	on compile_files(orgary, newary)
		set cnt to 0
		repeat with i in newary
			set cnt to cnt + 1
			if exist_obj(i) is false then
				set str to i & return & return & " Save. OK?"
				set res to default_dialog("SAVE", str, {"OK", "NOTSAVE"})
				if res is "OK" then
					set org_path to item cnt of orgary
					compile_sav(org_path, i as text)
				end if
			else
				error_save(i)
			end if
		end repeat
	end compile_files
	
end script

on run
	tell mycomplie
		#try
		start_dialog()
		set org_fold to get_dir("Plese select folder, contain .applescript files.")
		set new_fold to get_dir("Plese selecht new folder for scpt folder")
		set org_files to get_orgfiles(org_fold)
		set new_files to get_newfiles(org_files, new_fold)
		if new_files is {} then
			giving_dialog("error", "not exit file.applescript", {"Bye"})
			return
		end if
		
		# run .applescript Files to .scpt File
		compile_files(org_files, new_files)
		giving_dialog("Success", "See you", {"Bye"})
		#on error errMessage number errNO
		#	if errNO is -128 then
		#		giving_dialog("End", "User's Cancel", {"Bye"})
		#   else
		#       return errMessage
		#	end if
		#end try
	end tell
end run
