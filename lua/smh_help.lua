<!--This html document is in .lua extension because even text files aren't allowed for worskhop...-->

<html>
<head>
<title>Stop Motion Helper</title>
</head>
<body bgcolor="white">
<h2>Stop Motion Helper</h2>

<h3>How to use</h3>

<p>Open up console and bind a key to "+smh_menu". Use that key to open/close the menu.
In the menu, you see a list of frames with small buttons next and up to it.<br/>
<ul>
<li>+ button adds a frame after currently selected frame</li>
<li>- removes currently selected frame</li>
<li>* records currently selected frame</li>
<li>X clears currently selected frame</li>
</ul>
Below these buttons you see a number wang from reach 0 to 100. This sets how many pictures do you want
between the current and next frame.<br/>
Then there are 2 wangs: Ease in and Ease out. Edit these for the kind of speed you want your movement to be.
Here are few examples (S = Start, E = End):<br/>
<ul>
<li>S 1.0, E 0.0 for constantly accelerating movement.</li>
<li>S 0.0, E 1.0 for constantly slowing movement.</li>
<li>S 0.5, E 0.5 for acceleration until middle, and slowing after it.</li>
<li>S 0.1, E 0.1 for quick speedup and quick slowdown</li>
</ul>

<br/><br/>
Then there is wireframe color button, which opens a menu of red, green and blue sliders. These control
the color of wireframe models.<br/>
'Localized' checkbox controls if movement is localized. Localizing means (in this case), that all bones of a ragdoll are moving relatively to the main bone.
This can solve welding problems on some movements.<br/>
'Save on Add' checkbox controls if added frames automaticly record after adding them.<br/>
'Freeze All' controls if all bones are freezed when setting a frame. If unchecked, all bones that were unfreezed on recording will not be freezed.<br/>
To select a frame and see what it looks like, just click on it on the frame list. You can see the selected frame with * mark on it.<br/>
'Ghosts' controls if ghosts will be used. Ghosts are transparent, non-solid (Cannot grab with physgun or collide) copies
of selected entities. If they are enabled, they will show the previous frame of the entity.<br/>

Now, after you have set up your frames and their pics between values, bind keys to +smh_nextpic and +smh_prevpic.
These buttons will let you cycle through the pictures that will be generated. Use smh_cycletick to set the amount of seconds between picture change.<br/>
Finally, to generate pictures easily without having to spam the camera weapon, bind a key to "smh_makejpeg", go to the position or camera position
of your choice, equip the camera weapon and press the binded button. This will make a small sound and starts to generate pictures from the beginning.<br/>
Once all pictures are generated, it will make another sound to alert that its completed. You can abort the generation by pressing the binded button
again while generating.<br/>
<br/>
To select entities you wish to use, use the SMH selector tool. Chosen entities will be highlighted with halo effect.<br/>
To clear all SMH data (frames) from an entity, aim it with SMH selector and click reload.<br/>
<!--Your SMH project will be saved once you save the game, so when you load the game again, you can
start from where you left.-->
<b>Unfortunately, saving your SMH project is currently not working.</b>

</p>

<!--<p>SMH Save/Load tool can save and load SMH data to entities. Select an entity and write the filename and save or load.
To see if saving was successful, navigate to garrysmod/data/smh_saves. If your saved file is found there, then the
save was succesful. If the folder or file doesnt exist, it did not save. So press the save button again. However,
this tool is quite useless due to the new save system mentioned above.</p>-->

<h3>Contact</h3>
<p>For any questions or help, leave a comment in the workshop page. I will check on the comments as often as I can.</p>

</body>
</html>
	