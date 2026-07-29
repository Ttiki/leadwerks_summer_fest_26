#pragma once
#include "Leadwerks.h"
#include "Game.h"

using namespace Leadwerks;

class Game;

class GameMenu : public Object
{
    static bool LinkButton_ProcessEvent(const Event& event, shared_ptr<Object> extra);
    std::shared_ptr<Widget> CreateLinkButton(const WString& name, int x, int y, int width, int height, shared_ptr<Widget> parent, const LabelStyle style = LABEL_DEFAULT);
    
    struct ScrollPanel : public Object
    {
        std::shared_ptr<Widget> base, frame, innerpanel, slider;
        void Reset();
        void UpdateHeight();
        static bool ProcessEvent(const Event& event, shared_ptr<Object> extra);
    };
    
    static std::shared_ptr<ScrollPanel> GameMenu::CreateScrollPanel(int x, int y, int width, int height, shared_ptr<Widget> parent);

    struct PostEffect
    {
        WString name;
        WString file;
        std::shared_ptr<Widget> widget;
    };
    std::vector<PostEffect> posteffects;

public:
    std::shared_ptr<Widget> logopanel;
    std::shared_ptr<Widget> newgamebutton;
    std::shared_ptr<Widget> optionsbutton;
    std::shared_ptr<Widget> quitbutton;
    std::shared_ptr<Widget> quitpanel;
    std::shared_ptr<Widget> okquitbutton;
    std::shared_ptr<Widget> cancelquitbutton;
    std::shared_ptr<Widget> optionspanel;
    std::shared_ptr<Widget> tabber;
    std::shared_ptr<Widget> upscalelist;
    std::shared_ptr<Widget> okbutton;
    std::shared_ptr<Widget> cancelbutton;
    std::shared_ptr<Widget> videopanel;
    std::shared_ptr<ScrollPanel> optionsscrollpanel;
    std::shared_ptr<Widget> resolutionlist;
    std::shared_ptr<Widget> fullscreenbutton;
    std::shared_ptr<Widget> dpilist;
    std::shared_ptr<Widget> msaalist;
    std::shared_ptr<Widget> anisotropylist;
    std::shared_ptr<Widget> shadowqualitylist;
    std::shared_ptr<Widget> tessellationlist;
    std::shared_ptr<Widget> vsyncbutton;
    std::shared_ptr<Widget> ssrbutton;
    std::shared_ptr<Widget> terrainshadowsbutton;
    std::shared_ptr<Interface> ui;
    float defaultdpiscale = 1;
    iVec2 optionspanelsize;

    bool GetHidden();
    void SetHidden(const bool hide);
    bool Initialize();
    void UpdateLayout();
    void AddPostEffect(const WString& name, const WString& file, const bool enable = false);
    void UpdateSettings();
    void ApplySettings();
    void ApplyCameraSettings();

    static bool EvaluateEvent(const Event& event, shared_ptr<Object> extra);
    static bool PassEvent(const Event& event, shared_ptr<Object> extra);

    friend std::shared_ptr<GameMenu> CreateGameMenu();
};

extern std::shared_ptr<GameMenu> CreateGameMenu();