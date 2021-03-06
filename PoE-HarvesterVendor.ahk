#NoEnv
#Warn
#SingleInstance Force
SetWorkingDir %A_ScriptDir% 
global version := "0.2.4"
global augmetnCounter := 1
global removeCounter := 1
global raCounter := 1
global otherCounter := 1
global outArrayCount := 0
global outArray := []		
;global newArray := []    
global arr := []
global outstring := ""
global firstGuiOpen := 0
getLeagues()

^g:: ;ctrl+g launches straight into the capture, opens gui afterwards
    processCrafts()
    if (firstGuiOpen == 0) {
        buildGUI()
    } 
    Gui, HarvestUI:Show, w1230 h350
    craftSort(outArray)
return
^+g:: ;ctrl+shift+g opens the gui, yo go from there
    buildGUI()
    Gui, HarvestUI:Show, w1230 h350
	clearAll()
Return

GuiEscape:
    Gui, HarvestUI:Show
GuiClose:
    ExitApp

Add_crafts:
    processCrafts()
    CraftSort(outArray)
return

Clear_all:
	clearAll()    
return

Aug_Post:
    createPost("A")
return

Rem_Post:
    createPost("R")
return

RA_Post:
    createPost("RA")
return

O_Post:
    createPost("O")
return

postAll:
	createPost("All")
return

LeagueDropdown:
    guiControlGet, selectedLeague,,League, value
    iniWrite, %selectedLeague%, %A_WorkingDir%/settings.ini, selectedLeague, s
	allowAll()
return

IGN:
	guiControlGet, lastIGN,,IGN, value
    iniWrite, %lastIGN%, %A_WorkingDir%/settings.ini, IGN, n
return

help:
gui Help:new

gui font, s16
Gui, add, text,, This is the area you want to select
gui, font
Gui, Add, ActiveX, x0 y30 w500 h500 vWB1, Shell.Explorer

; This can be an image from a website, or an image from your computer. Just specify the path based off of the current script directory.
Edit := WebPic(WB1, "https://github.com/esge/PoE-HarvestVendor/blob/master/examples/example3.png?raw=true", "w436 h425 cFFFFFF")
;Gui, Add, Edit, x0 y105 w750 h215 -Wrap +HScroll vEdit TabStop WantReturn t8
Gui, Help:Show, w500 h500, Gui Example


