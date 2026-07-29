#include "Leadwerks.h"
#include "GameMenu.h"
#include "../CustomEvents.h"

using namespace Leadwerks;

bool GameMenu::LinkButton_ProcessEvent(const Event& event, shared_ptr<Object> extra)
{
    auto widget = event.source->As<Widget>();
    if (event.id == EVENT_MOUSEENTER)
    {
        widget->SetColor(1.0f, 1.0f, 1.0f, 1.0f, WIDGETCOLOR_FOREGROUND, 100);
        return false;
    }
    else if (event.id == EVENT_MOUSELEAVE)
    {
        widget->SetColor(1.0f, 1.0f, 1.0f, 0.8f, WIDGETCOLOR_FOREGROUND, 500);
        return false;
    }
    else if (event.id == EVENT_MOUSEDOWN)
    {
        EmitEvent(EVENT_WIDGETACTION, event.source);
        return false;
    }
    return true;
}

shared_ptr<Widget> GameMenu::CreateLinkButton(const WString& name, int x, int y, int width, int height, shared_ptr<Widget> parent, const LabelStyle style)
{
    auto widget = CreateLabel(name, x, y, width, height, parent, style);
    widget->SetColor(1.0f, 1.0f, 1.0f, 0.8f, WIDGETCOLOR_FOREGROUND);

    // Assuming ListenEvent takes event ID, widget reference, and handler function pointer
    ListenEvent(EVENT_MOUSEENTER, widget, LinkButton_ProcessEvent);
    ListenEvent(EVENT_MOUSELEAVE, widget, LinkButton_ProcessEvent);
    ListenEvent(EVENT_MOUSEDOWN, widget, LinkButton_ProcessEvent);

    return widget;
}

void GameMenu::ScrollPanel::Reset()
{
    slider->SetValue(0);
    EmitEvent(EVENT_WIDGETACTION, slider, 0);
}

void GameMenu::ScrollPanel::UpdateHeight()
{
    int indent = 0;
    int maxy = 0;

    // Loop through all child widgets
    for (size_t n = 0; n < innerpanel->kids.size(); ++n) 
    {
        auto& kid = innerpanel->kids[n];
        if (n == 0) {
            indent = kid->position.y;
            maxy = kid->position.y + kid->size.y;
        }
        else {
            indent = Min(indent, kid->position.y);
            maxy = Max(maxy, kid->position.y + kid->size.y);
        }
    }

    indent = 0; // Reset indent as per original code
    float frameHeight = frame->ClientSize().y;
    float scale = frame->GetInterface()->GetScale();
    float h = maxy + indent + 4 * scale;
    float inc = 10 * scale;
    float w = base->ClientSize().x;

    if (h > frameHeight) {
        slider->SetRange(frameHeight, h, inc);
        slider->SetHidden(false);
        float sliderX = slider->position.x;
        w = sliderX + 1;
        frame->SetShape(0, 0, static_cast<int>(w), slider->size.y);
    }
    else {
        frame->SetShape(0, 0, base->ClientSize().x, base->ClientSize().y);
        slider->SetHidden(true);
    }

    // Update innerpanel shape
    innerpanel->SetShape(innerpanel->position.x, innerpanel->position.y, innerpanel->size.x, h);
}

bool GameMenu::ScrollPanel::ProcessEvent(const Event& event, shared_ptr<Object> extra)
{
    auto scrollpanel = extra->As<ScrollPanel>();
    if (event.id == EVENT_WIDGETACTION)
    {
        if (event.source == scrollpanel->slider)
        {
            scrollpanel->innerpanel->SetShape(scrollpanel->innerpanel->position.x, -event.data, scrollpanel->innerpanel->size.x, scrollpanel->innerpanel->size.y);
        }
        return false;
    }
    return true;
}

