#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class Relay : public BaseComponent//Component
{
    uint64_t signaltime = 0;
public:
    float delay = 0.0f;//"Dekay"
    bool once = false;//"Only once"
    bool fastrefiring = true;//"Fast refire"
    /*
    bool enabled = true;//"Enabled"
    */
    
    Relay();

    virtual void Update();
    virtual void Signal();//inout
    virtual bool Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, shared_ptr<Object> extra);
    virtual bool Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, shared_ptr<Object> extra);
    virtual std::any CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args);
    virtual std::shared_ptr<Component> Copy();
};