helpClose:
Gui, HarvestUI:Default
return
;Test_button:
;return
buildGUI(){    
    firstGuiOpen := 1
    Gui HarvestUI:New,, PoE-HarvestVendor v%version%	
    ;== top stuff ==
    Gui Add, DropDownList, x10 y10 w150 vLeague gLeagueDropdown,
    leagueList() ;populate leagues dropdown and select the last used one
    Gui Add, Button, x165 y9 w80 h23 gAdd_crafts, Add crafts
    Gui Add, Button, x250 y9 w80 h23 gClear_all, Clear
	gui font, s10
	Gui Add, Text, x340 y15 w25 h23, IGN:
	gui font
	IniRead, name, %A_WorkingDir%/settings.ini, IGN, n
	if (name == "ERROR") {
		name:=""
		}
	Gui Add, Edit, x370 y10 w150 h23 vIGN gIGN, %name%
	Gui Add, Button, x530 y9 w80 h23 vpostAll gpostAll, Post all
	allowAll()

	gui add, CheckBox, x630 y14 vcanStream, Can Stream
    
	if (version != getVersion()) {
		gui Font, s14
		gui add, Link, x950 y10 vVersionLink, <a href="https://github.com/esge/PoE-HarvestVendor/releases">! New Version Available !</a>
		gui font
	}


	Gui font, s26
	Gui Add, Button, x1175 y2 w40 h40 gHelp, ?
	Gui font

    ;== Section Augment ==
    Awidth := 175
    Ax_groupbox := 10
    Ax_count := Ax_groupbox + 5 ;groupbox x+5
    Ax_craft := Ax_count + 40 ;count + 40
    Ax_price := Awidth + Ax_craft + 5 ; width+craft + 5
    Ax_checkbox := Ax_price + 35 + 5 ; price + 35 + 5

    Gui Add, Button, x190 y50 w80 h23 gAug_Post, Create Posting

    Gui Font, s10
    Gui Add, Groupbox, x%Ax_groupbox% y35 w290 h300, Augment
    Gui Font

    yrow1 := 80
    loop, 10 {
        yrow1_cbOffset := yrow1 + 5
        Gui Add, Edit, x%Ax_count% y%yrow1% w35 vA_count_%A_Index% 
        Gui Add, UpDown, Range0-20, 0
        Gui Add, Edit, x%Ax_craft% y%yrow1% w%Awidth% vA_craft_%A_Index% 
        Gui Add, Edit, x%Ax_price% y%yrow1% w35 vA_price_%A_Index% 
        Gui Add, CheckBox, x%Ax_checkbox% y%yrow1_cbOffset% w23 vA_cb_%A_Index% 
        yrow1 += 25
    }

    ;== Section Remove ==
    Rwidth := 120
    Rx_groupbox := 305
    Rx_count := Rx_groupbox + 5
    Rx_craft := Rx_count + 40
    Rx_price := Rwidth + Rx_craft + 5
    Rx_checkbox := Rx_price + 35 + 5 

    Gui Add, Button, x430 y50 w80 h23 gRem_Post, Create Posting

    Gui Font, s10
    Gui Add, Groupbox, x%Rx_groupbox% y35 w235 h300, Remove
    Gui Font

    yrow1 := 80
    loop, 10 {
        yrow1_cbOffset := yrow1 + 5
        Gui Add, Edit, x%Rx_count% y%yrow1% w35 vR_count_%A_Index%
        Gui Add, UpDown, Range0-20, 0
        Gui Add, Edit, x%Rx_craft% y%yrow1% w%Rwidth% vR_craft_%A_Index%
        Gui Add, Edit, x%Rx_price% y%yrow1% w35 vR_price_%A_Index%
        Gui Add, CheckBox, x%Rx_checkbox% y%yrow1_cbOffset% w23 vR_cb_%A_Index%
        yrow1 += 25
    }

    ;== Section Rem/Add ==
    RAwidth := 185
    RAx_groupbox := 545
    RAx_count := RAx_groupbox + 5
    RAx_craft := RAx_count + 40
    RAx_price := RAwidth + RAx_craft + 5
    RAx_checkbox :=  RAx_price + 35 + 5 

    Gui Add, Button, x735 y50 w80 h23 gRA_Post, Create Posting

    Gui Font, s10
    Gui Add, Groupbox, x%RAx_groupbox% y35 w300 h300, Remove/Add
    Gui Font

    yrow1 := 80
    loop, 10 {
        yrow1_cbOffset := yrow1 + 5
        Gui Add, Edit, x%RAx_count% y%yrow1% w35 vRA_count_%A_Index%
        Gui Add, UpDown, Range0-20, 0
        Gui Add, Edit, x%RAx_craft% y%yrow1% w%RAwidth% vRA_craft_%A_Index%
        Gui Add, Edit, x%RAx_price% y%yrow1% w35 vRA_price_%A_Index%
        Gui Add, CheckBox, x%RAx_checkbox% y%yrow1_cbOffset% w23 vRA_cb_%A_Index%
        yrow1 += 25
    }

    ;== Section Other ==
    Owidth := 250
    Ox_groupbox := 850
    Ox_count := Ox_groupbox + 5
    Ox_craft := Ox_count + 40
    Ox_price := Owidth + Ox_craft + 5
    Ox_checkbox := Ox_price + 35 + 5 

    Gui Add, Button, x1105 y50 w80 h23 gO_Post, Create Posting

    Gui Font, s10
    Gui Add, Groupbox, x%Ox_groupbox% y35 w365 h300, Other
    Gui Font

    yrow1 := 80
    loop, 10 {
        yrow1_cbOffset := yrow1 + 5
        Gui Add, Edit, x%Ox_count% y%yrow1% w35 vO_count_%A_Index%
        Gui Add, UpDown, Range0-20, 0
        Gui Add, Edit, x%Ox_craft% y%yrow1% w%Owidth% vO_craft_%A_Index%
        Gui Add, Edit, x%Ox_price% y%yrow1% w35 vO_price_%A_Index%
        Gui Add, CheckBox, x%Ox_checkbox% y%yrow1_cbOffset% w23 vO_cb_%A_Index%
        yrow1 += 25
    }

    
}
processCrafts(){
	Gui, HarvestUI:Hide    
	
	outArray := []
    ;sleep, 1000   
	getSelectionCoords(x_start, x_end, y_start, y_end)

	command = Capture2Text\Capture2Text.exe -s `"%x_start% %y_start% %x_end% %y_end%`" -o temp.txt --trim-capture
	RunWait, %command%
    
    sleep, 1000 ;sleep cos if i show the Gui too quick the capture will grab screenshot of gui    
    Gui, HarvestUI:Show

	FileRead, temp, temp.txt
	;FileRead, temp, test2.txt

	NewLined := RegExReplace(temp, "(Reforge |Randomise |Remove |Augment |Improves |Upgrades |Upgrade |Set |Change |Exchange |Sacrifice a|Sacrifice up|Attempt |Enchant |Reroll |Fracture |Add a random |Synthesise |Split |Corrupt )" , "`r`n$1")
	Arrayed := StrSplit(NewLined, "`r`n")

	for index in Arrayed {	
		Arrayed[index] := Trim(RegExReplace(Arrayed[index] , " +", " ")) ;remove possible double spaces from ocr
		if (Arrayed[index] == "") {
			;skip empty fields
		}
		;Augment
		else if InStr(Arrayed[index], "Augment") = 1 {
			if InStr(Arrayed[index], "Influence") > 0 {				
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(an item with a new|ifier|with|values)","")
			} else {	
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a Magic or Rare item with a new|a Rare item with a new modifier, with||an item with a new|modifier|with|values)","")
			}
		}
		;Remove
		else if InStr(Arrayed[index], "Remove") = 1 {				
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a random|modifier|from an item|and|a new)","")	
		}
		;Reforge
		else if InStr(Arrayed[index], "Reforge") = 1 {
			;prefixes, suffixes
			if (InStr(Arrayed[index], "Prefixes") > 0 or InStr(Arrayed[index], "Suffixes") > 0 ){					
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a Rare item, |ing all|a Rare item with|modifier values,)|(Prefixes|Suffixes)","$2")
			}
			;links
			else if (InStr(Arrayed[index], "links") > 0 and InStr(Arrayed[index], "10 times") = 0){
				if InStr(Arrayed[index],"six") > 0 {
					outArrayCount += 1
					outArray[outArrayCount] := "Six link (6-link)"
				}	
			} 
			else if (InStr(Arrayed[index], "colour") > 0 and InStr(Arrayed[index], "10 times") = 0){		
				RCtemp := RegExReplace(Arrayed[index],"(random|the colour of|on an item,)","")
				RCtemp := RegExReplace(RCtemp,"(turning them)"," > ")	
				outArrayCount += 1
				outArray[outArrayCount] := RCtemp
			} 
			else if InStr(Arrayed[index], "Influence") > 0 {
				RItemp := RegExReplace(Arrayed[index],"(a Rare item|new random modifiers, including an|ifier. Influence modifiers are)","")
				RItemp := RegExReplace(Arrayed[index],"(a Rare item|new random modifiers, including an|ifier. influence modifiers are)","")
				outArrayCount += 1
				outArray[outArrayCount] := RItemp			
			}
			else {
				;outArrayCount += 1
				;outArray[outArrayCount] := RegExReplace(Arrayed[index],"(as a Rare item|item|random modifiers,|new random modifiers, |including an|including a|ifier|modifiers are)","")	
			}
						
			;Reforge a Rare item, being much more likely to receive the same modifier types
			;Reforge a Rare item, being much less likely to receive the same modifier types
		} 
		;Enchant
		else if InStr(Arrayed[index], "Enchant") = 1 {
			;flask
			if InStr(Arrayed[index], "Flask") > 1 {
				EFtemp:= RegExReplace(Arrayed[index],"(Enchant a Flask)","Enchant Flask:")
				EFtemp:= RegExReplace(EFtemp,"with a modifier that grants|reased|The magnitude of this effect decreases with each use","")
				outArrayCount += 1
				outArray[outArrayCount] := EFtemp
			}
			;weapon
			else if InStr(Arrayed[index], "Weapon") > 1 {

				EWtemp := RegExReplace(Arrayed[index],"(Enchant a Weapon.|Enchant a Melee Weapon.)","Enchant weap: ")
				EWtemp := RegExReplace(EWtemp,"(Quality does not increase its Physical Damage,|has|grants|1% increased|ical Strike| per 4% | per 2% | per 8% | per 10% |Quality)","")
				;EWtemp := RegExReplace(EWtemp,"( per 4% | per 2% | per 8% | per 10% )","/")
				outArrayCount += 1
				outArray[outArrayCount] := EWtemp
			}			
			;body armour
			else if InStr(Arrayed[index], "Armour") > 1 {
				EBtemp := RegExReplace(Arrayed[index],"( Armour. )",":")
				EBtemp := RegExReplace(EBtemp,"(Quality does not increase its Defences, grants| per 2% quality)","" )
				outArrayCount += 1
				outArray[outArrayCount] := EBtemp 
			}	
		}
		;Attempt
		else if InStr(Arrayed[index], "Attempt") = 1 {
			;awaken
			if InStr(Arrayed[index], "Awaken") > 1 {
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(that can be Awakened with a 5% chance. If it does not Awaken, it is destroyed.)","")
			}
			;scarab upgrade
			else if InStr(Arrayed[index], "Scarab") > 1 {
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(, with a chance for it to become Winged)","")
			}	
		}
		;Change
		else if InStr(Arrayed[index], "Change") = 1 {
			; res mods
			if InStr(Arrayed[index], "Resistance") > 0 {
				outArrayCount += 1
				outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a modifier that grants|a similar-tier modifier that grants|istance)","")
			} else {
			; ignore others ?				
			}		
		} 
		;sacrifice 
		else if InStr(Arrayed[index], "Sacrifice") = 1 {
			;gem for gcp/xp
			if InStr(Arrayed[index], "Gem") > 1 {
				SGtemp := RegExReplace(Arrayed[index],"(Sacrifice a Corrupted Gem to gain)","Sacrifice Corrupted Gem > ")
				SGtemp := RegExReplace(SGtemp,"(of the gem's quality as Gemcutter's Prisms)","qual as GCP")
				SGtemp := RegExReplace(SGtemp,"(of the gem's total experience stored as a Facetor's Lens)","exp as Lense")
				outArrayCount += 1
				outArray[outArrayCount] := SGtemp
			} 

			;div cards gambling
			else if InStr(Arrayed[index], "Divination") > 1  {
				if InStr(Arrayed[index], "half a stack") > 1 {
					outArrayCount += 1
					outArray[outArrayCount] :=  RegExReplace(Arrayed[index],"(up to half a stack of|ination|to receive between 0 and twice that amount of the same Card)","")
				}
				;skipping this:
				;	Sacrifice a stack of Divination Cards for that many different Divination Cards
			} else {
				;ignores the rest of sacrifice crafts:
					;Sacrifice or Mortal Fragment into another random Fragment of that type
					;Sacrificie Maps for same or lower tier stuff
					;Sacrifice maps for missions
					;Sacrifice maps for map device infusions
					;Sacrifice maps for fragments
					;Sacrifice maps for map currency
					;Sacrifice maps for scarabs
					;sacrifice t14+ map for elder/shaper/synth map
					;sacrifice weap/ar to make similiar belt/ring/amulet/jewel				
			}
		} 

		;Improves
		else if InStr(Arrayed[index], "Improves") = 1 {			
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"( by at least 10%. Has greater effect on lower rarity flasks. The maximum quality is 20%| by at least 10%. The maximum quality is 20%)","")
		}	
		else if InStr(Arrayed[index], "Fracture") = 1 {			
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a random|on an item with at least 5 modifiers, locking it in place. This can't be used on Influenced, Synthesised, or Fractured items| on an item with at least 3 Suffixes. This can't be used on Influenced, Synthesised, or Fractured items| on an item with at least 3 Prefixes. This can't be used on Influenced, Synthesised, or Fractured items)","")
		} 		
		else if InStr(Arrayed[index], "Reroll") = 1 {
			RERtemp := RegExReplace(Arrayed[index],"(the values of Prefix, Suffix and Implicit modifiers on a Rare item, with Lucky modifier values)","all Lucky")
			RERtemp := RegExReplace(RERtemp,"(the values of|modifiers on a Magic or Rare item, with|modifier values)","")
			outArrayCount += 1
			outArray[outArrayCount] := RERtemp
		}
		else if InStr(Arrayed[index], "Randomise") = 1 {		
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"(the numeric|the random|ifier|on a Magic or Rare item)","")
		}
		else if InStr(Arrayed[index], "Add") = 1 {		
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"(a random|a Normal, Magic or Rare|Normal, Magic or Rare|that isn't influenced)","")
		}
		else if InStr(Arrayed[index], "Set") = 1 {		
			SJtemp := RegExReplace(Arrayed[index],"(Cobalt, Crimson, Viridian or Prismatic)","basic")
			SJtemp := RegExReplace(SJtemp,"(a new|modifier on an|modifier on a|Jewel or)","")
			outArrayCount += 1
			outArray[outArrayCount] := SJtemp
		}
		;Synthesise
		else if InStr(Arrayed[index], "Synthesise") = 1 {			
			outArrayCount += 1
			outArray[outArrayCount] := RegExReplace(Arrayed[index],"(, giving random Synthesised implicits. Cannot be used on Unique, Influenced, Synthesised or Fractured items)","")
		}

		else if InStr(Arrayed[index], "Corrupt") = 1 {	
			;Corrupt an item 10 times, or until getting a corrupted implicit modifier

			;outArrayCount += 1
			;outArray[outArrayCount] := Arrayed[index]
		}
	 ; ignoring this section of mods
	 ; and i do realize i could put them in a single if, but this way its already neatly split if i might want to add them into processing 	
		;Exchange 
		else if InStr(Arrayed[index], "Exchange") = 1 {
			;skipping all exchange crafts assuming anybody would just use them for themselfs
			
		} 
		;Upgrade
		else if InStr(Arrayed[index], "Upgrade") = 1 {
			;skipping upgrade crafts
			
		}	
	
		else if InStr(Arrayed[index], "Split") = 1 {
			;skipping Split scarab craft			
		}	


		;just add unknown stuff as is
		;else {
		;	out .= Arrayed[index] . "`r`n"
		;}		
	}

    for iFinal in outArray {	            
        outArray[iFinal] := RegExReplace(outArray[iFinal], "([^\w\s]+|_+)","")
		outArray[iFinal] := RegExReplace(outArray[iFinal] , "(Level )", "lv")
        ; removes multiple spaces, but all all non chars so it gets rid of stray .,' from OCR, we lose the  dash in non-Tag, but we can lve with that)
        outArray[iFinal] := Trim(RegExReplace(outArray[iFinal] , " +", " ")) 
    }
}


