#pragma once
#include "Leadwerks.h"

using namespace Leadwerks;

class Game : public Object
{
public:
	static inline WString name = "Totem Island";
	static inline WString settingspath;
	static inline std::shared_ptr<Window> window;
	static inline std::shared_ptr<Framebuffer> framebuffer;
	static inline std::shared_ptr<World> world;
	static inline std::shared_ptr<Scene> scene;
	static inline table commandline;
	static inline table settings;

	static bool Initialize();
	static bool LoadSettings();
	static bool SaveSettings();
};