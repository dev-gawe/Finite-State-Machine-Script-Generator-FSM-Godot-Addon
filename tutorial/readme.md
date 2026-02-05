# How to use FSM Generator Tool Godot Addon

### 1. Create an Entity
Project - Tools - FSM Script Generator - Create Entity

![Imagen 1](1.png)

### 2. Write a name entity
Cotorra is an argentinian parrot

Write any entity name and press enter

![Imagen 2](2.png)

### 3. Look at the File System folder generated
The tool generates two states, an state indexer, a EntityFSM class (cotorra.fsm) and cotorra.tscn scene with a node.gd attached

![Imagen 3](3.png)

### 4. Runs the scene
Press space bar to change state

[Ver Video 4](4.mp4)

### 5. Create an Entity State
Project - Tools - FSM Script Generator - Create Entity State

![Imagen 5](5.png)

### 6. Write the selected same name entity, and a name state
This parrot likes to walk

Write Walk and press enter

![Imagen 6](6.png)

### 7. Look at the FS cotorra Walk file generated

![Imagen 7](7.png)

### 8. Open FSM file and edit the behavior
I add a Walking label text, the leave state behaviour and the walk enter behavior in LeaveIdleState

Use the NormaCase as you wish

![Imagen 8](8.png)

### 9. Open Walk Sate File
Add the context in method callbacks and select the context methods

![Imagen 9](9.png)

### 10. Run to test Walk state
Test the walk behavior

[Ver Video 10](10.mp4)