clearAll(){
    loop, 10 {
        GuiControl,, A_craft_%A_Index%
        GuiControl,, R_craft_%A_Index%
        GuiControl,, RA_craft_%A_Index%
        GuiControl,, O_craft_%A_Index%
        GuiControl,, A_count_%A_Index%, 0
        GuiControl,, R_count_%A_Index%, 0
        GuiControl,, RA_count_%A_Index%, 0
        GuiControl,, O_count_%A_Index%, 0
        GuiControl,, A_cb_%A_Index%, 0
        GuiControl,, R_cb_%A_Index%, 0
        GuiControl,, RA_cb_%A_Index%, 0
        GuiControl,, O_cb_%A_Index%, 0
		GuiControl,, A_price_%A_Index%
        GuiControl,, R_price_%A_Index%
        GuiControl,, RA_price_%A_Index%
        GuiControl,, O_price_%A_Index%
		}
        augmetnCounter := 1
        removeCounter := 1
        raCounter := 1
        otherCounter := 1
        outArray := []
        arr := []
}


allowAll(){
	IniRead selLeague, %A_WorkingDir%/settings.ini, selectedLeague, s
	if InStr(selLeague, "Standard") = 0 {
		guicontrol, Disable, postAll
	} else {
		guicontrol, Enable, postAll
	}
}

