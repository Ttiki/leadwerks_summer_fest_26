#include "Leadwerks.h"
#include "ComponentSystem.h"
#include "Encryption.h"
#include "Game/Game.h"
#include "Game/GameMenu.h"
#include "CustomEvents.h"
//#include "Steamworks/Steamworks.h"

using namespace Leadwerks;

int main(int argc, const char* argv[])
{
#ifdef STEAM_API_H
    if (not Steamworks::Initialize())
    {
        RuntimeError("Steamworks failed to initialize.");
        return 1;
    }
#endif

    Game::commandline = ParseCommandLine(argc, argv);
    Game::Initialize();

    //Load packages
    std::vector<std::shared_ptr<Package> > packages;
    auto dir = LoadDir("");
    String password;
    GetPassword(password);
    for (auto file : dir)
    {
        if (ExtractExt(file).Lower() == "zip")
        {
            auto pak = LoadPackage(file);
            if (pak)
            {
                if (not password.empty())
                {
                    pak->SetPassword(password);
                    pak->Restrict();
                }
                packages.push_back(pak);
            }
        }
    }
    password.Clear();

    RegisterComponents();// Call this after packages are loaded

    auto mainmenu = CreateGameMenu();
    mainmenu->AddPostEffect("Bloom", "Effects/Bloom.fx");
    mainmenu->AddPostEffect("SSAO", "Effects/SSAO.fx");
    
    //Load the map
    if (Game::commandline["map"].is_string())
    {
        String mapname = Game::commandline["map"];
        Game::scene = LoadMap(Game::world, mapname);
        if (Game::scene)
        {
            mainmenu->ApplyCameraSettings();
            mainmenu->SetHidden(true);
            Game::window->SetCursor(CURSOR_NONE);
            mainmenu->newgamebutton->SetText("Resume Game");
        }
    }

    //Main loop
    while (true)
    {
        Game::world->Update();
        bool vsync = true;
        if (Game::settings["video"]["vsync"].is_boolean() and Game::settings["video"]["vsync"] == false) vsync = false;
        Game::world->Render(Game::framebuffer, vsync);

        while (PeekEvent())
        {
            // Get the next event
            auto event = WaitEvent();

            // Change the scene
            if (event.id == EVENT_CHANGELEVEL)
            {
                WString mapfile = "Maps/island.map";
                if (not event.text.empty()) mapfile = event.text;
                Game::scene = LoadScene(Game::world, mapfile);
                if (Game::scene)
                {
                    mainmenu->ApplyCameraSettings();
                    mainmenu->SetHidden(true);
                    mainmenu->newgamebutton->SetText("Resume Game");
                    Game::world->Resume();
                    Game::window->FlushKeys();
                    Game::window->FlushMouse();
                    Game::window->SetCursor(CURSOR_NONE);
                }
                else
                {
                    mainmenu->SetHidden(false);
                    Game::window->SetCursor(CURSOR_DEFAULT);
                }
            }
            // Exit the program if Alt + F4 is pressed
            else if (event.id == EVENT_QUIT)
            {
                goto Exit;
            }
            // Exit the program when window is closed
            else if (event.id == EVENT_WINDOWCLOSE && event.source == Game::window)
            {
                goto Exit;
            }
            // Pause the game
            else if (event.id == EVENT_WORLDPAUSE)
            {
                Game::window->SetCursor(CURSOR_DEFAULT);
            }
            // Resume the game
            else if (event.id == EVENT_WORLDRESUME)
            {
                Game::window->SetCursor(CURSOR_NONE);
                Game::window->FlushKeys();
                Game::window->FlushMouse();
            }
            // Detect first rendered frame
            else if (event.id == EVENT_STARTRENDERER)
            {
                if (event.data == 1)
                {
                    // Renderer initialized successfully
                    Print(event.text);
                    Game::window->SetHidden(false);
                    Game::window->Activate();
                }
                else
                {
                    // Renderer failed to initialize
                    Print("Error: Failed to initialize renderer");
                    Print(event.text);
                    goto Exit;
                }
            }
        }

#ifdef STEAM_API_H
        Steamworks::Update();
#endif
    }
Exit:
    Game::SaveSettings();

#ifdef STEAM_API_H
    Steamworks::Shutdown();
#endif
    return 0;
}