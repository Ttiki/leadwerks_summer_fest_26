#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class PushButton : public BaseComponent//Component
{
public: 
    bool enabled = true;//"Enable"
    WString soundfile;//"Sound file" SOUND
    float soundvolume = 100;//"Sound volume"
    float soundrange = 1000;//"Sound range"
    bool once = true;//"Use once"
    shared_ptr<Sound> sound;

    PushButton();

    virtual void Enable();//inout
    virtual void Disable();//inout
    virtual bool GetEnabled();
    virtual void Use(shared_ptr<Entity> entity);//out
	virtual bool Load(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra);
    virtual bool Save(table& properties, std::shared_ptr<Stream> binstream, std::shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
};