leagueList(){
    leagueString := ""
    loop, 8 {
        IniRead, tempList, %A_WorkingDir%/settings.ini, Leagues, %A_Index%
       ; msgbox % tempList
	   
        if InStr(tempList, "Hardcore") = 0 and InStr(tempList, "HC") = 0 {
            tempList .= " Softcore"
        } 
		if (tempList == "Hardcore") {
			tempList := "Standard Hardcore"
		}
		if InStr(tempList,"SSF") = 0 {
        	leagueString .= tempList . "|"
		}
    }
    guicontrol,, League, %leagueString%
	guicontrol, choose, League, 1
    iniRead, selectedL, %A_WorkingDir%/settings.ini, selectedLeague, s
    guicontrol, Choose, League, %selectedL%
}
getRowData(group, row) {
	GuiControlGet, tempCount,, %group%_count_%row%, value
	GuiControlGet, tempCraft,, %group%_craft_%row%, value
	GuiControlGet, tempPrice,, %group%_price_%row%, value
	GuiControlGet, tempCheck,, %group%_cb_%row%, value

	return [tempCount, tempCraft, tempPrice, tempCheck]
}

readyTT(){
   ClipWait
   ToolTip, Post Ready
	sleep, 2000
	Tooltip	
}

createPostRow(count,craft,price){
	if regexmatch(craft,"(lv\d\d)") > 0 {
	 	craft := RegExReplace(craft,"(lv\d\d)","][$1")
	}
	else {
		craft := craft . "][-"
	}
	outString .= "  (" . count . "x) [" . craft . "] - < " . price . " >`r`n"
}
codeblockWrap(){
	return "``````md`r`n" . outString . "``````"
}