std::shared_ptr<GameMenu::ScrollPanel> GameMenu::CreateScrollPanel(int x, int y, int width, int height, shared_ptr<Widget> parent)
{
    const int sw = 20;

    // Create the base panel
    auto base = CreatePanel(x, y, width, height, parent);
    base->SetColor(0, 0, 0, 0);

    // Create the inner widget panel
    auto widget = CreatePanel(0, 0, width - sw + 1, height, base, PANEL_BORDER);
    // Retrieve colors and set a darker shade
    auto colorSunken = widget->GetColor(WIDGETCOLOR_SUNKEN);
    auto colorBackground = widget->GetColor(WIDGETCOLOR_BACKGROUND);
    float r = (colorSunken.r + colorBackground.r) * 0.5f;
    float g = (colorSunken.g + colorBackground.g) * 0.5f;
    float b = (colorSunken.b + colorBackground.b) * 0.5f;
    widget->SetColor(r, g, b);

    widget->SetLayout(1, 1, 1, 1);

    // Create the scrollbar slider
    auto slider = CreateSlider(width - sw, 0, sw, height, base, SLIDER_SCROLLBAR | SLIDER_VERTICAL);
    slider->SetLayout(0, 1, 1, 1);

    // Create a child panel inside widget
    auto size = widget->ClientSize();
    auto child = CreatePanel(0, 0, size.x, size.y, widget);
    child->SetLayout(1, 1, 1, 0);
    child->SetColor(0, 0, 0, 0);

    // Assemble the scroll panel structure
    auto scrollpanel = std::make_shared<ScrollPanel>();
    scrollpanel->base = base;
    scrollpanel->slider = slider;
    scrollpanel->innerpanel = child;
    scrollpanel->frame = widget;

    // Set up event listening
    ListenEvent(EVENT_WIDGETACTION, slider, GameMenu::ScrollPanel::ProcessEvent, scrollpanel);

    return scrollpanel;
}

void GameMenu::UpdateLayout()
{
    float scale = ui->scale;

    // Position options dialog
    int w = Round(optionspanelsize.x * scale);
    int h = Round(optionspanelsize.y * scale);

    // Clamp w and h to background size
    w = Min(w, ui->background->size.x);
    h = Min(h, ui->background->size.y);

    // Center within parent
    float parentWidth = optionspanel->GetParent()->size.x;
    float parentHeight = optionspanel->GetParent()->size.y;
    int x = (parentWidth - w) / 2;
    int y = (parentHeight - h) / 2;
    optionspanel->SetShape(x, y, w, h);

    // Position quit dialog
    w = quitpanel->size.x;
    h = quitpanel->size.y;
    x = (parentWidth - w) / 2.0f;
    y = (parentHeight - h) / 2.0f;
    quitpanel->SetShape(x, y, w, h);

    // Position link buttons
    auto sz = newgamebutton->size;
    float spacing = 40.0f * scale;

    float bgWidth = ui->background->size.x;
    float bgHeight = ui->background->size.y;

    x = bgWidth * 0.1f;
    y = (bgHeight * 0.5f) - (sz.y * 0.5f) - spacing;

    if (logopanel != nullptr) {
        // Position logo panel above the buttons
        logopanel->SetShape(x - 10.0f * scale, y - logopanel->size.y, logopanel->size.x, logopanel->size.y);
    }

    // Position buttons
    newgamebutton->SetShape(x, y, sz.x, sz.y);
    y += spacing;

    optionsbutton->SetShape(x, y, sz.x, sz.y);
    y += spacing;

    quitbutton->SetShape(x, y, sz.x, sz.y);
}

bool GameMenu::GetHidden()
{
    return ui->background->GetHidden();
}

void GameMenu::SetHidden(const bool hide)
{
    ui->background->SetHidden(hide);
}

bool GameMenu::PassEvent(const Event& event, shared_ptr<Object> extra)
{
    auto menu = extra->As<GameMenu>();
    if (event.id == EVENT_KEYDOWN && event.data == KEY_ESCAPE)
    {
        if (menu->GetHidden())
        {
            menu->SetHidden(false);
            Game::world->Pause();
        }
        else
        {
            menu->SetHidden(true);
            Game::world->Resume();
        }
    }
    menu->ui->ProcessEvent(event);
    return true;
}

