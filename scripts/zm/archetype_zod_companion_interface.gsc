#using scripts\shared\ai\systems\ai_interface;
#using scripts\zm\archetype_zod_companion;

#namespace zodcompanioninterface;

/*
	Name: registerzodcompanioninterfaceattributes
	Namespace: zodcompanioninterface
	Checksum: 0x24852F7B
	Offset: 0xE8
	Size: 0x3B
	Parameters: 0
	Flags: None
*/
function registerzodcompanioninterfaceattributes()
{
	ai::RegisterMatchedInterface("zod_companion", "sprint", 0, Array(1, 0));
}