createPost(group){
    tempName := ""
	GuiControlGet, tempLeague,, League, value
	GuiControlGet, tempName,, IGN, value
	guiControlGet, tempStream,, canStream, value
    outString := ""

	if (tempName != "") {
    	outString .= "#WTS " . tempLeague . " - IGN: " . tempName . "`r`n" 
	} else {
		outString .= "#WTS " . tempLeague . "`r`n"
	}
	if (tempStream == 1 ){
		outString .= "  can stream if requested `r`n"
	}
    switch group {
        case "A":            
            loop, 10 {
				row:= getRowData("A",A_Index)
				if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
					;outString .= "  " . row[1] . "x " . row[2] . " - " . row[3] . "`r`n"
				}
            }
            Clipboard := codeblockWrap()
            readyTT()
        return
        case "R":            
            loop, 10 {                
				row:= getRowData("R",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}   
            }
            Clipboard := codeblockWrap()
            readyTT()
        return
        case "RA":            
            loop, 10 {
                row:= getRowData("RA",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}   
            }
            Clipboard := codeblockWrap()
            readyTT()
        return
        case "O":      
            loop, 10 {
                row:= getRowData("O",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}    
            }
            Clipboard := codeblockWrap()
            readyTT()
        return 
		case "All":
		 	loop, 10 {
               row:= getRowData("A",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}     
            }
			loop, 10 {
                row:= getRowData("R",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}   
            }
			loop, 10 {
                row:= getRowData("RA",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}   
            }
			loop, 10 {
                row:= getRowData("O",A_Index)
                if (row[4] == 1){
					createPostRow(row[1],row[2],row[3])
				}    
            }
			Clipboard := codeblockWrap()
            readyTT()
		return   
    }    
}

incCraftCount(group, craft){	
	switch group {
		case "A":
		loop, 10 {
			GuiControlGet, craftCheck,, A_craft_%A_Index%, value
			if (craftCheck == craft) {    				
				GuiCOntrolGet, craftCount,, A_count_%A_index%				
				craftCount += 1 
				GuiControl,, A_count_%A_Index%, %craftCount% 
				return true 
			}			
		}		
		return
		case "R":
		loop, 10 {
			GuiControlGet, craftCheck,, R_craft_%A_Index%, value
			if (craftCheck == craft) {				
				GuiCOntrolGet, craftCount,, R_count_%A_index%				
				craftCount += 1
				GuiControl,, R_count_%A_Index%, %craftCount%
				return true
			}	
		}
		return
		case "RA":
		loop, 10 { 
			GuiControlGet, craftCheck,, RA_craft_%A_Index%, value
			if (craftCheck == craft) {				
				GuiCOntrolGet, craftCount,, RA_count_%A_index%				
				craftCount += 1
				GuiControl,, RA_count_%A_Index%, %craftCount%
				return true
			}
		}
		return
		case "O":
		loop, 10 {
			GuiControlGet, craftCheck,, O_craft_%A_Index%, value
			if (craftCheck == craft) {				
				GuiCOntrolGet, craftCount,, O_count_%A_index%				
				craftCount += 1
				GuiControl,, O_count_%A_Index%, %craftCount%
				return true
			}
		}
		return
	}
}

insertIntoRow(group, rowCounter, craft){
    GuiControl,, %group%_craft_%rowCounter%, %craft%
    GuiControl,, %group%_count_%rowCounter%, 1
    GuiControl,, %group%_cb_%rowCounter%, 1
}

