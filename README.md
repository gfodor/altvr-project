AltVR Project
=============

This little project is a demonstration of collaborative whiteboarding in 3D (eventually VR?)

Go to [http://altvr.lulcards.com:8000](http://altvr.lulcards.com:8000) and you will be redirected to a new room.
The URL can be shared so others can join the room.

When in the room you can do the following:

* WASD to move around, with mouse look
* B to create a new whiteboard in front of where you are looking
* C to change the color of the pen
* E to erase the board you are looking at
* Click-drag to draw on the board

What sucks about it:
* Server stores everything in RAM. Server goes poof, so does all rooms.
* Players cannot see each other. Ran out of time, ideally should do dead reckoning, etc to see other players move around.
* Drawing does a very primitive quadratic spline averaging technique to make things look decent. Much better techniques exist.
* Is over TCP not UDP

What's cool about it:
* Server is relatively generic so new commands can be implemented by just changing the protobuf protocol + updating the client.
* Smart buffering/queuing + protocol design keeps packets small and fast
* Commands have proper timestamps with estimated latency applied from ping/pong. Important if new primitives added with layering and potential conflicts.
* Built in 48 hours
