#include "Leadwerks.h"
#include "Game.h"

using namespace Leadwerks;

bool Game::Initialize()
{
    //commandline = GetCommandLine();
    LoadSettings();

    auto displays = GetDisplays();
    if (displays.empty())
    {
        Print("Error: No displays detected");
        return false;
    }

    bool devmode = commandline["devmode"].is_boolean() and commandline["devmode"] == true;
    int w = 0;
    int h = 0;
    auto style = WINDOW_CENTER | WINDOW_TITLEBAR;

    if (devmode)
    {
        w = static_cast<int>(1280 * displays[0]->scale);
        h = static_cast<int>(720 * displays[0]->scale);
        w = Min(w, displays[0]->ClientArea().width);
        h = Min(h, displays[0]->ClientArea().height);
    }
    else
    {
        // Check if settings.video exists and has valid values
       bool fullscreen = true;
        if (settings["video"].is_object() and settings["video"]["fullscreen"].is_boolean()) fullscreen = settings["video"]["fullscreen"];
        if (settings["video"].is_object() and settings["video"]["windowsize"].is_array())
        {
            if (settings["video"]["windowsize"].size() >= 2)
            {
                w = settings["video"]["windowsize"][0];
                h = settings["video"]["windowsize"][1];
            }
        }
        else {
            // Default to 1080p if supported
            bool found1080p = false;
            for (const auto& mode : displays[0]->graphicsmodes)
            {
                if (mode.x == 1920 and mode.y == 1080)
                {
                    w = 1920;
                    h = 1080;
                    found1080p = true;
                    break;
                }
            }
            // If not found, use the native resolution
            if (w == 0 and not displays[0]->graphicsmodes.empty())
            {
                auto& lastMode = displays[0]->graphicsmodes.back();
                w = lastMode.x;
                h = lastMode.y;
            }
            if (!found1080p && w == 0)
            {
                // Fallback resolution if needed
                w = 1280;
                h = 720;
            }
        }
        if (fullscreen) style |= WINDOW_FULLSCREEN;
    }

    // Create window
    window = CreateWindow(name, 0, 0, w, h, displays[0], style);
    if (not window) return false;
    window->Activate();

    // Create framebuffer
    framebuffer = CreateFramebuffer(window);

    // Create world
    world = CreateWorld();

    return true;
}

bool Game::LoadSettings()
{
    settingspath = GetPath(PATH_PROGRAMDATA) + "/Leadwerks/Games/" + name + "/settings.json";

	//Reset all settings if commandline switch is found
	if (commandline["reset"].is_boolean() and commandline["reset"] == true)
	{
		settings = {};
		return true;
	}
	settings = LoadTable(settingspath);
	if (not settings.is_object())
	{
		settings = {};
		return false;
	}
	return true;
}

bool Game::SaveSettings()
{
	if (not settings.is_object()) return false;
	WString dir = ExtractDir(settingspath);
	if (FileType(dir) != 2)
	{
		if (not CreateDir(dir, true))
		{
			Print("Error: Failed to create folder \"" + dir + "\"");
			return false;
		}
	}
	return SaveTable(settings, settingspath);
}