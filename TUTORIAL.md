Stop Motion Helper tutorial
===========================

## Video tutorial

You can find a video tutorial covering the basics [here](http://www.youtube.com/embed/bei2e-uDfuE).

## How things basically work

Before we dive into details, let's go through how the tool basically works. When you open the SMH menu, you'll notice
the white vertical lines going in a row from left to right. This is the timeline. The white lines are representing frames.
The white rectangle with a black outline is the playhead, which can be used to cycle through our frames.

When you select an entity and drag the playhead around, nothing happens. This is because the timeline has no
recorded frames. Recorded frames are where a recorded state of the entity is stored. They are represented as
green rectangles in the timeline, and they can be moved, copied and removed. When the playhead is moved on
top of a recorded frame, the recorded state will be applied to the entity, and when the playhead is between two
recorded frames, the entity's state will be tweened between them.

## Opening the menu

The menu is opened using the `+smh_menu` console command. If you don't know how to access the console,
there are plenty of tutorials available showing you how to do so, so google up! Now, bind a key to the command, using
`bind <key> +smh_menu`. The menu will open when you hold down your bound key.

Before we can record frames, we need to tell SMH what entity we want to animate. An entity can be selected by right clicking
objects on the screen while the SMH menu is open. When an entity is glowing with a green outline, that entity is currently selected.

**NOTE:** The selected entity is the entity that you want to edit frames for. All entities that have any recorded frames are animated, so you don't need to select all of the entities that you want to animate seperately.

## Moving the playhead

You can simply left click and hold the playhead rectangle to drag it on the timeline. Left clicking in any empty space in the timeline will move the playhead to the nearest frame. 
You can also bind keys to `smh_next` and `smh_previous` commands, so you won't have to use the menu all the time.

## Recording frames

Move the playhead to the position in the timeline where you want to record your frame. Then simply press the record button on the right.
You can also bind a key to <i>smh_record</i> command, which has the same function as the record button, for easier access.

## Managing recorded frames

After a recorded frame has been created, it is shown as a green rectangle in the timeline. You can click and hold the rectangle with your left
mouse button to move the frame to another position. You can remove the frame by right clicking the rectangle. You can click and hold it with
your middle mouse button to make a copy of the frame to another position. Copying can also be done by holding down Ctrl and right clicking.

**NOTE:** Moving a frame on top of another frame will remove the frame that is not being moved. Be careful.

## Adding or reducing frames

By default, the timeline is 100 frames long. This can be changed from the "Frame count" input. Frame count determines the amount of frames
visible on the timeline as well as playback and rendering, which we will discuss below.

**NOTE:** If recorded frames go outside your frame count, they are not removed. They just won't be visible in the timeline.

## Animation playback

To preview your current scene, you can bind `+smh_playback` command to a key and hold it down. This will play the animation from frame 0 to your frame count with the framerate specified in the `Framerate` input. Note that previewing your animation with this
might not give an accurate display of the final animation. There may be slight lagging that will not be present when rendering the animation into images.

## Rendering

You can render your animation by simply using a camera and cycling through all of the frames and take pictures. However, this gets very
repetitive and takes time. SMH has the `smh_makejpeg` command, which automates this tedious task for you! Simply bind it to a key,
set up your camera and stuff, and fire away. After the rendering is complete, the resulted images are found in your local steam screenshots.

## Saving

You might want to continue animating later, or save your finished scene, just in case you want to come back and change things. You can
save your scene using the save menu found in the SMH menu. In the save menu, you give it a unique name, or overwrite one of the existing
saves, and then hit the save button. And you scene is saved!

## Loading

When you want to load your saved frames, you will need to do this individually for all entities. When you have selected an entity with SMH,
open the load menu. Select your previously saved scene. You will then see a list of saved entities, identified by their model name. Select
the right entity and then hit load, and the entity should now have all the frames that were saved.

## Backing up saves

All saves are located in `garrysmod/data/smh`, so you can back up your saved scenes from there, or move scenes to somewhere
else if they take up space in the save list.

## Quicksave

It's always good practice to frequently save your scene, as there are many unexpected things that can happen. Garry's mod might crash,
SMH might error out, your computer may crash or you have to lock down your house in case of a zombie apocalypse. Saving your scene
manually might not be the most ideal thing to do. That's why there's the `smh_quicksave` command. Bind a key into this command and
your scene will be saved with the name `quicksave` when you press it.

## Settings menu

There are two options you can change in the settings menu; `Freeze all` and `Don't animate phys bones`. The first option will keep all
physical bones of a ragdoll frozen when positioning to a frame, even if they were not frozen when the frame was recorded. The second option
will disable the animation of physical bones entirely. This can be used for puppeteering while playing a facial animation, for example. This might
not be usable in stop motion, so you'd have to use recording software, like Fraps.

## Ghosts

Ghosts are static objects that represent previous and next frames of an entity. They are useful for determining where you want to place your prop or
ragdoll before recording a frame. You can enable ghosts from the settings menu. `Ghost previous frame` will display a ghost for the previous
frame. `Ghost next frame` will display a ghost for the next frame. `Ghost all entities` will display ghosts for all entities that have any frames,
and not just the selected entity. `Ghost transparency` can be used to change the visibility of the ghosts, 0 being invisible and 1 being fully visible.

## Onion skinning

Onion skinning will display ghost-like objects representing all frames of an entity. This might be useful to visualize the animation flow of your prop or ragdoll.
To use onion skinning, bind a key to command `smh_onionskin`. You can then toggle onion skinning on and off. The option `Ghost all entities`
in the options menu applies to onion skinning as well, so enabling that will let you see all frames of all entities at the same time.

## That's all!

You can report any bugs on the workshop page. Or you can also give any other feedback, it helps too!