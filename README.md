# SolidStructuring
A cobbled together tool for Creating Unity Map Geometry.  
Places Colliders, Merges Faces, Customizes Materials+UVs, Sets up Light Probes.  
Basically a blocky simpler alternative to Blender/Probuilder.  
  
Create a Structure via Right Click -> 3D Object -> StructureBox  
Create "QuadBlocks" via Right Click -> 3D Object -> QuadBlock  
Resize Either by holding down Left Shift, Then Dragging the Edge-Handles that'll pop up.

StructureBoxes will generate 1 big Mesh for QuadBlocks within its boundaries  
Drag & Drop Materials onto a QuadBlock to make a face
Shift + R to modify face vertices
Shift + R + R to modify UVs

Set StructureBox.BoxColliderHolder to Generate BoxColliders for Quadblocks
Collision Mode "Material Unique Boxes" will create BoxColliders Per-Material
Shift + C will toggle if a QuadBlock has collision

Set a Light Probe Group to auto-generate some "good enough" light probes.
Supports Lightmapping, Yipee!

(FYI, Only tested w/ Unity 2021.3.16f1)