bool GameMenu::EvaluateEvent(const Event& event, shared_ptr<Object> extra)
{
    auto menu = extra->As<GameMenu>();
    if (event.id == EVENT_WIDGETACTION)
    {
        auto widget = event.source->As<Widget>();
        // Check for specific buttons
        if (widget->As<Leadwerks::Button>() and (widget->style & BUTTON_CHECKBOX) != 0)
        {
            if (event.data == 1)
            {
                widget->SetText("Enabled");
            }
            else {
                widget->SetText("Disabled");
            }
            return false;
        }
        else if (widget == menu->okbutton) {
            menu->optionspanel->SetHidden(true);
            menu->ApplySettings();
            return false;
        }
        else if (widget == menu->cancelbutton) {
            menu->optionspanel->SetHidden(true);
            return false;
        }
        else if (widget == menu->optionsbutton) {
            menu->optionsscrollpanel->Reset();
            menu->UpdateSettings();
            menu->optionspanel->SetHidden(false);
            menu->quitpanel->SetHidden(true);
            return false;
        }
        else if (widget == menu->newgamebutton) {
            menu->ui->background->SetHidden(true);
            menu->optionspanel->SetHidden(true);
            menu->quitpanel->SetHidden(true);
            menu->newgamebutton->SetColor(1.0f, 1.0f, 1.0f, 0.8f);
            if (menu->newgamebutton->GetText() == "New Game") {
                EmitEvent(EVENT_CHANGELEVEL);
            }
            else {
                Game::world->Resume();
            }
            return false;
        }
        else if (widget == menu->quitbutton) {
            menu->optionspanel->SetHidden(true);
            menu->quitpanel->SetHidden(false);
            return false;
        }
        else if (widget == menu->okquitbutton) {
            EmitEvent(EVENT_QUIT);
            return false;
        }
        else if (widget == menu->cancelquitbutton) {
            menu->quitpanel->SetHidden(true);
            return false;
        }
        else if (widget == menu->quitbutton) {
            menu->quitpanel->SetHidden(false);
            return false;
        }

        // Check post effects
        for (size_t n = 0; n < menu->posteffects.size(); ++n) {
            if (event.source == menu->posteffects[n].widget) {
                if (event.data == 1) {
                    menu->posteffects[n].widget->SetText("Enabled");
                }
                else {
                    menu->posteffects[n].widget->SetText("Disabled");
                }
            }
        }
    }
    return true;
}

void GameMenu::AddPostEffect(const WString& name, const WString& file, const bool enable)
{
    PostEffect t;
    t.name = name;
    t.file = file;

    float scale = ui->GetScale();
    int x = 8 * scale;
    int y = 0;
    int lh = 16;
    int bw = 72;
    int bh = 32;
    int cw = 160;

    if (enable)
    {
        if (not Game::settings["video"].is_object()) Game::settings["video"] = {};
        if (not Game::settings["video"]["posteffects"].is_object()) Game::settings["video"]["posteffects"] = {};
        std::string s = name.ToUtf8String();
        if (not Game::settings["video"]["posteffects"][s].is_boolean()) Game::settings["video"]["posteffects"][s] = true;
    }

    // Find the maximum y value among children in videopanel
    for (int n = 0; n < videopanel->kids.size(); ++n)
    {
        y = Max(y, videopanel->kids[n]->position.y + videopanel->kids[n]->size.y);
    }
    y += 16 * scale;

    // Create label
    auto sz = videopanel->ClientSize();
    CreateLabel(t.name, x, y, sz.x - 2 * x, lh * scale, videopanel);

    // Create checkbox button
    t.widget = CreateButton("Disabled", x + cw * scale, y, bw * scale, lh * scale, videopanel, BUTTON_CHECKBOX);

    // Listen for widget actions
    ListenEvent(EVENT_WIDGETACTION, t.widget, EvaluateEvent, Self());

    // Store the post effect
    posteffects.push_back(t);

    // Update the options scroll panel height
    optionsscrollpanel->UpdateHeight();
}

