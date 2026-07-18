#pragma once
#include "Leadwerks.h"
#include "ImpactNoise.h"

using namespace Leadwerks;

ImpactNoise::ImpactNoise()
{ 
    //name = "ImpactNoise";
}

void ImpactNoise::ApplyForce()
{
    if (force == 0.0f) return;
    auto entity = GetEntity();
    entity->AddForce(force);
}

void ImpactNoise::Collide(shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed)
{
    if (speed < minspeed) return;
    if (sounds.empty()) return;
    auto entity = GetEntity();
    auto world = entity->GetWorld();
    auto now = world->GetTime();
    if (now - lastplaytime < 200) return;
    lastplaytime = now;
    int index = Round(Random(sounds.size() - 1));
    if (sounds[index]) entity->EmitSound(sounds[index]);
}

bool ImpactNoise::Load(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const LoadFlags flags, std::shared_ptr<Object> extra)
{
    auto temp = sounds;
    sounds.clear();
    if (properties["force"].is_array() and properties["force"].size() >= 3)
    {
        force.x = properties["force"][0];
        force.y = properties["force"][1];
        force.z = properties["force"][2];
    }
    for (int n = 0; n < MaxSounds; ++n)
    {
        std::string key = "sound" + String(n);
        if (properties[key].is_string())
        {
            auto sound = LoadSound(std::string(properties[key]));
            if (sound) sounds.push_back(sound);
        }
    }
    if (properties["range"].is_number()) range = float(properties["range"]) / 100.0f;
    return true;
}

bool ImpactNoise::Save(table& properties, shared_ptr<Stream> binstream, shared_ptr<Scene> scene, const SaveFlags flags, std::shared_ptr<Object> extra)
{
    properties["range"] = range * 100.0f;
    return true;
}

//This method will work with simple components
shared_ptr<Component> ImpactNoise::Copy()
{
    return std::make_shared<ImpactNoise>(*this);
}

std::any ImpactNoise::CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments)
{
    if (name == "ApplyForce")
    {
        ApplyForce();
        return false;
    }
    return BaseComponent::CallMethod(sender, name, arguments);
}