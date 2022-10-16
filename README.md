# Island Generator
A simple terrain generator created in Godot 3.5, based on the diamond square algorithm. You can view the whole island or explore it in first person view.

There are no controls yet to control map size or island size. Also no export options. Map corners and all edge values are set to 0 to create islands.

* Run the generator in Godot.
Press SPACE to create a new map.
Press Tab to toggle between overview camera and first person camera.
Use cursor keys to control player.
Use the slider to control roughness. A lower value means rougher terrain.

A good explanation of the diamond square algorithm can be found here: https://youtu.be/4GuAV1PnurU

How to generate terrain from a heightmap in Godot is explained here: https://youtu.be/EulloPFWFXM

To create terrain using any noise algorithm the noise values are applied to the vertices instead of the heightmap data.
