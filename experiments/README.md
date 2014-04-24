A number of examples to help write the compiler. 
These are the expected C code for several simple cases.

HelloPonyworld.pony.c: 
	performs printf of simple string in the Main.main method

Countdown.pony.c:
	Adds a field to the main class. Uses this field to do a countdown,
	again printing to screen. 
	
TheOthers.pony.c:
	Adds another class to the mix. Creates an instance of this class,
	calls a method on it. The method prints a greeting and does a countdown.
	
PrimitiveSend.pony.c:
	Something that sends primitives around

StringSend.pony.c:
	Sends strings around, but not clear that it follows the correct protocol
	with the pony allocator. Need to ask Sylvain!
	
ActorSend.pony.c:
	Sends one actor to another. The first sends a message to the second,
	who prints a pleasant message to the screen.

Something that depends on the return value

Something that involves refactoring a class into a separate file.