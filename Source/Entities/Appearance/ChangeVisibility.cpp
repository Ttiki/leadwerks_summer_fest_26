#pragma once
#include "Leadwerks.h"
#include "ChangeVisibility.h"

using namespace Leadwerks;

ChangeVisibility::ChangeVisibility()
{ 
    //name = "ChangeVisibility";
}

bool ChangeVisibility::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
    if (properties["soundfile"].is_string())
    {
        String path = properties["soundfile"];
        if (not path.empty()) sound = LoadSound(path);
    }
    if (properties["soundrange"].is_number()) soundrange = properties["soundrange"];
    if (properties["soundvolume"].is_number()) soundvolume = properties["soundvolume"];
    return true;
}

void ChangeVisibility::Hide()
{
    auto entity = GetEntity();
    entity->SetHidden(true);
    if (sound) entity->EmitSound(sound, soundrange / 100.0f, soundvolume / 100.0f);
    FireOutputs("Hide");
}

void ChangeVisibility::Show()
{
    auto entity = GetEntity();
    entity->SetHidden(false);
    if (sound) entity->EmitSound(sound, soundrange / 100.0f, soundvolume / 100.0f);
    FireOutputs("Show");
}

std::any ChangeVisibility::CallMethod(shared_ptr<Component> caller, const WString& name, const std::vector<std::any>& args)
{
    if (name == "Hide")
    {
        Hide();
        return false;
    }
    else if (name == "Show")
    {
        Show();
        return false;
    }
    return BaseComponent::CallMethod(caller, name, args);
}

//This method will work with simple components
shared_ptr<Component> ChangeVisibility::Copy()
{
    return std::make_shared<ChangeVisibility>(*this);
}