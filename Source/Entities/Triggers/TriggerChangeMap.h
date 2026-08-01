#pragma once
#include "Leadwerks.h"
#include "../BaseComponent.h"

using namespace Leadwerks;

class TriggerChangeMap : public BaseComponent//Component
{
public: 
    String mapName = "";//"Map name"
    bool enabled = true;//"Enabled"

    virtual void Start();

    virtual bool ChangeMap();

    virtual void Collide(std::shared_ptr<Entity> collidedentity, const Vec3& position, const Vec3& normal, const float speed);
    virtual std::shared_ptr<Component> Copy();
    virtual std::any CallMethod(shared_ptr<Component> sender, const WString& name, const std::vector<std::any>& arguments);
};