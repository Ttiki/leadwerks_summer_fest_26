#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class ChangeVisibility : public BaseComponent//Component
{
public:
    float soundvolume = 100;//"Sound volume"
    float soundrange = 1000;//"Sound range"
    bool once = true;//"Use once"
    shared_ptr<Sound> sound;

    ChangeVisibility();

    virtual void Hide();//inout
    virtual void Show();//inout
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
    virtual bool Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
};