std::shared_ptr<GameMenu> CreateGameMenu()
{
    auto menu = std::make_shared<GameMenu>();

    const int sz = 14;
    const int h = 24;
    const int lh = 16;
    int x = 8;
    int y = 8;
    int bw = 72;
    int bh = 32;
    int cw = 160;
    int spacing = 40;

    // Load font
    auto font = LoadFont("Fonts/arial.ttf");
    if (!font) return nullptr;

    int lw = 150;
    float linkbuttonscale = 1.75f;

    menu->posteffects.clear();

    // Create interface
    menu->ui = CreateInterface(Game::world, font, Game::framebuffer->size);
    menu->ui->background->SetColor(0, 0, 0, 0.5f);
    menu->defaultdpiscale = Game::window->display->scale;

    // Main logo
    std::string logopath = "menulogo.dds";
    if (FileType(logopath) == 1) {
        auto logo = LoadPixmap(logopath);
        if (logo) {
            menu->logopanel = CreatePanel(0, 0, 220, 100, menu->ui->background);
            menu->logopanel->SetColor(0, 0, 0, 0);
            menu->logopanel->SetPixmap(logo, PIXMAP_CONTAIN);
        }
    }

    // Create main buttons
    menu->newgamebutton = menu->CreateLinkButton("New Game", 0, 0, lw, 40, menu->ui->background, LABEL_MIDDLE);
    menu->newgamebutton->SetFontScale(linkbuttonscale);
    menu->optionsbutton = menu->CreateLinkButton("Options", 0, 50, lw, 40, menu->ui->background, LABEL_MIDDLE);
    menu->optionsbutton->SetFontScale(linkbuttonscale);
    menu->quitbutton = menu->CreateLinkButton("Quit", 0, 100, lw, 40, menu->ui->background, LABEL_MIDDLE);
    menu->quitbutton->SetFontScale(linkbuttonscale);

    // Quit Dialog
    menu->quitpanel = CreatePanel(0, 0, 300, 120, menu->ui->background, PANEL_BORDER);
    auto label = CreateLabel("Are you sure you want to quit?", 0, 20, menu->quitpanel->ClientSize().x, 30, menu->quitpanel, LABEL_CENTER);
    label->SetLayout(1, 1, 1, 0);
    menu->okquitbutton = CreateButton("Yes", menu->quitpanel->ClientSize().x * 0.5f - bw - 12, 70, bw, bh, menu->quitpanel, BUTTON_OK);
    menu->cancelquitbutton = CreateButton("No", menu->quitpanel->ClientSize().x * 0.5f + 12, 70, bw, bh, menu->quitpanel, BUTTON_CANCEL);

    // Options Dialog
    menu->optionspanel = CreatePanel(0, 0, 430, 522, menu->ui->background, PANEL_BORDER);
    auto szOpts = menu->optionspanel->ClientSize();
    menu->tabber = CreateTabber(8, 8, szOpts.x - 16, szOpts.y - 16 - 38, menu->optionspanel);
    menu->tabber->SetLayout(1, 1, 1, 1);
    menu->tabber->AddItem("Options", true);

    menu->okbutton = CreateButton("Apply", szOpts.x - bw * 2 - 4 - 8, szOpts.y - bh - 4, bw, bh, menu->optionspanel, BUTTON_OK);
    menu->okbutton->SetLayout(0, 1, 0, 1);
    menu->cancelbutton = CreateButton("Close", szOpts.x - bw - 8, szOpts.y - bh - 4, bw, bh, menu->optionspanel);
    menu->cancelbutton->SetLayout(0, 1, 0, 1);

    auto szTabber = menu->tabber->ClientSize();

    y = x;
    auto scrollpanel = menu->CreateScrollPanel(8, 8, szTabber.x - 16, szTabber.y - 16, menu->tabber);
    scrollpanel->base->SetLayout(1, 1, 1, 1);
    scrollpanel->frame->SetLayout(1, 1, 1, 1);
    menu->videopanel = scrollpanel->innerpanel;
    menu->optionsscrollpanel = scrollpanel;

    auto szVideo = menu->videopanel->ClientSize();

    // Screen Resolution
    CreateLabel("Screen Resolution", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->resolutionlist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->resolutionlist->SetLayout(1, 1, 1, 0);
    for (auto& mode : Game::window->display->graphicsmodes) {
        menu->resolutionlist->AddItem(std::to_string(mode.x) + " x " + std::to_string(mode.y));
    }
    menu->resolutionlist->SelectItem(1);
    y += spacing;

    // Fullscreen
    CreateLabel("Fullscreen", x, y, szVideo.x - 2 * x, h, menu->videopanel);
    menu->fullscreenbutton = CreateButton("Disabled", x + cw, y, szVideo.x - 2 * x - cw, h, menu->videopanel, BUTTON_CHECKBOX);
    y += 32;

    // Display Scale
    CreateLabel("Display Scale", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->dpilist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->dpilist->SetLayout(1, 1, 1, 0);
    menu->dpilist->AddItem("Auto", true);
    menu->dpilist->AddItem("100%");
    menu->dpilist->AddItem("125%");
    menu->dpilist->AddItem("150%");
    menu->dpilist->AddItem("175%");
    menu->dpilist->AddItem("200%");
    y += spacing;

    // MSAA
    CreateLabel("MSAA", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->msaalist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->msaalist->SetLayout(1, 1, 1, 0);
    menu->msaalist->AddItem("Disabled", true);
    menu->msaalist->AddItem("2x");
    menu->msaalist->AddItem("4x");
    menu->msaalist->AddItem("8x");
    //menu->msaalist->AddItem("16x");
    //menu->msaalist->AddItem("32x");
    y += spacing;

    // Upscaling
    CreateLabel("Upscaling", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->upscalelist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->upscalelist->SetLayout(1, 1, 1, 0);
    menu->upscalelist->AddItem("Disabled", true);
    menu->upscalelist->AddItem("130%");
    menu->upscalelist->AddItem("150%");
    menu->upscalelist->AddItem("170%");
    menu->upscalelist->AddItem("200%");
    y += spacing;

    // Texture Anisotropy
    CreateLabel("Texture Anisotropy", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->anisotropylist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->anisotropylist->SetLayout(1, 1, 1, 0);
    menu->anisotropylist->AddItem("1x", true);
    menu->anisotropylist->AddItem("2x");
    menu->anisotropylist->AddItem("4x");
    menu->anisotropylist->AddItem("8x");
    //menu->anisotropylist->AddItem("16x");
    //menu->anisotropylist->AddItem("32x");
    y += spacing;

    // Shadow Quality
    CreateLabel("Shadow Quality", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->shadowqualitylist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->shadowqualitylist->SetLayout(1, 1, 1, 0);
    menu->shadowqualitylist->AddItem("Low");
    menu->shadowqualitylist->AddItem("Medium", true);
    menu->shadowqualitylist->AddItem("High");
    y += spacing;

    // Tessellation
    CreateLabel("Tessellation", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->tessellationlist = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->tessellationlist->SetLayout(1, 1, 1, 0);
    menu->tessellationlist->AddItem("Disabled", true);
    menu->tessellationlist->AddItem("Low");
    menu->tessellationlist->AddItem("Medium");
    menu->tessellationlist->AddItem("High");
    y += spacing;

    // Screen-space Reflection
    CreateLabel("Screen-space Reflection", x, y, szVideo.x - 2 * x, h, menu->videopanel, LABEL_MIDDLE);
    menu->ssrbutton = CreateComboBox(x + cw, y, szVideo.x - 2 * x - cw, 32, menu->videopanel);
    menu->ssrbutton->AddItem("Disabled", true);
    menu->ssrbutton->AddItem("Low");
    menu->ssrbutton->AddItem("Medium");
    menu->ssrbutton->AddItem("High");
    y += spacing;

    // Vertical Sync
    CreateLabel("Vertical Sync", x, y, szVideo.x - 2 * x, h, menu->videopanel);
    menu->vsyncbutton = CreateButton("Disabled", x + cw, y, szVideo.x - 2 * x - cw, h, menu->videopanel, BUTTON_CHECKBOX);
    y += 32;

    // Terrain Shadows
    CreateLabel("Terrain Shadows", x, y, szVideo.x - 2 * x, lh, menu->videopanel);
    menu->terrainshadowsbutton = CreateButton("Disabled", x + cw, y, bw, lh, menu->videopanel, BUTTON_CHECKBOX);
    y += 32;

    // Update height
    scrollpanel->UpdateHeight();
    menu->optionspanel->SetHidden(true);
    menu->quitpanel->SetHidden(true);
    menu->optionspanelsize = menu->optionspanel->size;

    // Update the interface when any of these events occur
    ListenEvent(EVENT_MOUSEMOVE, nullptr, GameMenu::PassEvent, menu);
    ListenEvent(EVENT_MOUSEDOWN, nullptr, GameMenu::PassEvent, menu);
    ListenEvent(EVENT_MOUSEUP, nullptr, GameMenu::PassEvent, menu);
    ListenEvent(EVENT_MOUSEWHEEL, nullptr, GameMenu::PassEvent, menu);
    ListenEvent(EVENT_KEYDOWN, nullptr, GameMenu::PassEvent, menu);
    ListenEvent(EVENT_KEYUP, nullptr, GameMenu::PassEvent, menu);
    
    //Update the UI layout each frame, if needed
    ListenEvent(EVENT_WIDGETACTION, menu->fullscreenbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->ssrbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->vsyncbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->okbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->cancelbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->newgamebutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->optionsbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->quitbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->okquitbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->cancelquitbutton, GameMenu::EvaluateEvent, menu);
    ListenEvent(EVENT_WIDGETACTION, menu->terrainshadowsbutton, GameMenu::EvaluateEvent, menu);
    
    // Set scale based on game settings
    if (not Game::commandline.is_object() or not Game::commandline["devmode"].is_boolean() or Game::commandline["devmode"] == false)
    {
        if (Game::settings.is_object() and Game::settings["video"].is_object() and Game::settings["video"]["dpiscale"].is_number())
        {
            menu->ui->SetScale(Game::settings["video"]["dpiscale"]);
        }
        else
        {
            menu->ui->SetScale(Game::window->display->scale);
        }
    }
    else
    {
        menu->ui->SetScale(Game::window->display->scale);
    }
    menu->UpdateLayout();

    return menu;
}

void GameMenu::UpdateSettings()
{
    // Get window resolution
    auto w = Game::window->size.x;
    auto h = Game::window->size.y;
    std::string s = std::to_string(w) + " x " + std::to_string(h);

    // Reset resolution list selection
    resolutionlist->SelectItem(0);
    for (auto n = 0; n <= resolutionlist->items.size(); ++n) {
        if (resolutionlist->items[n].text == s) {
            resolutionlist->SelectItem(n);
            break;
        }
    }

    // Fullscreen button state
    if ((Game::window->style & WINDOW_FULLSCREEN) != 0) {
        fullscreenbutton->SetState(true);
        fullscreenbutton->SetText("Enabled");
    }
    else {
        fullscreenbutton->SetState(false);
        fullscreenbutton->SetText("Disabled");
    }

    // VSync button default state
    vsyncbutton->SetState(true);

    if (Game::settings.is_object() && Game::settings["video"].is_object())
    {
        auto& video = Game::settings["video"];

        if (video["upscaling"].is_number()) upscalelist->SelectItem(int(video["upscaling"]));
        if (video["vsync"].is_boolean()) vsyncbutton->SetState(video["vsync"]);
        if (video["ssr"].is_number()) ssrbutton->SelectItem(video["ssr"]);
        if (video["terrainshadows"].is_boolean()) terrainshadowsbutton->SetState(video["terrainshadows"]);
        
        // Handle dpiscale
        float dpiscale = NAN;
        if (video["dpiscale"].is_number()) dpiscale = video["dpiscale"];
        if (Game::commandline["devmode"].is_boolean() and Game::commandline["devmode"] == true) dpiscale = NAN;
        if (not isnan(dpiscale))
        {
            auto scale = dpiscale;
            if (scale == 1) {
                dpilist->SelectItem(1);
            }
            else if (scale == 1.25f) {
                dpilist->SelectItem(2);
            }
            else if (scale == 1.5f) {
                dpilist->SelectItem(3);
            }
            else if (scale == 1.75f) {
                dpilist->SelectItem(4);
            }
            else if (scale == 2) {
                dpilist->SelectItem(5);
            }
        }

        // Handle MSAA
        if (video["msaa"].is_number())
        {
            int msaa_value = video["msaa"];
            int index = 0;
            switch (msaa_value)
            {
                case 2: index = 1; break;
                case 4: index = 2; break;
                case 8: index = 3; break;
                case 16: index = 4; break;
                case 32: index = 5; break;
            }
            index = Min(index, int(anisotropylist->items.size() - 1));
            msaalist->SelectItem(index);
        }

        // Handle texture anisotropy
        if (video["textureanisotropy"].is_number())
        {
            int anisotropy = video["textureanisotropy"];
            int index = 0;
            switch (anisotropy) {
                case 1: index = 0; break;
                case 2: index = 1; break;
                case 4: index = 2; break;
                case 8: index = 3; break;
                case 16: index = 4; break;
                case 32: index = 5; break;
            }
            index = Min(index, int(anisotropylist->items.size() - 1));
            anisotropylist->SelectItem(index);
        }

        // Handle shadow quality
        if (video["shadowquality"].is_number())
        {
            float sq = video["shadowquality"];
            if (sq == 0.5f) {
                shadowqualitylist->SelectItem(0);
            }
            else if (sq == 1.0f) {
                shadowqualitylist->SelectItem(1);
            }
            else if (sq == 2.0f) {
                shadowqualitylist->SelectItem(2);
            }
        }

        // Handle tessellation
        if (video["tessellation"].is_number())
        {
            int i = video["tessellation"];
            tessellationlist->SelectItem(i);
        }
    }

    // Post effects
    if (Game::settings["video"].is_object() and Game::settings["video"]["posteffects"].is_object())
    {
        for (auto n = 0; n < posteffects.size(); ++n)
        {
            std::string s = posteffects[n].name.ToUtf8String();
            this->posteffects[n].widget->SetState(false);
            this->posteffects[n].widget->SetText("Disabled");
            for (auto pair : Game::settings["video"]["posteffects"])
            {
                if (pair.first.get_type() == tablekey::type::name and pair.second.is_boolean() and pair.second == true)
                {
                    if (s == std::string(pair.first))
                    {
                        this->posteffects[n].widget->SetState(true);
                        this->posteffects[n].widget->SetText("Enabled");
                    }
                }
            }
        }
    }

    // Update button texts based on states
    if (vsyncbutton->GetState() == WIDGETSTATE_SELECTED)
        vsyncbutton->SetText("Enabled");
    else
        vsyncbutton->SetText("Disabled");

    if (terrainshadowsbutton->GetState() == WIDGETSTATE_SELECTED)
        terrainshadowsbutton->SetText("Enabled");
    else
        terrainshadowsbutton->SetText("Disabled");

    if (fullscreenbutton->GetState() == WIDGETSTATE_SELECTED)
        fullscreenbutton->SetText("Enabled");
    else
        fullscreenbutton->SetText("Disabled");
}

void GameMenu::ApplySettings()
{
    if (not Game::settings["video"]) Game::settings["video"] = {};

    // VSync
    Game::settings["video"]["vsync"] = (vsyncbutton->GetState() == WIDGETSTATE_SELECTED);

    // Texture anisotropy
    auto i = anisotropylist->GetSelectedItem();
    if (i > -1) {
        Game::settings["video"]["textureanisotropy"] = std::pow(2.0, i);
        SetAnisotropicFilter(Game::settings["video"]["textureanisotropy"]);
    }

    // Upscaling
    Game::settings["video"]["upscaling"] = upscalelist->GetSelectedItem();

    // MSAA
    i = msaalist->GetSelectedItem();
    if (i > -1)
    {
        int msaa = std::pow(2.0, i);
        Game::settings["video"]["msaa"] = msaa;
    }

    // SSR
    Game::settings["video"]["ssr"] = ssrbutton->GetSelectedItem();

    // Terrain shadows
    Game::settings["video"]["terrainshadows"] = (terrainshadowsbutton->GetState() == WIDGETSTATE_SELECTED);
    auto& entities = Game::world->GetEntities();
    for (auto& entity : entities) {
        auto terrain = entity->As<Terrain>();
        if (terrain) {
            terrain->SetShadows(Game::settings["video"]["terrainshadows"]);
        }
    }

    // Shadow quality
    i = shadowqualitylist->GetSelectedItem();
    if (i == 0) {
        Game::settings["video"]["shadowquality"] = 0.5;
    }
    else if (i == 1) {
        Game::settings["video"]["shadowquality"] = 1.0;
    }
    else if (i == 2) {
        Game::settings["video"]["shadowquality"] = 2.0;
    }
    if (Game::settings["video"]["shadowquality"].is_number()) {
        Game::world->SetShadowQuality(Game::settings["video"]["shadowquality"]);
    }

    // Tessellation
    i = tessellationlist->GetSelectedItem();
    Game::settings["video"]["tessellation"] = i;

    // Change window resolution
    auto resolutionIndex = resolutionlist->GetSelectedItem();
    if (resolutionIndex > 0) {
        bool newFullscreenMode = (fullscreenbutton->GetState() == WIDGETSTATE_SELECTED);
        bool oldFullscreenMode = (Game::window->style & WINDOW_FULLSCREEN) != 0;
        auto& item = resolutionlist->items[resolutionIndex];
        auto s = item.text;
        auto sarr = s.Split(" x ");
        auto w = std::stoi(sarr[0]);
        auto h = std::stoi(sarr[1]);

        if (w != Game::window->size.x || h != Game::window->size.y || newFullscreenMode != oldFullscreenMode) {
            auto style = WINDOW_CENTER | WINDOW_TITLEBAR;
            if (fullscreenbutton->GetState() == WIDGETSTATE_SELECTED) style |= WINDOW_FULLSCREEN;

            auto newWindow = CreateWindow(Game::window->text, Game::window->position.x, Game::window->position.y, w, h, Game::window->display, style);

            if (newWindow) {
                Game::window->SetHidden(true);
                Game::window = newWindow;
                Game::framebuffer = CreateFramebuffer(Game::window);
                ui->SetSize(Game::framebuffer->size);
                Game::settings["video"]["windowsize"] = {};
                Game::settings["video"]["windowsize"][0] = Game::window->size.x;
                Game::settings["video"]["windowsize"][1] = Game::window->size.y;
                Game::settings["video"]["fullscreen"] = (Game::window->style & WINDOW_FULLSCREEN) != 0;
            }
        }
    }

    // DPI Scaling
    i = dpilist->GetSelectedItem();
    Game::settings["video"]["dpiscale"] = nullptr;
    if (i == 0) {
        Game::settings["video"]["dpiscale"] = nullptr;
    }
    else if (i == 1) {
        Game::settings["video"]["dpiscale"] = 1.0;
    }
    else if (i == 2) {
        Game::settings["video"]["dpiscale"] = 1.25;
    }
    else if (i == 3) {
        Game::settings["video"]["dpiscale"] = 1.5;
    }
    else if (i == 4) {
        Game::settings["video"]["dpiscale"] = 1.75;
    }
    else if (i == 5) {
        Game::settings["video"]["dpiscale"] = 2.0;
    }

    if (Game::settings["video"]["dpiscale"].is_number())
    {
        ui->SetScale(Game::settings["video"]["dpiscale"]);
    }
    else
    {
        ui->SetScale(defaultdpiscale);
    }

    // Update layout
    UpdateLayout();
    optionsscrollpanel->UpdateHeight();

    // Post effects
    Game::settings["video"]["posteffects"] = {};
    for (auto& effect : posteffects)
    {
        std::string s = effect.name.ToUtf8String();
        Game::settings["video"]["posteffects"][s] = (effect.widget->GetState() == WIDGETSTATE_SELECTED);
    }

    // Camera settings
    ApplyCameraSettings();
}

void GameMenu::ApplyCameraSettings()
{
    auto entities = Game::world->GetEntities();
    for (auto entity : entities)
    {
        auto camera = entity->As<Camera>();
        if (camera)
        {
            if (camera->GetRenderTarget() == nullptr and not camera->GetHidden() && camera->GetProjectionMode() == PROJECTION_PERSPECTIVE)
            {
                if (Game::settings["video"].is_object())
                {
                    auto& videoSettings = Game::settings["video"];

                    // MSAA
                    if (videoSettings["msaa"].is_number()) {
                        int msaa = videoSettings["msaa"];
                        camera->SetMsaa(msaa);
                    }

                    // Upscaling
                    if (videoSettings["upscaling"].is_number()) {
                        int upscaling = videoSettings["upscaling"];
                        switch (upscaling)
                        {
                        case 0:
                            camera->SetUpscaling(1.0f);
                            break;
                        case 1:
                            camera->SetUpscaling(1.3f);
                            break;
                        case 2:
                            camera->SetUpscaling(1.5f);
                            break;
                        case 3:
                            camera->SetUpscaling(1.7f);
                            break;
                        case 4:
                            camera->SetUpscaling(2.0f);
                            break;
                        }
                    }

                    // Tessellation
                    if (videoSettings["tessellation"].is_number()) {
                        int tessValue = videoSettings["tessellation"];
                        int tess = 0;
                        if (tessValue == 1) {
                            tess = 8;
                        }
                        else if (tessValue == 2) {
                            tess = 4;
                        }
                        else if (tessValue == 3) {
                            tess = 2;
                        }
                        camera->SetTessellation(tess);
                    }

                    // Refraction
                    if (videoSettings["refraction"].is_boolean())
                    {
                        bool refraction = videoSettings["refraction"];
                        camera->SetRefraction(refraction);
                    }

                    // SSR
                    if (videoSettings["ssr"].is_number())
                    {
                        int ssr = videoSettings["ssr"];
                        switch (ssr)
                        {
                        case 1:
                            camera->SetSsr(true, 0.5f * camera->upscaling, 0.02f, 1.2f, 50, false);
                            break;
                        case 2:
                            camera->SetSsr(true, 0.75f * camera->upscaling, 0.01f, 1.1f, 100, false);
                            break;
                        case 3:
                            camera->SetSsr(true, 1.0f * camera->upscaling, 0.005f, 1.05f, 200, true);
                            break;
                        default:
                            camera->SetSsr(false);
                            break;
                        }
                    }

                    // Post Effects
                    auto peIt = videoSettings.find("posteffects");
                    camera->ClearPostEffects();
                    if (videoSettings["posteffects"].is_array())
                    {
                        auto& posteffects = videoSettings["posteffects"];                        
                        for (int n = 0; n < posteffects.size(); ++n)
                        {
                            if (not posteffects[n].is_string()) continue;
                            std::string path = posteffects[n];
                            auto fx = LoadPostEffect(path);
                            if (fx) camera->AddPostEffect(fx);
                        }
                    }

                }
            }
        }
    }
}