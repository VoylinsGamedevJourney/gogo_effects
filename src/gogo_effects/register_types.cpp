#include "register_types.hpp"


void initialize_gogo_effects_library_init_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
		return;

	ClassDB::register_class<GoGoEffectsEncoder>();
}

void uninitialize_gogo_effects_library_init_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE)
		return;
}

// Initialization
extern "C" {
GDExtensionBool GDE_EXPORT gogo_effects_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address,
													 GDExtensionClassLibraryPtr p_library,
													 GDExtensionInitialization* r_initialization) {
	GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_gogo_effects_library_init_module);
	init_obj.register_terminator(uninitialize_gogo_effects_library_init_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}