CraftSort(ar){
    tempC := ""
    for k in ar {        
        ;augment
        if InStr(ar[k], "Augment") = 1 {       
            tempC := ar[k]
            if not incCraftCount("A", tempC) {
				insertIntoRow("A",augmetnCounter,tempC)                
                augmetnCounter += 1
            }
        }        
        ;remove
        else if InStr(ar[k], "Remove") = 1 and InStr(ar[k], "add") = 0 {
            ;msgbox, Remove %removeCounter%
            tempC := ar[k]
            if not incCraftCount("R", tempC) {
                insertIntoRow("R",removeCounter,tempC)  
                removeCounter += 1
            }
        }
        ;remove/add
        else if InStr(ar[k], "Remove") = 1 and InStr(ar[k], "add") > 0 and InStr(ar[k], "non") = 0 {
            ;msgbox, RA %raCounter%
            tempC := ar[k]
            if not incCraftCount("RA", tempC) {
                insertIntoRow("RA",raCounter,tempC)
                raCounter += 1
            }
        }
        ;other
        else {
        ;if InStr(ar[index], "Augment") = 0 and InStr(ar[index], "add") > 0 and InStr(ar[index], "non") = 0{
            ;msgbox, O %otherCounter%
            tempC := ar[k]
            if not incCraftCount("O", tempC) {
                insertIntoRow("O",otherCounter,tempC)
                otherCounter += 1
            }
        }
    }
}

getLeagues(){
    oWhr := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    oWhr.Open("GET", "http://api.pathofexile.com/leagues?type=main&compact=1", false)
    oWhr.SetRequestHeader("Content-Type", "application/json")
    ;oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
    oWhr.Send()
    parsed := Jxon_load(oWhr.ResponseText) 
    ;couldnt figure out how to make the number in parsed.1.id work as paramter, it doesnt like %% in there between the dots
        tempParse := parsed.1.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 1
        tempParse := parsed.2.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 2
        tempParse := parsed.3.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 3
        tempParse := parsed.4.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 4
        tempParse := parsed.5.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 5
        tempParse := parsed.6.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 6
        tempParse := parsed.7.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 7
        tempParse := parsed.8.id          
        iniWrite, %tempParse%, %A_WorkingDir%/settings.ini, Leagues, 8
}

getVersion(){
	ver := ComObjCreate("WinHttp.WinHttpRequest.5.1")
    ver.Open("GET", "https://raw.githubusercontent.com/esge/PoE-HarvestVendor/master/version.txt", false)
    ver.SetRequestHeader("Content-Type", "application/json")
    ;oWhr.SetRequestHeader("Authorization", "Bearer 80b44ea9c302237f9178a137d9e86deb-20083fb12d9579469f24afa80816066b")
    ver.Send()
    return StrReplace(StrReplace(ver.ResponseText,"`r"),"`n")
}

getSelectionCoords(ByRef x_start, ByRef x_end, ByRef y_start, ByRef y_end) {
	;Mask Screen
    Gui, Select:New
	Gui, Color, FFFFFF
	Gui +LastFound
	WinSet, Transparent, 50
    Gui, -Caption 
	Gui, +AlwaysOnTop
	Gui, Select:Show, x0 y0 h%A_ScreenHeight% w%A_ScreenWidth%,"AutoHotkeySnapshotApp"     

	;Drag Mouse
	CoordMode, Mouse, Screen
	CoordMode, Tooltip, Screen
	WinGet, hw_frame_m,ID,"AutoHotkeySnapshotApp"
	hdc_frame_m := DllCall( "GetDC", "uint", hw_frame_m)
	KeyWait, LButton, D 
	MouseGetPos, scan_x_start, scan_y_start 
	Loop
	{
		Sleep, 10   
		KeyIsDown := GetKeyState("LButton")
		if (KeyIsDown = 1)
		{
			MouseGetPos, scan_x, scan_y 
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", 0,"int",0,"int", A_ScreenWidth,"int",A_ScreenWidth)
			DllCall( "gdi32.dll\Rectangle", "uint", hdc_frame_m, "int", scan_x_start,"int",scan_y_start,"int", scan_x,"int",scan_y)
		} else {
			break
		}
	}

	;KeyWait, LButton, U
	MouseGetPos, scan_x_end, scan_y_end
	Gui Select:Destroy
	Gui, HarvestUI:Default
	if (scan_x_start < scan_x_end)
	{
		x_start := scan_x_start
		x_end := scan_x_end
	} else {
		x_start := scan_x_end
		x_end := scan_x_start
	}
	
	if (scan_y_start < scan_y_end)
	{
		y_start := scan_y_start
		y_end := scan_y_end
	} else {
		y_start := scan_y_end
		y_end := scan_y_start
	}
}

;==== JSON PARSER FROM https://github.com/cocobelgica/AutoHotkey-JSON ====
Jxon_Load(ByRef src, args*)
{
	static q := Chr(34)

	key := "", is_key := false
	stack := [ tree := [] ]
	is_arr := { (tree): 1 }
	next := q . "{[01234567890-tfn"
	pos := 0
    value := ""
	while ( (ch := SubStr(src, ++pos, 1)) != "" )
	{
		if InStr(" `t`n`r", ch)
			continue
		if !InStr(next, ch, true)
		{
			ln := ObjLength(StrSplit(SubStr(src, 1, pos), "`n"))
			col := pos - InStr(src, "`n",, -(StrLen(src)-pos+1))

			msg := Format("{}: line {} col {} (char {})"
			,   (next == "")      ? ["Extra data", ch := SubStr(src, pos)][1]
			  : (next == "'")     ? "Unterminated string starting at"
			  : (next == "\")     ? "Invalid \escape"
			  : (next == ":")     ? "Expecting ':' delimiter"
			  : (next == q)       ? "Expecting object key enclosed in double quotes"
			  : (next == q . "}") ? "Expecting object key enclosed in double quotes or object closing '}'"
			  : (next == ",}")    ? "Expecting ',' delimiter or object closing '}'"
			  : (next == ",]")    ? "Expecting ',' delimiter or array closing ']'"
			  : [ "Expecting JSON value(string, number, [true, false, null], object or array)"
			    , ch := SubStr(src, pos, (SubStr(src, pos)~="[\]\},\s]|$")-1) ][1]
			, ln, col, pos)

			throw Exception(msg, -1, ch)
		}

		is_array := is_arr[obj := stack[1]]

		if i := InStr("{[", ch)
		{
			val := (proto := args[i]) ? new proto : {}
			is_array? ObjPush(obj, val) : obj[key] := val
			ObjInsertAt(stack, 1, val)
			
			is_arr[val] := !(is_key := ch == "{")
			next := q . (is_key ? "}" : "{[]0123456789-tfn")
		}

		else if InStr("}]", ch)
		{
			ObjRemoveAt(stack, 1)
			next := stack[1]==tree ? "" : is_arr[stack[1]] ? ",]" : ",}"
		}

		else if InStr(",:", ch)
		{
			is_key := (!is_array && ch == ",")
			next := is_key ? q : q . "{[0123456789-tfn"
		}

		else ; string | number | true | false | null
		{
			if (ch == q) ; string
			{
				i := pos
				while i := InStr(src, q,, i+1)
				{
					val := StrReplace(SubStr(src, pos+1, i-pos-1), "\\", "\u005C")
					static end := A_AhkVersion<"2" ? 0 : -1
					if (SubStr(val, end) != "\")
						break
				}
				if !i ? (pos--, next := "'") : 0
					continue

				pos := i ; update pos

				  val := StrReplace(val,    "\/",  "/")
				, val := StrReplace(val, "\" . q,    q)
				, val := StrReplace(val,    "\b", "`b")
				, val := StrReplace(val,    "\f", "`f")
				, val := StrReplace(val,    "\n", "`n")
				, val := StrReplace(val,    "\r", "`r")
				, val := StrReplace(val,    "\t", "`t")

				i := 0
				while i := InStr(val, "\",, i+1)
				{
					if (SubStr(val, i+1, 1) != "u") ? (pos -= StrLen(SubStr(val, i)), next := "\") : 0
						continue 2

					; \uXXXX - JSON unicode escape sequence
					xxxx := Abs("0x" . SubStr(val, i+2, 4))
					if (A_IsUnicode || xxxx < 0x100)
						val := SubStr(val, 1, i-1) . Chr(xxxx) . SubStr(val, i+6)
				}

				if is_key
				{
					key := val, next := ":"
					continue
				}
			}

			else ; number | true | false | null
			{
				val := SubStr(src, pos, i := RegExMatch(src, "[\]\},\s]|$",, pos)-pos)
			
			; For numerical values, numerify integers and keep floats as is.
			; I'm not yet sure if I should numerify floats in v2.0-a ...
				static number := "number", integer := "integer"
				if val is %number%
				{
					if val is %integer%
						val += 0
				}
			; in v1.1, true,false,A_PtrSize,A_IsUnicode,A_Index,A_EventInfo,
			; SOMETIMES return strings due to certain optimizations. Since it
			; is just 'SOMETIMES', numerify to be consistent w/ v2.0-a
				else if (val == "true" || val == "false")
					val := %value% + 0
			; AHK_H has built-in null, can't do 'val := %value%' where value == "null"
			; as it would raise an exception in AHK_H(overriding built-in var)
				else if (val == "null")
					val := ""
			; any other values are invalid, continue to trigger error
				else if (pos--, next := "#")
					continue
				
				pos += i-1
			}
			
			is_array? ObjPush(obj, val) : obj[key] := val
			next := obj==tree ? "" : is_array ? ",]" : ",}"
		}
	}

	return tree[1]
}

Jxon_Dump(obj, indent:="", lvl:=1)
{
	static q := Chr(34)

	if IsObject(obj)
	{
		static Type := Func("Type")
		if Type ? (Type.Call(obj) != "Object") : (ObjGetCapacity(obj) == "")
			throw Exception("Object type not supported.", -1, Format("<Object at 0x{:p}>", &obj))

		is_array := 0
		for k in obj
			is_array := k == A_Index
		until !is_array

		static integer := "integer"
		if indent is %integer%
		{
			if (indent < 0)
				throw Exception("Indent parameter must be a postive integer.", -1, indent)
			spaces := indent, indent := ""
			Loop % spaces
				indent .= " "
		}
		indt := ""
		Loop, % indent ? lvl : 0
			indt .= indent

		lvl += 1, out := "" ; Make #Warn happy
		for k, v in obj
		{
			if IsObject(k) || (k == "")
				throw Exception("Invalid object key.", -1, k ? Format("<Object at 0x{:p}>", &obj) : "<blank>")
			
			if !is_array
				out .= ( ObjGetCapacity([k], 1) ? Jxon_Dump(k) : q . k . q ) ;// key
				    .  ( indent ? ": " : ":" ) ; token + padding
			out .= Jxon_Dump(v, indent, lvl) ; value
			    .  ( indent ? ",`n" . indt : "," ) ; token + indent
		}

		if (out != "")
		{
			out := Trim(out, ",`n" . indent)
			if (indent != "")
				out := "`n" . indt . out . "`n" . SubStr(indt, StrLen(indent)+1)
		}
		
		return is_array ? "[" . out . "]" : "{" . out . "}"
	}

	; Number
	else if (ObjGetCapacity([obj], 1) == "")
		return obj

	; String (null -> not supported by AHK)
	if (obj != "")
	{
		  obj := StrReplace(obj,  "\",    "\\")
		, obj := StrReplace(obj,  "/",    "\/")
		, obj := StrReplace(obj,    q, "\" . q)
		, obj := StrReplace(obj, "`b",    "\b")
		, obj := StrReplace(obj, "`f",    "\f")
		, obj := StrReplace(obj, "`n",    "\n")
		, obj := StrReplace(obj, "`r",    "\r")
		, obj := StrReplace(obj, "`t",    "\t")

		static needle := (A_AhkVersion<"2" ? "O)" : "") . "[^\x20-\x7e]"
		while RegExMatch(obj, needle, m)
			obj := StrReplace(obj, m[0], Format("\u{:04X}", Ord(m[0])))
	}
	
	return q . obj . q
}

WebPic(WB, Website, Options := "") {
	RegExMatch(Options, "i)w\K\d+", W), (W = "") ? W := 50 :
	RegExMatch(Options, "i)h\K\d+", H), (H = "") ? H := 50 :
	RegExMatch(Options, "i)c\K\d+", C), (C = "") ? C := "EEEEEE" :
	WB.Silent := True
	HTML_Page :=
	(RTRIM
	"<!DOCTYPE html>
		<html>
			<head>
				<style>
					body {
						background-color: #" C ";
					}
					img {
						top: 0px;
						left: 0px;
					}
				</style>
			</head>
			<body>
				<img src=""" Website """ alt=""Picture"" style=""width:" W "px;height:" H "px;"" />
			</body>
		</html>"
	)
	While (WB.Busy)
		Sleep 10
	WB.Navigate("about:" HTML_Page)
	Return HTML_Page
}

; === all variables for GUI elements have to be global if i wanna run it from a function, so here we go ===
global League
global IGN
global postAll
global canStream
global VersionLink
global A_count_1
global A_count_2
global A_count_3
global A_count_4
global A_count_5
global A_count_6
global A_count_7
global A_count_8
global A_count_9
global A_count_10
global A_craft_1
global A_craft_2
global A_craft_3
global A_craft_4
global A_craft_5
global A_craft_6
global A_craft_7
global A_craft_8
global A_craft_9
global A_craft_10
global A_price_1
global A_price_2
global A_price_3
global A_price_4
global A_price_5
global A_price_6
global A_price_7
global A_price_8
global A_price_9
global A_price_10
global A_cb_1
global A_cb_2
global A_cb_3
global A_cb_4
global A_cb_5
global A_cb_6
global A_cb_7
global A_cb_8
global A_cb_9
global A_cb_10
global R_count_1
global R_count_2
global R_count_3
global R_count_4
global R_count_5
global R_count_6
global R_count_7
global R_count_8
global R_count_9
global R_count_10
global R_craft_1
global R_craft_2
global R_craft_3
global R_craft_4
global R_craft_5
global R_craft_6
global R_craft_7
global R_craft_8
global R_craft_9
global R_craft_10
global R_price_1
global R_price_2
global R_price_3
global R_price_4
global R_price_5
global R_price_6
global R_price_7
global R_price_8
global R_price_9
global R_price_10
global R_cb_1
global R_cb_2
global R_cb_3
global R_cb_4
global R_cb_5
global R_cb_6
global R_cb_7
global R_cb_8
global R_cb_9
global R_cb_10
global RA_count_1
global RA_count_2
global RA_count_3
global RA_count_4
global RA_count_5
global RA_count_6
global RA_count_7
global RA_count_8
global RA_count_9
global RA_count_10
global RA_craft_1
global RA_craft_2
global RA_craft_3
global RA_craft_4
global RA_craft_5
global RA_craft_6
global RA_craft_7
global RA_craft_8
global RA_craft_9
global RA_craft_10
global RA_price_1
global RA_price_2
global RA_price_3
global RA_price_4
global RA_price_5
global RA_price_6
global RA_price_7
global RA_price_8
global RA_price_9
global RA_price_10
global RA_cb_1
global RA_cb_2
global RA_cb_3
global RA_cb_4
global RA_cb_5
global RA_cb_6
global RA_cb_7
global RA_cb_8
global RA_cb_9
global RA_cb_10
global O_count_1
global O_count_2
global O_count_3
global O_count_4
global O_count_5
global O_count_6
global O_count_7
global O_count_8
global O_count_9
global O_count_10
global O_craft_1
global O_craft_2
global O_craft_3
global O_craft_4
global O_craft_5
global O_craft_6
global O_craft_7
global O_craft_8
global O_craft_9
global O_craft_10
global O_price_1
global O_price_2
global O_price_3
global O_price_4
global O_price_5
global O_price_6
global O_price_7
global O_price_8
global O_price_9
global O_price_10
global O_cb_1
global O_cb_2
global O_cb_3
global O_cb_4
global O_cb_5
global O_cb_6
global O_cb_7
global O_cb_8
global O_cb_9
global O_cb_10